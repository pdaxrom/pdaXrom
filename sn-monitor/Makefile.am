## Process this file with automake to produce Makefile.in

bin_PROGRAMS = sn-monitor

INCLUDES = \
	-I$(top_srcdir) \
	-DPACKAGE_BIN_DIR=\""$(bindir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(PACKAGE_CFLAGS) \
	$(G_CAST_CHECKS)

sn_monitor_SOURCES = \
	sn-monitor.c

sn_monitor_LDADD = \
		$(LIBS) \
		$(PACKAGE_LIBS) \
		$(INTLLIBS)
