#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <errno.h>

#include "ui.h"
#include "image.h"
#include "font.h"
#include "message.h"

#define SHM_BUF_SIZE	512
static int shmid;
static char *shared_buf;

static char str_buf[SHM_BUF_SIZE];

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

static int shared_open(int create)
{
    if((shmid = shmget(9999, SHM_BUF_SIZE, (create?IPC_CREAT:0) | 0666)) < 0) {
        printf("Error in shmget. errno is: %d\n", errno);
        return -1;
    }
    if ((shared_buf = shmat(shmid, NULL, 0)) < 0) {
	printf("Error in shm attach. errno is: %d\n", errno);
	return -1;
    }
    return 0;
}

static int shared_close(void)
{
    shmdt(shared_buf);
    shmctl(shmid, IPC_RMID, NULL);

    return 0;
}

void app_close(void)
{
    int i;
    for (i = 0; i < 16; i++)
	db_image_free(img_anim[i]);

    db_ui_close();
    shared_close();
}

int main(int argc, char *argv[])
{
    if (argc > 1) {
	if (!strcmp(argv[1], "-u")) {
	    if (shared_open(1) == -1) {
		return -1;
	    }
	
	    strcpy(shared_buf, argv[2]);
	    shmdt(shared_buf);

	    return 0;
	}
    }

    if (shared_open(1) == -1) {
	return -1;
    }
    str_buf[0] = 0;

#ifdef USE_X11
    db_ui_create_window(480, 480);
#else
    db_ui_create();
#endif

    atexit(app_close);

    db_font *font = db_font_open(DATADIR "/fonts/Vera.ttf", 25, 0);
    if (!font) {
	fprintf(stderr, "Can't open font!\n");
	return 1;
    }

    
    db_image *img_desk = db_ui_get_screen();
    //db_image *img_wallp = load_wallpaper(img_desk, DATADIR "/artwork/eye.jpg");
    db_image *img_wallp = db_image_load(DATADIR "/artwork/eye.jpg");
    if ((img_desk->width != img_wallp->width) ||
	(img_desk->height != img_wallp->height)) {
	fprintf(stderr, "resize\n");
	db_image *tmp = db_image_resize_image(img_wallp, img_desk->width, img_desk->height);
	db_image_free(img_wallp);
	img_wallp = tmp;
    }
    db_image_put_image(img_desk, img_wallp, 0, 0);

    load_animation(DATADIR "/artwork/animation/watch%02i.png");

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
	if (e.type == DB_EVENT_QUIT) {
	    fprintf(stderr, "DB_EVENT_QUIT\n");
	    break;
	}
#if 0
	if (e.type == DB_EVENT_SPLASH_PROGRESS) {
	    if (e.splash.data)
		free(e.splash.data);
		fprintf(stderr, "DB_EVENT_SPLASH_PROGRESS\n");
	    break;
	}
#endif
	if (*shared_buf) {
	    fprintf(stderr, ">>> %s\n", shared_buf);
	    if (!strncmp(shared_buf, "QUIT", 4))
		break;
	    if (!strncmp(shared_buf, "TEXT", 4)) {
		int w = 0, h = 0;
		db_image_put_image(img_desk, img_wallp, 0, 0);
		db_font_get_string_box(font, shared_buf + 5, &w, &h);
		db_image_put_string(img_desk, font, shared_buf + 5, (img_desk->width - w) / 2, img_desk->height - 80, 0xffffff);
		strcpy(str_buf, shared_buf + 5);
	    }
	    if (!strncmp(shared_buf, "SUCCESS", 7)) {
		int w = 0, h = 0;
		strcat(str_buf, " ... ");
		strcat(str_buf, shared_buf + 8);
		db_image_put_image(img_desk, img_wallp, 0, 0);
		db_font_get_string_box(font, str_buf, &w, &h);
		db_image_put_string(img_desk, font, str_buf, (img_desk->width - w) / 2, img_desk->height - 80, 0xffffff);
	    }
	    *shared_buf = 0;
	}
	int n = i % 16;
	db_image_put_image(img_desk, img_anim[n], (img_desk->width - img_anim[n]->width) / 2, img_desk->height - 40 - img_anim[n]->height / 2);
	db_ui_update_screen();
	usleep(100000);
	i++;
    }

    db_ui_close();

    return 0;
}
