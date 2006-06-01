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
ifdef PTXCONF_HEXEDIT
PACKAGES += hexedit
endif

#
# Paths and names
#
HEXEDIT_VENDOR_VERSION	= 1
HEXEDIT_VERSION		= 1.2.10
HEXEDIT			= hexedit-$(HEXEDIT_VERSION)
HEXEDIT_SUFFIX		= src.tgz
HEXEDIT_URL		= http://merd.net/pixel/$(HEXEDIT).$(HEXEDIT_SUFFIX)
HEXEDIT_SOURCE		= $(SRCDIR)/$(HEXEDIT).$(HEXEDIT_SUFFIX)
HEXEDIT_DIR		= $(BUILDDIR)/hexedit
HEXEDIT_IPKG_TMP	= $(HEXEDIT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

hexedit_get: $(STATEDIR)/hexedit.get

hexedit_get_deps = $(HEXEDIT_SOURCE)

$(STATEDIR)/hexedit.get: $(hexedit_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(HEXEDIT))
	touch $@

$(HEXEDIT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(HEXEDIT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

hexedit_extract: $(STATEDIR)/hexedit.extract

hexedit_extract_deps = $(STATEDIR)/hexedit.get

$(STATEDIR)/hexedit.extract: $(hexedit_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HEXEDIT_DIR))
	@$(call extract, $(HEXEDIT_SOURCE))
	@$(call patchin, $(HEXEDIT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

hexedit_prepare: $(STATEDIR)/hexedit.prepare

#
# dependencies
#
hexedit_prepare_deps = \
	$(STATEDIR)/hexedit.extract \
	$(STATEDIR)/virtual-xchain.install

HEXEDIT_PATH	=  PATH=$(CROSS_PATH)
HEXEDIT_ENV 	=  $(CROSS_ENV)
#HEXEDIT_ENV	+=
HEXEDIT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#HEXEDIT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
HEXEDIT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
HEXEDIT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
HEXEDIT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/hexedit.prepare: $(hexedit_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HEXEDIT_DIR)/config.cache)
	cd $(HEXEDIT_DIR) && \
		$(HEXEDIT_PATH) $(HEXEDIT_ENV) \
		./configure $(HEXEDIT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

hexedit_compile: $(STATEDIR)/hexedit.compile

hexedit_compile_deps = $(STATEDIR)/hexedit.prepare

$(STATEDIR)/hexedit.compile: $(hexedit_compile_deps)
	@$(call targetinfo, $@)
	$(HEXEDIT_PATH) $(MAKE) -C $(HEXEDIT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

hexedit_install: $(STATEDIR)/hexedit.install

$(STATEDIR)/hexedit.install: $(STATEDIR)/hexedit.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

hexedit_targetinstall: $(STATEDIR)/hexedit.targetinstall

hexedit_targetinstall_deps = $(STATEDIR)/hexedit.compile

$(STATEDIR)/hexedit.targetinstall: $(hexedit_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(HEXEDIT_IPKG_TMP)/usr/bin
	$(INSTALL) -m 755 $(HEXEDIT_DIR)/hexedit $(HEXEDIT_IPKG_TMP)/usr/bin
	$(CROSSSTRIP) $(HEXEDIT_IPKG_TMP)/usr/bin/hexedit
	mkdir -p $(HEXEDIT_IPKG_TMP)/CONTROL
	echo "Package: hexedit" 							 >$(HEXEDIT_IPKG_TMP)/CONTROL/control
	echo "Source: $(HEXEDIT_URL)"						>>$(HEXEDIT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(HEXEDIT_IPKG_TMP)/CONTROL/control
	echo "Section: Console" 							>>$(HEXEDIT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(HEXEDIT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(HEXEDIT_IPKG_TMP)/CONTROL/control
	echo "Version: $(HEXEDIT_VERSION)-$(HEXEDIT_VENDOR_VERSION)" 			>>$(HEXEDIT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(HEXEDIT_IPKG_TMP)/CONTROL/control
	echo "Description: hexedit - view and edit files in hexadecimal or in ASCII"	>>$(HEXEDIT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(HEXEDIT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_HEXEDIT_INSTALL
ROMPACKAGES += $(STATEDIR)/hexedit.imageinstall
endif

hexedit_imageinstall_deps = $(STATEDIR)/hexedit.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/hexedit.imageinstall: $(hexedit_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install hexedit
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

hexedit_clean:
	rm -rf $(STATEDIR)/hexedit.*
	rm -rf $(HEXEDIT_DIR)

# vim: syntax=make
