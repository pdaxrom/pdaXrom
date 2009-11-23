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

#include <gtk/gtk.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <malloc.h>

#ifndef RESDIR
#define RESDIR "."
#endif

#define IFACE_CONFIG	"/etc/network/interfaces"
//#define IFACE_CONFIG	"interfaces"

typedef struct _Iface Iface;
struct _Iface {
    int	dhcp;
    int wifi;
    char *ip;
    char *mask;
    char *gw;
    char *mode;
    char *essid;
    char *key;
};

typedef struct _Data Data;
struct _Data {
    GtkWidget	*iface_name;
    GtkWidget	*iface_dhcp;
    GtkWidget	*iface_ip;
    GtkWidget	*iface_mask;
    GtkWidget	*iface_gw;
    GtkWidget	*iface_wifi_mode;
    GtkWidget	*iface_wifi_essid;
    GtkWidget	*iface_wifi_key;
    GtkWidget	*wifi_table;
    Iface	iface;

    GtkWidget	*iface_hostname;
    GtkWidget	*iface_lan;
    GtkWidget	*iface_dns;
    GtkWidget	*iface_dns1;
};

static void dhcp_ip_fields(Data *data, gboolean active);

static int read_net_devices(Data *data)
{
    char buf[256];

    gtk_combo_box_remove_text(GTK_COMBO_BOX(data->iface_name), 0);

    FILE *f = fopen("/proc/net/dev", "rb");
    if (!f)
	return 0;

    fgets(buf, 255, f);
    fgets(buf, 255, f);

    while(fgets(buf, 255, f)) {
	char *ptr = buf;
	while(isspace(*ptr))
	    ptr++;
	char *ptr1 = strchr(ptr, ':');
	if (ptr1)
	    *ptr1 = 0;
	
	fprintf(stderr, "-- %s\n", ptr);
	if (!(!strncmp(ptr, "lo", 2) ||
	    !strncmp(ptr, "ppp", 3))) {
	    gtk_combo_box_append_text(GTK_COMBO_BOX(data->iface_name), ptr);
	}
    }
    fclose(f);

    gtk_combo_box_set_active(GTK_COMBO_BOX(data->iface_name), 0);

    return 0;
}

static int is_wireless(char *name)
{
    char buf[256];

    FILE *f = fopen("/proc/net/wireless", "rb");
    if (!f)
	return 0;

    fgets(buf, 255, f);
    fgets(buf, 255, f);

    while(fgets(buf, 255, f)) {
	char *ptr = buf;
	while(isspace(*ptr))
	    ptr++;
	char *ptr1 = strchr(ptr, ':');
	if (ptr1)
	    *ptr1 = 0;
	if (!strcmp(ptr, name)) {
	    fclose(f);
	    return 1;
	}
    }
    fclose(f);
    return 0;
}

static void write_iface_config(char *name, Iface *iface)
{
    char buf[256];
    char *v[4];
    int found = 0;

    FILE *f_tmp = fopen(IFACE_CONFIG ".tmp", "wb");
    if (!f_tmp)
	return;

    FILE *f = fopen(IFACE_CONFIG, "rb");
    if (f) {
	while (fgets(buf, 256, f)) {
	    int i;
	    char str[256];
	    char *tmp = strchr(buf, '\n');
	    if (tmp)
		*tmp = 0;
	    strcpy(str, buf);
	    for (i = 0; i < 4; i++)
		v[i] = strtok(i?NULL:buf, " ");
	    fprintf(stderr, "[%s] [%s] [%s] [%s]\n", v[0], v[1], v[2], v[3]);
	    if (found) {
		if (!v[0])
		    found = 0;
		v[0] = NULL;
		continue;
	    }
	    if (!v[0]) {
		fprintf(f_tmp, "\n");
		continue;
	    }
	    if ((!strcmp(v[0], "auto")) &&
		(!strcmp(v[1], name)))
		continue;
	    if ((!strcmp(v[0], "iface")) &&
		(!strcmp(v[1], name))) {
	        found = 1;
		continue;
	    }
	    fprintf(f_tmp, "%s\n", str);
	}
	if (v[0])
	    fprintf(f_tmp, "\n");
	fclose(f);
    }
    fprintf(f_tmp, "auto %s\n", name);
    if (iface->dhcp) {
	fprintf(f_tmp, "iface %s inet dhcp\n", name);
    } else {
	fprintf(f_tmp, "iface %s inet static\n", name);
	if (strlen(iface->ip))
	    fprintf(f_tmp, "address %s\n", iface->ip);
	if (strlen(iface->mask))
	    fprintf(f_tmp, "netmask %s\n", iface->mask);
	if (strlen(iface->gw))
	    fprintf(f_tmp, "gateway %s\n", iface->gw);
    }
    if (iface->wifi) {
	if (iface->mode)
	    fprintf(f_tmp, "wireless-mode %s\n", iface->mode);
	if (strlen(iface->essid))
	    fprintf(f_tmp, "wireless-essid %s\n", iface->essid);
	if (strlen(iface->key))
	    fprintf(f_tmp, "wireless-key %s\n", iface->key);
    }
    fclose(f_tmp);
    rename(IFACE_CONFIG ".tmp", IFACE_CONFIG);
}

static void read_iface_config(char *name, Iface *iface)
{
    char buf[256];
    char *v[4];
    int found = 0;

    iface->dhcp = 0;
    iface->ip = NULL;
    iface->mask = NULL;
    iface->gw = NULL;
    iface->mode = NULL;
    iface->essid = NULL;
    iface->key = NULL;

    FILE *f = fopen(IFACE_CONFIG, "rb");
    if (!f)
	return;

    while(fgets(buf, 256, f)) {
	int i;
	char *tmp = strchr(buf, '\n');
	if (tmp)
	    *tmp = 0;
	for (i = 0; i < 4; i++)
	    v[i] = strtok(i?NULL:buf, " ");
	fprintf(stderr, "[%s] [%s] [%s] [%s]\n", v[0], v[1], v[2], v[3]);
	if (found) {
	    if (!v[0])
		break;
	    if (!strcmp(v[0], "address"))
		iface->ip = strdup(v[1]);
	    else if (!strcmp(v[0], "netmask"))
		iface->mask = strdup(v[1]);
	    else if (!strcmp(v[0], "gateway"))
		iface->gw = strdup(v[1]);
	    else if (!strcmp(v[0], "wireless-mode"))
		iface->mode = strdup(v[1]);
	    else if (!strcmp(v[0], "wireless-essid"))
		iface->essid = strdup(v[1]);
	    else if (!strcmp(v[0], "wireless-key"))
		iface->key = strdup(v[1]);
	    continue;
	}
	if (!v[0])
	    continue;
	if ((!strcmp(v[0], "iface")) &&
	    (!strcmp(v[1], name))) {
	    found = 1;
	    if (!strcmp(v[3], "dhcp"))
		iface->dhcp = 1;
	}
    }

    fclose(f);
}

static void free_iface_config(Iface *i)
{
    if (i->ip)
	free(i->ip);
    if (i->mask)
	free(i->mask);
    if (i->gw)
	free(i->gw);
    if (i->mode)
	free(i->mode);
    if (i->essid)
	free(i->essid);
    if (i->key)
	free(i->key);
    i->ip = NULL;
    i->mask = NULL;
    i->gw = NULL;
    i->mode = NULL;
    i->essid = NULL;
    i->key = NULL;
}

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

void update_iface_fields(GtkWidget *widget, Data *data)
{
    char *iface_name = gtk_combo_box_get_active_text(GTK_COMBO_BOX(data->iface_name));
    fprintf(stderr, "re %s\n", iface_name);
    if (iface_name) {
	free_iface_config(&data->iface);
	read_iface_config(iface_name, &data->iface);
	if (data->iface.dhcp) {
	    dhcp_ip_fields(data, 1);
	    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(data->iface_dhcp), 1);
	} else {
	    dhcp_ip_fields(data, 0);
	    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(data->iface_dhcp), 0);
	}
	gtk_entry_set_text(GTK_ENTRY(data->iface_ip), data->iface.ip?data->iface.ip:"");
	gtk_entry_set_text(GTK_ENTRY(data->iface_mask), data->iface.mask?data->iface.mask:"");
	gtk_entry_set_text(GTK_ENTRY(data->iface_gw), data->iface.gw?data->iface.gw:"");
	
	if (is_wireless(iface_name)) {
	    gtk_entry_set_text(GTK_ENTRY(data->iface_wifi_essid), data->iface.essid?data->iface.essid:"");
	    gtk_entry_set_text(GTK_ENTRY(data->iface_wifi_key), data->iface.key?data->iface.key:"");
	    gtk_widget_show_all(GTK_WIDGET(data->wifi_table));
	    data->iface.wifi = 1;
	} else {
	    gtk_widget_hide_all(GTK_WIDGET(data->wifi_table));
	    data->iface.wifi = 0;
	}
	free(iface_name);
    }
    read_dns(data);
}

static void dhcp_ip_fields(Data *data, gboolean active)
{
    gtk_widget_set_sensitive(data->iface_ip, !active);
    gtk_widget_set_sensitive(data->iface_mask, !active);
    gtk_widget_set_sensitive(data->iface_gw, !active);
    gtk_widget_set_sensitive(data->iface_lan, !active);
    gtk_widget_set_sensitive(data->iface_dns, !active);
    gtk_widget_set_sensitive(data->iface_dns1, !active);
    if (!active)
	gtk_entry_set_text(GTK_ENTRY(data->iface_mask), "255.255.255.0");
}

void apply_iface(GtkWidget *widget, Data *data)
{
    free_iface_config(&data->iface);
    if (!data->iface.dhcp) {
	data->iface.ip = strdup(gtk_entry_get_text(GTK_ENTRY(data->iface_ip)));
	data->iface.mask = strdup(gtk_entry_get_text(GTK_ENTRY(data->iface_mask)));
	data->iface.gw = strdup(gtk_entry_get_text(GTK_ENTRY(data->iface_gw)));
    }
    if (data->iface.wifi) {
	data->iface.mode = gtk_combo_box_get_active_text(GTK_COMBO_BOX(data->iface_wifi_mode));
	data->iface.essid = strdup(gtk_entry_get_text(GTK_ENTRY(data->iface_wifi_essid)));
	data->iface.key = strdup(gtk_entry_get_text(GTK_ENTRY(data->iface_wifi_key)));
    }

    char *iface_name = gtk_combo_box_get_active_text(GTK_COMBO_BOX(data->iface_name));
    fprintf(stderr, "apply %s\n", iface_name);
    if (iface_name) {
	write_iface_config(iface_name, &data->iface);
	free(iface_name);
	write_dns(data);
	char buf[256];
	snprintf(buf, 256, "ifdown %s", iface_name);
	system(buf);
	snprintf(buf, 256, "ifup %s", iface_name);
	system(buf);
    }
}

void close_app(GtkWidget *widget, Data *data)
{
    gtk_main_quit();
}

void dhcp_toggled(GtkToggleButton *button, Data *data)
{
    gboolean active = gtk_toggle_button_get_active(button);

    dhcp_ip_fields(data, active);

    data->iface.dhcp = active?1:0;
}

int main (int argc, char **argv)
{
    GtkBuilder *gtkBuilder;
    GtkWidget *mainwin;
    Data data;

    memset(&data.iface, 0, sizeof(Iface));

    gtk_set_locale();

    /* Initialize the widget set */
    gtk_init (&argc, &argv);

    /* Create the main window */
    gtkBuilder= gtk_builder_new();
    gtk_builder_add_from_file(gtkBuilder,RESDIR "/netconfig.ui",NULL);

    mainwin= GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"window1"));

    data.iface_name = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_name"));
    data.iface_dhcp = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_dhcp"));
    data.iface_ip = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_ip"));
    data.iface_mask = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_mask"));
    data.iface_gw = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_gw"));
    data.iface_wifi_mode = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_wifi_mode"));
    data.iface_wifi_essid = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_wifi_essid"));
    data.iface_wifi_key = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_wifi_key"));
    data.wifi_table = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"wifi_table"));

    data.iface_hostname = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_hostname"));
    data.iface_lan = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_lan"));
    data.iface_dns = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_dns"));
    data.iface_dns1 = GTK_WIDGET(gtk_builder_get_object(gtkBuilder,"iface_dns1"));

    gtk_builder_connect_signals(gtkBuilder, &data);

    g_object_unref(G_OBJECT(gtkBuilder));

    read_net_devices(&data);

    /* Show the application window */
    gtk_widget_show(mainwin);

    /* Enter the main event loop, and wait for user interaction */
    gtk_main();

    /* The user lost interest */
    return 0;
}
