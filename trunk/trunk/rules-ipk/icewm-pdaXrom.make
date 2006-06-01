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
ifdef PTXCONF_ICEWM-PDAXROM
PACKAGES += icewm-pdaXrom
endif

#
# Paths and names
#
ICEWM-PDAXROM_VENDOR_VERSION	= 2
ICEWM-PDAXROM_VERSION		= 0.0.5
ICEWM-PDAXROM			= icewm-pdaXrom-$(ICEWM-PDAXROM_VERSION)
ICEWM-PDAXROM_SUFFIX		= tar.bz2
ICEWM-PDAXROM_URL		= http://www.pdaXrom.org/src/$(ICEWM-PDAXROM).$(ICEWM-PDAXROM_SUFFIX)
ICEWM-PDAXROM_SOURCE		= $(SRCDIR)/$(ICEWM-PDAXROM).$(ICEWM-PDAXROM_SUFFIX)
ICEWM-PDAXROM_DIR		= $(BUILDDIR)/$(ICEWM-PDAXROM)
ICEWM-PDAXROM_IPKG_TMP		= $(ICEWM-PDAXROM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

icewm-pdaXrom_get: $(STATEDIR)/icewm-pdaXrom.get

icewm-pdaXrom_get_deps = $(ICEWM-PDAXROM_SOURCE)

$(STATEDIR)/icewm-pdaXrom.get: $(icewm-pdaXrom_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ICEWM-PDAXROM))
	touch $@

$(ICEWM-PDAXROM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ICEWM-PDAXROM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

icewm-pdaXrom_extract: $(STATEDIR)/icewm-pdaXrom.extract

icewm-pdaXrom_extract_deps = $(STATEDIR)/icewm-pdaXrom.get

$(STATEDIR)/icewm-pdaXrom.extract: $(icewm-pdaXrom_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ICEWM-PDAXROM_DIR))
	@$(call extract, $(ICEWM-PDAXROM_SOURCE))
	@$(call patchin, $(ICEWM-PDAXROM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

icewm-pdaXrom_prepare: $(STATEDIR)/icewm-pdaXrom.prepare

#
# dependencies
#
icewm-pdaXrom_prepare_deps = \
	$(STATEDIR)/icewm-pdaXrom.extract \
	$(STATEDIR)/virtual-xchain.install

ICEWM-PDAXROM_PATH	=  PATH=$(CROSS_PATH)
ICEWM-PDAXROM_ENV 	=  $(CROSS_ENV)
#ICEWM-PDAXROM_ENV	+=
ICEWM-PDAXROM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ICEWM-PDAXROM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ICEWM-PDAXROM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ICEWM-PDAXROM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ICEWM-PDAXROM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/icewm-pdaXrom.prepare: $(icewm-pdaXrom_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ICEWM-PDAXROM_DIR)/config.cache)
	#cd $(ICEWM-PDAXROM_DIR) && \
	#	$(ICEWM-PDAXROM_PATH) $(ICEWM-PDAXROM_ENV) \
	#	./configure $(ICEWM-PDAXROM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

icewm-pdaXrom_compile: $(STATEDIR)/icewm-pdaXrom.compile

icewm-pdaXrom_compile_deps = $(STATEDIR)/icewm-pdaXrom.prepare

$(STATEDIR)/icewm-pdaXrom.compile: $(icewm-pdaXrom_compile_deps)
	@$(call targetinfo, $@)
	#$(ICEWM-PDAXROM_PATH) $(MAKE) -C $(ICEWM-PDAXROM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

icewm-pdaXrom_install: $(STATEDIR)/icewm-pdaXrom.install

$(STATEDIR)/icewm-pdaXrom.install: $(STATEDIR)/icewm-pdaXrom.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

icewm-pdaXrom_targetinstall: $(STATEDIR)/icewm-pdaXrom.targetinstall

icewm-pdaXrom_targetinstall_deps = $(STATEDIR)/icewm-pdaXrom.compile

$(STATEDIR)/icewm-pdaXrom.targetinstall: $(icewm-pdaXrom_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ICEWM-PDAXROM_IPKG_TMP)/etc/X11
	cp -af $(TOPDIR)/config/pdaXrom/kb $(ICEWM-PDAXROM_IPKG_TMP)/etc/X11
	mkdir -p $(ICEWM-PDAXROM_IPKG_TMP)/CONTROL
	echo "Package: icewm-pdaxrom" 										 >$(ICEWM-PDAXROM_IPKG_TMP)/CONTROL/control
	echo "Source: $(ICEWM-PDAXROM_URL)"									>>$(ICEWM-PDAXROM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(ICEWM-PDAXROM_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 										>>$(ICEWM-PDAXROM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(ICEWM-PDAXROM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(ICEWM-PDAXROM_IPKG_TMP)/CONTROL/control
	echo "Version: $(ICEWM-PDAXROM_VERSION)-$(ICEWM-PDAXROM_VENDOR_VERSION)" 				>>$(ICEWM-PDAXROM_IPKG_TMP)/CONTROL/control
	echo "Depends: icewm" 											>>$(ICEWM-PDAXROM_IPKG_TMP)/CONTROL/control
	echo "Description: IceWM pdaXrom specific files"							>>$(ICEWM-PDAXROM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ICEWM-PDAXROM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ICEWM-PDAXROM_INSTALL
ROMPACKAGES += $(STATEDIR)/icewm-pdaXrom.imageinstall
endif

icewm-pdaXrom_imageinstall_deps = $(STATEDIR)/icewm-pdaXrom.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/icewm-pdaXrom.imageinstall: $(icewm-pdaXrom_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install icewm-pdaxrom
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

icewm-pdaXrom_clean:
	rm -rf $(STATEDIR)/icewm-pdaXrom.*
	rm -rf $(ICEWM-PDAXROM_DIR)

# vim: syntax=make
