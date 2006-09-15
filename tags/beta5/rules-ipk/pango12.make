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
ifdef PTXCONF_PANGO12
PACKAGES += pango12
endif

#
# Paths and names
#
PANGO12_VENDOR_VERSION	= 1
PANGO12_VERSION		= 1.14.0
PANGO12			= pango-$(PANGO12_VERSION)
PANGO12_SUFFIX		= tar.bz2
PANGO12_URL		= http://ftp.gnome.org/pub/gnome/sources/pango/1.14/$(PANGO12).$(PANGO12_SUFFIX)
PANGO12_SOURCE		= $(SRCDIR)/$(PANGO12).$(PANGO12_SUFFIX)
PANGO12_DIR		= $(BUILDDIR)/$(PANGO12)
PANGO12_IPKG_TMP	= $(PANGO12_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pango12_get: $(STATEDIR)/pango12.get

pango12_get_deps = $(PANGO12_SOURCE)

$(STATEDIR)/pango12.get: $(pango12_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PANGO12))
	touch $@

$(PANGO12_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PANGO12_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pango12_extract: $(STATEDIR)/pango12.extract

pango12_extract_deps = $(STATEDIR)/pango12.get

$(STATEDIR)/pango12.extract: $(pango12_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PANGO12_DIR))
	@$(call extract, $(PANGO12_SOURCE))
	@$(call patchin, $(PANGO12))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pango12_prepare: $(STATEDIR)/pango12.prepare

#
# dependencies
#
pango12_prepare_deps = \
	$(STATEDIR)/pango12.extract \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/cairo.install \
	$(STATEDIR)/virtual-xchain.install

PANGO12_PATH	=  PATH=$(CROSS_PATH)
PANGO12_ENV 	=  $(CROSS_ENV)
PANGO12_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
PANGO12_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PANGO12_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PANGO12_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-debug \
	--enable-shared \
	--disable-glibtest

ifdef PTXCONF_XFREE430
PANGO12_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PANGO12_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pango12.prepare: $(pango12_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PANGO12_DIR)/config.cache)
	cd $(PANGO12_DIR) && \
		$(PANGO12_PATH) $(PANGO12_ENV) \
		./configure $(PANGO12_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pango12_compile: $(STATEDIR)/pango12.compile

pango12_compile_deps = $(STATEDIR)/pango12.prepare

$(STATEDIR)/pango12.compile: $(pango12_compile_deps)
	@$(call targetinfo, $@)
	$(PANGO12_PATH) $(MAKE) -C $(PANGO12_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pango12_install: $(STATEDIR)/pango12.install

$(STATEDIR)/pango12.install: $(STATEDIR)/pango12.compile
	@$(call targetinfo, $@)
	rm -rf $(PANGO12_IPKG_TMP)
	$(PANGO12_PATH) $(MAKE) -C $(PANGO12_DIR) DESTDIR=$(PANGO12_IPKG_TMP) install
	@$(call copyincludes, $(PANGO12_IPKG_TMP))
	@$(call copylibraries,$(PANGO12_IPKG_TMP))
	@$(call copymiscfiles,$(PANGO12_IPKG_TMP))
	rm -rf $(PANGO12_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pango12_targetinstall: $(STATEDIR)/pango12.targetinstall

pango12_targetinstall_deps = $(STATEDIR)/pango12.compile \
	$(STATEDIR)/glib22.targetinstall \
	$(STATEDIR)/libpng125.targetinstall \
	$(STATEDIR)/zlib.targetinstall \
	$(STATEDIR)/jpeg.targetinstall \
	$(STATEDIR)/cairo.targetinstall \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/pango12.targetinstall: $(pango12_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PANGO12_PATH) $(MAKE) -C $(PANGO12_DIR) DESTDIR=$(PANGO12_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(PANGO12_VERSION)-$(PANGO12_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh pango $(PANGO12_IPKG_TMP)

	@$(call removedevfiles, $(PANGO12_IPKG_TMP))
	@$(call stripfiles, $(PANGO12_IPKG_TMP))
	mkdir -p $(PANGO12_IPKG_TMP)/CONTROL
	echo "Package: pango" 								 >$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Source: $(PANGO12_URL)"							>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Version: $(PANGO12_VERSION)-$(PANGO12_VENDOR_VERSION)" 			>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Depends: glib2, xfree, cairo" 						>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Description: Pango is a library for layout and rendering of text, with an emphasis on internationalization.">>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh"								 >$(PANGO12_IPKG_TMP)/CONTROL/postinst
	echo "/usr/bin/pango-querymodules > /etc/pango/pango.modules" 			>>$(PANGO12_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(PANGO12_IPKG_TMP)/CONTROL/postinst
	cd $(FEEDDIR) && $(XMKIPKG) $(PANGO12_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PANGO12_INSTALL
ROMPACKAGES += $(STATEDIR)/pango12.imageinstall
endif

pango12_imageinstall_deps = $(STATEDIR)/pango12.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pango12.imageinstall: $(pango12_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pango
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pango12_clean:
	rm -rf $(STATEDIR)/pango12.*
	rm -rf $(PANGO12_DIR)

# vim: syntax=make
