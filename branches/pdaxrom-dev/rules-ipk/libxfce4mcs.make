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
ifdef PTXCONF_LIBXFCE4MCS
PACKAGES += libxfce4mcs
endif

#
# Paths and names
#
LIBXFCE4MCS_VENDOR_VERSION	= 1
LIBXFCE4MCS_VERSION	= 4.4.0
LIBXFCE4MCS		= libxfce4mcs-$(LIBXFCE4MCS_VERSION)
LIBXFCE4MCS_SUFFIX		= tar.bz2
LIBXFCE4MCS_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(LIBXFCE4MCS).$(LIBXFCE4MCS_SUFFIX)
LIBXFCE4MCS_SOURCE		= $(SRCDIR)/$(LIBXFCE4MCS).$(LIBXFCE4MCS_SUFFIX)
LIBXFCE4MCS_DIR		= $(BUILDDIR)/$(LIBXFCE4MCS)
LIBXFCE4MCS_IPKG_TMP	= $(LIBXFCE4MCS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libxfce4mcs_get: $(STATEDIR)/libxfce4mcs.get

libxfce4mcs_get_deps = $(LIBXFCE4MCS_SOURCE)

$(STATEDIR)/libxfce4mcs.get: $(libxfce4mcs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBXFCE4MCS))
	touch $@

$(LIBXFCE4MCS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBXFCE4MCS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libxfce4mcs_extract: $(STATEDIR)/libxfce4mcs.extract

libxfce4mcs_extract_deps = $(STATEDIR)/libxfce4mcs.get

$(STATEDIR)/libxfce4mcs.extract: $(libxfce4mcs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXFCE4MCS_DIR))
	@$(call extract, $(LIBXFCE4MCS_SOURCE))
	@$(call patchin, $(LIBXFCE4MCS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libxfce4mcs_prepare: $(STATEDIR)/libxfce4mcs.prepare

#
# dependencies
#
libxfce4mcs_prepare_deps = \
	$(STATEDIR)/libxfce4mcs.extract \
	$(STATEDIR)/virtual-xchain.install

LIBXFCE4MCS_PATH	=  PATH=$(CROSS_PATH)
LIBXFCE4MCS_ENV 	=  $(CROSS_ENV)
#LIBXFCE4MCS_ENV	+=
LIBXFCE4MCS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBXFCE4MCS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBXFCE4MCS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
LIBXFCE4MCS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBXFCE4MCS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libxfce4mcs.prepare: $(libxfce4mcs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXFCE4MCS_DIR)/config.cache)
	cd $(LIBXFCE4MCS_DIR) && \
		$(LIBXFCE4MCS_PATH) $(LIBXFCE4MCS_ENV) \
		./configure $(LIBXFCE4MCS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libxfce4mcs_compile: $(STATEDIR)/libxfce4mcs.compile

libxfce4mcs_compile_deps = $(STATEDIR)/libxfce4mcs.prepare

$(STATEDIR)/libxfce4mcs.compile: $(libxfce4mcs_compile_deps)
	@$(call targetinfo, $@)
	$(LIBXFCE4MCS_PATH) $(MAKE) -C $(LIBXFCE4MCS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libxfce4mcs_install: $(STATEDIR)/libxfce4mcs.install

$(STATEDIR)/libxfce4mcs.install: $(STATEDIR)/libxfce4mcs.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBXFCE4MCS_IPKG_TMP)
	$(LIBXFCE4MCS_PATH) $(MAKE) -C $(LIBXFCE4MCS_DIR) DESTDIR=$(LIBXFCE4MCS_IPKG_TMP) install
	@$(call copyincludes, $(LIBXFCE4MCS_IPKG_TMP))
	@$(call copylibraries,$(LIBXFCE4MCS_IPKG_TMP))
	@$(call copymiscfiles,$(LIBXFCE4MCS_IPKG_TMP))
	rm -rf $(LIBXFCE4MCS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libxfce4mcs_targetinstall: $(STATEDIR)/libxfce4mcs.targetinstall

libxfce4mcs_targetinstall_deps = $(STATEDIR)/libxfce4mcs.compile

LIBXFCE4MCS_DEPLIST = 

$(STATEDIR)/libxfce4mcs.targetinstall: $(libxfce4mcs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBXFCE4MCS_PATH) $(MAKE) -C $(LIBXFCE4MCS_DIR) DESTDIR=$(LIBXFCE4MCS_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LIBXFCE4MCS_VERSION)-$(LIBXFCE4MCS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh libxfce4mcs $(LIBXFCE4MCS_IPKG_TMP)

	@$(call removedevfiles, $(LIBXFCE4MCS_IPKG_TMP))
	@$(call stripfiles, $(LIBXFCE4MCS_IPKG_TMP))
	mkdir -p $(LIBXFCE4MCS_IPKG_TMP)/CONTROL
	echo "Package: libxfce4mcs" 							 >$(LIBXFCE4MCS_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBXFCE4MCS_URL)"							>>$(LIBXFCE4MCS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBXFCE4MCS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(LIBXFCE4MCS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(LIBXFCE4MCS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBXFCE4MCS_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBXFCE4MCS_VERSION)-$(LIBXFCE4MCS_VENDOR_VERSION)" 			>>$(LIBXFCE4MCS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(LIBXFCE4MCS_DEPLIST)" 						>>$(LIBXFCE4MCS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(LIBXFCE4MCS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LIBXFCE4MCS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBXFCE4MCS_INSTALL
ROMPACKAGES += $(STATEDIR)/libxfce4mcs.imageinstall
endif

libxfce4mcs_imageinstall_deps = $(STATEDIR)/libxfce4mcs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libxfce4mcs.imageinstall: $(libxfce4mcs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libxfce4mcs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libxfce4mcs_clean:
	rm -rf $(STATEDIR)/libxfce4mcs.*
	rm -rf $(LIBXFCE4MCS_DIR)

# vim: syntax=make
