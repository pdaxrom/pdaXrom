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
ifdef PTXCONF_OSB-BROWSER
PACKAGES += osb-browser
endif

#
# Paths and names
#
OSB-BROWSER_VENDOR_VERSION	= 1
OSB-BROWSER_VERSION		= cvs-27122005
OSB-BROWSER			= osb-browser-$(OSB-BROWSER_VERSION)
OSB-BROWSER_SUFFIX		= tar.bz2
OSB-BROWSER_URL			= http://citkit.dl.sourceforge.net/sourceforge/gtk-webcore/$(OSB-BROWSER).$(OSB-BROWSER_SUFFIX)
OSB-BROWSER_SOURCE		= $(SRCDIR)/$(OSB-BROWSER).$(OSB-BROWSER_SUFFIX)
OSB-BROWSER_DIR			= $(BUILDDIR)/osb-browser
OSB-BROWSER_IPKG_TMP		= $(OSB-BROWSER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

osb-browser_get: $(STATEDIR)/osb-browser.get

osb-browser_get_deps = $(OSB-BROWSER_SOURCE)

$(STATEDIR)/osb-browser.get: $(osb-browser_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OSB-BROWSER))
	touch $@

$(OSB-BROWSER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OSB-BROWSER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

osb-browser_extract: $(STATEDIR)/osb-browser.extract

osb-browser_extract_deps = $(STATEDIR)/osb-browser.get

$(STATEDIR)/osb-browser.extract: $(osb-browser_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OSB-BROWSER_DIR))
	@$(call extract, $(OSB-BROWSER_SOURCE))
	@$(call patchin, $(OSB-BROWSER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

osb-browser_prepare: $(STATEDIR)/osb-browser.prepare

#
# dependencies
#
osb-browser_prepare_deps = \
	$(STATEDIR)/osb-browser.extract \
	$(STATEDIR)/osb-nrcit.install \
	$(STATEDIR)/virtual-xchain.install

OSB-BROWSER_PATH	=  PATH=$(CROSS_PATH)
OSB-BROWSER_ENV 	=  $(CROSS_ENV)
#OSB-BROWSER_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
#OSB-BROWSER_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
OSB-BROWSER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OSB-BROWSER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
OSB-BROWSER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
OSB-BROWSER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OSB-BROWSER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/osb-browser.prepare: $(osb-browser_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OSB-BROWSER_DIR)/config.cache)
	cd $(OSB-BROWSER_DIR) && \
		$(OSB-BROWSER_PATH) $(OSB-BROWSER_ENV) \
		./autogen.sh
	cd $(OSB-BROWSER_DIR) && \
		$(OSB-BROWSER_PATH) $(OSB-BROWSER_ENV) \
		./configure $(OSB-BROWSER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

osb-browser_compile: $(STATEDIR)/osb-browser.compile

osb-browser_compile_deps = $(STATEDIR)/osb-browser.prepare

$(STATEDIR)/osb-browser.compile: $(osb-browser_compile_deps)
	@$(call targetinfo, $@)
	$(OSB-BROWSER_PATH) $(MAKE) -C $(OSB-BROWSER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

osb-browser_install: $(STATEDIR)/osb-browser.install

$(STATEDIR)/osb-browser.install: $(STATEDIR)/osb-browser.compile
	@$(call targetinfo, $@)
	###$(OSB-BROWSER_PATH) $(MAKE) -C $(OSB-BROWSER_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

osb-browser_targetinstall: $(STATEDIR)/osb-browser.targetinstall

osb-browser_targetinstall_deps = $(STATEDIR)/osb-browser.compile \
	$(STATEDIR)/osb-nrcit.targetinstall

$(STATEDIR)/osb-browser.targetinstall: $(osb-browser_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OSB-BROWSER_PATH) $(MAKE) -C $(OSB-BROWSER_DIR) DESTDIR=$(OSB-BROWSER_IPKG_TMP) install install_sh=install
	$(CROSSSTRIP) $(OSB-BROWSER_IPKG_TMP)/usr/bin/*
	mkdir -p $(OSB-BROWSER_IPKG_TMP)/CONTROL
	echo "Package: osb-browser" 								 >$(OSB-BROWSER_IPKG_TMP)/CONTROL/control
	echo "Source: $(OSB-BROWSER_URL)"							>>$(OSB-BROWSER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(OSB-BROWSER_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 								>>$(OSB-BROWSER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(OSB-BROWSER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(OSB-BROWSER_IPKG_TMP)/CONTROL/control
	echo "Version: $(OSB-BROWSER_VERSION)-$(OSB-BROWSER_VENDOR_VERSION)" 			>>$(OSB-BROWSER_IPKG_TMP)/CONTROL/control
	echo "Depends: osb-nrcit, libglade" 							>>$(OSB-BROWSER_IPKG_TMP)/CONTROL/control
	echo "Description: OSB Internet Browser"						>>$(OSB-BROWSER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OSB-BROWSER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OSB-BROWSER_INSTALL
ROMPACKAGES += $(STATEDIR)/osb-browser.imageinstall
endif

osb-browser_imageinstall_deps = $(STATEDIR)/osb-browser.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/osb-browser.imageinstall: $(osb-browser_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install osb-browser
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

osb-browser_clean:
	rm -rf $(STATEDIR)/osb-browser.*
	rm -rf $(OSB-BROWSER_DIR)

# vim: syntax=make
