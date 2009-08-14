#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <png.h>

unsigned char *load_png_file (char *file, int *width, int *height, int *has_alpha)
{
    FILE *fd;
    unsigned char *data;
    unsigned char header[8];
    int  bit_depth, color_type;

    png_uint_32  png_width, png_height, i, rowbytes;
    png_structp png_ptr;
    png_infop info_ptr;
    png_bytep *row_pointers;

    if ((fd = fopen( file, "rb" )) == NULL)
	return NULL;

    int rc = fread( header, 1, 8, fd );

    if (rc != 8) {
	fclose(fd);
        return NULL;
    }
    
    if ( ! png_check_sig( header, 8 ) ) {
	fclose(fd);
        return NULL;
    }

    png_ptr = png_create_read_struct( PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if ( ! png_ptr ) {
	fclose(fd);
	return NULL;
    }

    info_ptr = png_create_info_struct(png_ptr);
    if ( ! info_ptr ) {
	png_destroy_read_struct( &png_ptr, (png_infopp)NULL, (png_infopp)NULL);
	fclose(fd);
	return NULL;
    }

    if ( setjmp( png_ptr->jmpbuf ) ) {
	png_destroy_read_struct( &png_ptr, &info_ptr, NULL);
	fclose(fd);
	return NULL;
    }

    png_init_io( png_ptr, fd );
    png_set_sig_bytes( png_ptr, 8);
    png_read_info( png_ptr, info_ptr);
    png_get_IHDR( png_ptr, info_ptr, &png_width, &png_height, &bit_depth, 
		    &color_type, NULL, NULL, NULL);
    *width = (int) png_width;
    *height = (int) png_height;

    if (( color_type == PNG_COLOR_TYPE_PALETTE )||
	( png_get_valid( png_ptr, info_ptr, PNG_INFO_tRNS )))
	png_set_expand(png_ptr);

    if (( color_type == PNG_COLOR_TYPE_GRAY )||
        ( color_type == PNG_COLOR_TYPE_GRAY_ALPHA ))
	png_set_gray_to_rgb(png_ptr);
 
    if ( info_ptr->color_type == PNG_COLOR_TYPE_RGB_ALPHA 
        || info_ptr->color_type == PNG_COLOR_TYPE_GRAY_ALPHA
	)
	*has_alpha = 1;
    else
	*has_alpha = 0;

    /* 8 bits */
    if ( bit_depth == 16 )
	png_set_strip_16(png_ptr);

    if (bit_depth < 8)
	png_set_packing(png_ptr);

    /* not needed as data will be RGB not RGBA and have_alpha will reflect this
       png_set_filler(png_ptr, 0xff, PNG_FILLER_AFTER);
    */

    png_read_update_info( png_ptr, info_ptr);

    /* allocate space for data and row pointers */
    rowbytes = png_get_rowbytes( png_ptr, info_ptr);
    data = (unsigned char *) malloc( (rowbytes*(*height + 1)));
    row_pointers = (png_bytep *) malloc( (*height)*sizeof(png_bytep));

    if (( data == NULL )||( row_pointers == NULL )) {
	png_destroy_read_struct( &png_ptr, &info_ptr, NULL);
	free(data);
	free(row_pointers);
	return NULL;
    }

    for ( i = 0;  i < *height; i++ )
	row_pointers[i] = data + i*rowbytes;

    png_read_image( png_ptr, row_pointers );
    png_read_end( png_ptr, NULL);

    free(row_pointers);
    png_destroy_read_struct( &png_ptr, &info_ptr, NULL);
    fclose(fd);

    return data;
}

