#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <unistd.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>

#include "board.h"
#include "dotdesktop.h"

static int select_desktop_file(struct dirent *name)
{
    if (!strstr(name->d_name, ".desktop"))
	return 0;
    else
	return 1;
}

db_app **db_app_array(int *count)
{
    db_app **apps;
    struct dirent **namelist;
    int	namecount = 0;
    char dirn[512];
    int i;

    sprintf(dirn, "%s/applications", DATADIR);
    namecount = scandir(dirn, &namelist, select_desktop_file, alphasort);
    if (namecount < 1)
	return NULL;

    apps = (db_app **) malloc(sizeof(db_app *) * namecount);

    if (apps)
	*count = namecount;
    else
	*count = 0;
    
    for (i = 0; i < namecount; i++) {
	if (namelist[i]) {
	    if (apps) {
		char dirn[512];
		sprintf(dirn, "%s/applications/%s", DATADIR, namelist[i]->d_name);
		fprintf(stderr, "file %s\n", dirn);
		apps[i] = db_parse_desktop_file(dirn);
		if (apps[i]) {
		    fprintf(stderr, "name %s\n", apps[i]->name);
		    fprintf(stderr, "exec %s\n", apps[i]->exec);
		    if (!apps[i]->icon)
			fprintf(stderr, "no icon!\n");
		}
	    } else
		free(namelist[i]);
	}
    }
    
    free(namelist);
    
    return apps;
}

void db_app_array_free(db_app **apps, int count)
{
    int i;
    for (i = 0; i < count; i++) {
	if (apps[i]->name)
	    free(apps[i]->name);
	if (apps[i]->exec)
	    free(apps[i]->exec);
	if (apps[i]->icon)
	    db_image_free(apps[i]->icon);
    }
    free(apps);
}

db_desk *db_board_image_array(int width, int height)
{
    db_desk *desk;
    int i;

    desk = (db_desk *) malloc(sizeof(db_desk));
    if (!desk)
	return NULL;
    
    desk->apps = db_app_array(&desk->apps_count);

    if (!desk->apps) {
	free(desk);
	return NULL;
    }


    desk->font = db_font_open("fonts/Vera.ttf", 12, 0);
    if (!desk->font) {
	fprintf(stderr, "Can't open font!\n");
    }
    
    desk->images_count = (desk->apps_count + BOARD_APPS_HORIZ_MAX * BOARD_APPS_VERT_MAX)
		/ (BOARD_APPS_HORIZ_MAX * BOARD_APPS_VERT_MAX);
    
    fprintf(stderr, "images_count %d\n", desk->images_count);
    
    desk->images = (db_image **) malloc(sizeof(db_image *) * desk->images_count);
    
    for (i = 0; i < desk->images_count; i++) {
//    for (i = 0; i < 1; i++) {
	int j;
	int n = i * BOARD_APPS_HORIZ_MAX * BOARD_APPS_VERT_MAX;
	int sx = width / BOARD_APPS_HORIZ_MAX;
	int sy = height / BOARD_APPS_VERT_MAX;
	desk->images[i] = db_image_create(width, height, 1);
	fprintf(stderr, "image %d\n", i);
	for (j = 0; j < BOARD_APPS_HORIZ_MAX * BOARD_APPS_VERT_MAX; j++) {
	    if (n + j >= desk->apps_count)
		break;
	    int y = j / BOARD_APPS_HORIZ_MAX;
	    int x = j % BOARD_APPS_HORIZ_MAX;
	    fprintf(stderr, "x %d, y %d\n", x, y);
	    if (desk->apps[n + j]->icon)
		db_image_put_image(desk->images[i], 
				desk->apps[n + j]->icon, 
				sx * x + sx / 2 - desk->apps[n + j]->icon->width / 2, 
				sy * y + sy / 2 - desk->apps[n + j]->icon->height/ 2);

	    if (desk->font && desk->apps[n + j]->name) {
		int tw = 0;
		int th = 0;
		
		db_font_get_string_box(desk->font, desk->apps[n + j]->name, &tw, &th);
		
		fprintf(stderr, "tw %d, th %d, [%s]\n", tw, th, desk->apps[n + j]->name);

		db_image_put_string(desk->images[i],
				    desk->font,
				    desk->apps[n + j]->name,
				    sx * x + sx / 2 - tw / 2,
				    sy * y + sy / 2 + (desk->apps[n + j]->icon?desk->apps[n + j]->icon->height / 2:0) + th,
				    0xffffff);
	    }
	}
    }
        
    return desk;
}

void db_board_image_array_free(db_desk *desk)
{
    int i;
    for (i = 0; i < desk->images_count; i++) {
	db_image_free(desk->images[i]);
    }
    db_app_array_free(desk->apps, desk->apps_count);
    db_font_close(desk->font);
    free(desk);
}
