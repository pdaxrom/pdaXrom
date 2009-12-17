## Process this file with automake to produce Makefile.in

bin_PROGRAMS = netconfig

netconfigdir = $(datadir)/netconfig

INCLUDES = \
	-I$(top_srcdir) \
	-DPACKAGE_BIN_DIR=\""$(bindir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(PACKAGE_CFLAGS) \
	$(G_CAST_CHECKS) \
	-DRESDIR=\""$(netconfigdir)"\"

netconfig_SOURCES = \
	netconfig.c

netconfig_LDADD = \
		$(LIBS) \
		$(PACKAGE_LIBS) \
		$(INTLLIBS)

netconfig_DATA = \
		netconfig.ui

#ui_DATA = $(ui_in_files:.glade=.ui)

%.ui: %.glade
	gtk-builder-convert $< $@

netconfig_desktop_DATA = netconfig.desktop

netconfig_desktopdir = $(datadir)/applications

EXTRA_DIST = \
	$(netconfig_desktop_DATA)

CLEANFILES = \
        $(netconfig_DATA)
