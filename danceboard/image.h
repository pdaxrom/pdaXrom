#ifndef _IMAGE_H_
#define _IMAGE_H_

typedef struct {
    unsigned char *buf;
    int width;
    int height;
    int	has_alpha;
} db_image;

db_image *db_image_create(int width, int height, int has_alpha);
db_image *db_image_load(char *file);
void db_image_free(db_image *img);
void db_image_put_image(db_image *dst, db_image *src, int x, int y);
void db_image_put_image_crop(db_image *dst, db_image *src, int x, int y, int xoff, int yoff, int w, int h);

#endif
