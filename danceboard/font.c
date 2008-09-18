#include <stdio.h>
#include <string.h>
#include <math.h>

#include "font.h"

db_font *db_font_open(char *file, int xsize, int ysize)
{
    FT_Error	error;

    db_font *font = (db_font *) malloc(sizeof(db_font));
    if (!font)
	return NULL;

    error = FT_Init_FreeType(&font->library);
    if (!error) {
	error = FT_New_Face(font->library, file, 0, &font->face);
	if (!error) {
	    error = FT_Set_Char_Size( font->face, xsize << 6, ysize << 6, 0, 0);
	    if (!error)
		return font;
	    FT_Done_Face(font->face);
	}
	FT_Done_FreeType(font->library);
    }

    return NULL;
}

void db_font_close(db_font *font)
{
    FT_Done_Face(font->face);
    FT_Done_FreeType(font->library);
    
    free(font);
}

static void draw_bitmap(db_image *dst, FT_Bitmap *bitmap, int x, int y, uint32_t color)
{
    int i, j;
    FT_Int w = bitmap->width;
    FT_Int h = bitmap->rows;
    
    uint32_t *image = &((uint32_t *)dst->buf)[dst->width * y + x];
    uint8_t *src = (uint8_t *) bitmap->buffer;
    
    if (w + x >= dst->width)
	w = dst->width - w;
	
    if (h + y >= dst->height)
	h = dst->height - h;

    for (j = 0; j < h; j++) {
	for (i = 0; i < w; i++) {
	    image[i] |= (src[i] << 16) | (src[i] << 8) | src[i];
	}
	image += dst->width;
	src += bitmap->width;
    }
}

void db_image_put_string(db_image *dst, db_font *font, char *text, int x, int y, uint32_t color)
{
    int 	n;
    FT_Error	error;

    if (!dst)
	return;
    if (!font)
	return;
    if (!text)
	return;

    FT_GlyphSlot slot = font->face->glyph;

    for (n = 0; n < strlen(text); n++) {
	error = FT_Load_Char(font->face, text[n], FT_LOAD_RENDER);
	if (error)
	    continue;

	draw_bitmap(dst, &slot->bitmap, x, y - slot->bitmap_top, color);

	x += slot->advance.x >> 6;
    }
}

void db_font_get_string_box(db_font *font, char *text, int *width, int *height)
{
    int 	n;
    FT_Error	error;

    *width = 0;
    *height = 0;

    if (!font)
	return;
    if (!text)
	return;

    FT_GlyphSlot slot = font->face->glyph;

    for (n = 0; n < strlen(text); n++) {
	error = FT_Load_Char(font->face, text[n], FT_LOAD_RENDER);
	if (error)
	    continue;

	*width += slot->advance.x >> 6;
	*height = (slot->bitmap_top > *height)?slot->bitmap_top:*height;
    }
}
