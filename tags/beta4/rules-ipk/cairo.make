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
ifdef PTXCONF_CAIRO
PACKAGES += cairo
endif

#
# Paths and names
#
CAIRO_VENDOR_VERSION	= 1
CAIRO_VERSION		= 1.0.0
CAIRO			= cairo-$(CAIRO_VERSION)
CAIRO_SUFFIX		= tar.gz
CAIRO_URL		= ftp://ftp.gtk.org/pub/gtk/v2.8/dependencies/$(CAIRO).$(CAIRO_SUFFIX)
CAIRO_SOURCE		= $(SRCDIR)/$(CAIRO).$(CAIRO_SUFFIX)
CAIRO_DIR		= $(BUILDDIR)/$(CAIRO)
CAIRO_IPKG_TMP		= $(CAIRO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

cairo_get: $(STATEDIR)/cairo.get

cairo_get_deps = $(CAIRO_SOURCE)

$(STATEDIR)/cairo.get: $(cairo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CAIRO))
	touch $@

$(CAIRO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CAIRO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

cairo_extract: $(STATEDIR)/cairo.extract

cairo_extract_deps = $(STATEDIR)/cairo.get

$(STATEDIR)/cairo.extract: $(cairo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CAIRO_DIR))
	@$(call extract, $(CAIRO_SOURCE))
	@$(call patchin, $(CAIRO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

cairo_prepare: $(STATEDIR)/cairo.prepare

#
# dependencies
#
cairo_prepare_deps = \
	$(STATEDIR)/cairo.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

CAIRO_PATH	=  PATH=$(CROSS_PATH)
CAIRO_ENV 	=  $(CROSS_ENV)
CAIRO_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
CAIRO_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
CAIRO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CAIRO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
CAIRO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-gtk-doc \
	--disable-static \
	--enable-shared \
	--sysconfdir=/etc \
	--disable-glitz \
	--disable-pdf \
	--disable-ps \
	--disable-xcb \
	--enable-png

ifdef PTXCONF_XFREE430
CAIRO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CAIRO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/cairo.prepare: $(cairo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CAIRO_DIR)/config.cache)
	cd $(CAIRO_DIR) && \
		$(CAIRO_PATH) $(CAIRO_ENV) \
		./configure $(CAIRO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

cairo_compile: $(STATEDIR)/cairo.compile

cairo_compile_deps = $(STATEDIR)/cairo.prepare

$(STATEDIR)/cairo.compile: $(cairo_compile_deps)
	@$(call targetinfo, $@)
	$(CAIRO_PATH) $(MAKE) -C $(CAIRO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

cairo_install: $(STATEDIR)/cairo.install

$(STATEDIR)/cairo.install: $(STATEDIR)/cairo.compile
	@$(call targetinfo, $@)
	rm -rf $(CAIRO_IPKG_TMP)
	$(CAIRO_PATH) $(MAKE) -C $(CAIRO_DIR) DESTDIR=$(CAIRO_IPKG_TMP) install
	cp -a $(CAIRO_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(CAIRO_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libcairo.la
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/cairo.pc
	rm -rf $(CAIRO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

cairo_targetinstall: $(STATEDIR)/cairo.targetinstall

cairo_targetinstall_deps = $(STATEDIR)/cairo.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/cairo.targetinstall: $(cairo_targetinstall_deps)
	@$(call targetinfo, $@)
	$(CAIRO_PATH) $(MAKE) -C $(CAIRO_DIR) DESTDIR=$(CAIRO_IPKG_TMP) install
	rm -rf $(CAIRO_IPKG_TMP)/usr/include
	rm -rf $(CAIRO_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(CAIRO_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(CAIRO_IPKG_TMP)/usr/share/gtk-doc
	$(CROSSSTRIP) $(CAIRO_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(CAIRO_IPKG_TMP)/CONTROL
	echo "Package: cairo" 								 >$(CAIRO_IPKG_TMP)/CONTROL/control
	echo "Source: $(CAIRO_URL)"							>>$(CAIRO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(CAIRO_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(CAIRO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(CAIRO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(CAIRO_IPKG_TMP)/CONTROL/control
	echo "Version: $(CAIRO_VERSION)-$(CAIRO_VENDOR_VERSION)" 			>>$(CAIRO_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree" 								>>$(CAIRO_IPKG_TMP)/CONTROL/control
	echo "Description: Cairo is a 2D graphics library with support for multiple output devices."	>>$(CAIRO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(CAIRO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CAIRO_INSTALL
ROMPACKAGES += $(STATEDIR)/cairo.imageinstall
endif

cairo_imageinstall_deps = $(STATEDIR)/cairo.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/cairo.imageinstall: $(cairo_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install cairo
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

cairo_clean:
	rm -rf $(STATEDIR)/cairo.*
	rm -rf $(CAIRO_DIR)

# vim: syntax=make