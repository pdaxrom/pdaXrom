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
ifdef PTXCONF_ZMIXER
PACKAGES += zmixer
endif

#
# Paths and names
#
ZMIXER_VENDOR_VERSION	= 1
ZMIXER_VERSION		= 0.2.1
ZMIXER			= zmixer-$(ZMIXER_VERSION)
ZMIXER_SUFFIX		= tar.gz
ZMIXER_URL		= http://zwin.org/projects/zmixer/$(ZMIXER).$(ZMIXER_SUFFIX)
ZMIXER_SOURCE		= $(SRCDIR)/$(ZMIXER).$(ZMIXER_SUFFIX)
ZMIXER_DIR		= $(BUILDDIR)/$(ZMIXER)
ZMIXER_IPKG_TMP		= $(ZMIXER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

zmixer_get: $(STATEDIR)/zmixer.get

zmixer_get_deps = $(ZMIXER_SOURCE)

$(STATEDIR)/zmixer.get: $(zmixer_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ZMIXER))
	touch $@

$(ZMIXER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ZMIXER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

zmixer_extract: $(STATEDIR)/zmixer.extract

zmixer_extract_deps = $(STATEDIR)/zmixer.get

$(STATEDIR)/zmixer.extract: $(zmixer_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ZMIXER_DIR))
	@$(call extract, $(ZMIXER_SOURCE))
	@$(call patchin, $(ZMIXER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

zmixer_prepare: $(STATEDIR)/zmixer.prepare

#
# dependencies
#
zmixer_prepare_deps = \
	$(STATEDIR)/zmixer.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/alsa-lib.install \
	$(STATEDIR)/virtual-xchain.install

ZMIXER_PATH	=  PATH=$(CROSS_PATH)
ZMIXER_ENV 	=  $(CROSS_ENV)
#ZMIXER_ENV	+=
ZMIXER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ZMIXER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ZMIXER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ZMIXER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ZMIXER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/zmixer.prepare: $(zmixer_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ZMIXER_DIR)/config.cache)
	#cd $(ZMIXER_DIR) && \
	#	$(ZMIXER_PATH) $(ZMIXER_ENV) \
	#	./configure $(ZMIXER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

zmixer_compile: $(STATEDIR)/zmixer.compile

zmixer_compile_deps = $(STATEDIR)/zmixer.prepare

$(STATEDIR)/zmixer.compile: $(zmixer_compile_deps)
	@$(call targetinfo, $@)
	$(ZMIXER_PATH) $(ZMIXER_ENV) $(MAKE) -C $(ZMIXER_DIR) $(CROSS_ENV_CC) $(CROSS_ENV_STRIP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

zmixer_install: $(STATEDIR)/zmixer.install

$(STATEDIR)/zmixer.install: $(STATEDIR)/zmixer.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

zmixer_targetinstall: $(STATEDIR)/zmixer.targetinstall

zmixer_targetinstall_deps = $(STATEDIR)/zmixer.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/alsa-lib.targetinstall

$(STATEDIR)/zmixer.targetinstall: $(zmixer_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(ZMIXER_PATH) $(MAKE) -C $(ZMIXER_DIR) DESTDIR=$(ZMIXER_IPKG_TMP) install
	mkdir -p $(ZMIXER_IPKG_TMP)/usr/{bin,share/applications,share/pixmaps}
	cp -a $(ZMIXER_DIR)/zmixer $(ZMIXER_IPKG_TMP)/usr/bin/
	$(CROSSSTRIP) $(ZMIXER_IPKG_TMP)/usr/bin/*
	cp -a $(TOPDIR)/config/pics/kamix.png 		$(ZMIXER_IPKG_TMP)/usr/share/pixmaps/
	cp -a $(TOPDIR)/config/pics/zmixer.desktop 	$(ZMIXER_IPKG_TMP)/usr/share/applications/
	mkdir -p $(ZMIXER_IPKG_TMP)/CONTROL
	echo "Package: zmixer" 								 >$(ZMIXER_IPKG_TMP)/CONTROL/control
	echo "Source: $(ZMIXER_URL)"							>>$(ZMIXER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ZMIXER_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(ZMIXER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ZMIXER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ZMIXER_IPKG_TMP)/CONTROL/control
	echo "Version: $(ZMIXER_VERSION)-$(ZMIXER_VENDOR_VERSION)" 			>>$(ZMIXER_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, alsa-lib" 							>>$(ZMIXER_IPKG_TMP)/CONTROL/control
	echo "Description: Simple ALSA mixer"						>>$(ZMIXER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ZMIXER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ZMIXER_INSTALL
ROMPACKAGES += $(STATEDIR)/zmixer.imageinstall
endif

zmixer_imageinstall_deps = $(STATEDIR)/zmixer.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/zmixer.imageinstall: $(zmixer_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install zmixer
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

zmixer_clean:
	rm -rf $(STATEDIR)/zmixer.*
	rm -rf $(ZMIXER_DIR)

# vim: syntax=make
