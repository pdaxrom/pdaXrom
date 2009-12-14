/*
 * Copyright (C) 2002 Red Hat, Inc.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Copyright (C) 2009 Alexander Chukov <sash@pdaXrom.org>
 * Change cursor state
 *
 */

#include <X11/X.h>
#include <X11/Xcursor/Xcursor.h>
#include <X11/cursorfont.h>
#define SN_API_NOT_YET_FROZEN
#include <libsn/sn.h>

Display *xdisplay;

Cursor cursor_busy;
Cursor cursor_normal;

static Cursor load_cursor(const char *name, int fontval)
{
    Cursor c = None;

    c = XcursorLibraryLoadCursor(xdisplay, name);
    if (c == None)
        c = XCreateFontCursor(xdisplay, fontval);
    return c;
}

static void screen_set_root_cursor(int f)
{
    if (f)
        XDefineCursor(xdisplay, DefaultRootWindow(xdisplay), cursor_busy);
    else
        XDefineCursor(xdisplay, DefaultRootWindow(xdisplay), cursor_normal);
}

static void monitor_event_func (SnMonitorEvent *event, void *user_data)
{
    SnMonitorContext *context;
    SnStartupSequence *sequence;

    context = sn_monitor_event_get_context (event);
    sequence = sn_monitor_event_get_startup_sequence (event);

    switch (sn_monitor_event_get_type (event)) {
    case SN_MONITOR_EVENT_INITIATED:
    case SN_MONITOR_EVENT_CHANGED: {
#if 0
        const char *s;
        if (sn_monitor_event_get_type (event) == SN_MONITOR_EVENT_INITIATED) {
            printf ("Initiated sequence %s\n", sn_startup_sequence_get_id (sequence));
        } else {
            printf ("Changed sequence %s\n", sn_startup_sequence_get_id (sequence));
        }

        s = sn_startup_sequence_get_id (sequence);
        printf (" id %s\n", s ? s : "(unset)");

        s = sn_startup_sequence_get_name (sequence);
        printf (" name %s\n", s ? s : "(unset)");

        s = sn_startup_sequence_get_description (sequence);
        printf (" description %s\n", s ? s : "(unset)");

        printf (" workspace %d\n", sn_startup_sequence_get_workspace (sequence));

        s = sn_startup_sequence_get_binary_name (sequence);
        printf (" binary name %s\n", s ? s : "(unset)");
        s = sn_startup_sequence_get_icon_name (sequence);
        printf (" icon name %s\n", s ? s : "(unset)");

        s = sn_startup_sequence_get_wmclass (sequence);
        printf (" wm class %s\n", s ? s : "(unset)");
#endif
	screen_set_root_cursor(1);
        }
        break;

    case SN_MONITOR_EVENT_COMPLETED:
        printf ("Completed sequence %s\n", sn_startup_sequence_get_id (sequence));
	screen_set_root_cursor(0);
        break;

    case SN_MONITOR_EVENT_CANCELED:
        printf ("Canceled sequence %s\n", sn_startup_sequence_get_id (sequence));
	screen_set_root_cursor(0);
        break;
    }
}

int
main (int argc, char **argv)
{
    SnDisplay *display;
    SnMonitorContext *context;

    xdisplay = XOpenDisplay (NULL);
    if (xdisplay == NULL) {
	fprintf (stderr, "Could not open display\n");
	return 1;
    }

    if (getenv ("LIBSN_SYNC"))
	XSynchronize (xdisplay, True);

    //XSetErrorHandler (x_error_handler);

    cursor_busy = load_cursor("watch", XC_left_ptr);
    cursor_normal = load_cursor("left_ptr", XC_left_ptr);

    /* We have to select for property events on at least one
     * root window (but not all as INITIATE messages go to
     * all root windows)
     */
    XSelectInput (xdisplay, DefaultRootWindow (xdisplay), PropertyChangeMask);

    display = sn_display_new (xdisplay, NULL, NULL);

    context = sn_monitor_context_new (display, DefaultScreen (xdisplay), monitor_event_func, NULL, NULL);

    while (1) {
        XEvent xevent;

        XNextEvent (xdisplay, &xevent);

        sn_display_process_event (display, &xevent);
    }

    sn_monitor_context_unref (context);

    return 0;
}
