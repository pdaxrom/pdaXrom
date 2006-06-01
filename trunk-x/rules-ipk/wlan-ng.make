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
ifdef PTXCONF_WLAN-NG
PACKAGES += wlan-ng
endif

#
# Paths and names
#
WLAN-NG_VENDOR_VERSION	= 1
WLAN-NG_VERSION		= 0.2.1-pre26
WLAN-NG			= wlan-ng-$(WLAN-NG_VERSION)
WLAN-NG_SUFFIX		= tar.bz2
WLAN-NG_URL		= ftp://ftp.linux-wlan.org/pub/linux-wlan-ng/linux-$(WLAN-NG).$(WLAN-NG_SUFFIX)
WLAN-NG_SOURCE		= $(SRCDIR)/linux-$(WLAN-NG).$(WLAN-NG_SUFFIX)
WLAN-NG_DIR		= $(BUILDDIR)/linux-$(WLAN-NG)
WLAN-NG_IPKG_TMP	= $(WLAN-NG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

wlan-ng_get: $(STATEDIR)/wlan-ng.get

wlan-ng_get_deps = $(WLAN-NG_SOURCE)

$(STATEDIR)/wlan-ng.get: $(wlan-ng_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, linux-$(WLAN-NG))
	touch $@

$(WLAN-NG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WLAN-NG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

wlan-ng_extract: $(STATEDIR)/wlan-ng.extract

wlan-ng_extract_deps = $(STATEDIR)/wlan-ng.get

$(STATEDIR)/wlan-ng.extract: $(wlan-ng_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(WLAN-NG_DIR))
	@$(call extract, $(WLAN-NG_SOURCE))
	@$(call patchin, linux-$(WLAN-NG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

wlan-ng_prepare: $(STATEDIR)/wlan-ng.prepare

#
# dependencies
#
wlan-ng_prepare_deps = \
	$(STATEDIR)/wlan-ng.extract \
	$(STATEDIR)/virtual-xchain.install

WLAN-NG_PATH	=  PATH=$(CROSS_PATH)
WLAN-NG_ENV 	=  $(CROSS_ENV)
#WLAN-NG_ENV	+=
WLAN-NG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#WLAN-NG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
WLAN-NG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
WLAN-NG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
WLAN-NG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/wlan-ng.prepare: $(wlan-ng_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WLAN-NG_DIR)/config.cache)
ifdef PTXCONF_WLAN-NG-PCI
	echo "PRISM2_PCI=y" >> $(WLAN-NG_DIR)/config.in
else
	echo "PRISM2_PCI=n" >> $(WLAN-NG_DIR)/config.in
endif
ifdef PTXCONF_WLAN-NG-PLX
	echo "PRISM2_PLX=y" >> $(WLAN-NG_DIR)/config.in
else
	echo "PRISM2_PLX=n" >> $(WLAN-NG_DIR)/config.in
endif
ifdef PTXCONF_WLAN-NG-PCMCIA
	echo "PRISM2_PCMCIA=y" >> $(WLAN-NG_DIR)/config.in
else
	echo "PRISM2_PCMCIA=n" >> $(WLAN-NG_DIR)/config.in
endif
ifdef PTXCONF_WLAN-NG-USB
	echo "PRISM2_USB=y" >> $(WLAN-NG_DIR)/config.in
else
	echo "PRISM2_USB=n" >> $(WLAN-NG_DIR)/config.in
endif
	echo "LINUX_SRC=$(KERNEL_DIR)" >> $(WLAN-NG_DIR)/config.in
	#echo "CROSS_COMPILE_ENABLED=y" >> $(WLAN-NG_DIR)/config.in
	#echo "CROSS_COMPILE=$(PTXCONF_GNU_TARGET)-" >> $(WLAN-NG_DIR)/config.in
	perl -i -p -e "s,TARGET_ROOT_ON_HOST=,TARGET_ROOT_ON_HOST=$(WLAN-NG_IPKG_TMP),g" $(WLAN-NG_DIR)/config.in
	cd $(WLAN-NG_DIR) && \
		$(WLAN-NG_PATH) make auto_config CROSS_COMPILE=$(PTXCONF_GNU_TARGET)-
#		$(WLAN-NG_PATH) $(WLAN-NG_ENV)
#		./configure $(WLAN-NG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

wlan-ng_compile: $(STATEDIR)/wlan-ng.compile

wlan-ng_compile_deps = $(STATEDIR)/wlan-ng.prepare

$(STATEDIR)/wlan-ng.compile: $(wlan-ng_compile_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_KERNEL_EXTERNAL_GCC
	cd $(WLAN-NG_DIR) && PATH=$(PTXCONF_KERNEL_EXTERNAL_GCC_PATH):$(PATH) $(MAKE) -C $(WLAN-NG_DIR) all
else
	cd $(WLAN-NG_DIR) && $(WLAN-NG_PATH) $(MAKE) -C $(WLAN-NG_DIR) all CROSS_COMPILE=$(PTXCONF_GNU_TARGET)-
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

wlan-ng_install: $(STATEDIR)/wlan-ng.install

$(STATEDIR)/wlan-ng.install: $(STATEDIR)/wlan-ng.compile
	@$(call targetinfo, $@)
	#$(WLAN-NG_PATH) $(MAKE) -C $(WLAN-NG_DIR) install
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

wlan-ng_targetinstall: $(STATEDIR)/wlan-ng.targetinstall

wlan-ng_targetinstall_deps = $(STATEDIR)/wlan-ng.compile

$(STATEDIR)/wlan-ng.targetinstall: $(wlan-ng_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(WLAN-NG_PATH) $(MAKE) -C $(WLAN-NG_DIR) DESTDIR=$(WLAN-NG_IPKG_TMP) install
	$(WLAN-NG_PATH) $(MAKE) -C $(WLAN-NG_DIR) install
	$(CROSSSTRIP) $(WLAN-NG_IPKG_TMP)/sbin/*
#ifdef PTXCONF_WLAN-NG-USB
#ifeq ("sharp-tosa", $(PTXCONF_VENDORTWEAKS_USERCONFIG))
#	$(INSTALL) -m 755 $(TOPDIR)/config/pdaXrom/6000-usb-host/usbctl $(WLAN-NG_IPKG_TMP)/sbin/
#endif
#endif
	rm -rf $(WLAN-NG_IPKG_TMP)/usr
	mkdir -p $(WLAN-NG_IPKG_TMP)/CONTROL
	echo "Package: wlan-ng" 							 >$(WLAN-NG_IPKG_TMP)/CONTROL/control
	echo "Source: $(WLAN-NG_URL)"						>>$(WLAN-NG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(WLAN-NG_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(WLAN-NG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(WLAN-NG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(WLAN-NG_IPKG_TMP)/CONTROL/control
	echo "Version: $(WLAN-NG_VERSION)-$(WLAN-NG_VENDOR_VERSION)" 			>>$(WLAN-NG_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(WLAN-NG_IPKG_TMP)/CONTROL/control
	echo "Description: The linux-wlan package is a linux device driver and subsystem package that is intended to provide the full range of IEEE 802.11 MAC management capabilities for use in user-mode utilities and scripts." >>$(WLAN-NG_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh" 				 > $(WLAN-NG_IPKG_TMP)/CONTROL/postinst
	echo "depmod -a"				>> $(WLAN-NG_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(WLAN-NG_IPKG_TMP)/CONTROL/postinst
	cd $(FEEDDIR) && $(XMKIPKG) $(WLAN-NG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WLAN-NG_INSTALL
ROMPACKAGES += $(STATEDIR)/wlan-ng.imageinstall
endif

wlan-ng_imageinstall_deps = $(STATEDIR)/wlan-ng.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/wlan-ng.imageinstall: $(wlan-ng_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install wlan-ng
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

wlan-ng_clean:
	rm -rf $(STATEDIR)/wlan-ng.*
	rm -rf $(WLAN-NG_DIR)

# vim: syntax=make
