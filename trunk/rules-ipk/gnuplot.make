# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_GNUPLOT
PACKAGES += gnuplot
endif

#
# Paths and names
#
GNUPLOT_VENDOR_VERSION	= 1
GNUPLOT_VERSION		= 4.0.0
GNUPLOT			= gnuplot-$(GNUPLOT_VERSION)
GNUPLOT_SUFFIX		= tar.gz
GNUPLOT_URL		= http://citkit.dl.sourceforge.net/sourceforge/gnuplot/$(GNUPLOT).$(GNUPLOT_SUFFIX)
GNUPLOT_SOURCE		= $(SRCDIR)/$(GNUPLOT).$(GNUPLOT_SUFFIX)
GNUPLOT_DIR		= $(BUILDDIR)/$(GNUPLOT)
GNUPLOT_IPKG_TMP	= $(GNUPLOT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gnuplot_get: $(STATEDIR)/gnuplot.get

gnuplot_get_deps = $(GNUPLOT_SOURCE)

$(STATEDIR)/gnuplot.get: $(gnuplot_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GNUPLOT))
	touch $@

$(GNUPLOT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GNUPLOT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gnuplot_extract: $(STATEDIR)/gnuplot.extract

gnuplot_extract_deps = $(STATEDIR)/gnuplot.get

$(STATEDIR)/gnuplot.extract: $(gnuplot_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNUPLOT_DIR))
	@$(call extract, $(GNUPLOT_SOURCE))
	@$(call patchin, $(GNUPLOT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gnuplot_prepare: $(STATEDIR)/gnuplot.prepare

#
# dependencies
#
gnuplot_prepare_deps = \
	$(STATEDIR)/gnuplot.extract \
	$(STATEDIR)/virtual-xchain.install

GNUPLOT_PATH	=  PATH=$(CROSS_PATH)
GNUPLOT_ENV 	=  $(CROSS_ENV)
GNUPLOT_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
GNUPLOT_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
GNUPLOT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GNUPLOT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GNUPLOT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--with-readline=$(CROSS_LIB_DIR) \
	--libexecdir=/usr/lib

ifdef PTXCONF_XFREE430
GNUPLOT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GNUPLOT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gnuplot.prepare: $(gnuplot_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNUPLOT_DIR)/config.cache)
	cd $(GNUPLOT_DIR) && \
		$(GNUPLOT_PATH) $(GNUPLOT_ENV) \
		./configure $(GNUPLOT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gnuplot_compile: $(STATEDIR)/gnuplot.compile

gnuplot_compile_deps = $(STATEDIR)/gnuplot.prepare

$(STATEDIR)/gnuplot.compile: $(gnuplot_compile_deps)
	@$(call targetinfo, $@)
	$(GNUPLOT_PATH) $(MAKE) -C $(GNUPLOT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gnuplot_install: $(STATEDIR)/gnuplot.install

$(STATEDIR)/gnuplot.install: $(STATEDIR)/gnuplot.compile
	@$(call targetinfo, $@)
	$(GNUPLOT_PATH) $(MAKE) -C $(GNUPLOT_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gnuplot_targetinstall: $(STATEDIR)/gnuplot.targetinstall

gnuplot_targetinstall_deps = $(STATEDIR)/gnuplot.compile

$(STATEDIR)/gnuplot.targetinstall: $(gnuplot_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GNUPLOT_PATH) $(MAKE) -C $(GNUPLOT_DIR) DESTDIR=$(GNUPLOT_IPKG_TMP) install
	rm -rf $(GNUPLOT_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(GNUPLOT_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(GNUPLOT_IPKG_TMP)/usr/lib/gnuplot/4.0/*
	mkdir -p $(GNUPLOT_IPKG_TMP)/CONTROL
	echo "Package: gnuplot" 							 >$(GNUPLOT_IPKG_TMP)/CONTROL/control
	echo "Source: $(GNUPLOT_URL)"							>>$(GNUPLOT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GNUPLOT_IPKG_TMP)/CONTROL/control
	echo "Section: Math"	 							>>$(GNUPLOT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GNUPLOT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GNUPLOT_IPKG_TMP)/CONTROL/control
	echo "Version: $(GNUPLOT_VERSION)-$(GNUPLOT_VENDOR_VERSION)" 			>>$(GNUPLOT_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree" 								>>$(GNUPLOT_IPKG_TMP)/CONTROL/control
	echo "Description: Gnuplot  is a portable command-line driven interactive data and function plotting utility for UNIX, IBM OS/2, MS Windows, DOS, Macintosh, VMS, Atari and many other platforms." >>$(GNUPLOT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GNUPLOT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GNUPLOT_INSTALL
ROMPACKAGES += $(STATEDIR)/gnuplot.imageinstall
endif

gnuplot_imageinstall_deps = $(STATEDIR)/gnuplot.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gnuplot.imageinstall: $(gnuplot_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gnuplot
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gnuplot_clean:
	rm -rf $(STATEDIR)/gnuplot.*
	rm -rf $(GNUPLOT_DIR)

# vim: syntax=make
