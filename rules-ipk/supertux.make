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
ifdef PTXCONF_SUPERTUX
PACKAGES += supertux
endif

#
# Paths and names
#
SUPERTUX_VENDOR_VERSION	= 1
SUPERTUX_VERSION	= 0.1.2
SUPERTUX		= supertux-$(SUPERTUX_VERSION)
SUPERTUX_SUFFIX		= tar.bz2
SUPERTUX_URL		= http://download.berlios.de/supertux/$(SUPERTUX).$(SUPERTUX_SUFFIX)
SUPERTUX_SOURCE		= $(SRCDIR)/$(SUPERTUX).$(SUPERTUX_SUFFIX)
SUPERTUX_DIR		= $(BUILDDIR)/$(SUPERTUX)
SUPERTUX_IPKG_TMP	= $(SUPERTUX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

supertux_get: $(STATEDIR)/supertux.get

supertux_get_deps = $(SUPERTUX_SOURCE)

$(STATEDIR)/supertux.get: $(supertux_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SUPERTUX))
	touch $@

$(SUPERTUX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SUPERTUX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

supertux_extract: $(STATEDIR)/supertux.extract

supertux_extract_deps = $(STATEDIR)/supertux.get

$(STATEDIR)/supertux.extract: $(supertux_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SUPERTUX_DIR))
	@$(call extract, $(SUPERTUX_SOURCE))
	@$(call patchin, $(SUPERTUX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

supertux_prepare: $(STATEDIR)/supertux.prepare

#
# dependencies
#
supertux_prepare_deps = \
	$(STATEDIR)/supertux.extract \
	$(STATEDIR)/SDL_image.install \
	$(STATEDIR)/SDL_mixer.install \
	$(STATEDIR)/virtual-xchain.install

SUPERTUX_PATH	=  PATH=$(CROSS_PATH)
SUPERTUX_ENV 	=  $(CROSS_ENV)
SUPERTUX_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
SUPERTUX_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
SUPERTUX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SUPERTUX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SUPERTUX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-opengl \
	--disable-debug

ifdef PTXCONF_XFREE430
SUPERTUX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SUPERTUX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/supertux.prepare: $(supertux_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SUPERTUX_DIR)/config.cache)
	cd $(SUPERTUX_DIR) && \
		$(SUPERTUX_PATH) $(SUPERTUX_ENV) \
		./configure $(SUPERTUX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

supertux_compile: $(STATEDIR)/supertux.compile

supertux_compile_deps = $(STATEDIR)/supertux.prepare

$(STATEDIR)/supertux.compile: $(supertux_compile_deps)
	@$(call targetinfo, $@)
	$(SUPERTUX_PATH) $(MAKE) -C $(SUPERTUX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

supertux_install: $(STATEDIR)/supertux.install

$(STATEDIR)/supertux.install: $(STATEDIR)/supertux.compile
	@$(call targetinfo, $@)
	$(SUPERTUX_PATH) $(MAKE) -C $(SUPERTUX_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

supertux_targetinstall: $(STATEDIR)/supertux.targetinstall

supertux_targetinstall_deps = $(STATEDIR)/supertux.compile \
	$(STATEDIR)/SDL_image.install \
	$(STATEDIR)/SDL_mixer.install

$(STATEDIR)/supertux.targetinstall: $(supertux_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SUPERTUX_PATH) $(MAKE) -C $(SUPERTUX_DIR) DESTDIR=$(SUPERTUX_IPKG_TMP) install
	$(INSTALL) -D $(TOPDIR)/config/pics/supertux.desktop	$(SUPERTUX_IPKG_TMP)/usr/share/applications/supertux.desktop
	$(INSTALL) -D $(TOPDIR)/config/pics/supertux.png	$(SUPERTUX_IPKG_TMP)/usr/share/pixmaps/supertux.png
	$(CROSSSTRIP) $(SUPERTUX_IPKG_TMP)/usr/bin/*
	mkdir -p $(SUPERTUX_IPKG_TMP)/CONTROL
	echo "Package: supertux" 							 >$(SUPERTUX_IPKG_TMP)/CONTROL/control
	echo "Source: $(SUPERTUX_URL)"						>>$(SUPERTUX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SUPERTUX_IPKG_TMP)/CONTROL/control
	echo "Section: Games" 								>>$(SUPERTUX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SUPERTUX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SUPERTUX_IPKG_TMP)/CONTROL/control
	echo "Version: $(SUPERTUX_VERSION)-$(SUPERTUX_VENDOR_VERSION)" 			>>$(SUPERTUX_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl-image, sdl-mixer" 						>>$(SUPERTUX_IPKG_TMP)/CONTROL/control
	echo "Description: SuperTux is a classic 2D jump'n run sidescroller game in a style similar to the original SuperMario games." >>$(SUPERTUX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SUPERTUX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SUPERTUX_INSTALL
ROMPACKAGES += $(STATEDIR)/supertux.imageinstall
endif

supertux_imageinstall_deps = $(STATEDIR)/supertux.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/supertux.imageinstall: $(supertux_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install supertux
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

supertux_clean:
	rm -rf $(STATEDIR)/supertux.*
	rm -rf $(SUPERTUX_DIR)

# vim: syntax=make
