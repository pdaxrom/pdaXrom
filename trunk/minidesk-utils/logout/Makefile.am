## Process this file with automake to produce Makefile.in

bin_PROGRAMS = minilogout

INCLUDES = \
	-I$(top_srcdir) \
	-DPACKAGE_BIN_DIR=\""$(bindir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(PACKAGE_CFLAGS) \
	$(HAL_CFLAGS) \
	$(G_CAST_CHECKS)

minilogout_SOURCES = \
	logout.c

minilogout_LDADD = \
		$(LIBS) \
		$(PACKAGE_LIBS) \
		$(HAL_LIBS) \
		$(INTLLIBS)

imagedir=$(datadir)/pixmaps/minilogout

image_DATA= \
	images/gnome-session-halt.png \
	images/gnome-session-hibernate.png \
	images/gnome-session-logout.png \
	images/gnome-session-reboot.png \
	images/gnome-session-suspend.png \
	images/gnome-session-switch.png

EXTRA_DIST = \
	$(image_DATA)
