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
ifdef PTXCONF_XCAS
PACKAGES += xcas
endif

#
# Paths and names
#
XCAS_VENDOR_VERSION	= 1
XCAS_VERSION		= 0.5.0
XCAS			= xcas-$(XCAS_VERSION)
XCAS_SUFFIX		= tar.bz2
XCAS_URL		= http://belnet.dl.sourceforge.net/sourceforge/xcas/$(XCAS).$(XCAS_SUFFIX)
XCAS_SOURCE		= $(SRCDIR)/$(XCAS).$(XCAS_SUFFIX)
XCAS_DIR		= $(BUILDDIR)/$(XCAS)
XCAS_IPKG_TMP		= $(XCAS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xcas_get: $(STATEDIR)/xcas.get

xcas_get_deps = $(XCAS_SOURCE)

$(STATEDIR)/xcas.get: $(xcas_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCAS))
	touch $@

$(XCAS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCAS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xcas_extract: $(STATEDIR)/xcas.extract

xcas_extract_deps = $(STATEDIR)/xcas.get

$(STATEDIR)/xcas.extract: $(xcas_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCAS_DIR))
	@$(call extract, $(XCAS_SOURCE))
	@$(call patchin, $(XCAS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xcas_prepare: $(STATEDIR)/xcas.prepare

#
# dependencies
#
xcas_prepare_deps = \
	$(STATEDIR)/xcas.extract \
	$(STATEDIR)/fltk.install \
	$(STATEDIR)/virtual-xchain.install

XCAS_PATH	=  PATH=$(CROSS_PATH)
XCAS_ENV 	=  $(CROSS_ENV)
#XCAS_ENV	+=
XCAS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XCAS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XCAS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XCAS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XCAS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xcas.prepare: $(xcas_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCAS_DIR)/config.cache)
	cd $(XCAS_DIR) && \
		$(XCAS_PATH) $(XCAS_ENV) \
		./configure $(XCAS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xcas_compile: $(STATEDIR)/xcas.compile

xcas_compile_deps = $(STATEDIR)/xcas.prepare

$(STATEDIR)/xcas.compile: $(xcas_compile_deps)
	@$(call targetinfo, $@)
	$(XCAS_PATH) $(MAKE) -C $(XCAS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xcas_install: $(STATEDIR)/xcas.install

$(STATEDIR)/xcas.install: $(STATEDIR)/xcas.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xcas_targetinstall: $(STATEDIR)/xcas.targetinstall

xcas_targetinstall_deps = $(STATEDIR)/xcas.compile \
	$(STATEDIR)/fltk.targetinstall

$(STATEDIR)/xcas.targetinstall: $(xcas_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XCAS_PATH) $(MAKE) -C $(XCAS_DIR) DESTDIR=$(XCAS_IPKG_TMP) install
	mkdir -p $(XCAS_IPKG_TMP)/CONTROL
	echo "Package: xcas" 									 >$(XCAS_IPKG_TMP)/CONTROL/control
	echo "Source: $(XCAS_URL)"								>>$(XCAS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(XCAS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 								>>$(XCAS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(XCAS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(XCAS_IPKG_TMP)/CONTROL/control
	echo "Version: $(XCAS_VERSION)-$(XCAS_VENDOR_VERSION)" 					>>$(XCAS_IPKG_TMP)/CONTROL/control
	echo "Depends: fltk" 									>>$(XCAS_IPKG_TMP)/CONTROL/control
	echo "Description: GIAC/XCAS/wxCAS is a free computer algebra system for Windows, Mac OS X and Linux/Unix." >>$(XCAS_IPKG_TMP)/CONTROL/control
	asdasd
	@$(call makeipkg, $(XCAS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XCAS_INSTALL
ROMPACKAGES += $(STATEDIR)/xcas.imageinstall
endif

xcas_imageinstall_deps = $(STATEDIR)/xcas.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xcas.imageinstall: $(xcas_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xcas
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xcas_clean:
	rm -rf $(STATEDIR)/xcas.*
	rm -rf $(XCAS_DIR)

# vim: syntax=make
