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
ifdef PTXCONF_LIBSOUP
PACKAGES += libsoup
endif

#
# Paths and names
#
LIBSOUP_VENDOR_VERSION	= 1
LIBSOUP_VERSION		= 2.2.96
LIBSOUP			= libsoup-$(LIBSOUP_VERSION)
LIBSOUP_SUFFIX		= tar.bz2
LIBSOUP_URL		= ftp://ftp.gnome.org/pub/gnome/sources/libsoup/2.2/$(LIBSOUP).$(LIBSOUP_SUFFIX)
LIBSOUP_SOURCE		= $(SRCDIR)/$(LIBSOUP).$(LIBSOUP_SUFFIX)
LIBSOUP_DIR		= $(BUILDDIR)/$(LIBSOUP)
LIBSOUP_IPKG_TMP	= $(LIBSOUP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libsoup_get: $(STATEDIR)/libsoup.get

libsoup_get_deps = $(LIBSOUP_SOURCE)

$(STATEDIR)/libsoup.get: $(libsoup_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBSOUP))
	touch $@

$(LIBSOUP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBSOUP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libsoup_extract: $(STATEDIR)/libsoup.extract

libsoup_extract_deps = $(STATEDIR)/libsoup.get

$(STATEDIR)/libsoup.extract: $(libsoup_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBSOUP_DIR))
	@$(call extract, $(LIBSOUP_SOURCE))
	@$(call patchin, $(LIBSOUP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libsoup_prepare: $(STATEDIR)/libsoup.prepare

#
# dependencies
#
libsoup_prepare_deps = \
	$(STATEDIR)/libsoup.extract \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/gnutls.install \
	$(STATEDIR)/virtual-xchain.install

LIBSOUP_PATH	=  PATH=$(CROSS_PATH)
LIBSOUP_ENV 	=  $(CROSS_ENV)
#LIBSOUP_ENV	+=
LIBSOUP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBSOUP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBSOUP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
LIBSOUP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBSOUP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libsoup.prepare: $(libsoup_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBSOUP_DIR)/config.cache)
	cd $(LIBSOUP_DIR) && \
		$(LIBSOUP_PATH) $(LIBSOUP_ENV) \
		./configure $(LIBSOUP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libsoup_compile: $(STATEDIR)/libsoup.compile

libsoup_compile_deps = $(STATEDIR)/libsoup.prepare

$(STATEDIR)/libsoup.compile: $(libsoup_compile_deps)
	@$(call targetinfo, $@)
	$(LIBSOUP_PATH) $(MAKE) -C $(LIBSOUP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libsoup_install: $(STATEDIR)/libsoup.install

$(STATEDIR)/libsoup.install: $(STATEDIR)/libsoup.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBSOUP_IPKG_TMP)
	$(LIBSOUP_PATH) $(MAKE) -C $(LIBSOUP_DIR) DESTDIR=$(LIBSOUP_IPKG_TMP) install
	@$(call copyincludes, $(LIBSOUP_IPKG_TMP))
	@$(call copylibraries,$(LIBSOUP_IPKG_TMP))
	@$(call copymiscfiles,$(LIBSOUP_IPKG_TMP))
	rm -rf $(LIBSOUP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libsoup_targetinstall: $(STATEDIR)/libsoup.targetinstall

libsoup_targetinstall_deps = $(STATEDIR)/libsoup.compile \
	$(STATEDIR)/libxml2.targetinstall \
	$(STATEDIR)/gnutls.targetinstall

$(STATEDIR)/libsoup.targetinstall: $(libsoup_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBSOUP_PATH) $(MAKE) -C $(LIBSOUP_DIR) DESTDIR=$(LIBSOUP_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LIBSOUP_VERSION)-$(LIBSOUP_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh libsoup $(LIBSOUP_IPKG_TMP)

	@$(call removedevfiles, $(LIBSOUP_IPKG_TMP))
	@$(call stripfiles, $(LIBSOUP_IPKG_TMP))
	mkdir -p $(LIBSOUP_IPKG_TMP)/CONTROL
	echo "Package: libsoup" 							 >$(LIBSOUP_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBSOUP_URL)"							>>$(LIBSOUP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBSOUP_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LIBSOUP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBSOUP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBSOUP_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBSOUP_VERSION)-$(LIBSOUP_VENDOR_VERSION)" 			>>$(LIBSOUP_IPKG_TMP)/CONTROL/control
	echo "Depends: libxml2, gnutls" 						>>$(LIBSOUP_IPKG_TMP)/CONTROL/control
	echo "Description: The libsoup package contains an HTTP library implementation in C">>$(LIBSOUP_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LIBSOUP_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBSOUP_INSTALL
ROMPACKAGES += $(STATEDIR)/libsoup.imageinstall
endif

libsoup_imageinstall_deps = $(STATEDIR)/libsoup.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libsoup.imageinstall: $(libsoup_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libsoup
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libsoup_clean:
	rm -rf $(STATEDIR)/libsoup.*
	rm -rf $(LIBSOUP_DIR)

# vim: syntax=make
