#ifndef _SERVER_H_
#define _SERVER_H_

#define SOCKET_NAME "/tmp/ps3boot-sock"

int ps3boot_serv_on(void);

int ps3boot_serv_off(void);

int ps3boot_serv_check_msg(void);

#endif
