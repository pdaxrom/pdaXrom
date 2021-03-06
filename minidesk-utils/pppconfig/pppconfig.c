/* 
 * Copyright (C) 2009 Alexander Chukov <sash@pdaXrom.org>
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

#include <config.h>
#include <gtk/gtk.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <malloc.h>

#ifndef RESDIR
#define RESDIR "."
#endif

//#define PPP_DIR "ppp"

#ifndef PPP_DIR
#define PPP_DIR "/etc/ppp"
#endif

typedef struct _Data Data;
struct _Data {
    GtkWidget	*entry_type;
    GtkWidget	*entry_phone;
    GtkWidget	*entry_login;
    GtkWidget	*entry_passwd;
    GtkWidget	*entry_device;
    GtkWidget	*entry_speed;
    GtkWidget	*entry_ap;
    GtkWidget	*entry_cmdline;
    gint	type;
};

#if 0
static void read_dns(Data *data)
{
    FILE *f = fopen("/etc/hostname", "rb");
    if (f) {
	char buf[256];
	if (fgets(buf, 256, f)) {
	    char *tmp = strchr(buf, '\n');
	    if (tmp)
		*tmp = 0;
	    gtk_entry_set_text(GTK_ENTRY(data->iface_hostname), buf);
	}
	fclose(f);
    }

    f = fopen("/etc/resolv.conf", "rb");
    if (f) {
	char buf[256];
	char *v[2];
	int ns = 0;
	while (fgets(buf, 256, f)) {
	    char *tmp = strchr(buf, '\n');
	    if (tmp)
		*tmp = 0;
	    v[0] = strtok(buf, " ");
	    v[1] = strtok(NULL, " ");
	    if (!strcmp(v[0], "search")) {
		gtk_entry_set_text(GTK_ENTRY(data->iface_lan), v[1]);
	    } else if (!strcmp(v[0], "nameserver")) {
		if (!ns)
		    gtk_entry_set_text(GTK_ENTRY(data->iface_dns), v[1]);
		else
		    gtk_entry_set_text(GTK_ENTRY(data->iface_dns1), v[1]);
		ns++;
	    }
	}
	fclose(f);
    }
}

static void write_dns(Data *data)
{
    FILE *f = fopen("/etc/hostname", "wb");
    if (f) {
	fprintf(f, "%s\n", gtk_entry_get_text(GTK_ENTRY(data->iface_hostname)));
	fclose(f);
    }
    if (!data->iface.dhcp) {
	f = fopen("/etc/resolv.conf", "wb");
	if (f) {
	    const gchar *str = gtk_entry_get_text(GTK_ENTRY(data->iface_lan));
	    if (strlen(str)) {
		fprintf(f, "domain %s\n", str);
		fprintf(f, "search %s\n", str);
	    }
	    str = gtk_entry_get_text(GTK_ENTRY(data->iface_dns));
	    if (strlen(str))
		fprintf(f, "nameserver %s\n", str);
	    str = gtk_entry_get_text(GTK_ENTRY(data->iface_dns1));
	    if (strlen(str))
		fprintf(f, "nameserver %s\n", str);
	    fclose(f);
	}
    }
}
#endif

void update_secret(char *secret, char *login, char *passwd)
{
    FILE *inf = fopen(secret, "a+");
    if (inf) {
	char tmpname[256];
	char buf[256];
	sprintf(tmpname, "%s.tmp", secret);
	FILE *outf = fopen(tmpname, "wb");
	if (!outf) {
	    fclose(inf);
	    return;
	}
	while(fgets(buf, 256, inf)) {
	    if (!strncmp(buf, login, strlen(login)))
		continue;
	    fprintf(outf, "%s", buf);
	}
	fclose(inf);
	fprintf(outf, "%s * %s *\n", login, passwd);
	fclose(outf);
	rename(tmpname, secret);
    }
}

void apply_ppp(GtkWidget *widget, Data *data)
{
    FILE *outf = fopen(PPP_DIR "/peers/mobile", "wb");
    if (outf) {
	fprintf(outf, "%s\n", gtk_entry_get_text(GTK_ENTRY(data->entry_device)));
	fprintf(outf, "%s\n", gtk_combo_box_get_active_text(GTK_COMBO_BOX(data->entry_speed)));
	if (data->type)
	    fprintf(outf, "connect '/usr/sbin/chat -s -v \"\" \"at+crm=1;&C0\" OK ATDT%s CONNECT'\n",
		    gtk_entry_get_text(GTK_ENTRY(data->entry_phone)));
	else
	    fprintf(outf, "connect '/usr/sbin/chat -s -v ABORT \"NO CARRIER\" ABORT \"NO DIALTONE\" ABORT \"BUSY\" \"\" \"AT+CGDCONT=1,\\\\\\\"IP\\\\\\\",\\\\\\\"%s\\\\\\\"\" OK ATDT%s CONNECT'\n",
		    gtk_entry_get_text(GTK_ENTRY(data->entry_ap)), gtk_entry_get_text(GTK_ENTRY(data->entry_phone)));
	fprintf(outf, "crtscts\nnoipdefault\nmodem\nusepeerdns\ndefaultroute\nconnect-delay 6000\n"
		      "remotename pdaXrom-linux\nmaxfail 0\npersist\ndebug\nnodetach\nlogfile /tmp/ppp.txt\n");
	if (strlen(gtk_entry_get_text(GTK_ENTRY(data->entry_passwd))) == 0) {
	    if (strlen(gtk_entry_get_text(GTK_ENTRY(data->entry_login))) != 0) {
		fprintf(outf, "user %s\n", gtk_entry_get_text(GTK_ENTRY(data->entry_login)));
	    }
	    fprintf(outf, "noauth\n");
	} else {
	    fprintf(outf, "user %s\n", gtk_entry_get_text(GTK_ENTRY(data->entry_login)));
	    update_secret(PPP_DIR "/pap-secrets", (char *) gtk_entry_get_text(GTK_ENTRY(data->entry_login)), (char *) gtk_entry_get_text(GTK_ENTRY(data->entry_passwd)));
	    update_secret(PPP_DIR "/chap-secrets", (char *) gtk_entry_get_text(GTK_ENTRY(data->entry_login)), (char *) gtk_entry_get_text(GTK_ENTRY(data->entry_passwd)));
	}
	
	fclose(outf);
    } else {
	fprintf(stderr, "Can't write to " PPP_DIR "/peers/mobile\n");
    }
}

void update_conn_type(GtkWidget *widget, Data *data)
{
    data->type = gtk_combo_box_get_active(GTK_COMBO_BOX(data->entry_type));
    fprintf(stderr, "-- %d\n", data->type);
    gtk_entry_set_text(GTK_ENTRY(data->entry_phone), data->type?"#777":"*99#");
    if (data->type)
	gtk_widget_hide(data->entry_ap);
    else
	gtk_widget_show(data->entry_ap);
}

void close_app(GtkWidget *widget, Data *data)
{
    gtk_main_quit();
}

int main (int argc, char **argv)
{
    GtkBuilder *gtkBuilder;
    GtkWidget *mainwin;
    Data data;

    data.type = 0; // gprs

    gtk_set_locale();

    /* Initialize the widget set */
    gtk_init (&argc, &argv);

    /* Create the main window */
    gtkBuilder= gtk_builder_new();
    gtk_builder_add_from_file(gtkBuilder,RESDIR "/pppconfig.ui",NULL);

    mainwin= GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"dialog1"));

    data.entry_phone = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"entry_phone"));
    data.entry_login = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"entry_login"));
    data.entry_passwd = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"entry_passwd"));
    data.entry_device = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"entry_device"));
    data.entry_speed = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"combobox_speed"));
    data.entry_type = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"combobox_type"));
    data.entry_ap = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"entry_ap"));
    data.entry_cmdline = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"entry_cmdline"));

    gtk_builder_connect_signals(gtkBuilder, &data);

    g_object_unref(G_OBJECT(gtkBuilder));

    /* Show the application window */
    gtk_widget_show(mainwin);

    /* Enter the main event loop, and wait for user interaction */
    gtk_main();

    /* The user lost interest */
    return 0;
}
