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

void db_font_close(db_font *font);

void db_image_put_string(db_image *dst, db_font *font, char *text, int x, int y, uint32_t color);

void db_font_get_string_box(db_font *font, char *text, int *width, int *height);

#endif