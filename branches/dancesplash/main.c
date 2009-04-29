#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/time.h>

#include "ui.h"
#include "image.h"
#include "font.h"
#include "message.h"

static db_image *img_anim[16];

static int load_animation(char *name)
{
    char buf[512];
    int i;
    
    for (i = 0; i < 16; i++) {
	sprintf(buf, name, i + 1);
	img_anim[i] = db_image_load(buf);
	if (!img_anim[i])
	    fprintf(stderr, "can't load image %s\n", buf);
    }
    
    return 0;
}

static db_image *load_wallpaper(db_image *desk, char *name)
{
    int x, y, xoff, yoff, w, h;
    db_image *wallp = db_image_load(name);
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

void app_close(void)
{
    int i;
    for (i = 0; i < 16; i++)
	db_image_free(img_anim[i]);

    db_ui_close();
    
    fprintf(stderr, "Bye!\n");
}

int main(int argc, char *argv[])
{
    db_ui_create_window(480, 480);

    atexit(app_close);

    db_font *font = db_font_open(DATADIR "/fonts/Vera.ttf", 25, 0);
    if (!font) {
	fprintf(stderr, "Can't open font!\n");
	return 1;
    }

    
    db_image *img_desk = db_ui_get_screen();
    db_image *img_wallp = load_wallpaper(img_desk, DATADIR "/artwork/eye.jpg");
    db_image_put_image(img_desk, img_wallp, 0, 0);

    load_animation(DATADIR "/artwork/animation/watch%02i.png");

//    db_message_draw(img_desk, font, "PS3 bootshell v0.1\nhttp://wiki.pdaXrom.org", img_desk->width - 50, 50, 400, 120, 0xffffff, DB_WINDOW_COORD_UP_RIGHT);

    char *mesg = "Desktop is starting up. Please wait.";
    int w, h;
    db_font_get_string_box(font, mesg, &w, &h);
    db_image_put_string(img_desk, font, mesg, (img_desk->width - w) / 2, img_desk->height - 80, 0xffffff);

    db_image_put_image(img_desk, img_anim[0], (img_desk->width - img_anim[0]->width) / 2, img_desk->height - 40 - img_anim[0]->height / 2);
        
    db_ui_update_screen();

    int i = 0;
    while(1) {
	db_ui_event e;
	db_ui_check_events(&e);
	if (e.type == DB_EVENT_QUIT)
	    break;
	if (e.type == DB_EVENT_SPLASH_PROGRESS) {
	    if (e.splash.data)
		free(e.splash.data);
	    break;
	}
	//db_image_put_image(img_desk, img_wallp, 0, 0);
	//db_font_get_string_box(font, mesg, &w, &h);
	//db_image_put_string(img_desk, font, mesg, (img_desk->width - w) / 2, img_desk->height - 80, 0xffffff);
	int n = i % 16;
	db_image_put_image(img_desk, img_anim[n], (img_desk->width - img_anim[n]->width) / 2, img_desk->height - 40 - img_anim[n]->height / 2);
	db_ui_update_screen();
	usleep(100000);
	i++;
    }

    db_ui_close();

    return 0;
}
