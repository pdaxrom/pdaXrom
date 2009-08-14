# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_LPRNG
PACKAGES += LPRng
endif

#
# Paths and names
#
LPRNG_VENDOR_VERSION	= 1
LPRNG_VERSION		= 3.8.28
LPRNG			= LPRng-$(LPRNG_VERSION)
LPRNG_SUFFIX		= tgz
LPRNG_URL		= http://www.lprng.com/DISTRIB/LPRng/$(LPRNG).$(LPRNG_SUFFIX)
LPRNG_SOURCE		= $(SRCDIR)/$(LPRNG).$(LPRNG_SUFFIX)
LPRNG_DIR		= $(BUILDDIR)/$(LPRNG)
LPRNG_IPKG_TMP		= $(LPRNG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

LPRng_get: $(STATEDIR)/LPRng.get

LPRng_get_deps = $(LPRNG_SOURCE)

$(STATEDIR)/LPRng.get: $(LPRng_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LPRNG))
	touch $@

$(LPRNG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LPRNG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

LPRng_extract: $(STATEDIR)/LPRng.extract

LPRng_extract_deps = $(STATEDIR)/LPRng.get

$(STATEDIR)/LPRng.extract: $(LPRng_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LPRNG_DIR))
	@$(call extract, $(LPRNG_SOURCE))
	@$(call patchin, $(LPRNG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

LPRng_prepare: $(STATEDIR)/LPRng.prepare

#
# dependencies
#
LPRng_prepare_deps = \
	$(STATEDIR)/LPRng.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/virtual-xchain.install

LPRNG_PATH	=  PATH=$(CROSS_PATH)
LPRNG_ENV 	=  $(CROSS_ENV)
#LPRNG_ENV	+=
LPRNG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LPRNG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LPRNG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--libexecdir=/usr/lib \
	--enable-shared \
	--disable-static \
	--with-openssl=$(CROSS_LIB_DIR)

ifdef PTXCONF_XFREE430
LPRNG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LPRNG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/LPRng.prepare: $(LPRng_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LPRNG_DIR)/config.cache)
	cd $(LPRNG_DIR) && \
		$(LPRNG_PATH) $(LPRNG_ENV) \
		./configure $(LPRNG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

LPRng_compile: $(STATEDIR)/LPRng.compile

LPRng_compile_deps = $(STATEDIR)/LPRng.prepare

$(STATEDIR)/LPRng.compile: $(LPRng_compile_deps)
	@$(call targetinfo, $@)
	$(LPRNG_PATH) $(MAKE) -C $(LPRNG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

LPRng_install: $(STATEDIR)/LPRng.install

$(STATEDIR)/LPRng.install: $(STATEDIR)/LPRng.compile
	@$(call targetinfo, $@)
	rm -rf $(LPRNG_IPKG_TMP)
	$(LPRNG_PATH) $(MAKE) -C $(LPRNG_DIR) DESTDIR=$(LPRNG_IPKG_TMP) install
	@$(call copyincludes, $(LPRNG_IPKG_TMP))
	@$(call copylibraries,$(LPRNG_IPKG_TMP))
	@$(call copymiscfiles,$(LPRNG_IPKG_TMP))
	rm -rf $(LPRNG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

LPRng_targetinstall: $(STATEDIR)/LPRng.targetinstall

LPRng_targetinstall_deps = $(STATEDIR)/LPRng.compile \
	$(STATEDIR)/openssl.targetinstall

LPRNG_DEPLIST = 

$(STATEDIR)/LPRng.targetinstall: $(LPRng_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LPRNG_PATH) $(MAKE) -C $(LPRNG_DIR) DESTDIR=$(LPRNG_IPKG_TMP) install SUID_ROOT_PERMS=04755

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LPRNG_VERSION)-$(LPRNG_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh lprng $(LPRNG_IPKG_TMP)

	@$(call removedevfiles, $(LPRNG_IPKG_TMP))
	@$(call stripfiles, $(LPRNG_IPKG_TMP))
	mkdir -p $(LPRNG_IPKG_TMP)/CONTROL
	echo "Package: lprng" 								 >$(LPRNG_IPKG_TMP)/CONTROL/control
	echo "Source: $(LPRNG_URL)"							>>$(LPRNG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LPRNG_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(LPRNG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LPRNG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LPRNG_IPKG_TMP)/CONTROL/control
	echo "Version: $(LPRNG_VERSION)-$(LPRNG_VENDOR_VERSION)" 			>>$(LPRNG_IPKG_TMP)/CONTROL/control
	echo "Depends: $(LPRNG_DEPLIST)" 						>>$(LPRNG_IPKG_TMP)/CONTROL/control
	echo "Description: LPRng - An Enhanced Printer Spooler"				>>$(LPRNG_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LPRNG_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LPRNG_INSTALL
ROMPACKAGES += $(STATEDIR)/LPRng.imageinstall
endif

LPRng_imageinstall_deps = $(STATEDIR)/LPRng.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/LPRng.imageinstall: $(LPRng_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lprng
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

LPRng_clean:
	rm -rf $(STATEDIR)/LPRng.*
	rm -rf $(LPRNG_DIR)

# vim: syntax=make
