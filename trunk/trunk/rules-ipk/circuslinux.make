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
ifdef PTXCONF_CIRCUSLINUX
PACKAGES += circuslinux
endif

#
# Paths and names
#
CIRCUSLINUX_VENDOR_VERSION	= 1
CIRCUSLINUX_VERSION		= 1.0.3
CIRCUSLINUX			= circuslinux-$(CIRCUSLINUX_VERSION)
CIRCUSLINUX_SUFFIX		= tar.gz
CIRCUSLINUX_URL			= ftp://ftp.billsgames.com/unix/x/circus-linux/src/$(CIRCUSLINUX).$(CIRCUSLINUX_SUFFIX)
CIRCUSLINUX_SOURCE		= $(SRCDIR)/$(CIRCUSLINUX).$(CIRCUSLINUX_SUFFIX)
CIRCUSLINUX_DIR			= $(BUILDDIR)/$(CIRCUSLINUX)
CIRCUSLINUX_IPKG_TMP		= $(CIRCUSLINUX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

circuslinux_get: $(STATEDIR)/circuslinux.get

circuslinux_get_deps = $(CIRCUSLINUX_SOURCE)

$(STATEDIR)/circuslinux.get: $(circuslinux_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CIRCUSLINUX))
	touch $@

$(CIRCUSLINUX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CIRCUSLINUX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

circuslinux_extract: $(STATEDIR)/circuslinux.extract

circuslinux_extract_deps = $(STATEDIR)/circuslinux.get

$(STATEDIR)/circuslinux.extract: $(circuslinux_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CIRCUSLINUX_DIR))
	@$(call extract, $(CIRCUSLINUX_SOURCE))
	@$(call patchin, $(CIRCUSLINUX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

circuslinux_prepare: $(STATEDIR)/circuslinux.prepare

#
# dependencies
#
circuslinux_prepare_deps = \
	$(STATEDIR)/circuslinux.extract \
	$(STATEDIR)/SDL_image.install \
	$(STATEDIR)/SDL_mixer.install \
	$(STATEDIR)/virtual-xchain.install

CIRCUSLINUX_PATH	=  PATH=$(CROSS_PATH)
CIRCUSLINUX_ENV 	=  $(CROSS_ENV)
#CIRCUSLINUX_ENV	+=
CIRCUSLINUX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CIRCUSLINUX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
CIRCUSLINUX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
CIRCUSLINUX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CIRCUSLINUX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/circuslinux.prepare: $(circuslinux_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CIRCUSLINUX_DIR)/config.cache)
	#cd $(EXIT_DIR) && $(EXIT_PATH) aclocal
	#cd $(CIRCUSLINUX_DIR) && $(CIRCUSLINUX_PATH) automake --add-missing
	#cd $(CIRCUSLINUX_DIR) && $(CIRCUSLINUX_PATH) autoconf
	cd $(CIRCUSLINUX_DIR) && \
		$(CIRCUSLINUX_PATH) $(CIRCUSLINUX_ENV) \
		./configure $(CIRCUSLINUX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

circuslinux_compile: $(STATEDIR)/circuslinux.compile

circuslinux_compile_deps = $(STATEDIR)/circuslinux.prepare

$(STATEDIR)/circuslinux.compile: $(circuslinux_compile_deps)
	@$(call targetinfo, $@)
	$(CIRCUSLINUX_PATH) $(MAKE) -C $(CIRCUSLINUX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

circuslinux_install: $(STATEDIR)/circuslinux.install

$(STATEDIR)/circuslinux.install: $(STATEDIR)/circuslinux.compile
	@$(call targetinfo, $@)
	$(CIRCUSLINUX_PATH) $(MAKE) -C $(CIRCUSLINUX_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

circuslinux_targetinstall: $(STATEDIR)/circuslinux.targetinstall

circuslinux_targetinstall_deps = $(STATEDIR)/circuslinux.compile \
	$(STATEDIR)/SDL_image.targetinstall \
	$(STATEDIR)/SDL_mixer.targetinstall

$(STATEDIR)/circuslinux.targetinstall: $(circuslinux_targetinstall_deps)
	@$(call targetinfo, $@)
	$(CIRCUSLINUX_PATH) $(MAKE) -C $(CIRCUSLINUX_DIR) prefix=$(CIRCUSLINUX_IPKG_TMP)/usr install
	$(CROSSSTRIP) $(CIRCUSLINUX_IPKG_TMP)/usr/bin/*
	$(INSTALL) -D $(TOPDIR)/config/pics/circuslinux.desktop	$(CIRCUSLINUX_IPKG_TMP)/usr/share/applications/circuslinux.desktop
	$(INSTALL) -D $(TOPDIR)/config/pics/circuslinux.png	$(CIRCUSLINUX_IPKG_TMP)/usr/share/pixmaps/circuslinux.png
	mkdir -p $(CIRCUSLINUX_IPKG_TMP)/CONTROL
	echo "Package: circuslinux" 							 >$(CIRCUSLINUX_IPKG_TMP)/CONTROL/control
	echo "Source: $(CIRCUSLINUX_URL)"						>>$(CIRCUSLINUX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(CIRCUSLINUX_IPKG_TMP)/CONTROL/control
	echo "Section: Games" 								>>$(CIRCUSLINUX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(CIRCUSLINUX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(CIRCUSLINUX_IPKG_TMP)/CONTROL/control
	echo "Version: $(CIRCUSLINUX_VERSION)-$(CIRCUSLINUX_VENDOR_VERSION)" 		>>$(CIRCUSLINUX_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl, sdl-image,sdl-mixer" 					>>$(CIRCUSLINUX_IPKG_TMP)/CONTROL/control
	echo "Description: clone of the Atari 2600 game Circus Atari, produced by Atari, Inc." >>$(CIRCUSLINUX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(CIRCUSLINUX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CIRCUSLINUX_INSTALL
ROMPACKAGES += $(STATEDIR)/circuslinux.imageinstall
endif

circuslinux_imageinstall_deps = $(STATEDIR)/circuslinux.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/circuslinux.imageinstall: $(circuslinux_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install circuslinux
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

circuslinux_clean:
	rm -rf $(STATEDIR)/circuslinux.*
	rm -rf $(CIRCUSLINUX_DIR)

# vim: syntax=make
