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

int db_font_max_height(db_font *font)
{
    if (!font)
	return 0;
	
    return font->face->size->metrics.max_advance >> 6;
}

void db_font_close(db_font *font)
{
    FT_Done_Face(font->face);
    FT_Done_FreeType(font->library);
    
    free(font);
}

/* Blend the RGB values of two Pixels based on a source alpha value */
#define ALPHA_BLEND(sR, sG, sB, A, dR, dG, dB)	\
do {						\
	dR = (((sR-dR)*(A))>>8)+dR;		\
	dG = (((sG-dG)*(A))>>8)+dG;		\
	dB = (((sB-dB)*(A))>>8)+dB;		\
} while(0)

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
		unsigned int dr, dg, db, da;
		unsigned int sr, sg, sb;
		unsigned char *dp = (unsigned char *) &image[i];

		dr = *dp++;
		dg = *dp++;
		db = *dp++;
		da = *dp++;
		
		sr = (color >> 16) & 0xff;
		sg = (color >> 8 ) & 0xff;
		sb = (color      ) & 0xff;
		
		ALPHA_BLEND(sr, sg, sb, src[i], dr, dg, db);
		
		dp = (unsigned char *) &image[i];
		
		*dp++ = dr;
		*dp++ = dg;
		*dp++ = db;
		*dp++ = da;
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
    }
    *height = db_font_max_height(font);
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

    y += db_font_max_height(font);

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
    int		y_orig = y;

    int		font_height = db_font_max_height(font);

    if (!dst)
	return;
    if (!font)
	return;
    if (!text)
	return;

    y += db_font_max_height(font);

    FT_GlyphSlot slot = font->face->glyph;

    for (n = 0; n < strlen(text); n++) {
	if ((text[n] == '\n') ||
	    (x > x_orig + w)) {
	    x = x_orig;
	    y += font_height + TEXT_BORDER;
	    if (y - y_orig > h)
		break;
	    continue;
	}
	error = FT_Load_Char(font->face, text[n], FT_LOAD_RENDER);
	if (error)
	    continue;

	draw_bitmap(dst, &slot->bitmap, x, y - slot->bitmap_top, color);

	x += slot->advance.x >> 6;
    }
}

void db_font_get_text_box(db_font *font, char *text, int w, int h, int *real_w, int *real_h)
{
    int		x = 0;
    int 	n;
    FT_Error	error;

    int		font_height = db_font_max_height(font);

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
	    *real_w = (x > *real_w)?x:*real_w;
	    x = 0;
	    *real_h += font_height + TEXT_BORDER;
	    if (*real_h > h)
		break;
	    continue;
	}
	error = FT_Load_Char(font->face, text[n], FT_LOAD_RENDER);
	if (error)
	    continue;

	x += slot->advance.x >> 6;
    }
    *real_w = (x > *real_w)?x:*real_w;
    *real_h += font_height + TEXT_BORDER;
}
