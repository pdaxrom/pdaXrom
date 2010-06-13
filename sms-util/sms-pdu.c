/* 
 * Copyright (C) 2008-2010 Alexander Chukov <sash@pdaXrom.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <iconv.h>
#include <errno.h>
#include <termios.h>

typedef struct {
    u_int8_t	smsc_info_len;
    u_int8_t	message_type;
    u_int8_t	tp_message_reference;
    u_int8_t	address_len;
    u_int8_t	address_type;
    u_int8_t	number[6];
    u_int8_t	tp_pid;
    u_int8_t	tp_dcs;
    u_int8_t	tp_validity_period;
    u_int8_t	tp_user_data_len;
} PDU_send_header;

void hex_dump(char *buf, int len)
{
    int i;
    
    for (i = 0; i < len; i++) {
	if (!(i % 16))
	    fprintf(stderr, "\n%04X: ", i);
	fprintf(stderr, "%02X ", buf[i]);
    }
    fprintf(stderr, "\n");
}

int send_to_phone(int dev, char *str)
{
    return write(dev, str, strlen(str));
}

int recv_from_phone(int dev, char *str, int size)
{
    usleep(500000);
    return read(dev, str, size);
}

int send_at_string(int dev, char *str, char *retstr)
{
    int ret;
    char buf[4096];

    ret = send_to_phone(dev, str);
    
//    fprintf(stderr, "\n\n\nsend [%s] ret %d\n", str, ret);

//    memset(buf, 0, sizeof(buf));
    
    ret = recv_from_phone(dev, buf, sizeof(buf));
    
//    fprintf(stderr, "\n\n\nrecv ret %d\n", ret);
    
    if (ret > 0) {
	buf[ret] = 0;
	fprintf(stderr, "text: %s\n", buf);
	hex_dump(buf, ret);
	if (retstr) {
	    if (!strcmp(&buf[ret - strlen(retstr)], retstr)) {
		//fprintf(stderr, "COOL!\n");
		buf[ret - strlen(retstr)] = 0;
		printf(strchr(buf, '\n') + 3);
		return 0;
	    } else {
		//fprintf(stderr, "SUXX!\n");
	        return 1;
	    }
	}
	return 0;
    }

    return 1;
}

int convert_string(char *in_str, char *out_str, int size)
{
    int ret;
    size_t inbleft, outbleft;
    iconv_t conv = iconv_open("UCS-2BE", "UTF8");
	if (conv == (iconv_t) -1) {
	    if (errno == EINVAL)
		fprintf(stderr, "conversion not available\n");
	    else
		fprintf(stderr, "Conversion setup failed\n");
	return 0;
    } else {
	inbleft = strlen(in_str);
	outbleft= size;
	char *buf_start = out_str;
        ret = iconv(conv, &in_str, &inbleft, &buf_start, &outbleft);
	if (ret == (size_t) -1) {
    	    switch (errno) {
    	    case EILSEQ:
        	fprintf(stderr, "Invalid character sequence\n");
        	break;
    	    case EINVAL:
        	fprintf(stderr, "EINVAL\n");
        	break;
    	    case E2BIG:
        	fprintf(stderr, "E2BIG\n");
        	break;
    	    default:
        	fprintf(stderr, "unknown error\n");
    	    }
	    return 0;
	} else {
	    out_str[size - outbleft] = 0;
	}
 	//fprintf(stderr, "%d: %x : %s\n", ret, out_str[0], out_str);
    	iconv_close(conv);
    }
    
    return size - outbleft;
}

int pdu_prepare_send_header(PDU_send_header *hdr, char *number, int flash)
{
    int i;
    
    for (i = 0; i < 6; i++) {
	u_int8_t ol = number[i << 1] - '0';
	u_int8_t oh;
	if (i < 5)
	    oh = number[(i << 1) + 1] - '0';
	else
	    oh = 0x0f;
	hdr->number[i] = (oh << 4) | ol;
    }
    
    hdr->smsc_info_len	= 0x00;
    hdr->message_type	= 0x31;
    hdr->tp_message_reference = 0x00;
    hdr->address_len	= 0x0b;
    hdr->address_type	= 0x91;
    hdr->tp_pid		= 0x00;
    hdr->tp_dcs		= 0x08 | (flash?0x10:0);
    hdr->tp_validity_period = 0xaa;
    hdr->tp_user_data_len = 0x00;
    
    return 0;
}

void init_modem_port(int dev)
{
    struct termios options;

    /* get the current options */
    tcgetattr(dev, &options);

    /*
     * Set the baud rates to 115200...
     */
    cfsetispeed(&options, B115200);
    cfsetospeed(&options, B115200);
    //cfsetispeed(&options, B19200);
    //cfsetospeed(&options, B19200);

    /* No parity (8N1) */		  
    options.c_cflag &= ~PARENB;
    options.c_cflag &= ~CSTOPB;
    options.c_cflag &= ~CSIZE;
    options.c_cflag |= CS8;

    /* Also called CRTSCTS */
    options.c_cflag |= /*CNEW_RTSCTS*/ CRTSCTS;

    options.c_cflag |= (CLOCAL | CREAD);

    /* set raw input, 1 second timeout */
    options.c_lflag     &= ~(ICANON | ECHO | ECHOE /*| ECHOK | ECHONL*/ | ISIG);
    options.c_oflag     &= ~OPOST;
//    options.c_cc[VMIN]  = 0;
//    options.c_cc[VTIME] = 10;

    /* set the options */
    tcsetattr(dev, TCSANOW, &options);
}

int phone_open_dev(char *dev)
{
    int fd = open(dev, O_RDWR | O_NOCTTY);
    if (fd < 0) {
	fprintf(stderr, "can't open device %s\n", dev);
	return fd;
    }

    init_modem_port(fd);

    return fd;
}

int phone_close_dev(int fd)
{
    return close(fd);
}

int phone_send_sms(char *dev, char *num, char *text, int flash)
{
    int ret = -1;
    char buf[1024];
    char pdu_buf[1024];
    char msg[1024];
    int  msg_len;

    int fd = phone_open_dev(dev);

    if (fd < 0)
	return 1;

    do {
	if (send_at_string(fd, "at+cmgf=0\r", "OK\n\n"))
	    break;

	pdu_prepare_send_header((PDU_send_header *) pdu_buf, num, flash);

	msg_len = convert_string(text, msg, sizeof(msg));

	memcpy(pdu_buf + sizeof(PDU_send_header), msg, msg_len);
	((PDU_send_header *)pdu_buf)->tp_user_data_len = msg_len;

	//hex_dump(pdu_buf, sizeof(PDU_send_header) + msg_len);

	int i;
	for (i = 0; i <  sizeof(PDU_send_header) + msg_len; i ++) {
	    sprintf(buf + i * 2, "%02X", (u_int8_t) pdu_buf[i]);
	}

	sprintf(pdu_buf, "at+cmgs=%d\r", strlen(buf) / 2 - 1);
	if (!send_at_string(fd, pdu_buf, "> ")) {
	    sprintf(pdu_buf, "%s\032", buf);
	    fprintf(stderr, "::%s\n", pdu_buf);
	    send_at_string(fd, pdu_buf, NULL);
	}
	ret = 0;
    } while(0);

    phone_close_dev(fd);

    return ret;
}

int phone_list_sms(char *dev)
{
    int ret = 1;
    int fd = phone_open_dev(dev);

    if (fd < 0)
	return 1;

    do {
#if 0
        if (send_at_string(fd, "at+cmgf=0\r", "OK\n\n"))
	    break;
	if (send_at_string(fd, "at+cmgl=4\r", "OK\n\n"))
	    break;
#else
        if (send_at_string(fd, "at+cmgf=1\r", "OK\n\n"))
	    break;
        if (send_at_string(fd, "at+cscs=UTF8\r", "OK\n\n"))
	    break;
	if (send_at_string(fd, "at+cmgl\r", "OK\n\n"))
	    break;
#endif
	ret = 0;
    } while(0);
    
    phone_close_dev(fd);

    return ret;
}

int phone_del_sms(char *dev, char *id)
{
    int ret = -1;
    int fd = phone_open_dev(dev);

    if (fd < 0)
	return 1;

    do {
	char buf[1024];

        if (send_at_string(fd, "at+cmgf=1\r", "OK\n\n"))
	    break;
        if (send_at_string(fd, "at+cscs=UTF8\r", "OK\n\n"))
	    break;
	int d = atoi(id);
	if (d <=0)
	    break;
	sprintf(buf, "at+cmgd=%d\r", d);
	if (send_at_string(fd, buf, "OK\n\n"))
	    break;

	ret = 0;
    } while(0);

    close(fd);
    return ret;
}

void usage(char *prog)
{
    fprintf(stderr, "\nUsage:\n\t%s <modem device> <cmd> [arg1 [arg2]]\n" \
		    "Commands:\n" \
		    "\tsend <number> <text>       - send sms\n" \
		    "\tsend-flash <number> <text> - send flash sms\n" \
		    "\tlist                       - list all received sms\n" \
		    "\tdelete <N>                 - delete sms N from list\n\n" \
		    "Example: %s send +79234070523 \"Hello, bye-bye!\"\n\n",
		    prog, prog);
}

int main(int argc, char *argv[])
{
    int ret = 0;

    if ((argc < 3) ||
	!strncmp(argv[1], "-h", 2) ||
	!strncmp(argv[1], "--h", 3)) {
	usage(argv[0]);
	return 0;
    }

    char *dev  = argv[1];
    char *cmd  = argv[2];
    char *num  = argv[3];
    char *text = argv[4];

    if (!strcmp(cmd, "send"))
	ret = phone_send_sms(dev, num, text, 0);
    else if (!strcmp(cmd, "send-flash"))
	ret = phone_send_sms(dev, num, text, 1);
    else if (!strcmp(cmd, "list"))
	ret = phone_list_sms(dev);
    else if (!strcmp(cmd, "delete"))
	ret = phone_del_sms(dev, num);
    else if (!strcmp(cmd, "help"))
	usage(argv[0]);
    else {
	fprintf(stderr, "Unknown command!\n");
	usage(argv[0]);
    }
	
    if (ret) {
	fprintf(stderr, "Error during command execution!\n");
	return 1;
    }

    return 0;
}
