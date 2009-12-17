## Process this file with automake to produce Makefile.in

bin_PROGRAMS = minidesk-logout

INCLUDES = \
	-I$(top_srcdir) \
	-DPACKAGE_BIN_DIR=\""$(bindir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(PACKAGE_CFLAGS) \
	$(HAL_CFLAGS) \
	$(G_CAST_CHECKS)

minidesk_logout_SOURCES = \
	logout.c

minidesk_logout_LDADD = \
		$(LIBS) \
		$(PACKAGE_LIBS) \
		$(HAL_LIBS) \
		$(INTLLIBS)

imagedir=$(datadir)/pixmaps/minidesk-logout

image_DATA= \
	images/gnome-session-halt.png \
	images/gnome-session-hibernate.png \
	images/gnome-session-logout.png \
	images/gnome-session-reboot.png \
	images/gnome-session-suspend.png \
	images/gnome-session-switch.png

minidesk_logout_desktop_DATA = minidesk-logout.desktop

minidesk_logout_desktopdir = $(datadir)/applications

EXTRA_DIST = \
	$(minidesk_logout_desktop_DATA) \
	$(image_DATA)
