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
ifdef PTXCONF_GDICT
PACKAGES += gdict
endif

#
# Paths and names
#
GDICT_VENDOR_VERSION	= 1
GDICT_VERSION		= 0.0.6
GDICT			= gdict-$(GDICT_VERSION)
GDICT_SUFFIX		= tar.gz
GDICT_URL		= http://frustum.org/misc/data/projects/gdict/file/$(GDICT).$(GDICT_SUFFIX)
GDICT_DICT_URL		= http://www.pdaxrom.org/src/gdict.tar.gz
GDICT_SOURCE		= $(SRCDIR)/$(GDICT).$(GDICT_SUFFIX)
GDICT_DICT_SOURCE	= $(SRCDIR)/gdict.tar.gz
GDICT_DIR		= $(BUILDDIR)/$(GDICT)
GDICT_IPKG_TMP		= $(GDICT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gdict_get: $(STATEDIR)/gdict.get

gdict_get_deps = $(GDICT_SOURCE)

$(STATEDIR)/gdict.get: $(gdict_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GDICT))
	touch $@

$(GDICT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GDICT_URL))
	@$(call get, $(GDICT_DICT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gdict_extract: $(STATEDIR)/gdict.extract

gdict_extract_deps = $(STATEDIR)/gdict.get

$(STATEDIR)/gdict.extract: $(gdict_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(GDICT_DIR))
	@$(call extract, $(GDICT_SOURCE))
	@$(call extract, $(GDICT_DICT_SOURCE), $(GDICT_DIR))
	@$(call patchin, $(GDICT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gdict_prepare: $(STATEDIR)/gdict.prepare

#
# dependencies
#
gdict_prepare_deps = \
	$(STATEDIR)/gdict.extract \
	$(STATEDIR)/virtual-xchain.install

GDICT_PATH	=  PATH=$(CROSS_PATH)
GDICT_ENV 	=  $(CROSS_ENV)
#GDICT_ENV	+=
GDICT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GDICT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GDICT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GDICT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GDICT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gdict.prepare: $(gdict_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GDICT_DIR)/config.cache)
	cd $(GDICT_DIR) && \
		$(GDICT_PATH) $(GDICT_ENV) \
		./configure $(GDICT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gdict_compile: $(STATEDIR)/gdict.compile

gdict_compile_deps = $(STATEDIR)/gdict.prepare

$(STATEDIR)/gdict.compile: $(gdict_compile_deps)
	@$(call targetinfo, $@)
	$(GDICT_PATH) $(MAKE) -C $(GDICT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gdict_install: $(STATEDIR)/gdict.install

$(STATEDIR)/gdict.install: $(STATEDIR)/gdict.compile
	@$(call targetinfo, $@)
	###$(GDICT_PATH) $(MAKE) -C $(GDICT_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gdict_targetinstall: $(STATEDIR)/gdict.targetinstall

gdict_targetinstall_deps = $(STATEDIR)/gdict.compile

$(STATEDIR)/gdict.targetinstall: $(gdict_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GDICT_PATH) $(MAKE) -C $(GDICT_DIR) prefix=$(GDICT_IPKG_TMP)/usr install
	$(CROSSSTRIP) $(GDICT_IPKG_TMP)/usr/bin/*
	cp -a $(GDICT_DIR)/gdict/* $(GDICT_IPKG_TMP)/usr/share/gdict/
	$(INSTALL) -D -m 644 $(TOPDIR)/config/pics/gdict.desktop $(GDICT_IPKG_TMP)/usr/share/applications/gdict.desktop
	mkdir -p $(GDICT_IPKG_TMP)/CONTROL
	echo "Package: gdict" 								 >$(GDICT_IPKG_TMP)/CONTROL/control
	echo "Source: $(GDICT_URL)"						>>$(GDICT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GDICT_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 								>>$(GDICT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GDICT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GDICT_IPKG_TMP)/CONTROL/control
	echo "Version: $(GDICT_VERSION)-$(GDICT_VENDOR_VERSION)" 			>>$(GDICT_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 								>>$(GDICT_IPKG_TMP)/CONTROL/control
	echo "Description: Dictionary for UNIX"						>>$(GDICT_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(GDICT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GDICT_INSTALL
ROMPACKAGES += $(STATEDIR)/gdict.imageinstall
endif

gdict_imageinstall_deps = $(STATEDIR)/gdict.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gdict.imageinstall: $(gdict_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gdict
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gdict_clean:
	rm -rf $(STATEDIR)/gdict.*
	rm -rf $(GDICT_DIR)

# vim: syntax=make
