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
ifdef PTXCONF_HOSTAPD
PACKAGES += hostapd
endif

#
# Paths and names
#
HOSTAPD_VENDOR_VERSION	= 1
HOSTAPD_VERSION		= 0.5.8
HOSTAPD			= hostapd-$(HOSTAPD_VERSION)
HOSTAPD_SUFFIX		= tar.gz
HOSTAPD_URL		= http://hostap.epitest.fi/releases/$(HOSTAPD).$(HOSTAPD_SUFFIX)
HOSTAPD_SOURCE		= $(SRCDIR)/$(HOSTAPD).$(HOSTAPD_SUFFIX)
HOSTAPD_DIR		= $(BUILDDIR)/$(HOSTAPD)
HOSTAPD_IPKG_TMP	= $(HOSTAPD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

hostapd_get: $(STATEDIR)/hostapd.get

hostapd_get_deps = $(HOSTAPD_SOURCE)

$(STATEDIR)/hostapd.get: $(hostapd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(HOSTAPD))
	touch $@

$(HOSTAPD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(HOSTAPD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

hostapd_extract: $(STATEDIR)/hostapd.extract

hostapd_extract_deps = $(STATEDIR)/hostapd.get

$(STATEDIR)/hostapd.extract: $(hostapd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HOSTAPD_DIR))
	@$(call extract, $(HOSTAPD_SOURCE))
	@$(call patchin, $(HOSTAPD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

hostapd_prepare: $(STATEDIR)/hostapd.prepare

#
# dependencies
#
hostapd_prepare_deps = \
	$(STATEDIR)/hostapd.extract \
	$(STATEDIR)/virtual-xchain.install

HOSTAPD_PATH	=  PATH=$(CROSS_PATH)
HOSTAPD_ENV 	=  $(CROSS_ENV)
#HOSTAPD_ENV	+=
HOSTAPD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#HOSTAPD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
HOSTAPD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
HOSTAPD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
HOSTAPD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/hostapd.prepare: $(hostapd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HOSTAPD_DIR)/config.cache)
	#cd $(HOSTAPD_DIR) && \
	#	$(HOSTAPD_PATH) $(HOSTAPD_ENV) \
	#	./configure $(HOSTAPD_AUTOCONF)
	ln -sf defconfig $(HOSTAPD_DIR)/.config
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

hostapd_compile: $(STATEDIR)/hostapd.compile

hostapd_compile_deps = $(STATEDIR)/hostapd.prepare

$(STATEDIR)/hostapd.compile: $(hostapd_compile_deps)
	@$(call targetinfo, $@)
	$(HOSTAPD_PATH) $(HOSTAPD_ENV) $(MAKE) -C $(HOSTAPD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

hostapd_install: $(STATEDIR)/hostapd.install

$(STATEDIR)/hostapd.install: $(STATEDIR)/hostapd.compile
	@$(call targetinfo, $@)
	##$(HOSTAPD_PATH) $(MAKE) -C $(HOSTAPD_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

hostapd_targetinstall: $(STATEDIR)/hostapd.targetinstall

hostapd_targetinstall_deps = $(STATEDIR)/hostapd.compile 

$(STATEDIR)/hostapd.targetinstall: $(hostapd_targetinstall_deps)
	@$(call targetinfo, $@)
	$(HOSTAPD_PATH) $(HOSTAPD_ENV) $(MAKE) -C $(HOSTAPD_DIR) BINDIR=$(HOSTAPD_IPKG_TMP)/usr/sbin install
	$(CROSSSTRIP) $(HOSTAPD_IPKG_TMP)/usr/sbin/*
	mkdir -p $(HOSTAPD_IPKG_TMP)/etc/rc.d/init.d
	cp -a $(TOPDIR)/config/pics/hostapd 	$(HOSTAPD_IPKG_TMP)/etc/rc.d/init.d
	cp -a $(HOSTAPD_DIR)/hostapd.conf 	$(HOSTAPD_IPKG_TMP)/etc
	mkdir -p $(HOSTAPD_IPKG_TMP)/CONTROL
	echo "Package: hostapd" 							 >$(HOSTAPD_IPKG_TMP)/CONTROL/control
	echo "Source: $(HOSTAPD_URL)"							>>$(HOSTAPD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(HOSTAPD_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(HOSTAPD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(HOSTAPD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(HOSTAPD_IPKG_TMP)/CONTROL/control
	echo "Version: $(HOSTAPD_VERSION)-$(HOSTAPD_VENDOR_VERSION)" 			>>$(HOSTAPD_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(HOSTAPD_IPKG_TMP)/CONTROL/control
	echo "Description: WPA/RSN/EAP Authenticator"					>>$(HOSTAPD_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(HOSTAPD_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_HOSTAPD_INSTALL
ROMPACKAGES += $(STATEDIR)/hostapd.imageinstall
endif

hostapd_imageinstall_deps = $(STATEDIR)/hostapd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/hostapd.imageinstall: $(hostapd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install hostapd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

hostapd_clean:
	rm -rf $(STATEDIR)/hostapd.*
	rm -rf $(HOSTAPD_DIR)

# vim: syntax=make
