#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <semaphore.h>
#include <sys/time.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <errno.h>
#include <alloca.h>

#include "ui.h"
#include "image.h"
#include "font.h"
#include "message.h"
#include "readconf.h"

#define SHM_BUF_SIZE	512

typedef struct {
    sem_t	mutex;
    char	data[SHM_BUF_SIZE];
} dance_connector;

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

static dance_connector *shared_open(int *shmid, int f)
{
    dance_connector *ret;
    if ((*shmid = shmget(9999, SHM_BUF_SIZE, (f?IPC_CREAT:0) | 0666)) < 0) {
        printf("Error in shmget. errno is: %d\n", errno);
        return NULL;
    }
    if ((ret = shmat(*shmid, NULL, 0)) < 0) {
	printf("Error in shm attach. errno is: %d\n", errno);
	shmctl(*shmid, IPC_RMID, NULL);
	return NULL;
    }
    return ret;
}

static int shared_close(int shmid, dance_connector *connector, int f)
{
    shmdt(connector);
    if (!f)
	shmctl(shmid, IPC_RMID, NULL);

    return 0;
}

int main(int argc, char *argv[])
{
    char *wallp_name = (char *) alloca(512 * sizeof(char));
    char *config_name = (char *) alloca(512 * sizeof(char));
    char *font_name = (char *) alloca(512 * sizeof(char));
    char *conf_val = (char *) alloca(512 * sizeof(char));
    int font_size = 14;
    int fullscreen = 0;
    int rundaemon = 0;
    int shmid = -1;
    dance_connector *connector;

    wallp_name[0] = 0;
    font_name[0] = 0;

    strcpy(config_name, CONFIG_FILE);

    int i = 1;
    while (i < argc) {
	if (!strcmp(argv[i], "-c")) {
	    i++;
	    strncpy(config_name, argv[i], 256);
	} else if (!strcmp(argv[i], "-f")) {
	    fullscreen = 1;
	} else if (!strcmp(argv[i], "-b")) {
	    rundaemon = 1;
	} else if (!strcmp(argv[i], "-u")) {
	    i++;
	    if (!(connector = shared_open(&shmid, 1))) {
		return -1;
	    }
	    while (*connector->data)
		usleep(1000);
	    sem_wait(&connector->mutex);
	    strncpy(connector->data, argv[i], SHM_BUF_SIZE);
	    sem_post(&connector->mutex);
	    shared_close(shmid, connector, 1);
	    return 0;
	}
	i++;
    }

    if (rundaemon) {
	int ret = daemon(0, 1);
	if (ret) {
	    perror("daemonization failed");
	    exit(1);
	}
    }

    if (!strlen(wallp_name))
	db_readconf(config_name, "image", wallp_name);

    if (!strlen(wallp_name))
	strcpy(wallp_name, DATADIR "/artwork/eye.jpg");

    if (!(connector = shared_open(&shmid, 1))) {
	return -1;
    }
    sem_init(&connector->mutex, 1, 1);
    *connector->data = 0;

#ifdef USE_X11
    if (fullscreen)
	db_ui_create();
    else
	db_ui_create_window(480, 480);
#else
    db_ui_create();
#endif

    if (db_readconf(config_name, "fontsize", conf_val)) {
	font_size = atoi(conf_val);
	if ((font_size <= 0) ||
	    (font_size > 100))
	    font_size = 14;
    }

    if (!db_readconf(config_name, "fontname", font_name)) {
	strcpy(font_name, DATADIR "/fonts/Vera.ttf");
    }

    db_font *font = db_font_open(font_name, font_size, 0);
    if (!font)
	font = db_font_open(DATADIR "/fonts/Vera.ttf", font_size, 0);
    if (!font) {
	fprintf(stderr, "Can't open font!\n");
	return 1;
    }

    
    db_image *img_desk = db_ui_get_screen();
    //db_image *img_wallp = load_wallpaper(img_desk, DATADIR "/artwork/eye.jpg");
    db_image *img_wallp = db_image_load(wallp_name);
    if (!img_wallp)
	img_wallp = db_image_load(DATADIR "/artwork/eye.jpg");

    if ((img_desk->width != img_wallp->width) ||
	(img_desk->height != img_wallp->height)) {
	fprintf(stderr, "resize\n");
	db_image *tmp = db_image_resize_image(img_wallp, img_desk->width, img_desk->height);
	db_image_free(img_wallp);
	img_wallp = tmp;
    }
    db_image_put_image(img_desk, img_wallp, 0, 0);

    load_animation(DATADIR "/artwork/animation/watch%02i.png");

    char *mesg = "System is starting up. Please wait.";
    int w, h;
    db_font_get_string_box(font, mesg, &w, &h);
    db_image_put_string(img_desk, font, mesg, (img_desk->width - w) / 2, img_desk->height - 80, 0xffffff);

    db_image_put_image(img_desk, img_anim[0], (img_desk->width - img_anim[0]->width) / 2, img_desk->height - 40 - img_anim[0]->height / 2);
        
    db_ui_update_screen();

    while(1) {
	db_ui_event e;
	db_ui_check_events(&e);
	if (e.type == DB_EVENT_QUIT) {
	    fprintf(stderr, "DB_EVENT_QUIT\n");
	    break;
	}
	if (e.type == DB_EVENT_KEYPRESS) {
	    if (e.key.key == DB_KEY_ESCAPE) {
		fprintf(stderr, "Esc pressed\n");
		break;
	    }
	}
#if USE_X11
	if (e.type == DB_EVENT_SPLASH_PROGRESS) {
	    if (e.splash.data)
		free(e.splash.data);
		fprintf(stderr, "DB_EVENT_SPLASH_PROGRESS\n");
	    break;
	}
#endif
	if (*connector->data) {
	    sem_wait(&connector->mutex);
	    char str_buf[SHM_BUF_SIZE];
	    fprintf(stderr, ">>> %s\n", connector->data);
	    if (!strncmp(connector->data, "QUIT", 4))
		break;
	    if (!strncmp(connector->data, "TEXT", 4)) {
		int w = 0, h = 0;
		strcpy(str_buf, connector->data + 5);
		strcat(str_buf, " ... ");
		db_image_put_image(img_desk, img_wallp, 0, 0);
		db_font_get_string_box(font, str_buf, &w, &h);
		db_image_put_string(img_desk, font, str_buf, (img_desk->width - w) / 2, img_desk->height - 80, 0xffffffff);
	    }
	    if (!strncmp(connector->data, "SUCCESS", 7)) {
		int w = 0, h = 0;
		strcat(str_buf, connector->data + 8);
		db_image_put_image(img_desk, img_wallp, 0, 0);
		db_font_get_string_box(font, str_buf, &w, &h);
		db_image_put_string(img_desk, font, str_buf, (img_desk->width - w) / 2, img_desk->height - 80, 0xffffff);
	    }
	    *connector->data = 0;
	    sem_post(&connector->mutex);
	}

	int n = (i / 10) % 16;
	db_image_put_image(img_desk, img_anim[n], (img_desk->width - img_anim[n]->width) / 2, img_desk->height - 40 - img_anim[n]->height / 2);
	db_ui_update_screen();
	usleep(10000);
	i++;
    }

    for (i = 0; i < 16; i++)
	db_image_free(img_anim[i]);

    db_ui_close();

    shared_close(shmid, connector, 0);

    return 0;
}
