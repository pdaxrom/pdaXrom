#ifndef _BOARD_H_
#define _BOARD_H_

#include "image.h"
#include "font.h"

#define BOARD_APPS_HORIZ_MAX	4
#define BOARD_APPS_VERT_MAX	4

//#define DATADIR	"/usr/share"
//#define DATADIR	"."

typedef struct {
    char 	*name;
    char 	*exec;
    int	 	position;
    db_image	*icon;
} db_app;


typedef struct {
    db_app 	**apps;
    int	   	apps_count;
    db_image 	**images;
    int		images_count;
    db_font	*font;
} db_desk;

db_desk *db_board_image_array(int width, int height);
void db_board_image_array_free(db_desk *desk);

#endif
