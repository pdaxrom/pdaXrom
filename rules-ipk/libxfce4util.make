# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Adrian Crutchfield
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_LIBXFCE4UTIL
PACKAGES += libxfce4util
endif

#
# Paths and names
#
LIBXFCE4UTIL_VENDOR_VERSION	= 1
LIBXFCE4UTIL_VERSION	= 4.4.0
LIBXFCE4UTIL		= libxfce4util-$(LIBXFCE4UTIL_VERSION)
LIBXFCE4UTIL_SUFFIX		= tar.bz2
LIBXFCE4UTIL_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(LIBXFCE4UTIL).$(LIBXFCE4UTIL_SUFFIX)
LIBXFCE4UTIL_SOURCE		= $(SRCDIR)/$(LIBXFCE4UTIL).$(LIBXFCE4UTIL_SUFFIX)
LIBXFCE4UTIL_DIR		= $(BUILDDIR)/$(LIBXFCE4UTIL)
LIBXFCE4UTIL_IPKG_TMP	= $(LIBXFCE4UTIL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libxfce4util_get: $(STATEDIR)/libxfce4util.get

libxfce4util_get_deps = $(LIBXFCE4UTIL_SOURCE)

$(STATEDIR)/libxfce4util.get: $(libxfce4util_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBXFCE4UTIL))
	touch $@

$(LIBXFCE4UTIL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBXFCE4UTIL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libxfce4util_extract: $(STATEDIR)/libxfce4util.extract

libxfce4util_extract_deps = $(STATEDIR)/libxfce4util.get

$(STATEDIR)/libxfce4util.extract: $(libxfce4util_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXFCE4UTIL_DIR))
	@$(call extract, $(LIBXFCE4UTIL_SOURCE))
	@$(call patchin, $(LIBXFCE4UTIL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libxfce4util_prepare: $(STATEDIR)/libxfce4util.prepare

#
# dependencies
#
libxfce4util_prepare_deps = \
	$(STATEDIR)/libxfce4util.extract \
	$(STATEDIR)/virtual-xchain.install

LIBXFCE4UTIL_PATH	=  PATH=$(CROSS_PATH)
LIBXFCE4UTIL_ENV 	=  $(CROSS_ENV)
#LIBXFCE4UTIL_ENV	+=
LIBXFCE4UTIL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBXFCE4UTIL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBXFCE4UTIL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--with-broken-putenv \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
LIBXFCE4UTIL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBXFCE4UTIL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libxfce4util.prepare: $(libxfce4util_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXFCE4UTIL_DIR)/config.cache)
	cd $(LIBXFCE4UTIL_DIR) && \
		$(LIBXFCE4UTIL_PATH) $(LIBXFCE4UTIL_ENV) \
		./configure $(LIBXFCE4UTIL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libxfce4util_compile: $(STATEDIR)/libxfce4util.compile

libxfce4util_compile_deps = $(STATEDIR)/libxfce4util.prepare

$(STATEDIR)/libxfce4util.compile: $(libxfce4util_compile_deps)
	@$(call targetinfo, $@)
	$(LIBXFCE4UTIL_PATH) $(MAKE) -C $(LIBXFCE4UTIL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libxfce4util_install: $(STATEDIR)/libxfce4util.install

$(STATEDIR)/libxfce4util.install: $(STATEDIR)/libxfce4util.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBXFCE4UTIL_IPKG_TMP)
	$(LIBXFCE4UTIL_PATH) $(MAKE) -C $(LIBXFCE4UTIL_DIR) DESTDIR=$(LIBXFCE4UTIL_IPKG_TMP) install
	@$(call copyincludes, $(LIBXFCE4UTIL_IPKG_TMP))
	@$(call copylibraries,$(LIBXFCE4UTIL_IPKG_TMP))
	@$(call copymiscfiles,$(LIBXFCE4UTIL_IPKG_TMP))
	rm -rf $(LIBXFCE4UTIL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libxfce4util_targetinstall: $(STATEDIR)/libxfce4util.targetinstall

libxfce4util_targetinstall_deps = $(STATEDIR)/libxfce4util.compile

LIBXFCE4UTIL_DEPLIST = 

$(STATEDIR)/libxfce4util.targetinstall: $(libxfce4util_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBXFCE4UTIL_PATH) $(MAKE) -C $(LIBXFCE4UTIL_DIR) DESTDIR=$(LIBXFCE4UTIL_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LIBXFCE4UTIL_VERSION)-$(LIBXFCE4UTIL_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh libxfce4util $(LIBXFCE4UTIL_IPKG_TMP)

	@$(call removedevfiles, $(LIBXFCE4UTIL_IPKG_TMP))
	@$(call stripfiles, $(LIBXFCE4UTIL_IPKG_TMP))
	mkdir -p $(LIBXFCE4UTIL_IPKG_TMP)/CONTROL
	echo "Package: libxfce4util" 							 >$(LIBXFCE4UTIL_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBXFCE4UTIL_URL)"							>>$(LIBXFCE4UTIL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBXFCE4UTIL_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(LIBXFCE4UTIL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(LIBXFCE4UTIL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBXFCE4UTIL_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBXFCE4UTIL_VERSION)-$(LIBXFCE4UTIL_VENDOR_VERSION)" 			>>$(LIBXFCE4UTIL_IPKG_TMP)/CONTROL/control
	echo "Depends: $(LIBXFCE4UTIL_DEPLIST)" 						>>$(LIBXFCE4UTIL_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(LIBXFCE4UTIL_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LIBXFCE4UTIL_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBXFCE4UTIL_INSTALL
ROMPACKAGES += $(STATEDIR)/libxfce4util.imageinstall
endif

libxfce4util_imageinstall_deps = $(STATEDIR)/libxfce4util.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libxfce4util.imageinstall: $(libxfce4util_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libxfce4util
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libxfce4util_clean:
	rm -rf $(STATEDIR)/libxfce4util.*
	rm -rf $(LIBXFCE4UTIL_DIR)

# vim: syntax=make
