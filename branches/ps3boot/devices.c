#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <unistd.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>

#include "devices.h"
#include "parse-kboot.h"

#define ICON_WIDTH	64
#define ICON_HEIGHT	64
#define ICON_BORDER	5
#define TEXT_BORDER	3

extern db_font *font;

static boot_device *devices = NULL;
static boot_device *cur_device = NULL;

static db_image *img_dev_sel = NULL;
static int selected_device = 0;

static db_image *get_device_icon(char *dev_path)
{
    if (!strncmp(dev_path, "/dev/sd", 7))
	return db_image_load(DATADIR "artwork/hdd.png");
    if (!strncmp(dev_path, "/dev/sr", 7))
	return db_image_load(DATADIR "artwork/cdrom.png");
    if (!strcmp(dev_path, "gameos"))
	return db_image_load(DATADIR "artwork/gameos.png");
    return db_image_load(DATADIR "artwork/hdd.png");
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

static boot_device *bootdevice_create(char *dev_path)
{
    boot_device *dev = (boot_device *) malloc(sizeof(boot_device));    
    memset(dev, 0, sizeof(boot_device));
    
    kboot_conf_read(dev_path, dev);
    
    dev->icon = get_device_icon(dev_path);
    dev->device = strdup(dev_path);
    dev->next = NULL;
    
    return dev;
}

void bootdevice_add(char *dev_path)
{
    boot_device *dev = bootdevice_create(dev_path);
    
    if (devices == NULL) {
	devices = dev;
	cur_device = devices;
    } else {
	cur_device->next = dev;
	cur_device = dev;
    }
}

void bootdevice_remove(char *dev_path)
{
    boot_device *dev = devices;
    boot_device *prev = NULL;
    while (dev) {
	if (!strcmp(dev->device, dev_path)) {
	    if (prev) {
		prev->next = dev->next;
	    } else
		devices = dev->next;
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
    int yoff = 0;
    boot_config *conf = dev->conf;
    if (!conf)
	return;

    while (conf) {
	int t_w, t_h;
	char buf[1024];
	snprintf(buf, 1024, "%s: %s ", conf->label, conf->kernel);
	if (conf->initrd) {
	    strcat(buf, "initrd=");
	    strcat(buf, conf->initrd);
	}
	if (conf->cmdline) {
	    strcat(buf, " ");
	    strcat(buf, conf->cmdline);
	}
	if (!strcmp(dev->def, conf->label)) {
	    db_font_get_text_box(font, buf, w, h, &t_w, &t_h);
	    db_image_put_text(desk, font, buf, x, y + yoff, w, h, 0x0);
	    yoff += t_h + TEXT_BORDER;
	} else {
	    db_font_get_string_box(font, buf, &t_w, &t_h);
	    db_image_put_string_box(desk, font, buf, x, y + yoff, w, h, 0x0);
	    yoff += t_h + TEXT_BORDER;
	}
	conf = conf->next;
    }
}

db_image *bootdevices_draw_devices(db_image *desk, db_image *wallp)
{
    int count = 0;
    boot_device *dev = devices;
    db_image_put_image(desk, wallp, 0, 0);
    
    if (!img_dev_sel)
	img_dev_sel = db_image_load(DATADIR "artwork/devsel.png");
    
    int x_step = ICON_WIDTH + ICON_BORDER * 2;
    int y_step = ICON_HEIGHT + ICON_BORDER * 2;
    int x_pos = desk->width / 2 - bootdevices_count() * x_step / 2;
    int y_pos = desk->height / 2 - y_step / 2;
    
    while (dev) {
	int t_w, t_h;
	if (count == selected_device) {
	    db_image_put_image(desk, img_dev_sel, x_pos + ICON_BORDER, y_pos + ICON_BORDER);
	    if (dev->message) {
		int tw, th;
		db_font_get_text_box(font, dev->message, 480, 100, &tw, &th);
	        db_image_put_text(desk,
				  font,
				  dev->message,
				  desk->width / 2 - 240,
				  y_pos - 16 - th,
				  480,
				  100,
				  0x0);
	    }
	    bootdevices_draw_bootconfig(desk, 
					wallp, 
					dev,
					desk->width / 2 - 240,
					y_pos + y_step + 30,
					480,
					16);
	}
	db_image_put_image(desk, dev->icon, x_pos + ICON_BORDER, y_pos + ICON_BORDER);
	db_font_get_string_box(font, dev->device, &t_w, &t_h);
	db_image_put_string(desk,
			    font, 
			    dev->device, 
			    x_pos + x_step / 2 - t_w / 2, 
			    y_pos + y_step + t_h, 
			    0x0);
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
}

void bootdevice_select_next(void)
{
    int count = bootdevices_count() - 1;
    selected_device++;
    if (selected_device > count)
	selected_device = count;
}
