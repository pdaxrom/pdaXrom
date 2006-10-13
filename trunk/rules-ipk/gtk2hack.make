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
ifdef PTXCONF_GTK2HACK
PACKAGES += gtk2hack
endif

#
# Paths and names
#
GTK2HACK_VENDOR_VERSION	= 1
GTK2HACK_VERSION	= 0.5.7
GTK2HACK		= gtk2hack-$(GTK2HACK_VERSION)
GTK2HACK_SUFFIX		= tar.bz2
GTK2HACK_URL		= http://ovh.dl.sourceforge.net/sourceforge/gtk2hack/$(GTK2HACK).$(GTK2HACK_SUFFIX)
GTK2HACK_SOURCE		= $(SRCDIR)/$(GTK2HACK).$(GTK2HACK_SUFFIX)
GTK2HACK_DIR		= $(BUILDDIR)/$(GTK2HACK)
GTK2HACK_IPKG_TMP	= $(GTK2HACK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gtk2hack_get: $(STATEDIR)/gtk2hack.get

gtk2hack_get_deps = $(GTK2HACK_SOURCE)

$(STATEDIR)/gtk2hack.get: $(gtk2hack_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GTK2HACK))
	touch $@

$(GTK2HACK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GTK2HACK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gtk2hack_extract: $(STATEDIR)/gtk2hack.extract

gtk2hack_extract_deps = $(STATEDIR)/gtk2hack.get

$(STATEDIR)/gtk2hack.extract: $(gtk2hack_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTK2HACK_DIR))
	@$(call extract, $(GTK2HACK_SOURCE))
	@$(call patchin, $(GTK2HACK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gtk2hack_prepare: $(STATEDIR)/gtk2hack.prepare

#
# dependencies
#
gtk2hack_prepare_deps = \
	$(STATEDIR)/gtk2hack.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

GTK2HACK_PATH	=  PATH=$(CROSS_PATH)
GTK2HACK_ENV 	=  $(CROSS_ENV)
#GTK2HACK_ENV	+=
GTK2HACK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GTK2HACK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GTK2HACK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GTK2HACK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GTK2HACK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gtk2hack.prepare: $(gtk2hack_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTK2HACK_DIR)/config.cache)
	cd $(GTK2HACK_DIR) && \
		$(GTK2HACK_PATH) $(GTK2HACK_ENV) \
		./configure $(GTK2HACK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gtk2hack_compile: $(STATEDIR)/gtk2hack.compile

gtk2hack_compile_deps = $(STATEDIR)/gtk2hack.prepare

$(STATEDIR)/gtk2hack.compile: $(gtk2hack_compile_deps)
	@$(call targetinfo, $@)
	$(GTK2HACK_PATH) $(MAKE) -C $(GTK2HACK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gtk2hack_install: $(STATEDIR)/gtk2hack.install

$(STATEDIR)/gtk2hack.install: $(STATEDIR)/gtk2hack.compile
	@$(call targetinfo, $@)
	$(GTK2HACK_PATH) $(MAKE) -C $(GTK2HACK_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gtk2hack_targetinstall: $(STATEDIR)/gtk2hack.targetinstall

gtk2hack_targetinstall_deps = $(STATEDIR)/gtk2hack.compile \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/gtk2hack.targetinstall: $(gtk2hack_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GTK2HACK_PATH) $(MAKE) -C $(GTK2HACK_DIR) DESTDIR=$(GTK2HACK_IPKG_TMP) install
	mkdir -p $(GTK2HACK_IPKG_TMP)/CONTROL
	echo "Package: gtk2hack" 							 >$(GTK2HACK_IPKG_TMP)/CONTROL/control
	echo "Source: $(GTK2HACK_URL)"							>>$(GTK2HACK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GTK2HACK_IPKG_TMP)/CONTROL/control
	echo "Section: Games" 								>>$(GTK2HACK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GTK2HACK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GTK2HACK_IPKG_TMP)/CONTROL/control
	echo "Version: $(GTK2HACK_VERSION)-$(GTK2HACK_VENDOR_VERSION)" 			>>$(GTK2HACK_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 								>>$(GTK2HACK_IPKG_TMP)/CONTROL/control
	echo "Description: Gtk2Hack is a nice graphical frontend (window port in nethack terminology) for the popular rogue-like role playing game nethack using the modern GTK2 toolkit." >>$(GTK2HACK_IPKG_TMP)/CONTROL/control
	asdasd
	@$(call makeipkg, $(GTK2HACK_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GTK2HACK_INSTALL
ROMPACKAGES += $(STATEDIR)/gtk2hack.imageinstall
endif

gtk2hack_imageinstall_deps = $(STATEDIR)/gtk2hack.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gtk2hack.imageinstall: $(gtk2hack_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gtk2hack
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gtk2hack_clean:
	rm -rf $(STATEDIR)/gtk2hack.*
	rm -rf $(GTK2HACK_DIR)

# vim: syntax=make
