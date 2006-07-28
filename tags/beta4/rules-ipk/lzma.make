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
ifdef PTXCONF_LZMA
PACKAGES += lzma
endif

#
# Paths and names
#
LZMA_VENDOR_VERSION	= 1
LZMA_VERSION		= 417
LZMA			= lzma$(LZMA_VERSION)
LZMA_SUFFIX		= tar.bz2
LZMA_URL		= http://www.7-zip.org/dl/$(LZMA).$(LZMA_SUFFIX)
LZMA_SOURCE		= $(SRCDIR)/$(LZMA).$(LZMA_SUFFIX)
LZMA_DIR		= $(BUILDDIR)/$(LZMA)
LZMA_IPKG_TMP		= $(LZMA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lzma_get: $(STATEDIR)/lzma.get

lzma_get_deps = $(LZMA_SOURCE)

$(STATEDIR)/lzma.get: $(lzma_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LZMA))
	touch $@

$(LZMA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LZMA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lzma_extract: $(STATEDIR)/lzma.extract

lzma_extract_deps = $(STATEDIR)/lzma.get

$(STATEDIR)/lzma.extract: $(lzma_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(LZMA_DIR))
	@$(call extract, $(LZMA_SOURCE), $(LZMA_DIR))
	@$(call patchin, $(LZMA), $(LZMA_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lzma_prepare: $(STATEDIR)/lzma.prepare

#
# dependencies
#
lzma_prepare_deps = \
	$(STATEDIR)/lzma.extract \
	$(STATEDIR)/virtual-xchain.install

LZMA_PATH	=  PATH=$(CROSS_PATH)
LZMA_ENV 	=  $(CROSS_ENV)
#LZMA_ENV	+=
LZMA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LZMA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LZMA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LZMA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LZMA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/lzma.prepare: $(lzma_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LZMA_DIR)/config.cache)
	cd $(LZMA_DIR) && \
		$(LZMA_PATH) $(LZMA_ENV) \
		./configure $(LZMA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lzma_compile: $(STATEDIR)/lzma.compile

lzma_compile_deps = $(STATEDIR)/lzma.prepare

$(STATEDIR)/lzma.compile: $(lzma_compile_deps)
	@$(call targetinfo, $@)
	$(LZMA_PATH) $(MAKE) -C $(LZMA_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lzma_install: $(STATEDIR)/lzma.install

$(STATEDIR)/lzma.install: $(STATEDIR)/lzma.compile
	@$(call targetinfo, $@)
	$(LZMA_PATH) $(MAKE) -C $(LZMA_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lzma_targetinstall: $(STATEDIR)/lzma.targetinstall

lzma_targetinstall_deps = $(STATEDIR)/lzma.compile

$(STATEDIR)/lzma.targetinstall: $(lzma_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LZMA_PATH) $(MAKE) -C $(LZMA_DIR) DESTDIR=$(LZMA_IPKG_TMP) install
	mkdir -p $(LZMA_IPKG_TMP)/CONTROL
	echo "Package: lzma" 							 >$(LZMA_IPKG_TMP)/CONTROL/control
	echo "Source: $(LZMA_URL)"							>>$(LZMA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LZMA_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(LZMA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(LZMA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LZMA_IPKG_TMP)/CONTROL/control
	echo "Version: $(LZMA_VERSION)-$(LZMA_VENDOR_VERSION)" 			>>$(LZMA_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LZMA_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(LZMA_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LZMA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LZMA_INSTALL
ROMPACKAGES += $(STATEDIR)/lzma.imageinstall
endif

lzma_imageinstall_deps = $(STATEDIR)/lzma.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/lzma.imageinstall: $(lzma_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lzma
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lzma_clean:
	rm -rf $(STATEDIR)/lzma.*
	rm -rf $(LZMA_DIR)

# vim: syntax=make
