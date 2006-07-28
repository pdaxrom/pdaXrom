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
ifdef PTXCONF_GTKTERM2
PACKAGES += gtkterm2
endif

#
# Paths and names
#
GTKTERM2_VENDOR_VERSION	= 1
GTKTERM2_VERSION	= 0.2.3
GTKTERM2		= gtkterm2-$(GTKTERM2_VERSION)
GTKTERM2_SUFFIX		= tar.gz
GTKTERM2_URL		= http://switch.dl.sourceforge.net/sourceforge/gtkterm/$(GTKTERM2).$(GTKTERM2_SUFFIX)
GTKTERM2_SOURCE		= $(SRCDIR)/$(GTKTERM2).$(GTKTERM2_SUFFIX)
GTKTERM2_DIR		= $(BUILDDIR)/$(GTKTERM2)
GTKTERM2_IPKG_TMP	= $(GTKTERM2_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gtkterm2_get: $(STATEDIR)/gtkterm2.get

gtkterm2_get_deps = $(GTKTERM2_SOURCE)

$(STATEDIR)/gtkterm2.get: $(gtkterm2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GTKTERM2))
	touch $@

$(GTKTERM2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GTKTERM2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gtkterm2_extract: $(STATEDIR)/gtkterm2.extract

gtkterm2_extract_deps = $(STATEDIR)/gtkterm2.get

$(STATEDIR)/gtkterm2.extract: $(gtkterm2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTKTERM2_DIR))
	@$(call extract, $(GTKTERM2_SOURCE))
	@$(call patchin, $(GTKTERM2))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gtkterm2_prepare: $(STATEDIR)/gtkterm2.prepare

#
# dependencies
#
gtkterm2_prepare_deps = \
	$(STATEDIR)/gtkterm2.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/vte.install \
	$(STATEDIR)/virtual-xchain.install

GTKTERM2_PATH	=  PATH=$(CROSS_PATH)
GTKTERM2_ENV 	=  $(CROSS_ENV)
#GTKTERM2_ENV	+=
GTKTERM2_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GTKTERM2_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GTKTERM2_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GTKTERM2_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GTKTERM2_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gtkterm2.prepare: $(gtkterm2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTKTERM2_DIR)/config.cache)
	cd $(GTKTERM2_DIR) && \
		$(GTKTERM2_PATH) $(GTKTERM2_ENV) \
		./configure $(GTKTERM2_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gtkterm2_compile: $(STATEDIR)/gtkterm2.compile

gtkterm2_compile_deps = $(STATEDIR)/gtkterm2.prepare

$(STATEDIR)/gtkterm2.compile: $(gtkterm2_compile_deps)
	@$(call targetinfo, $@)
	$(GTKTERM2_PATH) $(MAKE) -C $(GTKTERM2_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gtkterm2_install: $(STATEDIR)/gtkterm2.install

$(STATEDIR)/gtkterm2.install: $(STATEDIR)/gtkterm2.compile
	@$(call targetinfo, $@)
	$(GTKTERM2_PATH) $(MAKE) -C $(GTKTERM2_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gtkterm2_targetinstall: $(STATEDIR)/gtkterm2.targetinstall

gtkterm2_targetinstall_deps = $(STATEDIR)/gtkterm2.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/vte.targetinstall

$(STATEDIR)/gtkterm2.targetinstall: $(gtkterm2_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GTKTERM2_PATH) $(MAKE) -C $(GTKTERM2_DIR) DESTDIR=$(GTKTERM2_IPKG_TMP) install
	rm -rf $(GTKTERM2_IPKG_TMP)/usr/doc
	rm -rf $(GTKTERM2_IPKG_TMP)/usr/share/locale
	$(CROSSSTRIP) $(GTKTERM2_IPKG_TMP)/usr/bin/*
	mkdir -p $(GTKTERM2_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/gtkterm2.desktop $(GTKTERM2_IPKG_TMP)/usr/share/applications
	mkdir -p $(GTKTERM2_IPKG_TMP)/CONTROL
	echo "Package: gtkterm2" 							 >$(GTKTERM2_IPKG_TMP)/CONTROL/control
	echo "Source: $(GTKTERM2_URL)"							>>$(GTKTERM2_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GTKTERM2_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(GTKTERM2_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GTKTERM2_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GTKTERM2_IPKG_TMP)/CONTROL/control
	echo "Version: $(GTKTERM2_VERSION)-$(GTKTERM2_VENDOR_VERSION)" 			>>$(GTKTERM2_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, vte" 							>>$(GTKTERM2_IPKG_TMP)/CONTROL/control
	echo "Description: GTK2 terminal with tabs"					>>$(GTKTERM2_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GTKTERM2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GTKTERM2_INSTALL
ROMPACKAGES += $(STATEDIR)/gtkterm2.imageinstall
endif

gtkterm2_imageinstall_deps = $(STATEDIR)/gtkterm2.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gtkterm2.imageinstall: $(gtkterm2_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gtkterm2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gtkterm2_clean:
	rm -rf $(STATEDIR)/gtkterm2.*
	rm -rf $(GTKTERM2_DIR)

# vim: syntax=make
