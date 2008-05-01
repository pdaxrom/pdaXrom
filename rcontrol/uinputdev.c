/* 
 * Copyright (C) 2008 Alexander Chukov <sash@pdaXrom.org>
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
#include <stdint.h>
#include <string.h>

#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <unistd.h>

#include <linux/input.h>
#include <linux/uinput.h>

#include "uinputdev.h"

/* UInput */
static char *uinput_filename[] = {"/dev/uinput", "/dev/input/uinput",
                           "/dev/misc/uinput"};
#define UINPUT_FILENAME_COUNT (sizeof(uinput_filename)/sizeof(char *))

int uinput_open(struct conf *conf)
{
    unsigned int i;

    /* Open uinput device */
    for (i=0; i < UINPUT_FILENAME_COUNT; i++) {
	if ((conf->fd = open(uinput_filename[i], O_RDWR)) >= 0) {
	    break;
	}
    }
    
    if (conf->fd < 0) {
	fprintf(stderr, "Unable to open uinput\n");
	return -1;
    }

    if (write(conf->fd, &conf->dev, sizeof conf->dev) != sizeof conf->dev) {
	fprintf(stderr, "Error on uinput device setup\n");
	close(conf->fd);
	return -1;
    }

    if (ioctl(conf->fd, UI_SET_EVBIT, EV_KEY) < 0) {
	fprintf(stderr, "Error on uinput ioctl (UI_SET_EVBIT, EV_KEY)\n");
	close(conf->fd);
	return -1;
    }	

    if (ioctl(conf->fd, UI_SET_EVBIT, EV_REL) < 0) {
	fprintf(stderr, "Error on uinput ioctl (UI_SET_EVBIT, EV_REL)\n");
	close(conf->fd);
	return -1;
    }	

    if (ioctl(conf->fd, UI_SET_RELBIT, REL_X) < 0) {
	fprintf(stderr, "Error on uinput ioctl (UI_SET_RELBIT, REL_X)\n");
	close(conf->fd);
	return -1;
    }	

    if (ioctl(conf->fd, UI_SET_RELBIT, REL_Y) < 0) {
	fprintf(stderr, "Error on uinput ioctl (UI_SET_RELBIT, REL_Y)\n");
	close(conf->fd);
	return -1;
    }	

    for (i=0; i < 0x100; i++) { 
	if (ioctl(conf->fd, UI_SET_KEYBIT, i) < 0) {
	    fprintf(stderr, "error on uinput ioctl (UI_SET_KEYBIT)\n");
	    return -1;
	}
    }

    ioctl(conf->fd, UI_SET_KEYBIT, BTN_MOUSE); 
    ioctl(conf->fd, UI_SET_KEYBIT, BTN_LEFT); 
    ioctl(conf->fd, UI_SET_KEYBIT, BTN_MIDDLE); 
    ioctl(conf->fd, UI_SET_KEYBIT, BTN_RIGHT); 
    ioctl(conf->fd, UI_SET_KEYBIT, BTN_FORWARD); 
    ioctl(conf->fd, UI_SET_KEYBIT, BTN_BACK);
    ioctl(conf->fd, UI_SET_KEYBIT, BTN_TOUCH); 
 
    if (ioctl(conf->fd, UI_DEV_CREATE) < 0) {
	fprintf(stderr, "Error on uinput dev create");
	close(conf->fd);
	return -1;
    }

    return 0;   
}

int uinput_close(struct conf *conf)
{
    if (ioctl(conf->fd, UI_DEV_DESTROY) < 0) {
	fprintf(stderr, "Error on uinput ioctl (UI_DEV_DESTROY)\n");
    }

    if (close(conf->fd)) {
	fprintf(stderr, "Error on uinput close");
	return -1;
    }

    return 0;
}

int uinput_send(struct conf *conf, __u16 type, __u16 code, __s32 value)
{
    struct input_event event;

    memset(&event, 0, sizeof(event));
    event.type = type;
    event.code = code;
    event.value = value;
    gettimeofday(&(event.time), NULL);

    if (write(conf->fd, &event, sizeof(event)) != sizeof(event)) {
	fprintf(stderr, "Error on send_event\n");
	return -1;
    }

    return 0;
}
