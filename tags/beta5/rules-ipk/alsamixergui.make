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
ifdef PTXCONF_ALSAMIXERGUI
PACKAGES += alsamixergui
endif

#
# Paths and names
#
ALSAMIXERGUI_VENDOR_VERSION	= 1
ALSAMIXERGUI_VERSION		= 0.9.0rc1-2
ALSAMIXERGUI			= alsamixergui-$(ALSAMIXERGUI_VERSION)
ALSAMIXERGUI_SUFFIX		= tar.gz
ALSAMIXERGUI_URL		= ftp://www.iua.upf.es/pub/mdeboer/projects/alsamixergui/$(ALSAMIXERGUI).$(ALSAMIXERGUI_SUFFIX)
ALSAMIXERGUI_SOURCE		= $(SRCDIR)/$(ALSAMIXERGUI).$(ALSAMIXERGUI_SUFFIX)
ALSAMIXERGUI_DIR		= $(BUILDDIR)/$(ALSAMIXERGUI)
ALSAMIXERGUI_IPKG_TMP		= $(ALSAMIXERGUI_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

alsamixergui_get: $(STATEDIR)/alsamixergui.get

alsamixergui_get_deps = $(ALSAMIXERGUI_SOURCE)

$(STATEDIR)/alsamixergui.get: $(alsamixergui_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ALSAMIXERGUI))
	touch $@

$(ALSAMIXERGUI_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ALSAMIXERGUI_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

alsamixergui_extract: $(STATEDIR)/alsamixergui.extract

alsamixergui_extract_deps = $(STATEDIR)/alsamixergui.get

$(STATEDIR)/alsamixergui.extract: $(alsamixergui_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALSAMIXERGUI_DIR))
	@$(call extract, $(ALSAMIXERGUI_SOURCE))
	@$(call patchin, $(ALSAMIXERGUI))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

alsamixergui_prepare: $(STATEDIR)/alsamixergui.prepare

#
# dependencies
#
alsamixergui_prepare_deps = \
	$(STATEDIR)/alsamixergui.extract \
	$(STATEDIR)/fltk-utf8.install \
	$(STATEDIR)/virtual-xchain.install

ALSAMIXERGUI_PATH	=  PATH=$(CROSS_PATH)
ALSAMIXERGUI_ENV 	=  $(CROSS_ENV)
#ALSAMIXERGUI_ENV	+=
ALSAMIXERGUI_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ALSAMIXERGUI_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ALSAMIXERGUI_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ALSAMIXERGUI_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ALSAMIXERGUI_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/alsamixergui.prepare: $(alsamixergui_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALSAMIXERGUI_DIR)/config.cache)
	cd $(ALSAMIXERGUI_DIR) && $(ALSAMIXERGUI_PATH) aclocal
	cd $(ALSAMIXERGUI_DIR) && $(ALSAMIXERGUI_PATH) automake --add-missing
	cd $(ALSAMIXERGUI_DIR) && $(ALSAMIXERGUI_PATH) autoconf
	cd $(ALSAMIXERGUI_DIR) && \
		$(ALSAMIXERGUI_PATH) $(ALSAMIXERGUI_ENV) \
		./configure $(ALSAMIXERGUI_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

alsamixergui_compile: $(STATEDIR)/alsamixergui.compile

alsamixergui_compile_deps = $(STATEDIR)/alsamixergui.prepare

$(STATEDIR)/alsamixergui.compile: $(alsamixergui_compile_deps)
	@$(call targetinfo, $@)
	$(ALSAMIXERGUI_PATH) $(MAKE) -C $(ALSAMIXERGUI_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

alsamixergui_install: $(STATEDIR)/alsamixergui.install

$(STATEDIR)/alsamixergui.install: $(STATEDIR)/alsamixergui.compile
	@$(call targetinfo, $@)
	$(ALSAMIXERGUI_PATH) $(MAKE) -C $(ALSAMIXERGUI_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

alsamixergui_targetinstall: $(STATEDIR)/alsamixergui.targetinstall

alsamixergui_targetinstall_deps = $(STATEDIR)/alsamixergui.compile \
	$(STATEDIR)/fltk-utf8.targetinstall

$(STATEDIR)/alsamixergui.targetinstall: $(alsamixergui_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ALSAMIXERGUI_PATH) $(MAKE) -C $(ALSAMIXERGUI_DIR) DESTDIR=$(ALSAMIXERGUI_IPKG_TMP) install
	mkdir -p $(ALSAMIXERGUI_IPKG_TMP)/CONTROL
	echo "Package: alsamixergui" 							 >$(ALSAMIXERGUI_IPKG_TMP)/CONTROL/control
	echo "Source: $(ALSAMIXERGUI_URL)"						>>$(ALSAMIXERGUI_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ALSAMIXERGUI_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(ALSAMIXERGUI_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ALSAMIXERGUI_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ALSAMIXERGUI_IPKG_TMP)/CONTROL/control
	echo "Version: $(ALSAMIXERGUI_VERSION)-$(ALSAMIXERGUI_VENDOR_VERSION)" 		>>$(ALSAMIXERGUI_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(ALSAMIXERGUI_IPKG_TMP)/CONTROL/control
	echo "Description: FLTK Alsamixer frontend"					>>$(ALSAMIXERGUI_IPKG_TMP)/CONTROL/control
	asdas
	cd $(FEEDDIR) && $(XMKIPKG) $(ALSAMIXERGUI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ALSAMIXERGUI_INSTALL
ROMPACKAGES += $(STATEDIR)/alsamixergui.imageinstall
endif

alsamixergui_imageinstall_deps = $(STATEDIR)/alsamixergui.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/alsamixergui.imageinstall: $(alsamixergui_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install alsamixergui
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

alsamixergui_clean:
	rm -rf $(STATEDIR)/alsamixergui.*
	rm -rf $(ALSAMIXERGUI_DIR)

# vim: syntax=make
