#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <unistd.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>

#include "devices.h"
#include "message.h"
#include "parse-config.h"

#define ICON_WIDTH	64
#define ICON_HEIGHT	64
#define ICON_BORDER	5
#define TEXT_BORDER	3

extern db_font *font;

static boot_device *devices = NULL;
static boot_device *cur_device = NULL;

static db_image *img_dev_sel = NULL;
static int selected_device = 0;
static int selected_config = -1;

//
// autoboot
//
static int   default_timeout = -1;
static char *default_label   = NULL;
static char *default_devname = NULL;
static char *default_kernel  = NULL;
static char *default_initrd  = NULL;
static char *default_cmdline = NULL;

//
// for external export
//
static int current_config_x_pos = 0;
static int current_config_y_pos = 0;
static boot_config *current_config_ptr = NULL;
//

void bootdevice_default_config(char *label, char *devname, char *kernel, char *initrd, char *cmdline, int timeout)
{
    if (default_timeout >= 0)
	return;
    default_timeout = timeout;
    if (label)
	default_label   = strdup(label);
    if (devname)
	default_devname = strdup(devname);
    if (kernel)
	default_kernel  = strdup(kernel);
    if (initrd)
	default_initrd  = strdup(initrd);
    if (cmdline)
	default_cmdline = strdup(cmdline);
    fprintf(stderr, "Default: %d,%s,%s,%s,%s,%s\n", default_timeout, default_label, default_devname, default_kernel, default_initrd, default_cmdline);
}

static db_image *get_device_icon(char *dev_path)
{
    if (!strncmp(dev_path, "/dev/sd", 7))
	return db_image_load(DATADIR "/artwork/hdd.png");
    if (!strncmp(dev_path, "/dev/sr", 7))
	return db_image_load(DATADIR "/artwork/cdrom.png");
    if (!strcmp(dev_path, "gameos"))
	return db_image_load(DATADIR "/artwork/gameos.png");
    if (!strcmp(dev_path, "poweroff"))
	return db_image_load(DATADIR "/artwork/halt.png");
    return db_image_load(DATADIR "/artwork/hdd.png");
}

static void boot_configs_free(boot_config *conf)
{
    while (conf) {
	boot_config *tmp = conf->next;
	if (conf->label)
	    free(conf->label);
	if (conf->kernel)
	    free(conf->kernel);
	if (conf->initrd)
	    free(conf->initrd);
	if (conf->cmdline)
	    free(conf->cmdline);
	free(conf);
	conf = tmp;
    }
}

static void bootdevice_free(boot_device *dev)
{
    if (!dev)
	return;
    if (dev->icon)
	db_image_free(dev->icon);
    if (dev->device)
	free(dev->device);
    if (dev->message)
	free(dev->message);
    if (dev->def)
	free(dev->def);
    if (dev->conf)
	boot_configs_free(dev->conf);
    free(dev);
}

static boot_device *bootdevice_create(char *dev_path, char *icon)
{
    boot_device *dev = (boot_device *) malloc(sizeof(boot_device));    
    memset(dev, 0, sizeof(boot_device));

    if (dev_path[0] == '/') {
	if (kboot_conf_read(dev_path, dev)) {
	    if (yaboot_conf_read(dev_path, dev)) {
		if (ps3boot_conf_read(dev_path, dev)) {
		    if (syslinux_conf_read(dev_path, dev)) {
			if (grub_conf_read(dev_path, dev)) {
			    free(dev);
			    return NULL;
			}
		    }
		}
	    }
	}
    }

    char buf[1024];
    snprintf(buf, 1024, DATADIR "/artwork/%s", icon);
    dev->icon = db_image_load(buf);
    if (!dev->icon)
	dev->icon = get_device_icon(dev_path);
    dev->device = strdup(dev_path);
    dev->next = NULL;

    return dev;
}

void bootdevice_init(void)
{
    if (devices == NULL) {
	devices = bootdevice_create("poweroff", "halt.png");
#ifndef PCBOOT
	devices->next = bootdevice_create("gameos", "gameos.png");
	cur_device = devices->next;
#else
	cur_device = devices;
#endif
    }
}

void bootdevice_add(char *dev_path, char *icon)
{
    char buf[1024];

    sprintf(buf, MKDIR_BIN " -p " MOUNT_DIR "%s", dev_path);
    int rc = system(buf);
    if (rc)
	fprintf(stderr, "mkdir problem\n");

    bootdevice_remove(dev_path);

    sprintf(buf, MOUNT_BIN " -o ro %s " MOUNT_DIR "%s", dev_path, dev_path);
    rc = system(buf);
    if (!rc) {
	boot_device *dev = bootdevice_create(dev_path, icon);
    
	if (dev) {
	    if (devices == NULL) {
		devices = dev;
		cur_device = devices;
	    } else {
		cur_device->next = dev;
		cur_device = dev;
	    }
	}

	sprintf(buf, UMOUNT_BIN " " MOUNT_DIR "%s", dev_path);
	rc = system(buf);
    }
    sprintf(buf, MOUNT_DIR "%s", dev_path);
    rc = rmdir(buf);
    if (rc)
	fprintf(stderr, "mkdir problem\n");
}

void bootdevice_remove(char *dev_path)
{
    boot_device *dev = devices;
    boot_device *prev = NULL;

    while (dev) {
	if (!strcmp(dev->device, dev_path)) {
	    if (prev) {
		prev->next = dev->next;
		if (!prev->next)
		    cur_device = prev;
	    } else {
		devices = dev->next;
		if (!devices->next)
		    cur_device = devices;
	    }
	    bootdevice_free(dev);
	    break;
	}
	prev = dev;
	dev = dev->next;
    }
}

void bootdevices_remove_all(void)
{
    boot_device *tmp;
    while (devices) {
	tmp = devices->next;
	bootdevice_free(devices);
	devices = tmp;
    }
}

static int bootdevices_count(void)
{
    int ret = 0;
    boot_device *dev = devices;
    while (dev) {
	ret++;
	dev = dev->next;
    }
    return ret;
}

void bootdevices_draw_bootconfig(db_image *desk,
				 db_image *wallp,
				 boot_device *dev,
				 int x,
				 int y,
			         int w,
				 int h)
{
    int count = 0;
    current_config_ptr = NULL;
    boot_config *conf = dev->conf;
    if (!conf)
	return;

    while (conf) {
	char buf[1024];
	snprintf(buf, 1024, "%s", conf->label);
	if (((!strcmp(dev->def?dev->def:conf->label, conf->label)) && (selected_config < 0)) ||
	    (count == selected_config)) {
	    db_message_draw(desk, font, buf, x, y, w, h, 0xffffff, DB_WINDOW_COORD_TOP_CENTER);
	    current_config_x_pos = x;
	    current_config_y_pos = y;
	    current_config_ptr = conf;
	    if (selected_config < 0)
		selected_config = count;
	}
	count++;
	conf = conf->next;
    }
}

db_image *bootdevices_draw_devices(db_image *desk, db_image *wallp)
{
    int count = 0;
    boot_device *dev = devices;
    db_image_put_image(desk, wallp, 0, 0);
    
    if (!img_dev_sel)
	img_dev_sel = db_image_load(DATADIR "/artwork/devsel.png");
    
    int x_step = ICON_WIDTH + ICON_BORDER * 2;
    int y_step = ICON_HEIGHT + ICON_BORDER * 2;
    int x_pos = desk->width / 2 - bootdevices_count() * x_step / 2;
    int y_pos = desk->height * 2 / 3 - y_step / 2;
    
    while (dev) {
	if (count == selected_device) {
	    db_image_put_image(desk, img_dev_sel, x_pos + ICON_BORDER, y_pos + ICON_BORDER);
	    if (dev->message) {
	        db_message_draw(desk,
				  font,
				  dev->message,
				  desk->width / 2,
				  y_pos,
				  desk->width - 64,
				  y_pos - 64,
				  0x0,
				  DB_WINDOW_COORD_BOTTOM_CENTER);
	    }
	    bootdevices_draw_bootconfig(desk, 
					wallp, 
					dev,
					x_pos + x_step / 2,/* desk->width / 2, */
					y_pos + y_step,
					desk->width - 256, /*480,*/
					40);
	}
	db_image_put_image(desk, dev->icon, x_pos + ICON_BORDER, y_pos + ICON_BORDER);
	x_pos += x_step;
	dev = dev->next;
	count++;
    }
    return desk;
}

void bootdevice_select_prev(void)
{
    selected_device--;
    if (selected_device < 0)
	selected_device = 0;
    selected_config = -1;
}

void bootdevice_select_next(void)
{
    int count = bootdevices_count() - 1;
    selected_device++;
    if (selected_device > count)
	selected_device = count;
    selected_config = -1;
}

int bootdevice_config_count(int n)
{
    int c = 0;
    boot_device *dev = devices;
    while (dev) {
	if (n == c) {
	    int ret = 0;
	    boot_config *conf = dev->conf;
	    while (conf) {
		ret++;
		conf = conf->next;
	    }
	    return ret;
	}
	c++;
	dev = dev->next;
    }
    return 0;
}

void bootdevice_config_prev(void)
{
    selected_config--;
    if (selected_config < 0)
	selected_config = 0;
}

void bootdevice_config_next(void)
{
    int count = bootdevice_config_count(selected_device) - 1;
    selected_config++;
    if (selected_config > count)
	selected_config = count;
}

extern void ps3boot_quit(void);

void bootdevice_boot(void)
{
    int c = 0;
    boot_device *dev = devices;
    while (dev) {
	if (selected_device == c) {
	    if (!strcmp(dev->device, "gameos")) {
		char *cmd = GAMEOS_BIN;
		fprintf(stderr, "Execute: %s\n", cmd);
		if (system(cmd))
		    fprintf(stderr, "problem execute %s\n", cmd);
		return;
	    } else if (!strcmp(dev->device, "poweroff")) {
		char *cmd = POWEROFF_BIN;
		fprintf(stderr, "Execute: %s\n", cmd);
		if (system(cmd))
		    fprintf(stderr, "problem execute %s\n", cmd);
		return;
	    }

	    boot_config *conf = dev->conf;
	    c = 0;
	    while (conf) {
		if (c == selected_config) {
		    execute_boot_conf(dev->device, conf->kernel, conf->initrd, conf->cmdline);
		    break;
		}
		c++;
		conf = conf->next;
	    }
	    return;
	}
	c++;
	dev = dev->next;
    }
}

boot_config *bootdevice_get_current_config(int *x, int *y)
{
    *x = current_config_x_pos;
    *y = current_config_y_pos;
    return current_config_ptr;
}

void execute_boot_conf(char *devname, char *kernel, char *initrd, char *cmdline)
{
    int rc;
    char buf[1024];

    sprintf(buf, MKDIR_BIN " -p " MOUNT_DIR "%s", devname);
    rc = system(buf);
    if (rc)
	fprintf(stderr, "mkdir problem\n");

    sprintf(buf, MOUNT_BIN " -o ro %s " MOUNT_DIR "%s", devname, devname);
    rc = system(buf);
    if (rc)
	return;

    if (!initrd && !kernel) {
	FILE *f = fopen("/tmp/ps3boot.inc", "w");
	if (f) {
	    fprintf(f, "mount %s /mnt\n", devname);
	    fprintf(f, "cd /mnt\n");
	    fprintf(f, "/mnt/%s\n", cmdline);
	    fprintf(f, "cd /tmp; umount /mnt || umount -lf /mnt\n");
	    fclose(f);
	}
	ps3boot_quit();
	return;
    }
    system("hciconfig hci0 down");
    snprintf(buf, 1024, KEXEC_BIN " -f ");
    if (initrd) {
	strcat(buf, "--initrd=");
	strcat(buf, MOUNT_DIR);
	strcat(buf, devname);
	strcat(buf, "/");
	strcat(buf, initrd);
	strcat(buf, " ");
    }
    if (cmdline) {
	strcat(buf, "--append=\"");
	strcat(buf, cmdline);
	strcat(buf, "\" ");
    }
    if (kernel) {
	strcat(buf, MOUNT_DIR);
	strcat(buf, devname);
	strcat(buf, "/");
	strcat(buf, kernel);
	fprintf(stderr, "Execute: %s\n", buf);
	if (system(buf))
	    fprintf(stderr, "error execute %s\n", buf);
	sprintf(buf, UMOUNT_BIN " " MOUNT_DIR "%s", devname);
	rc = system(buf);
	sprintf(buf, MOUNT_DIR "%s", devname);
	rc = rmdir(buf);
    }

    sprintf(buf, UMOUNT_BIN " " MOUNT_DIR "%s", devname);
    rc = system(buf);

    return;
}

int bootdevice_autoboot_timer(void)
{
    if (default_timeout < 0)
	return default_timeout;

    default_timeout--;

    if (default_timeout == 0) {
	execute_boot_conf(default_devname, default_kernel, default_initrd, default_cmdline);
    }

    return default_timeout;
}
