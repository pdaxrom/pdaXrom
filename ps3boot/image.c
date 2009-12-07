#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "image.h"
#include "jpegdec.h"
#include "pngdec.h"

db_image *db_image_create(int width, int height, int has_alpha)
{
    db_image *img = (db_image *) malloc(sizeof(db_image));
    if (!img)
	return NULL;
    
    img->width = width;
    img->height = height;
    img->has_alpha = has_alpha;
    
    img->buf = (unsigned char *) malloc(width * height * 4);

    memset(img->buf, 0, width * height * 4);
    
    return img;
}

db_image *db_image_load(char *file)
{
    db_image *img = (db_image *) malloc(sizeof(db_image));
    if (!img)
	return NULL;

    img->buf = NULL;

    if (strcasestr(file, ".png"))
	img->buf = load_png_file(file, &img->width, &img->height, &img->has_alpha);

    if (strcasestr(file, ".jpg"))
	img->buf = load_jpeg_file(file, &img->width, &img->height, &img->has_alpha);

    if (!img->buf) {
	free(img);
	fprintf(stderr, "error load image file %s\n", file);
	return NULL;
    }

    return img;
}

void db_image_free(db_image *img)
{
    if (!img)
	return;

    if (img->buf)
	free(img->buf);

    free(img);
}

/* Blend the RGB values of two Pixels based on a source alpha value */
#define ALPHA_BLEND(sR, sG, sB, A, dR, dG, dB)	\
do {						\
	dR = (((sR-dR)*(A))>>8)+dR;		\
	dG = (((sG-dG)*(A))>>8)+dG;		\
	dB = (((sB-dB)*(A))>>8)+dB;		\
} while(0)

void db_image_put_image(db_image *dst, db_image *src, int x, int y)
{
    int l;
    int o;
    int w, h;
    uint32_t *src_buf = ((uint32_t *)src->buf);
    uint32_t *dst_buf = &((uint32_t *)dst->buf)[dst->width * y + x];
    
    h = src->height;
    if ((y + h) >= dst->height)
	h = dst->height - y;
    
    w = src->width;
    if ((x + w) >= dst->width)
	w = dst->width - x;

    for (l = 0; l < h; l++) {
	for (o = 0; o < w; o++) {
	    if (src->has_alpha) {
		unsigned int sr, sg, sb, sa;
		unsigned int dr, dg, db, da;
		unsigned char *sp = (unsigned char *) &src_buf[o];
		unsigned char *dp = (unsigned char *) &dst_buf[o];

		sr = *sp++;
		sg = *sp++;
		sb = *sp++;
		sa = *sp++;
		
		dr = *dp++;
		dg = *dp++;
		db = *dp++;
		da = *dp++;
		
		ALPHA_BLEND(sr, sg, sb, sa, dr, dg, db);
		
		dp = (unsigned char *) &dst_buf[o];
		
		*dp++ = dr;
		*dp++ = dg;
		*dp++ = db;
		*dp++ = da;
	    } else
		dst_buf[o] = src_buf[o];
	}
	dst_buf += dst->width;
	src_buf += src->width;
    }    
}

void db_image_put_image_crop(db_image *dst, db_image *src, int x, int y, int xoff, int yoff, int w, int h)
{
    int l;
    int o;
    uint32_t *src_buf = &((uint32_t *)src->buf)[src->width * yoff + xoff];
    uint32_t *dst_buf = &((uint32_t *)dst->buf)[dst->width * y + x];
    
    if ((y + h - yoff) >= dst->height)
	h = dst->height + yoff - y;
    
    if ((x + w - xoff) >= dst->width)
	w = dst->width + xoff - x;

    for (l = 0; l < h; l++) {
	for (o = 0; o < w; o++)
	    dst_buf[o] = src_buf[o];
	dst_buf += dst->width;
	src_buf += src->width;
    }    
}
