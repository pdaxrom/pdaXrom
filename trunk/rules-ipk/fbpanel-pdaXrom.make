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
ifdef PTXCONF_FBPANEL-PDAXROM
PACKAGES += fbpanel-pdaXrom
endif

#
# Paths and names
#
FBPANEL-PDAXROM_VENDOR_VERSION	= 1
FBPANEL-PDAXROM_VERSION		= 1.0.0
FBPANEL-PDAXROM			= fbpanel-pdaXrom-$(FBPANEL-PDAXROM_VERSION)
FBPANEL-PDAXROM_SUFFIX		= tar.bz2
FBPANEL-PDAXROM_URL		= http://mail.pdaXrom.org/src/$(FBPANEL-PDAXROM).$(FBPANEL-PDAXROM_SUFFIX)
FBPANEL-PDAXROM_SOURCE		= $(SRCDIR)/$(FBPANEL-PDAXROM).$(FBPANEL-PDAXROM_SUFFIX)
FBPANEL-PDAXROM_DIR		= $(BUILDDIR)/$(FBPANEL-PDAXROM)
FBPANEL-PDAXROM_IPKG_TMP	= $(FBPANEL-PDAXROM_DIR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fbpanel-pdaXrom_get: $(STATEDIR)/fbpanel-pdaXrom.get

fbpanel-pdaXrom_get_deps = $(FBPANEL-PDAXROM_SOURCE)

$(STATEDIR)/fbpanel-pdaXrom.get: $(fbpanel-pdaXrom_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FBPANEL-PDAXROM))
	touch $@

$(FBPANEL-PDAXROM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FBPANEL-PDAXROM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fbpanel-pdaXrom_extract: $(STATEDIR)/fbpanel-pdaXrom.extract

fbpanel-pdaXrom_extract_deps = $(STATEDIR)/fbpanel-pdaXrom.get

$(STATEDIR)/fbpanel-pdaXrom.extract: $(fbpanel-pdaXrom_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FBPANEL-PDAXROM_DIR))
	@$(call extract, $(FBPANEL-PDAXROM_SOURCE))
	@$(call patchin, $(FBPANEL-PDAXROM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fbpanel-pdaXrom_prepare: $(STATEDIR)/fbpanel-pdaXrom.prepare

#
# dependencies
#
fbpanel-pdaXrom_prepare_deps = \
	$(STATEDIR)/fbpanel-pdaXrom.extract \
	$(STATEDIR)/virtual-xchain.install

FBPANEL-PDAXROM_PATH	=  PATH=$(CROSS_PATH)
FBPANEL-PDAXROM_ENV 	=  $(CROSS_ENV)
#FBPANEL-PDAXROM_ENV	+=
FBPANEL-PDAXROM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FBPANEL-PDAXROM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
FBPANEL-PDAXROM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
FBPANEL-PDAXROM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FBPANEL-PDAXROM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fbpanel-pdaXrom.prepare: $(fbpanel-pdaXrom_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FBPANEL-PDAXROM_DIR)/config.cache)
	#cd $(FBPANEL-PDAXROM_DIR) && \
	#	$(FBPANEL-PDAXROM_PATH) $(FBPANEL-PDAXROM_ENV) \
	#	./configure $(FBPANEL-PDAXROM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fbpanel-pdaXrom_compile: $(STATEDIR)/fbpanel-pdaXrom.compile

fbpanel-pdaXrom_compile_deps = $(STATEDIR)/fbpanel-pdaXrom.prepare

$(STATEDIR)/fbpanel-pdaXrom.compile: $(fbpanel-pdaXrom_compile_deps)
	@$(call targetinfo, $@)
	#$(FBPANEL-PDAXROM_PATH) $(MAKE) -C $(FBPANEL-PDAXROM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fbpanel-pdaXrom_install: $(STATEDIR)/fbpanel-pdaXrom.install

$(STATEDIR)/fbpanel-pdaXrom.install: $(STATEDIR)/fbpanel-pdaXrom.compile
	@$(call targetinfo, $@)
	#$(FBPANEL-PDAXROM_PATH) $(MAKE) -C $(FBPANEL-PDAXROM_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fbpanel-pdaXrom_targetinstall: $(STATEDIR)/fbpanel-pdaXrom.targetinstall

fbpanel-pdaXrom_targetinstall_deps = $(STATEDIR)/fbpanel-pdaXrom.compile

$(STATEDIR)/fbpanel-pdaXrom.targetinstall: $(fbpanel-pdaXrom_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(FBPANEL-PDAXROM_PATH) $(MAKE) -C $(FBPANEL-PDAXROM_DIR) DESTDIR=$(FBPANEL-PDAXROM_IPKG_TMP) install
	mkdir -p $(FBPANEL-PDAXROM_IPKG_TMP)/etc/X11
	cp -af $(TOPDIR)/config/pdaXrom/kb  $(FBPANEL-PDAXROM_IPKG_TMP)/etc/X11
	#mkdir -p $(FBPANEL-PDAXROM_IPKG_TMP)/CONTROL
	#echo "Package: fbpanel-pdaxrom" 							 >$(FBPANEL-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Source: $(FBPANEL-PDAXROM_URL)"							>>$(FBPANEL-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Priority: optional" 								>>$(FBPANEL-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Section: X11" 									>>$(FBPANEL-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(FBPANEL-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Architecture: $(SHORT_TARGET)" 							>>$(FBPANEL-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Version: $(FBPANEL-PDAXROM_VERSION)-$(FBPANEL-PDAXROM_VENDOR_VERSION)" 		>>$(FBPANEL-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Depends: fbpanel" 								>>$(FBPANEL-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Description: fbpanel pdaXrom vendor files"					>>$(FBPANEL-PDAXROM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FBPANEL-PDAXROM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FBPANEL-PDAXROM_INSTALL
ROMPACKAGES += $(STATEDIR)/fbpanel-pdaXrom.imageinstall
endif

fbpanel-pdaXrom_imageinstall_deps = $(STATEDIR)/fbpanel-pdaXrom.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fbpanel-pdaXrom.imageinstall: $(fbpanel-pdaXrom_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fbpanel-pdaxrom
	touch $@

# ----------------------------------------------------------------------------
# Image-Vendor-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FBPANEL-PDAXROM_VENDOR-INSTALL
VENDORPACKAGES += $(STATEDIR)/fbpanel-pdaXrom.vendorinstall
endif

fbpanel-pdaXrom_vendorinstall_deps = $(STATEDIR)/fbpanel-pdaXrom.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fbpanel-pdaXrom.vendorinstall: $(fbpanel-pdaXrom_vendorinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fbpanel-pdaxrom
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fbpanel-pdaXrom_clean:
	rm -rf $(STATEDIR)/fbpanel-pdaXrom.*
	rm -rf $(FBPANEL-PDAXROM_DIR)

# vim: syntax=make
