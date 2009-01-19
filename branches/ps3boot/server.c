#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <stdio.h>
#include <unistd.h>

#include "devices.h"
#include "ui.h"
#include "server.h"

static int sock = -1;

int ps3boot_serv_on(void)
{
    struct sockaddr_un server;
    
    sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sock < 0) {
	perror("opening stream socket");
	return -1;
    }
       
    server.sun_family = AF_UNIX;
    strcpy(server.sun_path, SOCKET_NAME);
    if (bind(sock, (struct sockaddr *) &server, sizeof(struct sockaddr_un))) {
	perror("binding stream socket");
	return -1;
    }
    
    fprintf(stderr, "Socket has name %s\n", server.sun_path);
    listen(sock, 5);
    
    return sock;
}

int ps3boot_serv_off(void)
{
    close(sock);
    unlink(SOCKET_NAME);
    return 0;
}

int ps3boot_serv_check_msg(void)
{
    int ret = 0;
    fd_set rfds;
    struct timeval tv;
    int retval;
    
    FD_ZERO(&rfds);
    FD_SET(sock, &rfds);
    
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    retval = select(sock + 1, &rfds, NULL, NULL, &tv);
    if (retval == -1)
	perror("select()");
    else if (retval) {
	fprintf(stderr, "data available\n");
	int rval = -1;
	int msgsock = accept(sock, NULL, NULL);
	if (msgsock == -1)
	    perror("accept");
	else do {
	    int rval;
	    char buf[1024];
	    memset(buf, 0, 1024);
	    if ((rval = read(msgsock, buf, 1024)) < 0)
		perror("reading stream message");
	    else if (rval == 0)
		fprintf(stderr, "ending connection\n");
	    else {
		fprintf(stderr, "read from socket: %s\n", buf);
		char *dev = strchr(buf, ',');
		if (dev) {
		    *dev++ = 0;
		    fprintf(stderr, "action: %s\ndevice: %s\n", buf, dev);
		    if (!strcmp(buf, "add")) {
			bootdevice_add(dev);
			ret = 1;
		    }
		    if (!strcmp(buf, "remove")) {
			bootdevice_remove(dev);
			ret = 1;
		    }
		}
	    }
	} while (rval > 0);
	close(msgsock);
    }
    
    return ret;
}
