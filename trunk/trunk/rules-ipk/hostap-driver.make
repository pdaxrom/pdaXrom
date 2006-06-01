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
ifdef PTXCONF_HOSTAP-DRIVER
PACKAGES += hostap-driver
endif

#
# Paths and names
#
HOSTAP-DRIVER_VENDOR_VERSION	= 1
HOSTAP-DRIVER_VERSION		= 0.4.7
HOSTAP-DRIVER			= hostap-driver-$(HOSTAP-DRIVER_VERSION)
HOSTAP-DRIVER_SUFFIX		= tar.gz
HOSTAP-DRIVER_URL		= http://hostap.epitest.fi/releases/$(HOSTAP-DRIVER).$(HOSTAP-DRIVER_SUFFIX)
HOSTAP-DRIVER_SOURCE		= $(SRCDIR)/$(HOSTAP-DRIVER).$(HOSTAP-DRIVER_SUFFIX)
HOSTAP-DRIVER_DIR		= $(BUILDDIR)/$(HOSTAP-DRIVER)
HOSTAP-DRIVER_IPKG_TMP		= $(HOSTAP-DRIVER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

hostap-driver_get: $(STATEDIR)/hostap-driver.get

hostap-driver_get_deps = $(HOSTAP-DRIVER_SOURCE)

$(STATEDIR)/hostap-driver.get: $(hostap-driver_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(HOSTAP-DRIVER))
	touch $@

$(HOSTAP-DRIVER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(HOSTAP-DRIVER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

hostap-driver_extract: $(STATEDIR)/hostap-driver.extract

hostap-driver_extract_deps = $(STATEDIR)/hostap-driver.get

$(STATEDIR)/hostap-driver.extract: $(hostap-driver_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HOSTAP-DRIVER_DIR))
	@$(call extract, $(HOSTAP-DRIVER_SOURCE))
	@$(call patchin, $(HOSTAP-DRIVER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

hostap-driver_prepare: $(STATEDIR)/hostap-driver.prepare

#
# dependencies
#
hostap-driver_prepare_deps = \
	$(STATEDIR)/hostap-driver.extract \
	$(STATEDIR)/virtual-xchain.install

HOSTAP-DRIVER_PATH	=  PATH=$(CROSS_PATH)
HOSTAP-DRIVER_ENV 	=  $(CROSS_ENV)
#HOSTAP-DRIVER_ENV	+=
HOSTAP-DRIVER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#HOSTAP-DRIVER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
HOSTAP-DRIVER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
HOSTAP-DRIVER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
HOSTAP-DRIVER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/hostap-driver.prepare: $(hostap-driver_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HOSTAP-DRIVER_DIR)/config.cache)
	#cd $(HOSTAP-DRIVER_DIR) && \
	#	$(HOSTAP-DRIVER_PATH) $(HOSTAP-DRIVER_ENV) \
	#	./configure $(HOSTAP-DRIVER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

hostap-driver_compile: $(STATEDIR)/hostap-driver.compile

hostap-driver_compile_deps = $(STATEDIR)/hostap-driver.prepare

$(STATEDIR)/hostap-driver.compile: $(hostap-driver_compile_deps)
	@$(call targetinfo, $@)
	cd $(HOSTAP-DRIVER_DIR) && $(HOSTAP-DRIVER_PATH) $(KERNEL_PATH) \
	    $(MAKE) -C $(HOSTAP-DRIVER_DIR) KERNEL_PATH=$(KERNEL_DIR) \
		$(KERNEL_MAKEVARS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

hostap-driver_install: $(STATEDIR)/hostap-driver.install

$(STATEDIR)/hostap-driver.install: $(STATEDIR)/hostap-driver.compile
	@$(call targetinfo, $@)
	$(HOSTAP-DRIVER_PATH) $(MAKE) -C $(HOSTAP-DRIVER_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

hostap-driver_targetinstall: $(STATEDIR)/hostap-driver.targetinstall

hostap-driver_targetinstall_deps = $(STATEDIR)/hostap-driver.compile

$(STATEDIR)/hostap-driver.targetinstall: $(hostap-driver_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(HOSTAP-DRIVER_IPKG_TMP)/etc/pcmcia
	cd $(HOSTAP-DRIVER_DIR) && $(HOSTAP-DRIVER_PATH) $(KERNEL_PATH) $(MAKE) -C $(HOSTAP-DRIVER_DIR) DESTDIR=$(HOSTAP-DRIVER_IPKG_TMP) install KERNEL_PATH=$(KERNEL_DIR)
	mkdir -p $(HOSTAP-DRIVER_IPKG_TMP)/CONTROL
	echo "Package: hostap-driver" 							 >$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Source: $(HOSTAP-DRIVER_URL)"						>>$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Version: $(HOSTAP-DRIVER_VERSION)-$(HOSTAP-DRIVER_VENDOR_VERSION)" 	>>$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Description: Host AP driver for Intersil Prism2/2.5/3, hostapd, and WPA Supplicant" >>$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh"								 >$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/postinst
	echo "/sbin/depmod -a"								>>$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/pcmcia stop"						>>$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/pcmcia start"						>>$(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(HOSTAP-DRIVER_IPKG_TMP)/CONTROL/postinst
	cd $(FEEDDIR) && $(XMKIPKG) $(HOSTAP-DRIVER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_HOSTAP-DRIVER_INSTALL
ROMPACKAGES += $(STATEDIR)/hostap-driver.imageinstall
endif

hostap-driver_imageinstall_deps = $(STATEDIR)/hostap-driver.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/hostap-driver.imageinstall: $(hostap-driver_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install hostap-driver
	rm -f $(ROOTDIR)/usr/lib/ipkg/info/hostap-driver.postinst
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

hostap-driver_clean:
	rm -rf $(STATEDIR)/hostap-driver.*
	rm -rf $(HOSTAP-DRIVER_DIR)

# vim: syntax=make
