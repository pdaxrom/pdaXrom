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
ifdef PTXCONF_DVFM
PACKAGES += dvfm
endif

#
# Paths and names
#
DVFM_VENDOR_VERSION	= 1
DVFM_VERSION		= 1.0.0
DVFM			= dvfm-$(DVFM_VERSION)
DVFM_SUFFIX		= tar.bz2
DVFM_URL		= http://mail.pdaxrom.org/src/$(DVFM).$(DVFM_SUFFIX)
DVFM_SOURCE		= $(SRCDIR)/$(DVFM).$(DVFM_SUFFIX)
DVFM_DIR		= $(BUILDDIR)/$(DVFM)
DVFM_IPKG_TMP		= $(DVFM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dvfm_get: $(STATEDIR)/dvfm.get

dvfm_get_deps = $(DVFM_SOURCE)

$(STATEDIR)/dvfm.get: $(dvfm_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DVFM))
	touch $@

$(DVFM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DVFM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dvfm_extract: $(STATEDIR)/dvfm.extract

dvfm_extract_deps = $(STATEDIR)/dvfm.get

$(STATEDIR)/dvfm.extract: $(dvfm_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DVFM_DIR))
	@$(call extract, $(DVFM_SOURCE))
	@$(call patchin, $(DVFM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dvfm_prepare: $(STATEDIR)/dvfm.prepare

#
# dependencies
#
dvfm_prepare_deps = \
	$(STATEDIR)/dvfm.extract \
	$(STATEDIR)/virtual-xchain.install

DVFM_PATH	=  PATH=$(CROSS_PATH)
DVFM_ENV 	=  $(CROSS_ENV)
#DVFM_ENV	+=
DVFM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DVFM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
DVFM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
DVFM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DVFM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dvfm.prepare: $(dvfm_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DVFM_DIR)/config.cache)
	#cd $(DVFM_DIR) && \
	#	$(DVFM_PATH) $(DVFM_ENV) \
	#	./configure $(DVFM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dvfm_compile: $(STATEDIR)/dvfm.compile

dvfm_compile_deps = $(STATEDIR)/dvfm.prepare

$(STATEDIR)/dvfm.compile: $(dvfm_compile_deps)
	@$(call targetinfo, $@)
	$(DVFM_PATH) $(MAKE) -C $(DVFM_DIR) KERNEL_DIR=$(KERNEL_DIR) $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dvfm_install: $(STATEDIR)/dvfm.install

$(STATEDIR)/dvfm.install: $(STATEDIR)/dvfm.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dvfm_targetinstall: $(STATEDIR)/dvfm.targetinstall

dvfm_targetinstall_deps = $(STATEDIR)/dvfm.compile

$(STATEDIR)/dvfm.targetinstall: $(dvfm_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DVFM_PATH) $(MAKE) -C $(DVFM_DIR) DESTDIR=$(DVFM_IPKG_TMP) install
	$(CROSSSTRIP) $(DVFM_IPKG_TMP)/bin/*
	mkdir -p $(DVFM_IPKG_TMP)/CONTROL
	echo "Package: dvfm" 								 >$(DVFM_IPKG_TMP)/CONTROL/control
	echo "Source: $(DVFM_URL)"							>>$(DVFM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DVFM_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(DVFM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DVFM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DVFM_IPKG_TMP)/CONTROL/control
	echo "Version: $(DVFM_VERSION)-$(DVFM_VENDOR_VERSION)" 				>>$(DVFM_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(DVFM_IPKG_TMP)/CONTROL/control
	echo "Description: frequency scale utility"					>>$(DVFM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DVFM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DVFM_INSTALL
ROMPACKAGES += $(STATEDIR)/dvfm.imageinstall
endif

dvfm_imageinstall_deps = $(STATEDIR)/dvfm.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dvfm.imageinstall: $(dvfm_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dvfm
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dvfm_clean:
	rm -rf $(STATEDIR)/dvfm.*
	rm -rf $(DVFM_DIR)

# vim: syntax=make
