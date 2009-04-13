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
 * gcc keyboard-tray.c -o keyboard-tray `pkg-config gtk+-2.0 --cflags --libs`
 *
 */

#include <gtk/gtk.h>
#include <stdio.h>

static pthread_t tid;

static int f_keyboard = 0;

static void keyboard_thread()
{
    f_keyboard = 1;
    system("matchbox-keyboard");
    f_keyboard = 0;
}

static void tray_menu(GtkWidget *widget, guint button, guint time, gpointer userdata)
{
    int retval;
    
    if (f_keyboard)
	system("killall matchbox-keyboard");
    else
	retval = pthread_create(&tid, NULL, (void *) &keyboard_thread, NULL);
}

int main(int argc, char *argv[])
{
    gtk_init (&argc, &argv);
    
    GtkStatusIcon *tray_icon = gtk_status_icon_new_from_icon_name("gnome-dev-keyboard");
    
    gtk_status_icon_set_visible(tray_icon, TRUE);
    
    g_signal_connect (G_OBJECT (tray_icon), "activate", G_CALLBACK (tray_menu), tray_icon);
    
    gtk_main();
    
    return 0;
}
