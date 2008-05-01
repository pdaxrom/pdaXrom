/* 
 * Copyright (C) 2008 Alexander Chukov <sash@pdaXrom.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include "msp430lib.h"
#include "uinputdev.h"

#include "keymap.h"

static int done;

void catch_int(int sig_num) {
    done = 1;
//    fprintf(stderr, "Terminating...\n");
}

struct rc_event *get_rc_event(int key)
{
    struct rc_event *tmp = rc_events;

    while (tmp->scan) {
	if (key == tmp->scan)
	    return tmp;
	tmp++;
    }
    
    return NULL;
}

int main(int argc, char *argv[])
{
#if 0
    int ret = daemon(1, 1);

    if (ret) {
        perror("daemonization failed");
        return 1;
    }
#endif

    if (msp430lib_init() == MSP430LIB_SUCCESS) {
	struct conf conf;

	memset(&conf.dev, 0, sizeof(conf.dev));   // Intialize the uInput device to NULL
	strncpy(conf.dev.name, "Elecard iTelec STB-610 Remote Control", UINPUT_MAX_NAME_SIZE);
	conf.dev.id.version = 1;
	conf.dev.id.bustype = BUS_USB;

	if (!uinput_open(&conf)) {
	    int k;
	    int old_k = 0xdead;
	    
	    done = 0;

//	    uinput_send(&conf, EV_REL, REL_Y, -100);
//	    uinput_send(&conf, EV_SYN, SYN_REPORT, 0);

	    signal(SIGINT,   catch_int);
	    signal(SIGTERM,  catch_int);

	    while (!done) {
		if (msp430lib_get_ir_key(&k, MSP430LIB_WITHOUT_TOGGLE) == MSP430LIB_SUCCESS) {
		    struct rc_event *ev = get_rc_event(k);
//		    if (k)
//			fprintf(stderr, "key = %4x\n", k);
		    if (ev) {
//			fprintf(stderr, "mode = %d, t=%d, c=%d, v=%d\n", ev->mode, ev->type, ev->code, ev->value);
			
			switch (ev->mode) {
			    case MODE_MOUSE:
				uinput_send(&conf, ev->type, ev->code, ev->value);
				uinput_send(&conf, EV_SYN, SYN_REPORT, 0);
				break;
			    case MODE_KEYBOARD:
				uinput_send(&conf, ev->type, ev->code, 1);
				uinput_send(&conf, EV_SYN, SYN_REPORT, 0);
				usleep(1000);
				uinput_send(&conf, ev->type, ev->code, 0);
				uinput_send(&conf, EV_SYN, SYN_REPORT, 0);
				break;
			}
		    }
		}
		usleep(100000);
	    }
	
	    uinput_close(&conf);
	}
	msp430lib_exit();
    }
    return 0;
}
