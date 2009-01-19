#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <stdio.h>
#include <unistd.h>

#include "server.h"

int main(int argc, char *argv[])
{
    int sock;
    struct sockaddr_un server;
    char buf[1024];
    
    sock = socket(AF_UNIX, SOCK_STREAM, 0);
    
    if (sock < 0) {
	perror("opening stream socket");
	return 1;
    }
    
    server.sun_family = AF_UNIX;
    strcpy(server.sun_path, SOCKET_NAME);
    
    if (connect(sock, (struct sockaddr *) &server, sizeof(struct sockaddr_un)) < 0) {
	close(sock);
	perror("connecting stream socket");
	return 1;
    }
    
    if (write(sock, argv[1], strlen(argv[1])) < 0)
	perror("writing on stream socket");
    
    close(sock);
    
    return 0;
}
