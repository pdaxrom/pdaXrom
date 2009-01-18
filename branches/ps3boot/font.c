#include <stdio.h>
#include <string.h>
#include <math.h>

#include "font.h"

#define TEXT_BORDER	3

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

static inline uint32_t pixel_brightness(uint32_t pixel, uint8_t level)
{
    uint32_t ret = 0;
    int i = 0;
    if (level == 0)
	return 0;
    if (level == 255)
	return pixel;
    for (i = 0; i < 3; i++) {
	ret <<= 8;
	ret |= ((((pixel >> 16) & 0xff) * level) >> 8);
	pixel <<=8;
    }
    return ret;
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
	    if (src[i]) {
		int dr, dg, db, da;
		unsigned char *dp = (unsigned char *) &image[i];

		dr = *dp++;
		dg = *dp++;
		db = *dp++;
		da = *dp++;
		
		uint32_t p = pixel_brightness((dr << 16) | (dg << 8) | db, 255 - src[i]);

		dp = (unsigned char *) &image[i];
		
		*dp++ = (p >> 16) | (color >> 16);
		*dp++ = (p >> 8 ) | (color >> 8 );
		*dp++ = (p      ) | (color      );
		*dp++ = da;

//		image[i] = pixel_brightness(image[i], 255 - src[i]) | color;
	    }
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

void db_image_put_string_box(db_image *dst, db_font *font, char *text, int x, int y, int w, int h, uint32_t color)
{
    int 	n;
    FT_Error	error;
    int		x_orig = x;

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
	if (x > x_orig + w)
	    break;
    }
}

void db_image_put_text(db_image *dst, db_font *font, char *text, int x, int y, int w, int h, uint32_t color)
{
    int 	n;
    FT_Error	error;
    int		x_orig = x;
    int		th = 0;

    if (!dst)
	return;
    if (!font)
	return;
    if (!text)
	return;

    FT_GlyphSlot slot = font->face->glyph;

    for (n = 0; n < strlen(text); n++) {
	if ((text[n] == '\n') ||
	    (x > x_orig + w)) {
	    x = x_orig;
	    y += th + TEXT_BORDER;
	    th = 0;
	    continue;
	}
	error = FT_Load_Char(font->face, text[n], FT_LOAD_RENDER);
	if (error)
	    continue;

	draw_bitmap(dst, &slot->bitmap, x, y - slot->bitmap_top, color);

	x += slot->advance.x >> 6;
	th = (slot->bitmap_top > th)?slot->bitmap_top:th;
    }
}

void db_font_get_text_box(db_font *font, char *text, int w, int h, int *real_w, int *real_h)
{
    int		x = 0;
    int		y = 0;
    int 	n;
    FT_Error	error;

    *real_w = 0;
    *real_h = 0;

    if (!font)
	return;
    if (!text)
	return;

    FT_GlyphSlot slot = font->face->glyph;

    for (n = 0; n < strlen(text); n++) {
	if ((text[n] == '\n') ||
	    (x >  w)) {
	    *real_w += w;
	    x = 0;
	    *real_h += y + TEXT_BORDER;
	    y = 0;
	    continue;
	}
	error = FT_Load_Char(font->face, text[n], FT_LOAD_RENDER);
	if (error)
	    continue;

	x += slot->advance.x >> 6;
	y = (slot->bitmap_top > y)?slot->bitmap_top:y;
    }
    *real_h += y + TEXT_BORDER;
}
