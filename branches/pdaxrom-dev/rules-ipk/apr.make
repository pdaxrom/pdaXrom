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
ifdef PTXCONF_APR
PACKAGES += apr
endif

#
# Paths and names
#
APR_VENDOR_VERSION	= 1
APR_VERSION	= 1.2.12
APR		= apr-$(APR_VERSION)
APR_SUFFIX		= tar.gz
APR_URL		= http://apache.mirror.facebook.com/apr/$(APR).$(APR_SUFFIX)
APR_SOURCE		= $(SRCDIR)/$(APR).$(APR_SUFFIX)
APR_DIR		= $(BUILDDIR)/$(APR)
APR_IPKG_TMP	= $(APR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

apr_get: $(STATEDIR)/apr.get

apr_get_deps = $(APR_SOURCE)

$(STATEDIR)/apr.get: $(apr_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(APR))
	touch $@

$(APR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(APR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

apr_extract: $(STATEDIR)/apr.extract

apr_extract_deps = $(STATEDIR)/apr.get

$(STATEDIR)/apr.extract: $(apr_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(APR_DIR))
	@$(call extract, $(APR_SOURCE))
	@$(call patchin, $(APR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

apr_prepare: $(STATEDIR)/apr.prepare

#
# dependencies
#
apr_prepare_deps = \
	$(STATEDIR)/apr.extract \
	$(STATEDIR)/virtual-xchain.install

APR_PATH	=  PATH=$(CROSS_PATH)
APR_ENV 	=  $(CROSS_ENV)
#APR_ENV	+=
APR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#APR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
APR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
APR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
APR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/apr.prepare: $(apr_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(APR_DIR)/config.cache)
	cd $(APR_DIR) && \
		$(APR_PATH) $(APR_ENV) \
		./configure $(APR_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

apr_compile: $(STATEDIR)/apr.compile

apr_compile_deps = $(STATEDIR)/apr.prepare

$(STATEDIR)/apr.compile: $(apr_compile_deps)
	@$(call targetinfo, $@)
	$(APR_PATH) $(MAKE) -C $(APR_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

apr_install: $(STATEDIR)/apr.install

$(STATEDIR)/apr.install: $(STATEDIR)/apr.compile
	@$(call targetinfo, $@)
	rm -rf $(APR_IPKG_TMP)
	$(APR_PATH) $(MAKE) -C $(APR_DIR) DESTDIR=$(APR_IPKG_TMP) install
	@$(call copyincludes, $(APR_IPKG_TMP))
	@$(call copylibraries,$(APR_IPKG_TMP))
	@$(call copymiscfiles,$(APR_IPKG_TMP))
	rm -rf $(APR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

apr_targetinstall: $(STATEDIR)/apr.targetinstall

apr_targetinstall_deps = $(STATEDIR)/apr.compile

APR_DEPLIST = 

$(STATEDIR)/apr.targetinstall: $(apr_targetinstall_deps)
	@$(call targetinfo, $@)
	$(APR_PATH) $(MAKE) -C $(APR_DIR) DESTDIR=$(APR_IPKG_TMP) install
	rm -rf $(APR_IPKG_TMP)/usr/build-1

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(APR_VERSION)-$(APR_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh apr $(APR_IPKG_TMP)

	@$(call removedevfiles, $(APR_IPKG_TMP))
	@$(call stripfiles, $(APR_IPKG_TMP))
	mkdir -p $(APR_IPKG_TMP)/CONTROL
	echo "Package: apr" 							 >$(APR_IPKG_TMP)/CONTROL/control
	echo "Source: $(APR_URL)"							>>$(APR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(APR_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(APR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(APR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(APR_IPKG_TMP)/CONTROL/control
	echo "Version: $(APR_VERSION)-$(APR_VENDOR_VERSION)" 			>>$(APR_IPKG_TMP)/CONTROL/control
	echo "Depends: $(APR_DEPLIST)" 						>>$(APR_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(APR_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(APR_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_APR_INSTALL
ROMPACKAGES += $(STATEDIR)/apr.imageinstall
endif

apr_imageinstall_deps = $(STATEDIR)/apr.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/apr.imageinstall: $(apr_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install apr
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

apr_clean:
	rm -rf $(STATEDIR)/apr.*
	rm -rf $(APR_DIR)

# vim: syntax=make
