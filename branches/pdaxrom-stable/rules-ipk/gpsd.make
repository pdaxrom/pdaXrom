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
ifdef PTXCONF_GPSD
PACKAGES += gpsd
endif

#
# Paths and names
#
GPSD_VENDOR_VERSION	= 1
GPSD_VERSION		= 2.22
GPSD			= gpsd-$(GPSD_VERSION)
GPSD_SUFFIX		= tar.gz
GPSD_URL		= http://download.berlios.de/gpsd/$(GPSD).$(GPSD_SUFFIX)
GPSD_SOURCE		= $(SRCDIR)/$(GPSD).$(GPSD_SUFFIX)
GPSD_DIR		= $(BUILDDIR)/$(GPSD)
GPSD_IPKG_TMP		= $(GPSD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gpsd_get: $(STATEDIR)/gpsd.get

gpsd_get_deps = $(GPSD_SOURCE)

$(STATEDIR)/gpsd.get: $(gpsd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GPSD))
	touch $@

$(GPSD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GPSD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gpsd_extract: $(STATEDIR)/gpsd.extract

gpsd_extract_deps = $(STATEDIR)/gpsd.get

$(STATEDIR)/gpsd.extract: $(gpsd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GPSD_DIR))
	@$(call extract, $(GPSD_SOURCE))
	@$(call patchin, $(GPSD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gpsd_prepare: $(STATEDIR)/gpsd.prepare

#
# dependencies
#
gpsd_prepare_deps = \
	$(STATEDIR)/gpsd.extract \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

GPSD_PATH	=  PATH=$(CROSS_PATH)
GPSD_ENV 	=  $(CROSS_ENV)
#GPSD_ENV	+=
GPSD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GPSD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GPSD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
GPSD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GPSD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gpsd.prepare: $(gpsd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GPSD_DIR)/config.cache)
	cd $(GPSD_DIR) && \
		$(GPSD_PATH) $(GPSD_ENV) \
		./configure $(GPSD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gpsd_compile: $(STATEDIR)/gpsd.compile

gpsd_compile_deps = $(STATEDIR)/gpsd.prepare

$(STATEDIR)/gpsd.compile: $(gpsd_compile_deps)
	@$(call targetinfo, $@)
	$(GPSD_PATH) $(MAKE) -C $(GPSD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gpsd_install: $(STATEDIR)/gpsd.install

$(STATEDIR)/gpsd.install: $(STATEDIR)/gpsd.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gpsd_targetinstall: $(STATEDIR)/gpsd.targetinstall

gpsd_targetinstall_deps = $(STATEDIR)/gpsd.compile \
	$(STATEDIR)/ncurses.targetinstall \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/gpsd.targetinstall: $(gpsd_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GPSD_PATH) $(MAKE) -C $(GPSD_DIR) DESTDIR=$(GPSD_IPKG_TMP) install
	rm -rf $(GPSD_IPKG_TMP)/usr/include
	rm -rf $(GPSD_IPKG_TMP)/usr/man
	rm -rf $(GPSD_IPKG_TMP)/usr/lib/libgps.la
	$(CROSSSTRIP) $(GPSD_IPKG_TMP)/usr/lib/*.so*
	$(CROSSSTRIP) $(GPSD_IPKG_TMP)/usr/bin/{sirfmon,xgps,xgpsspeed}
	$(CROSSSTRIP) $(GPSD_IPKG_TMP)/usr/sbin/gpsd
	mkdir -p $(GPSD_IPKG_TMP)/CONTROL
	echo "Package: gpsd" 								 >$(GPSD_IPKG_TMP)/CONTROL/control
	echo "Source: $(GPSD_URL)"						>>$(GPSD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPSD_IPKG_TMP)/CONTROL/control
	echo "Section: Navigation" 							>>$(GPSD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPSD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPSD_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPSD_VERSION)-$(GPSD_VENDOR_VERSION)" 				>>$(GPSD_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree, ncurses" 						>>$(GPSD_IPKG_TMP)/CONTROL/control
	echo "Description: gpsd is a service daemon that monitors a GPS attached to a host computer through a serial or USB port, making its data on the location/course/velocity of the sensor available to be queried on TCP port 2947 of the host computer." >>$(GPSD_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(GPSD_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GPSD_INSTALL
ROMPACKAGES += $(STATEDIR)/gpsd.imageinstall
endif

gpsd_imageinstall_deps = $(STATEDIR)/gpsd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gpsd.imageinstall: $(gpsd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gpsd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gpsd_clean:
	rm -rf $(STATEDIR)/gpsd.*
	rm -rf $(GPSD_DIR)

# vim: syntax=make
