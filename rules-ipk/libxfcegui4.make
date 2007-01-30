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
ifdef PTXCONF_LIBXFCEGUI4
PACKAGES += libxfcegui4
endif

#
# Paths and names
#
LIBXFCEGUI4_VENDOR_VERSION	= 1
LIBXFCEGUI4_VERSION	= 4.4.0
LIBXFCEGUI4		= libxfcegui4-$(LIBXFCEGUI4_VERSION)
LIBXFCEGUI4_SUFFIX		= tar.bz2
LIBXFCEGUI4_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(LIBXFCEGUI4).$(LIBXFCEGUI4_SUFFIX)
LIBXFCEGUI4_SOURCE		= $(SRCDIR)/$(LIBXFCEGUI4).$(LIBXFCEGUI4_SUFFIX)
LIBXFCEGUI4_DIR		= $(BUILDDIR)/$(LIBXFCEGUI4)
LIBXFCEGUI4_IPKG_TMP	= $(LIBXFCEGUI4_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libxfcegui4_get: $(STATEDIR)/libxfcegui4.get

libxfcegui4_get_deps = $(LIBXFCEGUI4_SOURCE)

$(STATEDIR)/libxfcegui4.get: $(libxfcegui4_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBXFCEGUI4))
	touch $@

$(LIBXFCEGUI4_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBXFCEGUI4_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libxfcegui4_extract: $(STATEDIR)/libxfcegui4.extract

libxfcegui4_extract_deps = $(STATEDIR)/libxfcegui4.get

$(STATEDIR)/libxfcegui4.extract: $(libxfcegui4_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXFCEGUI4_DIR))
	@$(call extract, $(LIBXFCEGUI4_SOURCE))
	@$(call patchin, $(LIBXFCEGUI4))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libxfcegui4_prepare: $(STATEDIR)/libxfcegui4.prepare

#
# dependencies
#
libxfcegui4_prepare_deps = \
	$(STATEDIR)/libxfcegui4.extract \
	$(STATEDIR)/virtual-xchain.install

LIBXFCEGUI4_PATH	=  PATH=$(CROSS_PATH)
LIBXFCEGUI4_ENV 	=  $(CROSS_ENV)
#LIBXFCEGUI4_ENV	+=
LIBXFCEGUI4_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBXFCEGUI4_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBXFCEGUI4_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
LIBXFCEGUI4_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBXFCEGUI4_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libxfcegui4.prepare: $(libxfcegui4_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXFCEGUI4_DIR)/config.cache)
	cd $(LIBXFCEGUI4_DIR) && \
		$(LIBXFCEGUI4_PATH) $(LIBXFCEGUI4_ENV) \
		./configure $(LIBXFCEGUI4_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libxfcegui4_compile: $(STATEDIR)/libxfcegui4.compile

libxfcegui4_compile_deps = $(STATEDIR)/libxfcegui4.prepare

$(STATEDIR)/libxfcegui4.compile: $(libxfcegui4_compile_deps)
	@$(call targetinfo, $@)
	$(LIBXFCEGUI4_PATH) $(MAKE) -C $(LIBXFCEGUI4_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libxfcegui4_install: $(STATEDIR)/libxfcegui4.install

$(STATEDIR)/libxfcegui4.install: $(STATEDIR)/libxfcegui4.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBXFCEGUI4_IPKG_TMP)
	$(LIBXFCEGUI4_PATH) $(MAKE) -C $(LIBXFCEGUI4_DIR) DESTDIR=$(LIBXFCEGUI4_IPKG_TMP) install
	@$(call copyincludes, $(LIBXFCEGUI4_IPKG_TMP))
	@$(call copylibraries,$(LIBXFCEGUI4_IPKG_TMP))
	@$(call copymiscfiles,$(LIBXFCEGUI4_IPKG_TMP))
	rm -rf $(LIBXFCEGUI4_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libxfcegui4_targetinstall: $(STATEDIR)/libxfcegui4.targetinstall

libxfcegui4_targetinstall_deps = $(STATEDIR)/libxfcegui4.compile

LIBXFCEGUI4_DEPLIST = 

$(STATEDIR)/libxfcegui4.targetinstall: $(libxfcegui4_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBXFCEGUI4_PATH) $(MAKE) -C $(LIBXFCEGUI4_DIR) DESTDIR=$(LIBXFCEGUI4_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LIBXFCEGUI4_VERSION)-$(LIBXFCEGUI4_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh libxfcegui4 $(LIBXFCEGUI4_IPKG_TMP)

	@$(call removedevfiles, $(LIBXFCEGUI4_IPKG_TMP))
	@$(call stripfiles, $(LIBXFCEGUI4_IPKG_TMP))
	mkdir -p $(LIBXFCEGUI4_IPKG_TMP)/CONTROL
	echo "Package: libxfcegui4" 							 >$(LIBXFCEGUI4_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBXFCEGUI4_URL)"							>>$(LIBXFCEGUI4_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBXFCEGUI4_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(LIBXFCEGUI4_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(LIBXFCEGUI4_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBXFCEGUI4_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBXFCEGUI4_VERSION)-$(LIBXFCEGUI4_VENDOR_VERSION)" 			>>$(LIBXFCEGUI4_IPKG_TMP)/CONTROL/control
	echo "Depends: $(LIBXFCEGUI4_DEPLIST)" 						>>$(LIBXFCEGUI4_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(LIBXFCEGUI4_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LIBXFCEGUI4_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBXFCEGUI4_INSTALL
ROMPACKAGES += $(STATEDIR)/libxfcegui4.imageinstall
endif

libxfcegui4_imageinstall_deps = $(STATEDIR)/libxfcegui4.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libxfcegui4.imageinstall: $(libxfcegui4_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libxfcegui4
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libxfcegui4_clean:
	rm -rf $(STATEDIR)/libxfcegui4.*
	rm -rf $(LIBXFCEGUI4_DIR)

# vim: syntax=make
