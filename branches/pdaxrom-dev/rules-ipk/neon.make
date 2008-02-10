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
ifdef PTXCONF_NEON
PACKAGES += neon
endif

#
# Paths and names
#
NEON_VENDOR_VERSION	= 1
NEON_VERSION		= 0.25.5
NEON			= neon-$(NEON_VERSION)
NEON_SUFFIX		= tar.bz2
NEON_URL		= http://www.webdav.org/neon/$(NEON).$(NEON_SUFFIX)
NEON_SOURCE		= $(SRCDIR)/$(NEON).$(NEON_SUFFIX)
NEON_DIR		= $(BUILDDIR)/$(NEON)
NEON_IPKG_TMP		= $(NEON_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

neon_get: $(STATEDIR)/neon.get

neon_get_deps = $(NEON_SOURCE)

$(STATEDIR)/neon.get: $(neon_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NEON))
	touch $@

$(NEON_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NEON_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

neon_extract: $(STATEDIR)/neon.extract

neon_extract_deps = $(STATEDIR)/neon.get

$(STATEDIR)/neon.extract: $(neon_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NEON_DIR))
	@$(call extract, $(NEON_SOURCE))
	@$(call patchin, $(NEON))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

neon_prepare: $(STATEDIR)/neon.prepare

#
# dependencies
#
neon_prepare_deps = \
	$(STATEDIR)/neon.extract \
	$(STATEDIR)/virtual-xchain.install

NEON_PATH	=  PATH=$(CROSS_PATH)
NEON_ENV 	=  $(CROSS_ENV)
#NEON_ENV	+=
NEON_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NEON_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
NEON_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--with-ssl=openssl

ifdef PTXCONF_XFREE430
NEON_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NEON_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/neon.prepare: $(neon_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NEON_DIR)/config.cache)
	cd $(NEON_DIR) && \
		$(NEON_PATH) $(NEON_ENV) \
		./configure $(NEON_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

neon_compile: $(STATEDIR)/neon.compile

neon_compile_deps = $(STATEDIR)/neon.prepare

$(STATEDIR)/neon.compile: $(neon_compile_deps)
	@$(call targetinfo, $@)
	$(NEON_PATH) $(MAKE) -C $(NEON_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

neon_install: $(STATEDIR)/neon.install

$(STATEDIR)/neon.install: $(STATEDIR)/neon.compile
	@$(call targetinfo, $@)
	rm -rf $(NEON_IPKG_TMP)
	$(NEON_PATH) $(MAKE) -C $(NEON_DIR) DESTDIR=$(NEON_IPKG_TMP) install
	@$(call copyincludes, $(NEON_IPKG_TMP))
	@$(call copylibraries,$(NEON_IPKG_TMP))
	@$(call copymiscfiles,$(NEON_IPKG_TMP))
	rm -rf $(NEON_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

neon_targetinstall: $(STATEDIR)/neon.targetinstall

neon_targetinstall_deps = $(STATEDIR)/neon.compile

NEON_DEPLIST = 

$(STATEDIR)/neon.targetinstall: $(neon_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NEON_PATH) $(MAKE) -C $(NEON_DIR) DESTDIR=$(NEON_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(NEON_VERSION)-$(NEON_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh neon $(NEON_IPKG_TMP)

	@$(call removedevfiles, $(NEON_IPKG_TMP))
	@$(call stripfiles, $(NEON_IPKG_TMP))
	mkdir -p $(NEON_IPKG_TMP)/CONTROL
	echo "Package: neon" 							 >$(NEON_IPKG_TMP)/CONTROL/control
	echo "Source: $(NEON_URL)"							>>$(NEON_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(NEON_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(NEON_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(NEON_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(NEON_IPKG_TMP)/CONTROL/control
	echo "Version: $(NEON_VERSION)-$(NEON_VENDOR_VERSION)" 			>>$(NEON_IPKG_TMP)/CONTROL/control
	echo "Depends: $(NEON_DEPLIST)" 						>>$(NEON_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(NEON_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(NEON_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NEON_INSTALL
ROMPACKAGES += $(STATEDIR)/neon.imageinstall
endif

neon_imageinstall_deps = $(STATEDIR)/neon.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/neon.imageinstall: $(neon_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install neon
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

neon_clean:
	rm -rf $(STATEDIR)/neon.*
	rm -rf $(NEON_DIR)

# vim: syntax=make
