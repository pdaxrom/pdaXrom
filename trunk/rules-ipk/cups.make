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
ifdef PTXCONF_CUPS
PACKAGES += cups
endif

#
# Paths and names
#
CUPS_VENDOR_VERSION	= 1
CUPS_VERSION		= 1.2.4
CUPS			= cups-$(CUPS_VERSION)
CUPS_SUFFIX		= tar.bz2
CUPS_URL		= http://ftp.funet.fi/pub/mirrors/ftp.easysw.com/pub/cups/1.2.4/$(CUPS)-source.$(CUPS_SUFFIX)
CUPS_SOURCE		= $(SRCDIR)/$(CUPS)-source.$(CUPS_SUFFIX)
CUPS_DIR		= $(BUILDDIR)/$(CUPS)
CUPS_IPKG_TMP		= $(CUPS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

cups_get: $(STATEDIR)/cups.get

cups_get_deps = $(CUPS_SOURCE)

$(STATEDIR)/cups.get: $(cups_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CUPS))
	touch $@

$(CUPS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CUPS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

cups_extract: $(STATEDIR)/cups.extract

cups_extract_deps = $(STATEDIR)/cups.get

$(STATEDIR)/cups.extract: $(cups_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CUPS_DIR))
	@$(call extract, $(CUPS_SOURCE))
	@$(call patchin, $(CUPS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

cups_prepare: $(STATEDIR)/cups.prepare

#
# dependencies
#
cups_prepare_deps = \
	$(STATEDIR)/cups.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/virtual-xchain.install

CUPS_PATH	=  PATH=$(CROSS_PATH)
CUPS_ENV 	=  $(CROSS_ENV)
#CUPS_ENV	+=
CUPS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CUPS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
CUPS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--disable-gnutls

ifdef PTXCONF_XFREE430
CUPS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CUPS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/cups.prepare: $(cups_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CUPS_DIR)/config.cache)
	cd $(CUPS_DIR) && \
		$(CUPS_PATH) $(CUPS_ENV) \
		./configure $(CUPS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

cups_compile: $(STATEDIR)/cups.compile

cups_compile_deps = $(STATEDIR)/cups.prepare

$(STATEDIR)/cups.compile: $(cups_compile_deps)
	@$(call targetinfo, $@)
	$(CUPS_PATH) $(MAKE) -C $(CUPS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

cups_install: $(STATEDIR)/cups.install

$(STATEDIR)/cups.install: $(STATEDIR)/cups.compile
	@$(call targetinfo, $@)
	rm -rf $(CUPS_IPKG_TMP)
	$(CUPS_PATH) $(MAKE) -C $(CUPS_DIR) DSTROOT=$(CUPS_IPKG_TMP) install
	@$(call copyincludes, $(CUPS_IPKG_TMP))
	@$(call copylibraries,$(CUPS_IPKG_TMP))
	@$(call copymiscfiles,$(CUPS_IPKG_TMP))
	rm -rf $(CUPS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

cups_targetinstall: $(STATEDIR)/cups.targetinstall

cups_targetinstall_deps = $(STATEDIR)/cups.compile \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/zlib.targetinstall \
	$(STATEDIR)/libpng125.targetinstall \
	$(STATEDIR)/jpeg.targetinstall

CUPS_DEPLIST = openssl, libz, libpng, libjpeg

$(STATEDIR)/cups.targetinstall: $(cups_targetinstall_deps)
	@$(call targetinfo, $@)
	$(CUPS_PATH) $(MAKE) -C $(CUPS_DIR) DSTROOT=$(CUPS_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(CUPS_VERSION)-$(CUPS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh cups $(CUPS_IPKG_TMP)

	@$(call removedevfiles, $(CUPS_IPKG_TMP))
	@$(call stripfiles, $(CUPS_IPKG_TMP))
	mkdir -p $(CUPS_IPKG_TMP)/CONTROL
	echo "Package: cups" 								 >$(CUPS_IPKG_TMP)/CONTROL/control
	echo "Source: $(CUPS_URL)"							>>$(CUPS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(CUPS_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 								>>$(CUPS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(CUPS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(CUPS_IPKG_TMP)/CONTROL/control
	echo "Version: $(CUPS_VERSION)-$(CUPS_VENDOR_VERSION)" 				>>$(CUPS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(CUPS_DEPLIST)" 						>>$(CUPS_IPKG_TMP)/CONTROL/control
	echo "Description: An Internet printing system for Unix."			>>$(CUPS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(CUPS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CUPS_INSTALL
ROMPACKAGES += $(STATEDIR)/cups.imageinstall
endif

cups_imageinstall_deps = $(STATEDIR)/cups.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/cups.imageinstall: $(cups_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install cups
ifdef PTXCONF_CUPS-DOC_INSTALL
	cd $(FEEDDIR) && $(XIPKG) install cups-doc
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

cups_clean:
	rm -rf $(STATEDIR)/cups.*
	rm -rf $(CUPS_DIR)

# vim: syntax=make
