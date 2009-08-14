#ifndef _FONT_H_
#define _FONT_H_

#include <ft2build.h>
#include FT_FREETYPE_H
#include <inttypes.h>

#include "image.h"

typedef struct {
    FT_Library    library;
    FT_Face       face;
} db_font;

db_font *db_font_open(char *file, int xsize, int ysize);

int db_font_max_height(db_font *font);

void db_font_close(db_font *font);

void db_image_put_string(db_image *dst, db_font *font, char *text, int x, int y, uint32_t color);

void db_font_get_string_box(db_font *font, char *text, int *width, int *height);

void db_image_put_string_box(db_image *dst, db_font *font, char *text, int x, int y, int w, int h, uint32_t color);

void db_image_put_text(db_image *dst, db_font *font, char *text, int x, int y, int w, int h, uint32_t color);

void db_font_get_text_box(db_font *font, char *text, int w, int h, int *real_w, int *real_h);

#endif
