#ifndef _MESSAGE_H_
#define _MESSAGE_H_

#include "image.h"
#include "font.h"

enum {
    DB_WINDOW_COORD_UP_LEFT = 0,
    DB_WINDOW_COORD_UP_RIGHT,
    DB_WINDOW_COORD_TOP_CENTER,
    DB_WINDOW_COORD_BOTTOM_CENTER,
    DB_WINDOW_COORD_CENTER
};

int db_message_draw(db_image *img, db_font *font, char *msg, int x, int y, int w, int h, u_int32_t color, unsigned int attr);

#endif
