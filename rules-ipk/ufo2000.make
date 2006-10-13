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
ifdef PTXCONF_UFO2000
PACKAGES += ufo2000
endif

#
# Paths and names
#
UFO2000_VENDOR_VERSION	= 1
UFO2000_VERSION		= 0.6.627
UFO2000			= ufo2000-$(UFO2000_VERSION)-src
UFO2000_SUFFIX		= tar.bz2
UFO2000_URL		= http://citkit.dl.sourceforge.net/sourceforge/ufo2000/$(UFO2000).$(UFO2000_SUFFIX)
UFO2000_SOURCE		= $(SRCDIR)/$(UFO2000).$(UFO2000_SUFFIX)
UFO2000_DIR		= $(BUILDDIR)/ufo2000-$(UFO2000_VERSION)
UFO2000_IPKG_TMP	= $(UFO2000_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ufo2000_get: $(STATEDIR)/ufo2000.get

ufo2000_get_deps = $(UFO2000_SOURCE)

$(STATEDIR)/ufo2000.get: $(ufo2000_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(UFO2000))
	touch $@

$(UFO2000_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(UFO2000_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ufo2000_extract: $(STATEDIR)/ufo2000.extract

ufo2000_extract_deps = $(STATEDIR)/ufo2000.get

$(STATEDIR)/ufo2000.extract: $(ufo2000_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UFO2000_DIR))
	@$(call extract, $(UFO2000_SOURCE))
	@$(call patchin, $(UFO2000))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ufo2000_prepare: $(STATEDIR)/ufo2000.prepare

#
# dependencies
#
ufo2000_prepare_deps = \
	$(STATEDIR)/ufo2000.extract \
	$(STATEDIR)/allegro.install \
	$(STATEDIR)/HawkNL.install \
	$(STATEDIR)/virtual-xchain.install

UFO2000_PATH	=  PATH=$(CROSS_PATH)
UFO2000_ENV 	=  $(CROSS_ENV)
#UFO2000_ENV	+=
UFO2000_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#UFO2000_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
UFO2000_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
UFO2000_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
UFO2000_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ufo2000.prepare: $(ufo2000_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UFO2000_DIR)/config.cache)
	#cd $(UFO2000_DIR) && \
	#	$(UFO2000_PATH) $(UFO2000_ENV) \
	#	./configure $(UFO2000_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ufo2000_compile: $(STATEDIR)/ufo2000.compile

ufo2000_compile_deps = $(STATEDIR)/ufo2000.prepare

$(STATEDIR)/ufo2000.compile: $(ufo2000_compile_deps)
	@$(call targetinfo, $@)
	$(UFO2000_PATH) $(MAKE) -C $(UFO2000_DIR) $(CROSS_ENV_CC) CX=$(PTXCONF_GNU_TARGET)-g++ AR="$(PTXCONF_GNU_TARGET)-ar rcu" $(CROSS_ENV_RANLIB) $(CROSS_ENV_STRIP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ufo2000_install: $(STATEDIR)/ufo2000.install

$(STATEDIR)/ufo2000.install: $(STATEDIR)/ufo2000.compile
	@$(call targetinfo, $@)
	##$(UFO2000_PATH) $(MAKE) -C $(UFO2000_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ufo2000_targetinstall: $(STATEDIR)/ufo2000.targetinstall

ufo2000_targetinstall_deps = $(STATEDIR)/ufo2000.compile \
	$(STATEDIR)/allegro.targetinstall \
	$(STATEDIR)/HawkNL.targetinstall

$(STATEDIR)/ufo2000.targetinstall: $(ufo2000_targetinstall_deps)
	@$(call targetinfo, $@)
	##$(UFO2000_PATH) $(MAKE) -C $(UFO2000_DIR) DESTDIR=$(UFO2000_IPKG_TMP) install
	mkdir -p $(UFO2000_IPKG_TMP)/usr/bin
	mkdir -p $(UFO2000_IPKG_TMP)/usr/share/ufo2000
	cp -a $(UFO2000_DIR)/*.{txt,ini,dat,conf,html} 	$(UFO2000_IPKG_TMP)/usr/share/ufo2000/
	cp -a $(UFO2000_DIR)/ufo2000 			$(UFO2000_IPKG_TMP)/usr/share/ufo2000/
	$(CROSSSTRIP) $(UFO2000_IPKG_TMP)/usr/share/ufo2000/ufo2000
	cp -a $(UFO2000_DIR)/{TFTD*,XCOM*,arts,init-scripts,newmaps,newmusic,newunits,script,translations} $(UFO2000_IPKG_TMP)/usr/share/ufo2000/
	mkdir -p $(UFO2000_IPKG_TMP)/CONTROL
	echo "Package: ufo2000" 							 >$(UFO2000_IPKG_TMP)/CONTROL/control
	echo "Source: $(UFO2000_URL)"							>>$(UFO2000_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(UFO2000_IPKG_TMP)/CONTROL/control
	echo "Section: Games"	 							>>$(UFO2000_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(UFO2000_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(UFO2000_IPKG_TMP)/CONTROL/control
	echo "Version: $(UFO2000_VERSION)-$(UFO2000_VENDOR_VERSION)" 			>>$(UFO2000_IPKG_TMP)/CONTROL/control
	echo "Depends: allegro, hawknl" 						>>$(UFO2000_IPKG_TMP)/CONTROL/control
	echo "Description: UFO2000 is free and opensource turn based tactical squad simulation game with multiplayer support." >>$(UFO2000_IPKG_TMP)/CONTROL/control
	
	echo "#!/bin/sh"								 >$(UFO2000_IPKG_TMP)/usr/bin/runufo
	echo "cd /usr/share/ufo2000"							>>$(UFO2000_IPKG_TMP)/usr/bin/runufo
	echo "./ufo2000"								>>$(UFO2000_IPKG_TMP)/usr/bin/runufo
	
	@$(call makeipkg, $(UFO2000_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_UFO2000_INSTALL
ROMPACKAGES += $(STATEDIR)/ufo2000.imageinstall
endif

ufo2000_imageinstall_deps = $(STATEDIR)/ufo2000.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ufo2000.imageinstall: $(ufo2000_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ufo2000
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ufo2000_clean:
	rm -rf $(STATEDIR)/ufo2000.*
	rm -rf $(UFO2000_DIR)

# vim: syntax=make
