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
ifdef PTXCONF_WPA_SUPPLICANT
PACKAGES += wpa_supplicant
endif

#
# Paths and names
#
WPA_SUPPLICANT_VENDOR_VERSION	= 1
WPA_SUPPLICANT_VERSION		= 0.4.7
WPA_SUPPLICANT			= wpa_supplicant-$(WPA_SUPPLICANT_VERSION)
WPA_SUPPLICANT_SUFFIX		= tar.gz
WPA_SUPPLICANT_URL		= http://hostap.epitest.fi/releases/$(WPA_SUPPLICANT).$(WPA_SUPPLICANT_SUFFIX)
WPA_SUPPLICANT_SOURCE		= $(SRCDIR)/$(WPA_SUPPLICANT).$(WPA_SUPPLICANT_SUFFIX)
WPA_SUPPLICANT_DIR		= $(BUILDDIR)/$(WPA_SUPPLICANT)
WPA_SUPPLICANT_IPKG_TMP		= $(WPA_SUPPLICANT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

wpa_supplicant_get: $(STATEDIR)/wpa_supplicant.get

wpa_supplicant_get_deps = $(WPA_SUPPLICANT_SOURCE)

$(STATEDIR)/wpa_supplicant.get: $(wpa_supplicant_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(WPA_SUPPLICANT))
	touch $@

$(WPA_SUPPLICANT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WPA_SUPPLICANT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

wpa_supplicant_extract: $(STATEDIR)/wpa_supplicant.extract

wpa_supplicant_extract_deps = $(STATEDIR)/wpa_supplicant.get

$(STATEDIR)/wpa_supplicant.extract: $(wpa_supplicant_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WPA_SUPPLICANT_DIR))
	@$(call extract, $(WPA_SUPPLICANT_SOURCE))
	@$(call patchin, $(WPA_SUPPLICANT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

wpa_supplicant_prepare: $(STATEDIR)/wpa_supplicant.prepare

#
# dependencies
#
wpa_supplicant_prepare_deps = \
	$(STATEDIR)/wpa_supplicant.extract \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/readline.install \
	$(STATEDIR)/virtual-xchain.install

WPA_SUPPLICANT_PATH	=  PATH=$(CROSS_PATH)
WPA_SUPPLICANT_ENV 	=  $(CROSS_ENV)
#WPA_SUPPLICANT_ENV	+=
WPA_SUPPLICANT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#WPA_SUPPLICANT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
WPA_SUPPLICANT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
WPA_SUPPLICANT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
WPA_SUPPLICANT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/wpa_supplicant.prepare: $(wpa_supplicant_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WPA_SUPPLICANT_DIR)/config.cache)
	#cd $(WPA_SUPPLICANT_DIR) && \
	#	$(WPA_SUPPLICANT_PATH) $(WPA_SUPPLICANT_ENV) \
	#	./configure $(WPA_SUPPLICANT_AUTOCONF)
	ln -sf defconfig $(WPA_SUPPLICANT_DIR)/.config
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

wpa_supplicant_compile: $(STATEDIR)/wpa_supplicant.compile

wpa_supplicant_compile_deps = $(STATEDIR)/wpa_supplicant.prepare

$(STATEDIR)/wpa_supplicant.compile: $(wpa_supplicant_compile_deps)
	@$(call targetinfo, $@)
	$(WPA_SUPPLICANT_PATH) $(WPA_SUPPLICANT_ENV) $(MAKE) -C $(WPA_SUPPLICANT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

wpa_supplicant_install: $(STATEDIR)/wpa_supplicant.install

$(STATEDIR)/wpa_supplicant.install: $(STATEDIR)/wpa_supplicant.compile
	@$(call targetinfo, $@)
	##$(WPA_SUPPLICANT_PATH) $(MAKE) -C $(WPA_SUPPLICANT_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

wpa_supplicant_targetinstall: $(STATEDIR)/wpa_supplicant.targetinstall

wpa_supplicant_targetinstall_deps = $(STATEDIR)/wpa_supplicant.compile

$(STATEDIR)/wpa_supplicant.targetinstall: $(wpa_supplicant_targetinstall_deps)
	@$(call targetinfo, $@)
	$(WPA_SUPPLICANT_PATH) $(MAKE) -C $(WPA_SUPPLICANT_DIR) DESTDIR=$(WPA_SUPPLICANT_IPKG_TMP) install
	$(CROSSSTRIP) $(WPA_SUPPLICANT_IPKG_TMP)/usr/sbin/*
	mkdir -p $(WPA_SUPPLICANT_IPKG_TMP)/etc/rc.d/init.d
	cp -a $(TOPDIR)/config/pics/wpa_supplicant 	$(WPA_SUPPLICANT_IPKG_TMP)/etc/rc.d/init.d
	cp -a $(WPA_SUPPLICANT_DIR)/wpa_supplicant.conf $(WPA_SUPPLICANT_IPKG_TMP)/etc
	mkdir -p $(WPA_SUPPLICANT_IPKG_TMP)/CONTROL
	echo "Package: wpa-supplicant" 							 >$(WPA_SUPPLICANT_IPKG_TMP)/CONTROL/control
	echo "Source: $(WPA_SUPPLICANT_URL)"						>>$(WPA_SUPPLICANT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(WPA_SUPPLICANT_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(WPA_SUPPLICANT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(WPA_SUPPLICANT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(WPA_SUPPLICANT_IPKG_TMP)/CONTROL/control
	echo "Version: $(WPA_SUPPLICANT_VERSION)-$(WPA_SUPPLICANT_VENDOR_VERSION)" 	>>$(WPA_SUPPLICANT_IPKG_TMP)/CONTROL/control
	echo "Depends: openssl, ncurses, readline" 					>>$(WPA_SUPPLICANT_IPKG_TMP)/CONTROL/control
	echo "Description: WPA/RSN Supplicant (wpa_supplicant)"				>>$(WPA_SUPPLICANT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WPA_SUPPLICANT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WPA_SUPPLICANT_INSTALL
ROMPACKAGES += $(STATEDIR)/wpa_supplicant.imageinstall
endif

wpa_supplicant_imageinstall_deps = $(STATEDIR)/wpa_supplicant.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/wpa_supplicant.imageinstall: $(wpa_supplicant_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install wpa-supplicant
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

wpa_supplicant_clean:
	rm -rf $(STATEDIR)/wpa_supplicant.*
	rm -rf $(WPA_SUPPLICANT_DIR)

# vim: syntax=make
