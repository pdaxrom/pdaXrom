#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <inttypes.h>

#include <linux/vt.h>
#include <linux/kd.h>
#include <linux/fb.h>
#include <linux/keyboard.h>
#include <termios.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ui.h"
#include "ui-linuxfb.h"

static char *defaultfbdevice = "/dev/fb0";
static int fb_fd = -1;
static char *fbdevice = NULL;
static struct fb_fix_screeninfo fix;
static struct fb_var_screeninfo var;

static int display_width, display_height;
static int display_depth;
static int display_pitch;
static unsigned char *display_buffer;
static db_image *screen_image = NULL;

static char 	*defaultconsoledevice = "/dev/tty";
static char	*consoledevice = NULL;
static int 	con_fd = -1, last_vt = -1;
static int 	cnt_cur = 0, cnt_all = 0;
static unsigned char	buf[256];

static int	LinuxKbdTrans;
static struct termios	LinuxTermios;

#define NUM_VGAKEYMAPS	(1<<KG_CAPSSHIFT)
static ushort vga_keymap[NUM_VGAKEYMAPS][NR_KEYS];
static DBKey keymap[128];
static ushort keymap_temp[128]; /* only used at startup */

static int framebuffer_on(void)
{
    if ((fbdevice = getenv ("DANCEBOARD_FBDEVICE")) == NULL)
	fbdevice = defaultfbdevice;

    fb_fd = open(fbdevice, O_RDWR);
    if (fb_fd == -1) {
	perror("open fbdevice");
	return 1;
    }

    if (ioctl(fb_fd, FBIOGET_FSCREENINFO, &fix) < 0) {
	perror("ioctl FBIOGET_FSCREENINFO");
	close(fb_fd);
	fb_fd = -1;
	return 1;
    }

    if (ioctl(fb_fd, FBIOGET_VSCREENINFO, &var) < 0) {
	perror("ioctl FBIOGET_VSCREENINFO");
	close(fb_fd);
	fb_fd = -1;
	return 1;
    }

    display_buffer = mmap(NULL, fix.line_length * var.yres, PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, fb_fd, 0);
    if (display_buffer == (unsigned char *)-1) {
	perror("mmap framebuffer");
	close(fb_fd);
	fb_fd = -1;
	return 1;
    }

    memset(display_buffer,0,fix.line_length * var.yres);

    display_width = var.xres;
    display_height = var.yres;
    display_depth = var.bits_per_pixel;
    display_pitch  = fix.line_length;

    fprintf(stderr, "depth %d\nwidth %d\npitch %d\nheight %d\n", display_depth, display_width, display_pitch, display_height);

    return 0;
}

static int framebuffer_off(void)
{
    if (fb_fd < 0)
	return 0;
	
    munmap(display_buffer, fix.line_length * var.yres);

    close(fb_fd);
    fb_fd = -1;
    return 0;
}

static void keyboard_vgainitkeymaps(int fd)
{
    struct kbentry entry;
    int map, i;

    /* Don't do anything if we are passed a closed keyboard */
    if ( fd < 0 ) {
	return;
    }

    /* Load all the keysym mappings */
    for ( map=0; map<NUM_VGAKEYMAPS; ++map ) {
	memset(vga_keymap[map], 0, NR_KEYS*sizeof(ushort));
	for ( i=0; i<NR_KEYS; ++i ) {
	    entry.kb_table = map;
	    entry.kb_index = i;
	    if ( ioctl(fd, KDGKBENT, &entry) == 0 ) {
		/* fill keytemp. This replaces SDL_fbkeys.h */
		if ( (map == 0) && (i<128) ) {
		    keymap_temp[i] = entry.kb_value;
		}
		/* The "Enter" key is a special case */
		if ( entry.kb_value == K_ENTER ) {
		    entry.kb_value = K(KT_ASCII,13);
		}
		/* Handle numpad specially as well */
		if ( KTYP(entry.kb_value) == KT_PAD ) {
		    switch ( entry.kb_value ) {
		    case K_P0:
		    case K_P1:
		    case K_P2:
		    case K_P3:
		    case K_P4:
		    case K_P5:
		    case K_P6:
		    case K_P7:
		    case K_P8:
		    case K_P9:
			vga_keymap[map][i]=entry.kb_value;
			vga_keymap[map][i]+= '0';
			break;
		    case K_PPLUS:
			vga_keymap[map][i]=K(KT_ASCII,'+');
			break;
		    case K_PMINUS:
			vga_keymap[map][i]=K(KT_ASCII,'-');
			break;
		    case K_PSTAR:
			vga_keymap[map][i]=K(KT_ASCII,'*');
			break;
		    case K_PSLASH:
			vga_keymap[map][i]=K(KT_ASCII,'/');
			break;
		    case K_PENTER:
			vga_keymap[map][i]=K(KT_ASCII,'\r');
			break;
		    case K_PCOMMA:
			vga_keymap[map][i]=K(KT_ASCII,',');
			break;
		    case K_PDOT:
			vga_keymap[map][i]=K(KT_ASCII,'.');
			break;
		    default:
			break;
		    }
		}
		/* Do the normal key translation */
		if ((KTYP(entry.kb_value) == KT_LATIN) ||
		    (KTYP(entry.kb_value) == KT_ASCII) ||
		    (KTYP(entry.kb_value) == KT_LETTER)) {
		    vga_keymap[map][i] = entry.kb_value;
		}
	    }
	}
    }
}

static void keyboard_InitOSKeymap(void)
{
    int i;

    /* Initialize the Linux key translation table */

    /* First get the ascii keys and others not well handled */
    for (i=0; i < SCANCODE_TABLESIZE(keymap); ++i) {
	switch(i) {
#ifdef __i386__
	/* These aren't handled by the x86 kernel keymapping (?) */
	case SCANCODE_PRINTSCREEN:
	    keymap[i] = DB_KEY_PRINT;
	    break;
	case SCANCODE_BREAK:
	    keymap[i] = DB_KEY_BREAK;
	    break;
	case SCANCODE_BREAK_ALTERNATIVE:
	    keymap[i] = DB_KEY_PAUSE;
	    break;
	case SCANCODE_LEFTSHIFT:
	    keymap[i] = DB_KEY_LSHIFT;
	    break;
	case SCANCODE_RIGHTSHIFT:
	    keymap[i] = DB_KEY_RSHIFT;
	    break;
	case SCANCODE_LEFTCONTROL:
	    keymap[i] = DB_KEY_LCTRL;
	    break;
	case SCANCODE_RIGHTCONTROL:
	    keymap[i] = DB_KEY_RCTRL;
	    break;
	case SCANCODE_RIGHTWIN:
	    keymap[i] = DB_KEY_RSUPER;
	    break;
	case SCANCODE_LEFTWIN:
	    keymap[i] = DB_KEY_LSUPER;
	    break;
	case 127:
	    keymap[i] = DB_KEY_MENU;
	    break;
#endif
	/* this should take care of all standard ascii keys */
	default:
	    keymap[i] = KVAL(vga_keymap[0][i]);
	    break;
        }
    }
    for (i=0; i < SCANCODE_TABLESIZE(keymap); ++i) {
	switch(keymap_temp[i]) {
	case K_F1:  	keymap[i] = DB_KEY_F1;  break;
	case K_F2:  	keymap[i] = DB_KEY_F2;  break;
	case K_F3:  	keymap[i] = DB_KEY_F3;  break;
	case K_F4:  	keymap[i] = DB_KEY_F4;  break;
	case K_F5:  	keymap[i] = DB_KEY_F5;  break;
	case K_F6:  	keymap[i] = DB_KEY_F6;  break;
	case K_F7:  	keymap[i] = DB_KEY_F7;  break;
	case K_F8:  	keymap[i] = DB_KEY_F8;  break;
	case K_F9:  	keymap[i] = DB_KEY_F9;  break;
	case K_F10: 	keymap[i] = DB_KEY_F10; break;
	case K_F11: 	keymap[i] = DB_KEY_F11; break;
	case K_F12: 	keymap[i] = DB_KEY_F12; break;

	case K_DOWN:  	keymap[i] = DB_KEY_DOWN;  break;
	case K_LEFT:  	keymap[i] = DB_KEY_LEFT;  break;
	case K_RIGHT: 	keymap[i] = DB_KEY_RIGHT; break;
	case K_UP:    	keymap[i] = DB_KEY_UP;    break;

	case K_P0:     	keymap[i] = DB_KEY_KP0; break;
	case K_P1:     	keymap[i] = DB_KEY_KP1; break;
	case K_P2:     	keymap[i] = DB_KEY_KP2; break;
	case K_P3:     	keymap[i] = DB_KEY_KP3; break;
	case K_P4:     	keymap[i] = DB_KEY_KP4; break;
	case K_P5:     	keymap[i] = DB_KEY_KP5; break;
	case K_P6:     	keymap[i] = DB_KEY_KP6; break;
	case K_P7:     	keymap[i] = DB_KEY_KP7; break;
	case K_P8:     	keymap[i] = DB_KEY_KP8; break;
	case K_P9:     	keymap[i] = DB_KEY_KP9; break;
	case K_PPLUS:  	keymap[i] = DB_KEY_KP_PLUS; break;
	case K_PMINUS: 	keymap[i] = DB_KEY_KP_MINUS; break;
	case K_PSTAR:  	keymap[i] = DB_KEY_KP_MULTIPLY; break;
	case K_PSLASH: 	keymap[i] = DB_KEY_KP_DIVIDE; break;
	case K_PENTER: 	keymap[i] = DB_KEY_KP_ENTER; break;
	case K_PDOT:   	keymap[i] = DB_KEY_KP_PERIOD; break;

	case K_SHIFT:	if ( keymap[i] != DB_KEY_RSHIFT )
	            	    keymap[i] = DB_KEY_LSHIFT;
	        	break;
	case K_SHIFTL: 	keymap[i] = DB_KEY_LSHIFT; break;
	case K_SHIFTR: 	keymap[i] = DB_KEY_RSHIFT; break;
	case K_CTRL:  	if (keymap[i] != DB_KEY_RCTRL )
	                    keymap[i] = DB_KEY_LCTRL;
	        	break;
	case K_CTRLL:  	keymap[i] = DB_KEY_LCTRL;  break;
	case K_CTRLR:  	keymap[i] = DB_KEY_RCTRL;  break;
	case K_ALT:    	keymap[i] = DB_KEY_LALT;   break;
	case K_ALTGR:  	keymap[i] = DB_KEY_RALT;   break;

	case K_INSERT: 	keymap[i] = DB_KEY_INSERT;   break;
	case K_REMOVE: 	keymap[i] = DB_KEY_DELETE;   break;
	case K_PGUP:   	keymap[i] = DB_KEY_PAGEUP;   break;
	case K_PGDN:   	keymap[i] = DB_KEY_PAGEDOWN; break;
	case K_FIND:   	keymap[i] = DB_KEY_HOME;     break;
	case K_SELECT: 	keymap[i] = DB_KEY_END;      break;

	case K_NUM:  	keymap[i] = DB_KEY_NUMLOCK;   break;
	case K_CAPS: 	keymap[i] = DB_KEY_CAPSLOCK;  break;

	case K_F13:   	keymap[i] = DB_KEY_PRINT;     break;
	case K_HOLD:  	keymap[i] = DB_KEY_SCROLLOCK; break;
	case K_PAUSE: 	keymap[i] = DB_KEY_PAUSE;     break;

	case 127: 	keymap[i] = DB_KEY_BACKSPACE; break;
	     
	default: break;
	}
    }
}

static int keyboard_on(void)
{
    if ((consoledevice = getenv ("DANCEBOARD_CONSOLEDEVICE")) == NULL)
	consoledevice = defaultconsoledevice;

    if (strcmp (consoledevice, "none") != 0) {
	struct vt_stat	vts;
	char 		vtname[128];
	struct termios	nTty;
	unsigned char   buf[256];
	int		n, nr;
	int 		fd;

	sprintf (vtname,"%s%d", consoledevice, 1);

        fd = open (vtname, O_WRONLY);
        if (fd < 0) {
    	    perror("open consoledevice");
    	    return 1;
        }

	if (ioctl(fd, VT_OPENQRY, &nr) < 0) {
    	    perror("ioctl VT_OPENQRY");
    	    return 1;
        }
        close(fd);

        sprintf(vtname, "%s%d", consoledevice, nr);

        con_fd = open(vtname, O_RDWR | O_NDELAY);
        if (con_fd < 0) {
    	    perror("open tty");
    	    return 1;
        }

	keyboard_vgainitkeymaps(con_fd);

        if (ioctl(con_fd, VT_GETSTATE, &vts) == 0)
        last_vt = vts.v_active;

        if (ioctl(con_fd, VT_ACTIVATE, nr) < 0) {
    	    perror("VT_ACTIVATE");
    	    close(con_fd);
    	    return 1;
        }

        if (ioctl(con_fd, VT_WAITACTIVE, nr) < 0) {
    	    perror("VT_WAITACTIVE");
    	    close(con_fd);
    	    return 1;
        }

        if (ioctl(con_fd, KDSETMODE, KD_GRAPHICS) < 0) {
    	    perror("KDSETMODE");
    	    close(con_fd);
    	    return 1;
        }

	ioctl(con_fd, KDGKBMODE, &LinuxKbdTrans);
	tcgetattr(con_fd, &LinuxTermios);
    
	ioctl(con_fd, KDSKBMODE, K_MEDIUMRAW);
	nTty = LinuxTermios;
	nTty.c_iflag = (IGNPAR | IGNBRK) & (~PARMRK) & (~ISTRIP);
	nTty.c_oflag = 0;
	nTty.c_cflag = CREAD | CS8;
	nTty.c_lflag = 0;
	nTty.c_cc[VTIME]=0;
	nTty.c_cc[VMIN]=1;
	cfsetispeed(&nTty, 9600);
	cfsetospeed(&nTty, 9600);
	tcsetattr(con_fd, TCSANOW, &nTty);
	/*
	 * Flush any pending keystrokes
	 */
	while ((n = read (con_fd, buf, sizeof (buf))) > 0) ;
    }

    keyboard_InitOSKeymap();
    
    cnt_cur = cnt_all = 0;

    return 0;
}

static int keyboard_off(void)
{
    if (con_fd < 0)
	return 0;

    if(strcmp(consoledevice,"none")!=0) {	
	ioctl(con_fd, KDSKBMODE, LinuxKbdTrans);
	tcsetattr(con_fd, TCSANOW, &LinuxTermios);

	if (ioctl(con_fd, KDSETMODE, KD_TEXT) < 0)
    	    perror("KDSETMODE");

	if (last_vt >= 0)
    	    if (ioctl(con_fd, VT_ACTIVATE, last_vt))
        	perror("VT_ACTIVATE");
	close(con_fd);
	con_fd = -1;
    }

    return 0;
}

static int keyboard_read(unsigned int *scancode, unsigned int *keycode)
{
    if (cnt_cur != cnt_all) {
	*scancode = buf[cnt_cur++];
	*keycode = keymap[*scancode & 0x7F];
	return 1;
    } else {
	cnt_cur = 0;
	if ((cnt_all = read (con_fd, buf, sizeof (buf))) > 0) {
	    *scancode = buf[cnt_cur++];
	    *keycode = keymap[*scancode & 0x7F];
	    return 1;
	} else cnt_all = 0;
    }
    
    return 0;
}

static int update_screen_from_image(db_image *desk)
{
    int width = (desk->width < display_width)?desk->width:display_width;
    int height = (desk->height < display_height)?desk->height:display_height;
    if (display_depth >= 24) {
	u_int32_t *src = (u_int32_t *) desk->buf;
	u_int32_t *dst = (u_int32_t *) display_buffer;
	int x, y;
	for (y = 0; y < height; y++) {
	    for (x = 0; x < width; x++) {
		unsigned int r, g, b;
		unsigned char *p = (unsigned char *) &src[x];
		r = *p++ << 16;
		g = *p++ << 8;
		b = *p++;
		dst[x] = r | g | b;
	    }
	    src += desk->width;
	    //dst = (u_int32_t *) ((char *) dst + display_pitch);
	    dst += (display_pitch / 4);
	}
    } else if (display_depth >= 15) {
	u_int32_t *src = (u_int32_t *) desk->buf;
	u_int16_t *dst = (u_int16_t *) display_buffer;
	int x, y;
	for (y = 0; y < height; y++) {
	    for (x = 0; x < width; x++) {
		int r, g, b;
		r = (src[x] & 0xf80000) >> 8;
		g = (src[x] & 0x00fa00) >> 5;
		b = (src[x] & 0x0000f8) >> 3;
		dst[x] = r | g | b;
	    }
	    src += desk->width;
	    dst += (display_pitch / 2);
	}
    } else {
	fprintf (stderr, "unable to build image an image on a display with < 15 bpp\n");
	return 1;
    }

    return 0;
}

int db_ui_create(void)
{
    if (framebuffer_on())
	return 1;
    if (keyboard_on())
	return 1;

    screen_image = db_image_create(display_width, display_height, 0);

    return 0;
}

db_image *db_ui_get_screen(void)
{
    return screen_image;
}

int db_ui_update_screen(void)
{
    update_screen_from_image(screen_image);
    
    return 0;
}

int db_ui_check_events(db_ui_event *event)
{
    unsigned int scan, key;
    event->type = DB_EVENT_NONE;

    if (keyboard_read(&scan, &key)) {
	event->type = (scan & 0x80)?DB_EVENT_KEYRELEASE:DB_EVENT_KEYPRESS;
	event->key.keycode = scan;
	event->key.key = key;
    }

    return event->type;
}

void db_ui_close(void)
{
    db_image_free(screen_image);

    keyboard_off();
    framebuffer_off();
}
