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
ifdef PTXCONF_UDEV
PACKAGES += udev
endif

#
# Paths and names
#
UDEV_VENDOR_VERSION	= 1
UDEV_VERSION		= 071
UDEV			= udev-$(UDEV_VERSION)
UDEV_SUFFIX		= tar.bz2
UDEV_URL		= http://kernel.org/pub/linux/utils/kernel/hotplug/$(UDEV).$(UDEV_SUFFIX)
UDEV_SOURCE		= $(SRCDIR)/$(UDEV).$(UDEV_SUFFIX)
UDEV_DIR		= $(BUILDDIR)/$(UDEV)
UDEV_IPKG_TMP		= $(UDEV_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

udev_get: $(STATEDIR)/udev.get

udev_get_deps = $(UDEV_SOURCE)

$(STATEDIR)/udev.get: $(udev_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(UDEV))
	touch $@

$(UDEV_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(UDEV_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

udev_extract: $(STATEDIR)/udev.extract

udev_extract_deps = $(STATEDIR)/udev.get

$(STATEDIR)/udev.extract: $(udev_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UDEV_DIR))
	@$(call extract, $(UDEV_SOURCE))
	@$(call patchin, $(UDEV))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

udev_prepare: $(STATEDIR)/udev.prepare

#
# dependencies
#
udev_prepare_deps = \
	$(STATEDIR)/udev.extract \
	$(STATEDIR)/virtual-xchain.install

UDEV_PATH	=  PATH=$(CROSS_PATH)
UDEV_ENV 	=  $(CROSS_ENV)
#UDEV_ENV	+=
UDEV_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#UDEV_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
UDEV_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
UDEV_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
UDEV_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/udev.prepare: $(udev_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UDEV_DIR)/config.cache)
	#cd $(UDEV_DIR) && \
	#	$(UDEV_PATH) $(UDEV_ENV) \
	#	./configure $(UDEV_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

udev_compile: $(STATEDIR)/udev.compile

udev_compile_deps = $(STATEDIR)/udev.prepare

$(STATEDIR)/udev.compile: $(udev_compile_deps)
	@$(call targetinfo, $@)
	$(UDEV_PATH) $(MAKE) -C $(UDEV_DIR) KERNEL_DIR=$(KERNEL_DIR) CROSS=$(PTXCONF_GNU_TARGET)-
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

udev_install: $(STATEDIR)/udev.install

$(STATEDIR)/udev.install: $(STATEDIR)/udev.compile
	@$(call targetinfo, $@)
	##$(UDEV_PATH) $(MAKE) -C $(UDEV_DIR) install
	sdfsdf
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

udev_targetinstall: $(STATEDIR)/udev.targetinstall

udev_targetinstall_deps = $(STATEDIR)/udev.compile

$(STATEDIR)/udev.targetinstall: $(udev_targetinstall_deps)
	@$(call targetinfo, $@)
	$(UDEV_PATH) $(MAKE) -C $(UDEV_DIR) DESTDIR=$(UDEV_IPKG_TMP) install
	$(CROSSSTRIP) $(UDEV_IPKG_TMP)/sbin/*
	$(CROSSSTRIP) $(UDEV_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(UDEV_IPKG_TMP)/usr/sbin/*
	cp -a $(TOPDIR)/config/pdaXrom/udev/* $(UDEV_IPKG_TMP)/etc/udev/
	rm -rf $(UDEV_IPKG_TMP)/usr/share/man
	mkdir -p $(UDEV_IPKG_TMP)/CONTROL
	echo "Package: udev" 								 >$(UDEV_IPKG_TMP)/CONTROL/control
	echo "Source: $(UDEV_URL)"							>>$(UDEV_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(UDEV_IPKG_TMP)/CONTROL/control
	echo "Section: System"	 							>>$(UDEV_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(UDEV_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(UDEV_IPKG_TMP)/CONTROL/control
	echo "Version: $(UDEV_VERSION)-$(UDEV_VENDOR_VERSION)" 				>>$(UDEV_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(UDEV_IPKG_TMP)/CONTROL/control
	echo "Description: udev is a program which dynamically creates and removes device nodes from /dev" >>$(UDEV_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(UDEV_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_UDEV_INSTALL
ROMPACKAGES += $(STATEDIR)/udev.imageinstall
endif

udev_imageinstall_deps = $(STATEDIR)/udev.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/udev.imageinstall: $(udev_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install udev
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

udev_clean:
	rm -rf $(STATEDIR)/udev.*
	rm -rf $(UDEV_DIR)

# vim: syntax=make
