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
ifdef PTXCONF_JPILOT
PACKAGES += jpilot
endif

#
# Paths and names
#
JPILOT_VENDOR_VERSION	= 1
JPILOT_VERSION		= 0.99.8
JPILOT			= jpilot-$(JPILOT_VERSION)
JPILOT_SUFFIX		= tar.gz
JPILOT_URL		= http://jpilot.org/$(JPILOT).$(JPILOT_SUFFIX)
JPILOT_SOURCE		= $(SRCDIR)/$(JPILOT).$(JPILOT_SUFFIX)
JPILOT_DIR		= $(BUILDDIR)/$(JPILOT)
JPILOT_IPKG_TMP		= $(JPILOT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

jpilot_get: $(STATEDIR)/jpilot.get

jpilot_get_deps = $(JPILOT_SOURCE)

$(STATEDIR)/jpilot.get: $(jpilot_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(JPILOT))
	touch $@

$(JPILOT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(JPILOT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

jpilot_extract: $(STATEDIR)/jpilot.extract

jpilot_extract_deps = $(STATEDIR)/jpilot.get

$(STATEDIR)/jpilot.extract: $(jpilot_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(JPILOT_DIR))
	@$(call extract, $(JPILOT_SOURCE))
	@$(call patchin, $(JPILOT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

jpilot_prepare: $(STATEDIR)/jpilot.prepare

#
# dependencies
#
jpilot_prepare_deps = \
	$(STATEDIR)/jpilot.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/pilot-link.install \
	$(STATEDIR)/virtual-xchain.install

JPILOT_PATH	=  PATH=$(CROSS_PATH)
JPILOT_ENV 	=  $(CROSS_ENV)
#JPILOT_ENV	+=
JPILOT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#JPILOT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
JPILOT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-gtk2 \
	--with-pilot-prefix=$(CROSS_LIB_DIR) \
	--disable-debug

ifdef PTXCONF_XFREE430
JPILOT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
JPILOT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/jpilot.prepare: $(jpilot_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(JPILOT_DIR)/config.cache)
	cd $(JPILOT_DIR) && \
		$(JPILOT_PATH) $(JPILOT_ENV) \
		./configure $(JPILOT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

jpilot_compile: $(STATEDIR)/jpilot.compile

jpilot_compile_deps = $(STATEDIR)/jpilot.prepare

$(STATEDIR)/jpilot.compile: $(jpilot_compile_deps)
	@$(call targetinfo, $@)
	$(JPILOT_PATH) $(MAKE) -C $(JPILOT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

jpilot_install: $(STATEDIR)/jpilot.install

$(STATEDIR)/jpilot.install: $(STATEDIR)/jpilot.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

jpilot_targetinstall: $(STATEDIR)/jpilot.targetinstall

jpilot_targetinstall_deps = $(STATEDIR)/jpilot.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/pilot-link.targetinstall

$(STATEDIR)/jpilot.targetinstall: $(jpilot_targetinstall_deps)
	@$(call targetinfo, $@)
	$(JPILOT_PATH) $(MAKE) -C $(JPILOT_DIR) DESTDIR=$(JPILOT_IPKG_TMP) install
	rm -rf $(JPILOT_IPKG_TMP)/usr/man
	rm -rf $(JPILOT_IPKG_TMP)/usr/share/doc
	rm -rf $(JPILOT_IPKG_TMP)/usr/share/locale
	rm -rf $(JPILOT_IPKG_TMP)/usr/lib/jpilot/plugins/*.*a
	$(CROSSSTRIP) $(JPILOT_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(JPILOT_IPKG_TMP)/usr/lib/jpilot/plugins/*.so*
	mkdir -p $(JPILOT_IPKG_TMP)/usr/share/pixmaps
	cp -a $(TOPDIR)/config/pics/jpilot.desktop $(JPILOT_IPKG_TMP)/usr/share/applications/
	cp -a $(TOPDIR)/config/pics/jpilot.png $(JPILOT_IPKG_TMP)/usr/share/pixmaps/
	mkdir -p $(JPILOT_IPKG_TMP)/CONTROL
	echo "Package: jpilot" 								 >$(JPILOT_IPKG_TMP)/CONTROL/control
	echo "Source: $(JPILOT_URL)"							>>$(JPILOT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(JPILOT_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 								>>$(JPILOT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(JPILOT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(JPILOT_IPKG_TMP)/CONTROL/control
	echo "Version: $(JPILOT_VERSION)-$(JPILOT_VENDOR_VERSION)" 			>>$(JPILOT_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libpisync, libpisock" 					>>$(JPILOT_IPKG_TMP)/CONTROL/control
	echo "Description: J-Pilot is a desktop organizer application for PalmOS devices." >>$(JPILOT_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(JPILOT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_JPILOT_INSTALL
ROMPACKAGES += $(STATEDIR)/jpilot.imageinstall
endif

jpilot_imageinstall_deps = $(STATEDIR)/jpilot.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/jpilot.imageinstall: $(jpilot_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install jpilot
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

jpilot_clean:
	rm -rf $(STATEDIR)/jpilot.*
	rm -rf $(JPILOT_DIR)

# vim: syntax=make
