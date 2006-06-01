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
ifdef PTXCONF_EFLTK
PACKAGES += efltk
endif

#
# Paths and names
#
EFLTK_VENDOR_VERSION	= 1
EFLTK_VERSION		= 2.0.5
EFLTK			= efltk-$(EFLTK_VERSION)
EFLTK_SUFFIX		= tar.bz2
EFLTK_URL		= http://citkit.dl.sourceforge.net/sourceforge/ede/$(EFLTK).$(EFLTK_SUFFIX)
EFLTK_SOURCE		= $(SRCDIR)/$(EFLTK).$(EFLTK_SUFFIX)
EFLTK_DIR		= $(BUILDDIR)/efltk
EFLTK_IPKG_TMP		= $(EFLTK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

efltk_get: $(STATEDIR)/efltk.get

efltk_get_deps = $(EFLTK_SOURCE)

$(STATEDIR)/efltk.get: $(efltk_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(EFLTK))
	touch $@

$(EFLTK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(EFLTK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

efltk_extract: $(STATEDIR)/efltk.extract

efltk_extract_deps = $(STATEDIR)/efltk.get

$(STATEDIR)/efltk.extract: $(efltk_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EFLTK_DIR))
	@$(call extract, $(EFLTK_SOURCE))
	@$(call patchin, $(EFLTK), $(EFLTK_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

efltk_prepare: $(STATEDIR)/efltk.prepare

#
# dependencies
#
efltk_prepare_deps = \
	$(STATEDIR)/efltk.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/xchain-efltk.install \
	$(STATEDIR)/virtual-xchain.install

EFLTK_PATH	=  PATH=$(CROSS_PATH)
EFLTK_ENV 	=  $(CROSS_ENV)
#EFLTK_ENV	+=
EFLTK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#EFLTK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
EFLTK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-xft \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--disable-opengl \
	--enable-plugins \
	--disable-unixODBC \
	--disable-mysql

ifdef PTXCONF_XFREE430
EFLTK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
EFLTK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/efltk.prepare: $(efltk_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EFLTK_DIR)/config.cache)
	cd $(EFLTK_DIR) && \
		$(EFLTK_PATH) $(EFLTK_ENV) \
		./configure $(EFLTK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

efltk_compile: $(STATEDIR)/efltk.compile

efltk_compile_deps = $(STATEDIR)/efltk.prepare

$(STATEDIR)/efltk.compile: $(efltk_compile_deps)
	@$(call targetinfo, $@)
	$(EFLTK_PATH) $(MAKE) -C $(EFLTK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

efltk_install: $(STATEDIR)/efltk.install

$(STATEDIR)/efltk.install: $(STATEDIR)/efltk.compile
	@$(call targetinfo, $@)
	rm -rf $(EFLTK_IPKG_TMP)
	mkdir -p $(EFLTK_IPKG_TMP)/usr/lib
	$(EFLTK_PATH) $(MAKE) -C $(EFLTK_DIR) prefix=$(EFLTK_IPKG_TMP)/usr install
	cp -a $(EFLTK_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(EFLTK_IPKG_TMP)/usr/lib/*.so*	$(CROSS_LIB_DIR)/lib/
	cp -a $(EFLTK_IPKG_TMP)/usr/bin/efltk-config $(PTXCONF_PREFIX)/bin
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(PTXCONF_PREFIX)/bin/efltk-config
	rm -rf $(EFLTK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

efltk_targetinstall: $(STATEDIR)/efltk.targetinstall

efltk_targetinstall_deps = $(STATEDIR)/efltk.compile \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/libxml2.targetinstall

$(STATEDIR)/efltk.targetinstall: $(efltk_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(EFLTK_IPKG_TMP)

	mkdir -p $(EFLTK_IPKG_TMP)/usr/lib
	$(EFLTK_PATH) $(MAKE) -C $(EFLTK_DIR) prefix=$(EFLTK_IPKG_TMP)/usr install

	rm -rf $(EFLTK_IPKG_TMP)/usr/include
	rm -f  $(EFLTK_IPKG_TMP)/usr/bin/{efltk-config,efluid,etranslate}
	
	$(CROSSSTRIP) $(EFLTK_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(EFLTK_IPKG_TMP)/usr/lib/fltk/*
	$(CROSSSTRIP) $(EFLTK_IPKG_TMP)/usr/lib/*.so*

	mkdir -p $(EFLTK_IPKG_TMP)/CONTROL
	echo "Package: efltk" 										 >$(EFLTK_IPKG_TMP)/CONTROL/control
	echo "Source: $(EFLTK_URL)"									>>$(EFLTK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(EFLTK_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 										>>$(EFLTK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 						>>$(EFLTK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(EFLTK_IPKG_TMP)/CONTROL/control
	echo "Version: $(EFLTK_VERSION)-$(EFLTK_VENDOR_VERSION)" 					>>$(EFLTK_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree, libxml2" 									>>$(EFLTK_IPKG_TMP)/CONTROL/control
	echo "Description: modified FLTK library (called extended FLTK or just eFLTK)"			>>$(EFLTK_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(EFLTK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_EFLTK_INSTALL
ROMPACKAGES += $(STATEDIR)/efltk.imageinstall
endif

efltk_imageinstall_deps = $(STATEDIR)/efltk.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/efltk.imageinstall: $(efltk_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install efltk
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

efltk_clean:
	rm -rf $(STATEDIR)/efltk.*
	rm -rf $(EFLTK_DIR)

# vim: syntax=make
