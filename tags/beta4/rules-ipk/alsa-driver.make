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
ifdef PTXCONF_ALSA-DRIVER
PACKAGES += alsa-driver
endif

#
# Paths and names
#
ALSA-DRIVER_VENDOR_VERSION	= 1
ALSA-DRIVER_VERSION		= 1.0.11rc4
ALSA-DRIVER			= alsa-driver-$(ALSA-DRIVER_VERSION)
ALSA-DRIVER_SUFFIX		= tar.bz2
ALSA-DRIVER_URL			= ftp://ftp.alsa-project.org/pub/driver/$(ALSA-DRIVER).$(ALSA-DRIVER_SUFFIX)
ALSA-DRIVER_SOURCE		= $(SRCDIR)/$(ALSA-DRIVER).$(ALSA-DRIVER_SUFFIX)
ALSA-DRIVER_DIR			= $(BUILDDIR)/$(ALSA-DRIVER)
ALSA-DRIVER_IPKG_TMP		= $(ALSA-DRIVER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

alsa-driver_get: $(STATEDIR)/alsa-driver.get

alsa-driver_get_deps = $(ALSA-DRIVER_SOURCE)

$(STATEDIR)/alsa-driver.get: $(alsa-driver_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ALSA-DRIVER))
	touch $@

$(ALSA-DRIVER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ALSA-DRIVER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

alsa-driver_extract: $(STATEDIR)/alsa-driver.extract

alsa-driver_extract_deps = $(STATEDIR)/alsa-driver.get

$(STATEDIR)/alsa-driver.extract: $(alsa-driver_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALSA-DRIVER_DIR))
	@$(call extract, $(ALSA-DRIVER_SOURCE))
	@$(call patchin, $(ALSA-DRIVER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

alsa-driver_prepare: $(STATEDIR)/alsa-driver.prepare

#
# dependencies
#
alsa-driver_prepare_deps = \
	$(STATEDIR)/alsa-driver.extract \
	$(STATEDIR)/virtual-xchain.install

ALSA-DRIVER_PATH	=  PATH=$(CROSS_PATH)
ALSA-DRIVER_ENV 	=  $(CROSS_ENV)
#ALSA-DRIVER_ENV	+=
ALSA-DRIVER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ALSA-DRIVER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ALSA-DRIVER_AUTOCONF = \
	--prefix=/usr \
	--sysconfdir=/etc \
	--with-kernel=$(KERNEL_DIR) \
	--with-build=$(KERNEL_DIR) \
	--with-cards=all \
	--with-oss=yes \
	--with-sequencer=yes

#	--with-cross=$(PTXCONF_GNU_TARGET)-

#	--build=$(GNU_HOST)
#	--host=$(PTXCONF_GNU_TARGET)

ifdef PTXCONF_XFREE430
ALSA-DRIVER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ALSA-DRIVER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/alsa-driver.prepare: $(alsa-driver_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALSA-DRIVER_DIR)/config.cache)
	cd $(ALSA-DRIVER_DIR) && \
		$(ALSA-DRIVER_PATH) $(ALSA-DRIVER_ENV) \
		./configure $(ALSA-DRIVER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

alsa-driver_compile: $(STATEDIR)/alsa-driver.compile

alsa-driver_compile_deps = $(STATEDIR)/alsa-driver.prepare

$(STATEDIR)/alsa-driver.compile: $(alsa-driver_compile_deps)
	@$(call targetinfo, $@)
	$(ALSA-DRIVER_PATH) $(MAKE) -C $(ALSA-DRIVER_DIR)
	# ARCH=$(PTXCONF_ARCH)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

alsa-driver_install: $(STATEDIR)/alsa-driver.install

$(STATEDIR)/alsa-driver.install: $(STATEDIR)/alsa-driver.compile
	@$(call targetinfo, $@)
	$(ALSA-DRIVER_PATH) $(MAKE) -C $(ALSA-DRIVER_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

alsa-driver_targetinstall: $(STATEDIR)/alsa-driver.targetinstall

alsa-driver_targetinstall_deps = $(STATEDIR)/alsa-driver.compile

$(STATEDIR)/alsa-driver.targetinstall: $(alsa-driver_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ALSA-DRIVER_IPKG_TMP)/usr/include
	$(ALSA-DRIVER_PATH) $(MAKE) -C $(ALSA-DRIVER_DIR) DESTDIR=$(ALSA-DRIVER_IPKG_TMP) install
	mkdir -p $(ALSA-DRIVER_IPKG_TMP)/CONTROL
	echo "Package: alsa-driver" 								 >$(ALSA-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Source: $(ALSA-DRIVER_URL)"							>>$(ALSA-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(ALSA-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 								>>$(ALSA-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(ALSA-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(ALSA-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Version: $(ALSA-DRIVER_VERSION)-$(ALSA-DRIVER_VENDOR_VERSION)" 			>>$(ALSA-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Depends: " 									>>$(ALSA-DRIVER_IPKG_TMP)/CONTROL/control
	echo "Description: ALSA kernel drivers"							>>$(ALSA-DRIVER_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(ALSA-DRIVER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ALSA-DRIVER_INSTALL
ROMPACKAGES += $(STATEDIR)/alsa-driver.imageinstall
endif

alsa-driver_imageinstall_deps = $(STATEDIR)/alsa-driver.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/alsa-driver.imageinstall: $(alsa-driver_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install alsa-driver
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

alsa-driver_clean:
	rm -rf $(STATEDIR)/alsa-driver.*
	rm -rf $(ALSA-DRIVER_DIR)

# vim: syntax=make
