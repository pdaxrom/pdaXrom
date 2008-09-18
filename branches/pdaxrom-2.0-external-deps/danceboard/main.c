#include <X11/Xlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "board.h"
#include "image.h"
#include "font.h"

static Display *dpy;
static Window rootwin;
static Window win;
static Colormap cmap;
static int scr;
static GC gc;
static int display_width, display_height;
static int display_depth;

static XImage *create_image_from_buffer (Display *dis, int screen, unsigned char *buf, int width, int height) 
{
    int depth;
    XImage *img = NULL;
    Visual *vis;
    double rRatio;
    double gRatio;
    double bRatio;
    int outIndex = 0;	
    int i;
		
    depth = DefaultDepth (dis, screen);
    vis = DefaultVisual (dis, screen);

    rRatio = vis->red_mask / 255.0;
    gRatio = vis->green_mask / 255.0;
    bRatio = vis->blue_mask / 255.0;
	
    if (depth >= 24) {
	int numBytes = (4 * (width * height));
	u_int32_t *newBuffer = malloc (numBytes);
	
	for (i = 0; i < numBytes; i += 2) {
	    int r, g, b;
	    r = (buf[i] * rRatio);
	    ++i;
	    g = (buf[i] * gRatio);
	    ++i;
	    b = (buf[i] * bRatio);
					
	    r &= vis->red_mask;
	    g &= vis->green_mask;
	    b &= vis->blue_mask;
			
	    newBuffer[outIndex] = r | g | b;
	    ++outIndex;
	}		
		
	img = XCreateImage (dis, 
		CopyFromParent, 24, 
		ZPixmap, 0, 
		(char *) newBuffer,
		width, height,
		32, 0
		);	
    } else if (depth >= 15) {
	int numBytes = (2 * (width * height));
	u_int16_t *newBuffer = malloc (numBytes);
		
	for (i = 0; i < numBytes; i += 2) {
	    int r, g, b;
	    r = (buf[i] * rRatio);
	    ++i;
	    g = (buf[i] * gRatio);
	    ++i;
	    b = (buf[i] * bRatio);
					
	    r &= vis->red_mask;
	    g &= vis->green_mask;
	    b &= vis->blue_mask;
			
	    newBuffer[outIndex] = r | g | b;
	    ++outIndex;
	}		
		
	img = XCreateImage (dis,
		CopyFromParent, 16,
		ZPixmap, 0,
		(char *) newBuffer,
		width, height,
		16, 0
		);
    } else {
	fprintf (stderr, "unable to build an image on a display with < 15 bpp\n");
	return NULL;
    }

    return img;
}

int main(int argc, char *argv[])
{
    XEvent e;
    XImage *img = NULL;
    XImage *img2 = NULL;
    
    if(!(dpy=XOpenDisplay(NULL))) {
	fprintf(stderr, "ERROR: could not open display\n");
	exit(1);
    }

    scr = DefaultScreen(dpy);
    rootwin = RootWindow(dpy, scr);
    cmap = DefaultColormap(dpy, scr);

    display_width = DisplayWidth(dpy, scr);
    display_height = DisplayHeight(dpy, scr);
    display_depth = DefaultDepth(dpy, scr);

    fprintf(stderr, "%dx%d@%d\n", display_width, display_height, display_depth);

    unsigned long valuemask = CWOverrideRedirect;
    XSetWindowAttributes attributes;

    win = XCreateSimpleWindow(dpy, rootwin, 0, 0, display_width, display_height, 0, 
			BlackPixel(dpy, scr), BlackPixel(dpy, scr));

    attributes.override_redirect = True;
    XChangeWindowAttributes(dpy, win, valuemask, &attributes);

    XStoreName(dpy, win, "DanceBoard");

    gc = XCreateGC(dpy, win, 0, NULL);

    XSelectInput(dpy, win, ExposureMask|ButtonPressMask);

    XMapWindow(dpy, win);

/*
    db_image *_img = db_image_load("./pixmaps/wall2.jpg");
    db_image *_img2 = db_image_load("./pixmaps/email.png");
    db_image *_img3 = db_image_load("./pixmaps/webbrowser.png");

    db_image_put_image(_img, _img2, 100, 100, 0, 0, _img2->width, _img2->height);
    db_image_put_image(_img, _img3, 100, 200, 0, 0, _img3->width, _img3->height);
 */

    db_desk *desk = db_board_image_array(display_width, display_height);

#if 0
    db_font *font = db_font_open("fonts/Vera.ttf", 12, 0);
    if (!font) {
	fprintf(stderr, "Can't open font!\n");
    } else {
	db_image_put_string(desk->images[0], font, "Hello page", 100, 100, 0xffffff);
    }
#endif

    if (desk) {
	img = create_image_from_buffer (dpy, 
					scr, 
					desk->images[1]->buf, 
					desk->images[1]->width, 
					desk->images[1]->height);
    }

    while(1) {
	if (XCheckMaskEvent(dpy, ExposureMask | ButtonPressMask | PropertyChangeMask, &e) == True) {
	    if (e.type == Expose && e.xexpose.count < 1) {
		if (img)
		    XPutImage (dpy, win, gc, img, 0, 0, 
				(display_width - desk->images[0]->width) / 2, 
				(display_height - desk->images[0]->height) / 2, 
				desk->images[0]->width, 
				desk->images[0]->height);
	    } else if (e.type == ButtonPress) 
		break;
	}
    }

    XCloseDisplay(dpy);

    return 0;
}
