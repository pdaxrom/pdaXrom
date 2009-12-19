## Process this file with automake to produce Makefile.in

bin_PROGRAMS = minidesk-pppconfig

minidesk_pppconfigdir = $(datadir)/minidesk/pppconfig

INCLUDES = \
	-I$(top_srcdir) \
	-DPACKAGE_BIN_DIR=\""$(bindir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(PACKAGE_CFLAGS) \
	$(G_CAST_CHECKS) \
	-DRESDIR=\""$(minidesk_pppconfigdir)"\"

minidesk_pppconfig_SOURCES = \
	pppconfig.c

minidesk_pppconfig_LDADD = \
		$(LIBS) \
		$(PACKAGE_LIBS) \
		$(INTLLIBS)

minidesk_pppconfig_DATA = \
		pppconfig.ui

#ui_DATA = $(ui_in_files:.glade=.ui)

%.ui: %.glade
	gtk-builder-convert $< $@

minidesk_pppconfig_desktop_DATA = minidesk-pppconfig.desktop

minidesk_pppconfig_desktopdir = $(datadir)/applications

EXTRA_DIST = \
	$(minidesk_pppconfig_desktop_DATA)

CLEANFILES = \
        $(minidesk_pppconfig_DATA)
