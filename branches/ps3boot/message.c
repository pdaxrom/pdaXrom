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
    
    fprintf(stderr, "w=%d (%d)\nh=%d (%d)\n", w, real_w, h, real_h);
    
//    int e_w = (real_w + MESSAGE_BORDER * 2) / (MESSAGE_E_W * 2);
//    int e_h = (real_h + MESSAGE_BORDER * 2) / (MESSAGE_E_H * 2);

    int e_w = (real_w / MESSAGE_E_W) + 2;
    int e_h = (real_h / MESSAGE_E_H) + 2;
    
//    if (e_w < 1)
//	e_w = 1;
//    if (e_h < 1)
//	e_h = 1;
    
//    int i_w = e_w * MESSAGE_E_W * 2;
    int i_w = e_w * MESSAGE_E_W;
    int i_h = e_h * MESSAGE_E_H;
    
    fprintf(stderr, "ew = %d\neh = %d\n", e_w, e_h);
    fprintf(stderr, "iw = %d\nih = %d\n", i_w, i_h);

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

    db_image_put_text(img, font, msg, x + MESSAGE_BORDER, y + MESSAGE_BORDER, real_w, real_h - MESSAGE_BORDER, color);
    
    return i_h;
}
