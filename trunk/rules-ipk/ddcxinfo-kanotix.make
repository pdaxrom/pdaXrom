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
ifdef PTXCONF_DDCXINFO-KANOTIX
PACKAGES += ddcxinfo-kanotix
endif

#
# Paths and names
#
DDCXINFO-KANOTIX_VENDOR_VERSION	= 1
DDCXINFO-KANOTIX_VERSION	= 0.6.16
DDCXINFO-KANOTIX		= ddcxinfo-kanotix-$(DDCXINFO-KANOTIX_VERSION)
DDCXINFO-KANOTIX_SUFFIX		= tar.gz
DDCXINFO-KANOTIX_URL		= http://mail.pdaXrom.org/src/$(DDCXINFO-KANOTIX).$(DDCXINFO-KANOTIX_SUFFIX)
DDCXINFO-KANOTIX_SOURCE		= $(SRCDIR)/$(DDCXINFO-KANOTIX).$(DDCXINFO-KANOTIX_SUFFIX)
DDCXINFO-KANOTIX_DIR		= $(BUILDDIR)/$(DDCXINFO-KANOTIX)
DDCXINFO-KANOTIX_IPKG_TMP	= $(DDCXINFO-KANOTIX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ddcxinfo-kanotix_get: $(STATEDIR)/ddcxinfo-kanotix.get

ddcxinfo-kanotix_get_deps = $(DDCXINFO-KANOTIX_SOURCE)

$(STATEDIR)/ddcxinfo-kanotix.get: $(ddcxinfo-kanotix_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DDCXINFO-KANOTIX))
	touch $@

$(DDCXINFO-KANOTIX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DDCXINFO-KANOTIX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ddcxinfo-kanotix_extract: $(STATEDIR)/ddcxinfo-kanotix.extract

ddcxinfo-kanotix_extract_deps = $(STATEDIR)/ddcxinfo-kanotix.get

$(STATEDIR)/ddcxinfo-kanotix.extract: $(ddcxinfo-kanotix_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DDCXINFO-KANOTIX_DIR))
	@$(call extract, $(DDCXINFO-KANOTIX_SOURCE))
	@$(call patchin, $(DDCXINFO-KANOTIX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ddcxinfo-kanotix_prepare: $(STATEDIR)/ddcxinfo-kanotix.prepare

#
# dependencies
#
ddcxinfo-kanotix_prepare_deps = \
	$(STATEDIR)/ddcxinfo-kanotix.extract \
	$(STATEDIR)/virtual-xchain.install

DDCXINFO-KANOTIX_PATH	=  PATH=$(CROSS_PATH)
DDCXINFO-KANOTIX_ENV 	=  $(CROSS_ENV)
#DDCXINFO-KANOTIX_ENV	+=
DDCXINFO-KANOTIX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DDCXINFO-KANOTIX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
DDCXINFO-KANOTIX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
DDCXINFO-KANOTIX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DDCXINFO-KANOTIX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ddcxinfo-kanotix.prepare: $(ddcxinfo-kanotix_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DDCXINFO-KANOTIX_DIR)/config.cache)
	#cd $(DDCXINFO-KANOTIX_DIR) && \
	#	$(DDCXINFO-KANOTIX_PATH) $(DDCXINFO-KANOTIX_ENV) \
	#	./configure $(DDCXINFO-KANOTIX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ddcxinfo-kanotix_compile: $(STATEDIR)/ddcxinfo-kanotix.compile

ddcxinfo-kanotix_compile_deps = $(STATEDIR)/ddcxinfo-kanotix.prepare

$(STATEDIR)/ddcxinfo-kanotix.compile: $(ddcxinfo-kanotix_compile_deps)
	@$(call targetinfo, $@)
	$(DDCXINFO-KANOTIX_PATH) $(MAKE) -C $(DDCXINFO-KANOTIX_DIR) $(CROSS_ENV_CC) $(CROSS_ENV_CPP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ddcxinfo-kanotix_install: $(STATEDIR)/ddcxinfo-kanotix.install

$(STATEDIR)/ddcxinfo-kanotix.install: $(STATEDIR)/ddcxinfo-kanotix.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ddcxinfo-kanotix_targetinstall: $(STATEDIR)/ddcxinfo-kanotix.targetinstall

ddcxinfo-kanotix_targetinstall_deps = $(STATEDIR)/ddcxinfo-kanotix.compile

$(STATEDIR)/ddcxinfo-kanotix.targetinstall: $(ddcxinfo-kanotix_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(DDCXINFO-KANOTIX_PATH) $(MAKE) -C $(DDCXINFO-KANOTIX_DIR) DESTDIR=$(DDCXINFO-KANOTIX_IPKG_TMP) install
	mkdir -p $(DDCXINFO-KANOTIX_IPKG_TMP)/usr/sbin
	cp -a $(DDCXINFO-KANOTIX_DIR)/ddcxinfo-kanotix $(DDCXINFO-KANOTIX_IPKG_TMP)/usr/sbin/
	$(CROSSSTRIP) $(DDCXINFO-KANOTIX_IPKG_TMP)/usr/sbin/*
	cp -a $(TOPDIR)/config/pdaXrom-x86/xdetect $(DDCXINFO-KANOTIX_IPKG_TMP)/usr/sbin/
	mkdir -p $(DDCXINFO-KANOTIX_IPKG_TMP)/CONTROL
	echo "Package: ddcxinfo-kanotix" 						 >$(DDCXINFO-KANOTIX_IPKG_TMP)/CONTROL/control
	echo "Source: $(DDCXINFO-KANOTIX_URL)"						>>$(DDCXINFO-KANOTIX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DDCXINFO-KANOTIX_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(DDCXINFO-KANOTIX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DDCXINFO-KANOTIX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DDCXINFO-KANOTIX_IPKG_TMP)/CONTROL/control
	echo "Version: $(DDCXINFO-KANOTIX_VERSION)-$(DDCXINFO-KANOTIX_VENDOR_VERSION)" 	>>$(DDCXINFO-KANOTIX_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(DDCXINFO-KANOTIX_IPKG_TMP)/CONTROL/control
	echo "Description: VBE/DDC stuff"						>>$(DDCXINFO-KANOTIX_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(DDCXINFO-KANOTIX_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DDCXINFO-KANOTIX_INSTALL
ROMPACKAGES += $(STATEDIR)/ddcxinfo-kanotix.imageinstall
endif

ddcxinfo-kanotix_imageinstall_deps = $(STATEDIR)/ddcxinfo-kanotix.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ddcxinfo-kanotix.imageinstall: $(ddcxinfo-kanotix_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ddcxinfo-kanotix
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ddcxinfo-kanotix_clean:
	rm -rf $(STATEDIR)/ddcxinfo-kanotix.*
	rm -rf $(DDCXINFO-KANOTIX_DIR)

# vim: syntax=make
