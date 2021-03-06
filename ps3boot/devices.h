#ifndef _DEVICES_H_
#define _DEVICES_H_

#include "image.h"
#include "font.h"

#define MOUNT_DIR	"/media"

#define POWEROFF_BIN	"/sbin/poweroff"
#define GAMEOS_BIN	"/usr/sbin/ps3-boot-game-os"
#define VIDMOD_BIN	"/usr/bin/ps3-video-mode"
#define KEXEC_BIN	"/sbin/kexec"
#define MOUNT_BIN	"/bin/mount"
#define UMOUNT_BIN	"/bin/umount"
#define MKDIR_BIN	"/bin/mkdir"

typedef struct boot_config {
    char *label;
    char *kernel;
    char *initrd;
    char *cmdline;
    struct boot_config *next;
} boot_config;

typedef struct boot_device {
    db_image *icon;
    char *device;
    char *message;
    char *def;
    int timeout;
    boot_config *conf;
    struct boot_device *next;
} boot_device;

void bootdevice_init(void);

void bootdevice_default_config(char *label, char *devname, char *kernel, char *initrd, char *cmdline, int timeout);

void bootdevice_add(char *dev_path, char *icon);

void bootdevice_remove(char *dev_path);

void bootdevices_remove_all(void);

db_image *bootdevices_draw_devices(db_image *desk, db_image *wallp);

void bootdevice_select_prev(void);

void bootdevice_select_next(void);

void bootdevice_config_prev(void);

void bootdevice_config_next(void);

void bootdevice_boot(void);

boot_config *bootdevice_get_current_config(int *x, int *y);

void execute_boot_conf(char *devname, char *kernel, char *initrd, char *cmdline);

int bootdevice_autoboot_timer(void);

#endif
