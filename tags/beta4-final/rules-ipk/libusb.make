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
ifdef PTXCONF_LIBUSB
PACKAGES += libusb
endif

#
# Paths and names
#
LIBUSB_VENDOR_VERSION	= 1
LIBUSB_VERSION		= 0.1.10a
LIBUSB			= libusb-$(LIBUSB_VERSION)
LIBUSB_SUFFIX		= tar.gz
LIBUSB_URL		= http://citkit.dl.sourceforge.net/sourceforge/libusb/$(LIBUSB).$(LIBUSB_SUFFIX)
LIBUSB_SOURCE		= $(SRCDIR)/$(LIBUSB).$(LIBUSB_SUFFIX)
LIBUSB_DIR		= $(BUILDDIR)/$(LIBUSB)
LIBUSB_IPKG_TMP		= $(LIBUSB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libusb_get: $(STATEDIR)/libusb.get

libusb_get_deps = $(LIBUSB_SOURCE)

$(STATEDIR)/libusb.get: $(libusb_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBUSB))
	touch $@

$(LIBUSB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBUSB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libusb_extract: $(STATEDIR)/libusb.extract

libusb_extract_deps = $(STATEDIR)/libusb.get

$(STATEDIR)/libusb.extract: $(libusb_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBUSB_DIR))
	@$(call extract, $(LIBUSB_SOURCE))
	@$(call patchin, $(LIBUSB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libusb_prepare: $(STATEDIR)/libusb.prepare

#
# dependencies
#
libusb_prepare_deps = \
	$(STATEDIR)/libusb.extract \
	$(STATEDIR)/virtual-xchain.install

LIBUSB_PATH	=  PATH=$(CROSS_PATH)
LIBUSB_ENV 	=  $(CROSS_ENV)
#LIBUSB_ENV	+=
LIBUSB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBUSB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBUSB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
LIBUSB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBUSB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libusb.prepare: $(libusb_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBUSB_DIR)/config.cache)
	cd $(LIBUSB_DIR) && \
		$(LIBUSB_PATH) $(LIBUSB_ENV) \
		./configure $(LIBUSB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libusb_compile: $(STATEDIR)/libusb.compile

libusb_compile_deps = $(STATEDIR)/libusb.prepare

$(STATEDIR)/libusb.compile: $(libusb_compile_deps)
	@$(call targetinfo, $@)
	$(LIBUSB_PATH) $(MAKE) -C $(LIBUSB_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libusb_install: $(STATEDIR)/libusb.install

$(STATEDIR)/libusb.install: $(STATEDIR)/libusb.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBUSB_IPKG_TMP)
	$(LIBUSB_PATH) $(MAKE) -C $(LIBUSB_DIR) DESTDIR=$(LIBUSB_IPKG_TMP) install
	cp -a $(LIBUSB_IPKG_TMP)/usr/bin/libusb-config $(PTXCONF_PREFIX)/bin/
	cp -a $(LIBUSB_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(LIBUSB_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g"		$(PTXCONF_PREFIX)/bin/libusb-config
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g"	$(CROSS_LIB_DIR)/lib/libusb.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g"	$(CROSS_LIB_DIR)/lib/libusbpp.la
	rm -rf $(LIBUSB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libusb_targetinstall: $(STATEDIR)/libusb.targetinstall

libusb_targetinstall_deps = $(STATEDIR)/libusb.compile

$(STATEDIR)/libusb.targetinstall: $(libusb_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBUSB_PATH) $(MAKE) -C $(LIBUSB_DIR) DESTDIR=$(LIBUSB_IPKG_TMP) install
	rm -rf $(LIBUSB_IPKG_TMP)/usr/bin
	rm -rf $(LIBUSB_IPKG_TMP)/usr/include
	rm -rf $(LIBUSB_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(LIBUSB_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(LIBUSB_IPKG_TMP)/CONTROL
	echo "Package: libusb" 								 >$(LIBUSB_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBUSB_URL)"						>>$(LIBUSB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBUSB_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LIBUSB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBUSB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBUSB_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBUSB_VERSION)-$(LIBUSB_VENDOR_VERSION)" 			>>$(LIBUSB_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LIBUSB_IPKG_TMP)/CONTROL/control
	echo "Description: libusb is a library which allows userspace application access to USB devices." >>$(LIBUSB_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBUSB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBUSB_INSTALL
ROMPACKAGES += $(STATEDIR)/libusb.imageinstall
endif

libusb_imageinstall_deps = $(STATEDIR)/libusb.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libusb.imageinstall: $(libusb_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libusb
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libusb_clean:
	rm -rf $(STATEDIR)/libusb.*
	rm -rf $(LIBUSB_DIR)

# vim: syntax=make
