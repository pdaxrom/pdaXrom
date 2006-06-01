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
ifdef PTXCONF_GPSDRIVE
PACKAGES += gpsdrive
endif

#
# Paths and names
#
GPSDRIVE_VENDOR_VERSION	= 1
GPSDRIVE_VERSION	= 2.10pre2
GPSDRIVE		= gpsdrive-$(GPSDRIVE_VERSION)
GPSDRIVE_SUFFIX		= tar.gz
GPSDRIVE_URL		= http://gpsdrive.kraftvoll.at/$(GPSDRIVE).$(GPSDRIVE_SUFFIX)
GPSDRIVE_SOURCE		= $(SRCDIR)/$(GPSDRIVE).$(GPSDRIVE_SUFFIX)
GPSDRIVE_DIR		= $(BUILDDIR)/$(GPSDRIVE)
GPSDRIVE_IPKG_TMP	= $(GPSDRIVE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gpsdrive_get: $(STATEDIR)/gpsdrive.get

gpsdrive_get_deps = $(GPSDRIVE_SOURCE)

$(STATEDIR)/gpsdrive.get: $(gpsdrive_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GPSDRIVE))
	touch $@

$(GPSDRIVE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GPSDRIVE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gpsdrive_extract: $(STATEDIR)/gpsdrive.extract

gpsdrive_extract_deps = $(STATEDIR)/gpsdrive.get

$(STATEDIR)/gpsdrive.extract: $(gpsdrive_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GPSDRIVE_DIR))
	@$(call extract, $(GPSDRIVE_SOURCE))
	@$(call patchin, $(GPSDRIVE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gpsdrive_prepare: $(STATEDIR)/gpsdrive.prepare

#
# dependencies
#
gpsdrive_prepare_deps = \
	$(STATEDIR)/gpsdrive.extract \
	$(STATEDIR)/virtual-xchain.install

GPSDRIVE_PATH	=  PATH=$(CROSS_PATH)
GPSDRIVE_ENV 	=  $(CROSS_ENV)
#GPSDRIVE_ENV	+=
GPSDRIVE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GPSDRIVE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GPSDRIVE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GPSDRIVE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GPSDRIVE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gpsdrive.prepare: $(gpsdrive_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GPSDRIVE_DIR)/config.cache)
	cd $(GPSDRIVE_DIR) && \
		$(GPSDRIVE_PATH) $(GPSDRIVE_ENV) \
		./configure $(GPSDRIVE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gpsdrive_compile: $(STATEDIR)/gpsdrive.compile

gpsdrive_compile_deps = $(STATEDIR)/gpsdrive.prepare

$(STATEDIR)/gpsdrive.compile: $(gpsdrive_compile_deps)
	@$(call targetinfo, $@)
	$(GPSDRIVE_PATH) $(MAKE) -C $(GPSDRIVE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gpsdrive_install: $(STATEDIR)/gpsdrive.install

$(STATEDIR)/gpsdrive.install: $(STATEDIR)/gpsdrive.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gpsdrive_targetinstall: $(STATEDIR)/gpsdrive.targetinstall

gpsdrive_targetinstall_deps = $(STATEDIR)/gpsdrive.compile

$(STATEDIR)/gpsdrive.targetinstall: $(gpsdrive_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GPSDRIVE_PATH) $(MAKE) -C $(GPSDRIVE_DIR) DESTDIR=$(GPSDRIVE_IPKG_TMP) install
	mkdir -p $(GPSDRIVE_IPKG_TMP)/CONTROL
	echo "Package: gpsdrive" 							 >$(GPSDRIVE_IPKG_TMP)/CONTROL/control
	echo "Source: $(GPSDRIVE_URL)"						>>$(GPSDRIVE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPSDRIVE_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(GPSDRIVE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(GPSDRIVE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPSDRIVE_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPSDRIVE_VERSION)-$(GPSDRIVE_VENDOR_VERSION)" 			>>$(GPSDRIVE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(GPSDRIVE_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(GPSDRIVE_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(GPSDRIVE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GPSDRIVE_INSTALL
ROMPACKAGES += $(STATEDIR)/gpsdrive.imageinstall
endif

gpsdrive_imageinstall_deps = $(STATEDIR)/gpsdrive.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gpsdrive.imageinstall: $(gpsdrive_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gpsdrive
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gpsdrive_clean:
	rm -rf $(STATEDIR)/gpsdrive.*
	rm -rf $(GPSDRIVE_DIR)

# vim: syntax=make
