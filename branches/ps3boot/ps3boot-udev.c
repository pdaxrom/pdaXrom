#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <sys/un.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <asm/byteorder.h>
#include <linux/cdrom.h>
#include <linux/limits.h>
#include <limits.h>
#include <sys/ioctl.h>
#include <syslog.h>

#include "server.h"

#define REMOVABLE_SLEEP_DELAY	2

#define streq(a,b) (!strcasecmp((a),(b)))

static int is_removable_device(const char *sysfs_path) 
{
    char full_path[PATH_MAX];
    char buf[80];
    int fd, buf_len;

    sprintf(full_path, "/sys/%s/removable", sysfs_path);
    fd = open(full_path, O_RDONLY);
    syslog(LOG_INFO, " -> removable check on %s, fd=%d\n", full_path, fd);
    if (fd < 0)
    	return 0;
    buf_len = read(fd, buf, 79);
    close(fd);
    if (buf_len < 0)
	return 0;
    buf[buf_len] = 0;
    return strtol(buf, NULL, 10);
}

static int is_ignored_device(const char *devname)
{
    static const char *ignored_devices[] =
		{ "/dev/ram", "/dev/loop", NULL };
    const char **dev;

    for (dev = ignored_devices; *dev; dev++)
	if (!strncmp(devname, *dev, strlen(*dev)))
    	    return 1;

    return 0;
}

static const char *get_icon(void)
{
    const char *type = getenv("ID_TYPE");
    const char *bus = getenv("ID_BUS");
    const char *sysfs_path = getenv("DEVPATH");
    char full_path[PATH_MAX];
    char buf[128];
    int fd, buf_len;

    syslog(LOG_INFO, "type=%s, bus=%s, path=%s\n", type, bus, sysfs_path);

    sprintf(full_path, "/sys/%s/../device/model", sysfs_path);
    fd = open(full_path, O_RDONLY);
    if (fd >= 0) {
	buf_len = read(fd, buf, 79);
	close(fd);
	if (buf_len > 0) {
	    buf[buf_len] = 0;
	    if (strcasestr(buf, " CF"))
		return "cf.png";
	    if (strcasestr(buf, " SD"))
		return "sd.png";
	    if (strcasestr(buf, " MS"))
		return "ms.png";
	}
    }

    if (type && streq(type, "cd"))
    	return "cdrom.png";

    if (strstr(sysfs_path, "block/sr"))
	return "cdrom.png";

    if (!bus)
	return "hdd.png";

    if (streq(bus, "usb"))
	return "usbpen.png";

    if (streq(bus, "ata") || streq(bus, "scsi"))
    	return "hdd.png";

    return "tux.png";
}

int send_action(const char *action, const char *dev_path)
{
    int sock;
    struct sockaddr_un server;
    char buf[1024];

    if (streq(action, "add")) {
	const char *icon = get_icon();
	sprintf(buf, "%s,%s,%s", action, dev_path, icon);
    } else if (streq(action, "remove")) {
	sprintf(buf, "%s,%s", action, dev_path);
    } else
	return 1;

    sock = socket(AF_UNIX, SOCK_STREAM, 0);
    
    if (sock < 0) {
	syslog(LOG_ERR, "opening stream socket");
	return 1;
    }
    
    server.sun_family = AF_UNIX;
    strcpy(server.sun_path, SOCKET_NAME);
    
    if (connect(sock, (struct sockaddr *) &server, sizeof(struct sockaddr_un)) < 0) {
	close(sock);
	syslog(LOG_ERR, "connecting stream socket");
	return 1;
    }

    if (write(sock, buf, strlen(buf)) < 0)
	syslog(LOG_ERR, "writing on stream socket: %s", buf);
    
    close(sock);
    
    return 0;
}

static void detach_and_sleep(int sec)
{
	static int forked = 0;
	int rc = 0;

	if (sec <= 0)
		return;

	if (!forked) {
		syslog(LOG_INFO, "running in background...");
		rc = fork();
		forked = 1;
	}

	if (rc == 0) {
		sleep(sec);

	} else if (rc == -1) {
		perror("fork()");
		exit(EXIT_FAILURE);
	} else {
		exit(EXIT_SUCCESS);
	}
}

static int poll_device_plug(const char *dev_path,
			    int *optical)
{
	int rc, fd;

	/* Polling loop for optical drive */
	for (; (*optical) != 0; ) {
		fd = open(dev_path, O_RDONLY|O_NONBLOCK);
		if (fd < 0)
			return EXIT_FAILURE;
		rc = ioctl(fd, CDROM_DRIVE_STATUS, CDSL_CURRENT);
		close(fd);
		if (rc == -1)
			break;

		*optical = 1;
		if (rc == CDS_DISC_OK)
			return EXIT_SUCCESS;

		detach_and_sleep(REMOVABLE_SLEEP_DELAY);
	}

	/* Fall back to bare open() */
	*optical = 0;
	for (;;) {
		fd = open(dev_path, O_RDONLY);
		if (fd < 0 && errno != ENOMEDIUM)
			return EXIT_FAILURE;
		close(fd);
		if (fd >= 0)
			return EXIT_SUCCESS;
		detach_and_sleep(REMOVABLE_SLEEP_DELAY);
	}
}

static int poll_device_unplug(const char *dev_path, int optical)
{
	int rc, fd;

	for (;optical;) {
		fd = open(dev_path, O_RDONLY|O_NONBLOCK);
		if (fd < 0)
			return EXIT_FAILURE;
		rc = ioctl(fd, CDROM_DRIVE_STATUS, CDSL_CURRENT);
		close(fd);
		if (rc != CDS_DISC_OK)
			return EXIT_SUCCESS;
		detach_and_sleep(REMOVABLE_SLEEP_DELAY);
	}

	/* Fall back to bare open() */
	for (;;) {
		fd = open(dev_path, O_RDONLY);
		if (fd < 0 && errno != ENOMEDIUM)
			return EXIT_FAILURE;
		close(fd);
		if (fd < 0)
			return EXIT_SUCCESS;
		detach_and_sleep(REMOVABLE_SLEEP_DELAY);
	}
}

static int poll_removable_device(const char *sysfs_path,
				 const char *dev_path)
{
	int rc, mounted, optical = -1;
       
	for (;;) {
		rc = poll_device_plug(dev_path, &optical);
		if (rc == EXIT_FAILURE)
			return rc;
		send_action("add", dev_path);
		mounted = (rc == EXIT_SUCCESS);

		poll_device_unplug(dev_path, optical);

		send_action("remove", dev_path);

		detach_and_sleep(1);
	}
}

int main(int argc, char *argv[])
{
    struct stat s;
    
    if (stat(SOCKET_NAME, &s))
	return EXIT_SUCCESS;
    
    openlog("ps3boot-udev", LOG_PID | LOG_CONS, LOG_DAEMON);
    syslog(LOG_INFO, "Starting daemon");

    char *action = getenv("ACTION");

    if (!action) {
	syslog(LOG_ERR, "ACTION - missing environment?");
	return EXIT_FAILURE;
    }

    char *dev_path = getenv("DEVNAME");
    if (!dev_path) {
	syslog(LOG_ERR, "missing environment?");
	return EXIT_FAILURE;
    }

    if (is_ignored_device(dev_path)) {
	syslog(LOG_ERR, "ignore %s", dev_path);
	return EXIT_FAILURE;
    }

    if (!strcmp(action, "add")) {
	char *sysfs_path = getenv("DEVPATH");
	if (sysfs_path && is_removable_device(sysfs_path))
	    poll_removable_device(sysfs_path, dev_path);
	else
	    send_action(action, dev_path);
    } else if (!strcmp(action, "remove")) {
	send_action(action, dev_path);
    } else {
	syslog(LOG_ERR, "Unknown action %s", action);
    }
    
    closelog();
    
    return EXIT_SUCCESS;
}
