## Process this file with automake to produce Makefile.in

bin_PROGRAMS = minidesk-netconfig

minidesk_netconfigdir = $(datadir)/minidesk/netconfig

INCLUDES = \
	-I$(top_srcdir) \
	-DPACKAGE_BIN_DIR=\""$(bindir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(PACKAGE_CFLAGS) \
	$(G_CAST_CHECKS) \
	-DRESDIR=\""$(minidesk_netconfigdir)"\"

minidesk_netconfig_SOURCES = \
	netconfig.c

minidesk_netconfig_LDADD = \
		$(LIBS) \
		$(PACKAGE_LIBS) \
		$(INTLLIBS)

minidesk_netconfig_DATA = \
		netconfig.ui

#ui_DATA = $(ui_in_files:.glade=.ui)

%.ui: %.glade
	gtk-builder-convert $< $@

minidesk_netconfig_desktop_DATA = minidesk-netconfig.desktop

minidesk_netconfig_desktopdir = $(datadir)/applications

EXTRA_DIST = \
	$(minidesk_netconfig_desktop_DATA)

CLEANFILES = \
        $(minidesk_netconfig_DATA)
