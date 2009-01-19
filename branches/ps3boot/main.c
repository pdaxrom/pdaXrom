#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "ui.h"
#include "image.h"
#include "font.h"
#include "devices.h"
#include "message.h"
#include "server.h"

db_font *font = NULL;

db_image *load_wallpaper(db_image *desk)
{
    int x, y, xoff, yoff, w, h;
    db_image *wallp = db_image_load(DATADIR "/artwork/background.jpg");
    db_image *ret = db_image_create(desk->width, desk->height, 0);
    if (desk->width >= wallp->width) {
	x = (desk->width - wallp->width) / 2;
	xoff = 0;
	w = wallp->width;
    } else {
	x = 0;
	xoff = (wallp->width - desk->width) / 2;
	w = desk->width;
    }
    if (desk->height >= wallp->height) {
	y = (desk->height - wallp->height) / 2;
	yoff = 0;
	h = wallp->height;
    } else {
	y = 0;
	yoff = (wallp->height - desk->height) / 2;
	h = desk->height;
    }
    db_image_put_image_crop(ret, wallp, x, y, xoff, yoff, w, h);
    db_image_free(wallp);
    
    return ret;
}

int main(int argc, char *argv[])
{
    db_ui_create();
    
    font = db_font_open(DATADIR "/fonts/Vera.ttf", 12, 0);
    if (!font) {
	fprintf(stderr, "Can't open font!\n");
    }

    db_image *img_desk = db_ui_get_screen();
    db_image *img_wallp = load_wallpaper(img_desk);
    
    bootdevice_init();
    ps3boot_serv_on();

//    bootdevice_add("gameos");
//    bootdevice_add("/dev/sr0");
//    bootdevice_add("/dev/sda1");
//    bootdevice_add("/dev/sda2");
//    bootdevice_add("/dev/sdd1");

    bootdevices_draw_devices(img_desk, img_wallp);
    db_message_draw(img_desk, font, "PS3 bootshell v0.1\nhttp://wiki.pdaXrom.org", img_desk->width - 50, 50, 400, 120, 0xffffff, DB_WINDOW_COORD_UP_RIGHT);
    
    db_ui_update_screen();
    
    int f_quit = 0;
    int f_edit = 0;
    int tmp_x = 0;
    int tmp_y = 0;
    boot_config *tmp_bconf = NULL;
    char tmp_edit[1024];
    memset(tmp_edit, 0, 1024);
    
    while(!f_quit) {
	db_ui_event e;
	if (ps3boot_serv_check_msg()) {
	    f_edit = 0;
	    bootdevices_draw_devices(img_desk, img_wallp);
	    db_ui_update_screen();
	}
	db_ui_check_events(&e);
	if (e.type == DB_EVENT_QUIT)
	    break;
	switch (e.type) {
	    case DB_EVENT_KEYPRESS: {
		if (f_edit) {
		    f_edit = db_message_edit(img_desk, font, e.key.key, tmp_edit, 256, tmp_x, tmp_y, 300, 100, 0x0, DB_WINDOW_COORD_TOP_CENTER);
		    db_ui_update_screen();
		    if (!f_edit) {
			free(tmp_bconf->cmdline);
			tmp_bconf->cmdline = strdup(tmp_edit);
			fprintf(stderr, ">>>%s\n", tmp_bconf->cmdline);
			bootdevices_draw_devices(img_desk, img_wallp);
			db_ui_update_screen();
		    }
		    continue;
		}
		switch (e.key.key) {
		    case DB_KEY_LEFT:
			bootdevice_select_prev();
			break;
		    case DB_KEY_RIGHT:
			bootdevice_select_next();
			break;
		    case DB_KEY_UP:
			bootdevice_config_prev();
			break;
		    case DB_KEY_DOWN:
			bootdevice_config_next();
			break;
		    case DB_KEY_ESCAPE:
			f_quit = 1;
			break;
		    case DB_KEY_RETURN:
			bootdevice_boot();
			break;
		    case DB_KEY_SPACE:
			tmp_bconf = bootdevice_get_current_config(&tmp_x, &tmp_y);
			if (!tmp_bconf)
			    break;
			if (!tmp_bconf->cmdline)
			    break;
			strcpy(tmp_edit, tmp_bconf->cmdline);
			db_message_edit(img_desk, font, 0, tmp_edit, 256, tmp_x, tmp_y, 300, 100, 0x0, DB_WINDOW_COORD_TOP_CENTER);
			db_ui_update_screen();
			fprintf(stderr, "edit mode\n");
			f_edit = 1;
			continue;
		};
		bootdevices_draw_devices(img_desk, img_wallp);
		db_ui_update_screen();
	    }; break;
	}
    }

    ps3boot_serv_off();
    db_ui_close();

    return 0;
}
