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
ifdef PTXCONF_APR-UTIL
PACKAGES += apr-util
endif

#
# Paths and names
#
APR-UTIL_VENDOR_VERSION	= 1
APR-UTIL_VERSION	= 1.2.12
APR-UTIL		= apr-util-$(APR-UTIL_VERSION)
APR-UTIL_SUFFIX		= tar.gz
APR-UTIL_URL		= http://apache.mirror.facebook.com/apr/$(APR-UTIL).$(APR-UTIL_SUFFIX)
APR-UTIL_SOURCE		= $(SRCDIR)/$(APR-UTIL).$(APR-UTIL_SUFFIX)
APR-UTIL_DIR		= $(BUILDDIR)/$(APR-UTIL)
APR-UTIL_IPKG_TMP	= $(APR-UTIL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

apr-util_get: $(STATEDIR)/apr-util.get

apr-util_get_deps = $(APR-UTIL_SOURCE)

$(STATEDIR)/apr-util.get: $(apr-util_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(APR-UTIL))
	touch $@

$(APR-UTIL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(APR-UTIL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

apr-util_extract: $(STATEDIR)/apr-util.extract

apr-util_extract_deps = $(STATEDIR)/apr-util.get

$(STATEDIR)/apr-util.extract: $(apr-util_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(APR-UTIL_DIR))
	@$(call extract, $(APR-UTIL_SOURCE))
	@$(call patchin, $(APR-UTIL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

apr-util_prepare: $(STATEDIR)/apr-util.prepare

#
# dependencies
#
apr-util_prepare_deps = \
	$(STATEDIR)/apr-util.extract \
	$(STATEDIR)/expat.install \
	$(STATEDIR)/apr.install \
	$(STATEDIR)/virtual-xchain.install

APR-UTIL_PATH	=  PATH=$(CROSS_PATH)
APR-UTIL_ENV 	=  $(CROSS_ENV)
#APR-UTIL_ENV	+=
APR-UTIL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#APR-UTIL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
APR-UTIL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--with-apr=$(APR_DIR)
#	--with-apr=$(CROSS_LIB_DIR)/../bin/apr-1-config

ifdef PTXCONF_XFREE430
APR-UTIL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
APR-UTIL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/apr-util.prepare: $(apr-util_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(APR-UTIL_DIR)/config.cache)
	cd $(APR-UTIL_DIR) && \
		$(APR-UTIL_PATH) $(APR-UTIL_ENV) \
		./configure $(APR-UTIL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

apr-util_compile: $(STATEDIR)/apr-util.compile

apr-util_compile_deps = $(STATEDIR)/apr-util.prepare

$(STATEDIR)/apr-util.compile: $(apr-util_compile_deps)
	@$(call targetinfo, $@)
	$(APR-UTIL_PATH) $(MAKE) -C $(APR-UTIL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

apr-util_install: $(STATEDIR)/apr-util.install

$(STATEDIR)/apr-util.install: $(STATEDIR)/apr-util.compile
	@$(call targetinfo, $@)
	rm -rf $(APR-UTIL_IPKG_TMP)
	$(APR-UTIL_PATH) $(MAKE) -C $(APR-UTIL_DIR) DESTDIR=$(APR-UTIL_IPKG_TMP) install
	@$(call copyincludes, $(APR-UTIL_IPKG_TMP))
	@$(call copylibraries,$(APR-UTIL_IPKG_TMP))
	@$(call copymiscfiles,$(APR-UTIL_IPKG_TMP))
	rm -rf $(APR-UTIL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

apr-util_targetinstall: $(STATEDIR)/apr-util.targetinstall

apr-util_targetinstall_deps = $(STATEDIR)/apr-util.compile \
	$(STATEDIR)/expat.targetinstall \
	$(STATEDIR)/apr.targetinstall

APR-UTIL_DEPLIST = 

$(STATEDIR)/apr-util.targetinstall: $(apr-util_targetinstall_deps)
	@$(call targetinfo, $@)
	$(APR-UTIL_PATH) $(MAKE) -C $(APR-UTIL_DIR) DESTDIR=$(APR-UTIL_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(APR-UTIL_VERSION)-$(APR-UTIL_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh apr-util $(APR-UTIL_IPKG_TMP)

	@$(call removedevfiles, $(APR-UTIL_IPKG_TMP))
	@$(call stripfiles, $(APR-UTIL_IPKG_TMP))
	mkdir -p $(APR-UTIL_IPKG_TMP)/CONTROL
	echo "Package: apr-util" 							 >$(APR-UTIL_IPKG_TMP)/CONTROL/control
	echo "Source: $(APR-UTIL_URL)"							>>$(APR-UTIL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(APR-UTIL_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(APR-UTIL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(APR-UTIL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(APR-UTIL_IPKG_TMP)/CONTROL/control
	echo "Version: $(APR-UTIL_VERSION)-$(APR-UTIL_VENDOR_VERSION)" 			>>$(APR-UTIL_IPKG_TMP)/CONTROL/control
	echo "Depends: $(APR-UTIL_DEPLIST)" 						>>$(APR-UTIL_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(APR-UTIL_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(APR-UTIL_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_APR-UTIL_INSTALL
ROMPACKAGES += $(STATEDIR)/apr-util.imageinstall
endif

apr-util_imageinstall_deps = $(STATEDIR)/apr-util.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/apr-util.imageinstall: $(apr-util_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install apr-util
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

apr-util_clean:
	rm -rf $(STATEDIR)/apr-util.*
	rm -rf $(APR-UTIL_DIR)

# vim: syntax=make
