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
ifdef PTXCONF_SLANG
PACKAGES += slang
endif

#
# Paths and names
#
SLANG_VENDOR_VERSION	= 1
SLANG_VERSION		= 2.0.6
SLANG			= slang-$(SLANG_VERSION)
SLANG_SUFFIX		= tar.bz2
SLANG_URL		= ftp://ftp.plig.org/pub/slang/v2.0/$(SLANG).$(SLANG_SUFFIX)
SLANG_SOURCE		= $(SRCDIR)/$(SLANG).$(SLANG_SUFFIX)
SLANG_DIR		= $(BUILDDIR)/$(SLANG)
SLANG_IPKG_TMP		= $(SLANG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

slang_get: $(STATEDIR)/slang.get

slang_get_deps = $(SLANG_SOURCE)

$(STATEDIR)/slang.get: $(slang_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SLANG))
	touch $@

$(SLANG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SLANG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

slang_extract: $(STATEDIR)/slang.extract

slang_extract_deps = $(STATEDIR)/slang.get

$(STATEDIR)/slang.extract: $(slang_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SLANG_DIR))
	@$(call extract, $(SLANG_SOURCE))
	@$(call patchin, $(SLANG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

slang_prepare: $(STATEDIR)/slang.prepare

#
# dependencies
#
slang_prepare_deps = \
	$(STATEDIR)/slang.extract \
	$(STATEDIR)/virtual-xchain.install

SLANG_PATH	=  PATH=$(CROSS_PATH)
SLANG_ENV 	=  $(CROSS_ENV)
#SLANG_ENV	+=
SLANG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SLANG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SLANG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
SLANG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SLANG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/slang.prepare: $(slang_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SLANG_DIR)/config.cache)
	cd $(SLANG_DIR) && \
		$(SLANG_PATH) $(SLANG_ENV) \
		./configure $(SLANG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

slang_compile: $(STATEDIR)/slang.compile

slang_compile_deps = $(STATEDIR)/slang.prepare

$(STATEDIR)/slang.compile: $(slang_compile_deps)
	@$(call targetinfo, $@)
	$(SLANG_PATH) $(MAKE) -C $(SLANG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

slang_install: $(STATEDIR)/slang.install

$(STATEDIR)/slang.install: $(STATEDIR)/slang.compile
	@$(call targetinfo, $@)
	rm -rf $(SLANG_IPKG_TMP)
	$(SLANG_PATH) $(MAKE) -C $(SLANG_DIR) DESTDIR=$(SLANG_IPKG_TMP) install
	cp -a $(SLANG_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include/
	cp -a $(SLANG_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib/
	rm -rf $(SLANG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

slang_targetinstall: $(STATEDIR)/slang.targetinstall

slang_targetinstall_deps = $(STATEDIR)/slang.compile

$(STATEDIR)/slang.targetinstall: $(slang_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SLANG_PATH) $(MAKE) -C $(SLANG_DIR) DESTDIR=$(SLANG_IPKG_TMP) install
	mkdir -p $(SLANG_IPKG_TMP)/CONTROL
	echo "Package: slang" 								 >$(SLANG_IPKG_TMP)/CONTROL/control
	echo "Source: $(SLANG_URL)"							>>$(SLANG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SLANG_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(SLANG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SLANG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SLANG_IPKG_TMP)/CONTROL/control
	echo "Version: $(SLANG_VERSION)-$(SLANG_VENDOR_VERSION)" 			>>$(SLANG_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(SLANG_IPKG_TMP)/CONTROL/control
	echo "Description:  S-Lang is a multi-platform programmer's library designed to allow a developer to create robust multi-platform software." >>$(SLANG_IPKG_TMP)/CONTROL/control
	asdas
	@$(call makeipkg, $(SLANG_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SLANG_INSTALL
ROMPACKAGES += $(STATEDIR)/slang.imageinstall
endif

slang_imageinstall_deps = $(STATEDIR)/slang.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/slang.imageinstall: $(slang_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install slang
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

slang_clean:
	rm -rf $(STATEDIR)/slang.*
	rm -rf $(SLANG_DIR)

# vim: syntax=make
