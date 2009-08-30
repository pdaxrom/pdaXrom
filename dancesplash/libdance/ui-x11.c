#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "ui.h"

static Display *dpy = NULL;
static Window rootwin;
static Window win;
static Colormap cmap;
static int scr;
static GC gc;
static XImage *_img = NULL;
static int display_width, display_height;
static int display_depth;
static db_image *screen_image = NULL;

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

static Atom atom_net_wm_desktop;

static int init_xatoms(Display *dpy)
{
    atom_net_wm_desktop = XInternAtom(dpy, "_NET_WM_DESKTOP", False);

    if (atom_net_wm_desktop == BadAlloc) {
	fprintf(stderr, "XInternAtom BadAlloc\n");
	return -1;
    }

    if (atom_net_wm_desktop == BadValue) {
	fprintf(stderr, "XInternAtom BadValue\n");
	return -1;
    }

    return 0;
}

int db_ui_create(void)
{
    if(!(dpy = XOpenDisplay(NULL))) {
	fprintf(stderr, "ERROR: could not open display\n");
	exit(1);
    }

    init_xatoms(dpy);

    scr = DefaultScreen(dpy);
    rootwin = RootWindow(dpy, scr);
    cmap = DefaultColormap(dpy, scr);

    display_width = DisplayWidth(dpy, scr);
    display_height = DisplayHeight(dpy, scr);
    display_depth = DefaultDepth(dpy, scr);

    fprintf(stderr, "%dx%d@%d\n", display_width, display_height, display_depth);

    win = XCreateSimpleWindow(dpy, rootwin, 0, 0, display_width, display_height, 0, 
			BlackPixel(dpy, scr), BlackPixel(dpy, scr));

    XStoreName(dpy, win, "DanceBoard");

    gc = XCreateGC(dpy, win, 0, NULL);

    XSelectInput(dpy, win, ExposureMask|ButtonPressMask|KeyPressMask|KeyReleaseMask|StructureNotifyMask|PropertyChangeMask);

    XMapWindow(dpy, win);

    screen_image = db_image_create(display_width, display_height, 0);

    return 0;
}

int db_ui_create_window(int width, int height)
{
    if(!(dpy = XOpenDisplay(NULL))) {
	fprintf(stderr, "ERROR: could not open display\n");
	exit(1);
    }

    init_xatoms(dpy);

    scr = DefaultScreen(dpy);
    rootwin = RootWindow(dpy, scr);
    cmap = DefaultColormap(dpy, scr);

    display_width = width;//DisplayWidth(dpy, scr);
    display_height = height;//DisplayHeight(dpy, scr);
    display_depth = DefaultDepth(dpy, scr);

    fprintf(stderr, "%dx%d@%d\n", display_width, display_height, display_depth);

    win = XCreateSimpleWindow(dpy, rootwin, 0, 0, display_width, display_height, 0, 
			BlackPixel(dpy, scr), BlackPixel(dpy, scr));

    XMoveWindow(dpy, win, (DisplayWidth(dpy, scr) - display_width) / 2, (DisplayHeight(dpy, scr) - display_height) / 2);

    XStoreName(dpy, win, "DanceBoard");

    gc = XCreateGC(dpy, win, 0, NULL);

    XSelectInput(dpy, win, ExposureMask|ButtonPressMask|KeyPressMask|KeyReleaseMask|StructureNotifyMask|PropertyChangeMask);

    XMapWindow(dpy, win);

    screen_image = db_image_create(display_width, display_height, 0);

    return 0;
}

db_image *db_ui_get_screen(void)
{
    return screen_image;
}

int db_ui_update_screen(void)
{
    if (_img)
	XDestroyImage(_img);    

    _img = create_image_from_buffer (dpy, 
			    	     scr, 
				     screen_image->buf, 
				     screen_image->width, 
				     screen_image->height);

    XPutImage (dpy, win, gc, _img, 0, 0, 
	    (display_width - _img->width) / 2, 
	    (display_height - _img->height) / 2, 
	    _img->width, 
	    _img->height);
    return 0;
}

int db_ui_check_events(db_ui_event *event)
{
    XEvent e;
    event->type = DB_EVENT_NONE;
    if (XCheckMaskEvent(dpy, ExposureMask|ButtonPressMask|KeyPressMask|KeyReleaseMask|StructureNotifyMask|PropertyChangeMask, &e) == True) {
	if (e.type == Expose && e.xexpose.count < 1) {
	    if (_img)
		XPutImage (dpy, win, gc, _img, 0, 0, 
			    (display_width - _img->width) / 2, 
			    (display_height - _img->height) / 2, 
			    _img->width, 
			    _img->height);
//	} else if (e.type == ButtonPress) {
//	    return DB_EVENT_QUIT;
	} else if (e.type == KeyPress) {
	    event->type = DB_EVENT_KEYPRESS;
	    fprintf(stderr, "key %d\n", e.xkey.keycode);
	    event->key.keycode = e.xkey.keycode;
	    KeySym keysum = XKeycodeToKeysym(dpy, e.xkey.keycode, 0);
	    switch (keysum) {
	    case XK_Left:	event->key.key = DB_KEY_LEFT; break;
	    case XK_Right:	event->key.key = DB_KEY_RIGHT; break;
	    case XK_Up:		event->key.key = DB_KEY_UP; break;
	    case XK_Down:	event->key.key = DB_KEY_DOWN; break;
	    case XK_Escape:	event->key.key = DB_KEY_ESCAPE; break;
	    case XK_Return:	event->key.key = DB_KEY_RETURN; break;
	    case XK_space:	event->key.key = DB_KEY_SPACE; break;
	    default:
		if ((keysum >= 0x20) && (keysum < 0x80))
		    event->key.key = keysum;
		else
		    event->key.key = 0;
	    }
	} else //if (e.type == ClientMessage) {
	    if (e.xclient.message_type == atom_net_wm_desktop) {
		event->type = DB_EVENT_SPLASH_PROGRESS;
		if (e.xclient.data.b)
		    event->splash.data = NULL; //strdup(e.xclient.data.b);
	    //}
	}
    }
    return event->type;
}

void db_ui_close(void)
{
    if (!dpy)
	return;
    db_image_free(screen_image);
    screen_image = NULL;
    XCloseDisplay(dpy);
    dpy = NULL;
}

void db_ui_create_display(void)
{
    if (screen_image)
	db_image_free(screen_image);
    screen_image = db_image_create(display_width, display_height, 0);
}

void db_ui_close_display(void)
{
    db_image_free(screen_image);
    screen_image = NULL;
}

int db_ui_readkey(void)
{
    return 0;
}
