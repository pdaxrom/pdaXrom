#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <unistd.h>

#include <jpeglib.h>
#include <jerror.h>

static void jpeg_error_exit (j_common_ptr cinfo) {
    cinfo->err->output_message (cinfo);
    exit (EXIT_FAILURE);
}

/*This returns an array for a 24 bit image stored within 32 bits (8 unused)*/
unsigned char *load_jpeg_file (char *file, int *width, int *height, int *has_alpha) {
    register JSAMPARRAY lineBuffer;
    struct jpeg_decompress_struct cinfo;
    struct jpeg_error_mgr err_mgr;
    int bytesPerPix;
    FILE *inFile;
    unsigned char *retBuf;
    int lineOffset;	
    int line;
    int i;

    inFile = fopen (file, "rb");
    if (NULL == inFile) { 
	return NULL;
    }

    cinfo.err = jpeg_std_error (&err_mgr);
    err_mgr.error_exit = jpeg_error_exit;	

    jpeg_create_decompress (&cinfo);
    jpeg_stdio_src (&cinfo, inFile);
    jpeg_read_header (&cinfo, 0);
    cinfo.do_fancy_upsampling = 0;
    cinfo.do_block_smoothing = 0;
    jpeg_start_decompress (&cinfo);

    *width = cinfo.output_width;
    *height = cinfo.output_height;
    bytesPerPix = cinfo.output_components;

    *has_alpha = 0;
	
    lineOffset = (*width * 4);
    lineBuffer = cinfo.mem->alloc_sarray ((j_common_ptr) &cinfo, JPOOL_IMAGE, (*width * bytesPerPix), 1);
    retBuf = (unsigned char *) malloc (4 * (*width * *height));
		
    if (NULL == retBuf)
	goto out;
		
    line = 0;
    while (cinfo.output_scanline < cinfo.output_height) {
	int lineBufferIndex = 0;
		
	jpeg_read_scanlines (&cinfo, lineBuffer, 1);
		
	for (i = 0; i < lineOffset; i += 2) {
	    /*red*/
	    retBuf[(lineOffset * line) + i] = lineBuffer[0][lineBufferIndex];
	    ++i;
	    ++lineBufferIndex;
			
	    /*green*/
	    retBuf[(lineOffset * line) + i] = lineBuffer[0][lineBufferIndex];
	    ++i;
	    ++lineBufferIndex;
			
	    /*blue*/
	    retBuf[(lineOffset * line) + i] = lineBuffer[0][lineBufferIndex];
	    ++lineBufferIndex;
	}
	++line;
    }

 out:
    jpeg_finish_decompress (&cinfo);
    jpeg_destroy_decompress (&cinfo);
    fclose (inFile);
			
    return retBuf;
}
