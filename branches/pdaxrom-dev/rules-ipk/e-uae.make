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
ifdef PTXCONF_E-UAE
PACKAGES += e-uae
endif

#
# Paths and names
#
E-UAE_VENDOR_VERSION	= 1
E-UAE_VERSION		= 0.8.28-RC2
E-UAE			= e-uae-$(E-UAE_VERSION)
E-UAE_SUFFIX		= tar.bz2
E-UAE_URL		= http://www.rcdrummond.net/uae/$(E-UAE)/$(E-UAE).$(E-UAE_SUFFIX)
E-UAE_SOURCE		= $(SRCDIR)/$(E-UAE).$(E-UAE_SUFFIX)
E-UAE_DIR		= $(BUILDDIR)/$(E-UAE)
E-UAE_IPKG_TMP		= $(E-UAE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

e-uae_get: $(STATEDIR)/e-uae.get

e-uae_get_deps = $(E-UAE_SOURCE)

$(STATEDIR)/e-uae.get: $(e-uae_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(E-UAE))
	touch $@

$(E-UAE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(E-UAE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

e-uae_extract: $(STATEDIR)/e-uae.extract

e-uae_extract_deps = $(STATEDIR)/e-uae.get

$(STATEDIR)/e-uae.extract: $(e-uae_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(E-UAE_DIR))
	@$(call extract, $(E-UAE_SOURCE))
	@$(call patchin, $(E-UAE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

e-uae_prepare: $(STATEDIR)/e-uae.prepare

#
# dependencies
#
e-uae_prepare_deps = \
	$(STATEDIR)/e-uae.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/virtual-xchain.install

E-UAE_PATH	=  PATH=$(CROSS_PATH)
E-UAE_ENV 	=  $(CROSS_ENV)
ifdef PTXCONF_ARM_ARCH_PXA
E-UAE_ENV	+= CFLAGS="-Os -fomit-frame-pointer -mcpu=xscale -mtune=xscale"
E-UAE_ENV	+= CXXFLAGS="-Os -fomit-frame-pointer -mcpu=xscale -mtune=xscale"
endif
E-UAE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#E-UAE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
E-UAE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-zlib=$(CROSS_LIB_DIR) \
	--with-sdl \
	--with-sdl-sound \
	--with-sdl-gfx

ifdef PTXCONF_XFREE430
E-UAE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
E-UAE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/e-uae.prepare: $(e-uae_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(E-UAE_DIR)/config.cache)
	cd $(E-UAE_DIR) && \
		$(E-UAE_PATH) $(E-UAE_ENV) \
		./configure $(E-UAE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

e-uae_compile: $(STATEDIR)/e-uae.compile

e-uae_compile_deps = $(STATEDIR)/e-uae.prepare

$(STATEDIR)/e-uae.compile: $(e-uae_compile_deps)
	@$(call targetinfo, $@)
	$(E-UAE_PATH) $(MAKE) -C $(E-UAE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

e-uae_install: $(STATEDIR)/e-uae.install

$(STATEDIR)/e-uae.install: $(STATEDIR)/e-uae.compile
	@$(call targetinfo, $@)
	$(E-UAE_PATH) $(MAKE) -C $(E-UAE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

e-uae_targetinstall: $(STATEDIR)/e-uae.targetinstall

e-uae_targetinstall_deps = $(STATEDIR)/e-uae.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/SDL.targetinstall

$(STATEDIR)/e-uae.targetinstall: $(e-uae_targetinstall_deps)
	@$(call targetinfo, $@)
	$(E-UAE_PATH) $(MAKE) -C $(E-UAE_DIR) DESTDIR=$(E-UAE_IPKG_TMP) install
	$(CROSSSTRIP) $(E-UAE_IPKG_TMP)/usr/bin/*
	mkdir -p $(E-UAE_IPKG_TMP)/CONTROL
	echo "Package: e-uae" 								 >$(E-UAE_IPKG_TMP)/CONTROL/control
	echo "Source: $(E-UAE_URL)"							>>$(E-UAE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(E-UAE_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(E-UAE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(E-UAE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(E-UAE_IPKG_TMP)/CONTROL/control
	echo "Version: $(E-UAE_VERSION)-$(E-UAE_VENDOR_VERSION)" 			>>$(E-UAE_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, sdl" 							>>$(E-UAE_IPKG_TMP)/CONTROL/control
	echo "Description: Amiga emulator"						>>$(E-UAE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(E-UAE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_E-UAE_INSTALL
ROMPACKAGES += $(STATEDIR)/e-uae.imageinstall
endif

e-uae_imageinstall_deps = $(STATEDIR)/e-uae.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/e-uae.imageinstall: $(e-uae_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install e-uae
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

e-uae_clean:
	rm -rf $(STATEDIR)/e-uae.*
	rm -rf $(E-UAE_DIR)

# vim: syntax=make
