#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "ui.h"
#include "image.h"
#include "font.h"
#include "message.h"

#define MESSAGE_BORDER	16

#define MESSAGE_E_W	16
#define MESSAGE_E_H	16

static int db_messages_is_inited = 0;

static db_image *img_ul, *img_ur, *img_dl, *img_dr, *img_cc;

void db_messages_init(void)
{
    img_ul = db_image_load(DATADIR "/artwork/ul.png");
    img_ur = db_image_load(DATADIR "/artwork/ur.png");
    img_dl = db_image_load(DATADIR "/artwork/dl.png");
    img_dr = db_image_load(DATADIR "/artwork/dr.png");
    img_cc = db_image_load(DATADIR "/artwork/cc.png");
}

int db_message_draw(db_image *img, db_font *font, char *msg, int x, int y, int w, int h, u_int32_t color, unsigned int attr)
{
    int real_w, real_h;
    
    if (!db_messages_is_inited)
	db_messages_init();
    
    db_font_get_text_box(font, msg, w - MESSAGE_BORDER * 2, h - MESSAGE_BORDER * 2 - 13, &real_w, &real_h);
    
    int e_w = (real_w / MESSAGE_E_W) + 2;
    int e_h = (real_h / MESSAGE_E_H) + 2;
    
    int i_w = e_w * MESSAGE_E_W;
    int i_h = e_h * MESSAGE_E_H;
    
    if (attr == DB_WINDOW_COORD_UP_RIGHT)
	x -= i_w;

    if (attr == DB_WINDOW_COORD_TOP_CENTER)
	x -= (i_w / 2);

    if (attr == DB_WINDOW_COORD_BOTTOM_CENTER) {
	x -= (i_w / 2);
	y -= (i_h);
    }

    if (attr == DB_WINDOW_COORD_CENTER) {
	x -= (i_w / 2);
	y -= (i_h / 2);
    }

    if (x + i_w >= img->width)
	x -= (x + i_w - img->width);

    if (x < 0)
	x = 0;

    db_image_put_image(img, img_ul, x, y);
    db_image_put_image(img, img_ur, x + i_w - img_ur->width, y);
    db_image_put_image(img, img_dl, x, y + i_h - img_dl->height);
    db_image_put_image(img, img_dr, x + i_w - img_dr->width, y + i_h - img_dr->height);

    int i, j;
    for (j = y; j < y + i_h; j += img_cc->height) {
        for (i = x + img_cc->width; i < x + i_w - img_cc->width; i += img_cc->width) {
    	    db_image_put_image(img, img_cc, i, j);
        }
	if ((j != y) && (j != y + i_h - img_cc->height)) {
	    db_image_put_image(img, img_cc, x, j);
	    db_image_put_image(img, img_cc, x + i_w - img_cc->width, j);
	}
    }
    
    if (e_h == 1)
	y -= MESSAGE_BORDER / 2;

    db_image_put_text(img, font, msg, x + MESSAGE_BORDER, y + MESSAGE_BORDER, real_w, real_h, color);
    
    return i_h;
}

int db_message_edit(db_image *img, db_font *font, int key, char *msg, int size, int x, int y, int w, int h, u_int32_t color, unsigned int attr)
{
    switch (key) {
	case DB_KEY_RETURN:
	    return 0;
	case DB_KEY_RSHIFT:
	case DB_KEY_LSHIFT:
	case DB_KEY_RCTRL:
	case DB_KEY_LCTRL:
	case DB_KEY_RALT:
	case DB_KEY_LALT:
	case DB_KEY_RMETA:
	case DB_KEY_LMETA:
	case DB_KEY_LSUPER:
	case DB_KEY_RSUPER:
	case DB_KEY_MODE:
	case DB_KEY_COMPOSE:
	    return 1;
	case DB_KEY_LEFT:
	case DB_KEY_BACKSPACE:
	    if (strlen(msg) > 0)
		msg[strlen(msg) - 1] = 0;
	    break;
	default:
	    if (strlen(msg) < size - 1) {
		msg[strlen(msg)] = key;
		msg[strlen(msg) + 1] = 0;
	    }
    }
    db_message_draw(img, font, msg, x, y, w, h, color, attr);
    
    return 1;
}
