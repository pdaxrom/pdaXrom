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
ifdef PTXCONF_GNOME-DOC-UTILS
PACKAGES += gnome-doc-utils
endif

#
# Paths and names
#
GNOME-DOC-UTILS_VENDOR_VERSION	= 1
GNOME-DOC-UTILS_VERSION		= 0.7.2
GNOME-DOC-UTILS			= gnome-doc-utils-$(GNOME-DOC-UTILS_VERSION)
GNOME-DOC-UTILS_SUFFIX		= tar.bz2
GNOME-DOC-UTILS_URL		= http://ftp.acc.umu.se/pub/gnome/sources/gnome-doc-utils/0.7/$(GNOME-DOC-UTILS).$(GNOME-DOC-UTILS_SUFFIX)
GNOME-DOC-UTILS_SOURCE		= $(SRCDIR)/$(GNOME-DOC-UTILS).$(GNOME-DOC-UTILS_SUFFIX)
GNOME-DOC-UTILS_DIR		= $(BUILDDIR)/$(GNOME-DOC-UTILS)
GNOME-DOC-UTILS_IPKG_TMP	= $(GNOME-DOC-UTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gnome-doc-utils_get: $(STATEDIR)/gnome-doc-utils.get

gnome-doc-utils_get_deps = $(GNOME-DOC-UTILS_SOURCE)

$(STATEDIR)/gnome-doc-utils.get: $(gnome-doc-utils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GNOME-DOC-UTILS))
	touch $@

$(GNOME-DOC-UTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GNOME-DOC-UTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gnome-doc-utils_extract: $(STATEDIR)/gnome-doc-utils.extract

gnome-doc-utils_extract_deps = $(STATEDIR)/gnome-doc-utils.get

$(STATEDIR)/gnome-doc-utils.extract: $(gnome-doc-utils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-DOC-UTILS_DIR))
	@$(call extract, $(GNOME-DOC-UTILS_SOURCE))
	@$(call patchin, $(GNOME-DOC-UTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gnome-doc-utils_prepare: $(STATEDIR)/gnome-doc-utils.prepare

#
# dependencies
#
gnome-doc-utils_prepare_deps = \
	$(STATEDIR)/gnome-doc-utils.extract \
	$(STATEDIR)/virtual-xchain.install

GNOME-DOC-UTILS_PATH	=  PATH=$(CROSS_PATH)
GNOME-DOC-UTILS_ENV 	=  $(CROSS_ENV)
#GNOME-DOC-UTILS_ENV	+=
GNOME-DOC-UTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GNOME-DOC-UTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GNOME-DOC-UTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GNOME-DOC-UTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GNOME-DOC-UTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gnome-doc-utils.prepare: $(gnome-doc-utils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-DOC-UTILS_DIR)/config.cache)
	cd $(GNOME-DOC-UTILS_DIR) && \
		$(GNOME-DOC-UTILS_PATH) $(GNOME-DOC-UTILS_ENV) \
		./configure $(GNOME-DOC-UTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gnome-doc-utils_compile: $(STATEDIR)/gnome-doc-utils.compile

gnome-doc-utils_compile_deps = $(STATEDIR)/gnome-doc-utils.prepare

$(STATEDIR)/gnome-doc-utils.compile: $(gnome-doc-utils_compile_deps)
	@$(call targetinfo, $@)
	$(GNOME-DOC-UTILS_PATH) $(MAKE) -C $(GNOME-DOC-UTILS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gnome-doc-utils_install: $(STATEDIR)/gnome-doc-utils.install

$(STATEDIR)/gnome-doc-utils.install: $(STATEDIR)/gnome-doc-utils.compile
	@$(call targetinfo, $@)
	rm -rf $(GNOME-DOC-UTILS_IPKG_TMP)
	$(GNOME-DOC-UTILS_PATH) $(MAKE) -C $(GNOME-DOC-UTILS_DIR) DESTDIR=$(GNOME-DOC-UTILS_IPKG_TMP) install
	@$(call copyincludes, $(GNOME-DOC-UTILS_IPKG_TMP))
	@$(call copylibraries,$(GNOME-DOC-UTILS_IPKG_TMP))
	@$(call copymiscfiles,$(GNOME-DOC-UTILS_IPKG_TMP))
	rm -rf $(GNOME-DOC-UTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gnome-doc-utils_targetinstall: $(STATEDIR)/gnome-doc-utils.targetinstall

gnome-doc-utils_targetinstall_deps = $(STATEDIR)/gnome-doc-utils.compile

$(STATEDIR)/gnome-doc-utils.targetinstall: $(gnome-doc-utils_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GNOME-DOC-UTILS_PATH) $(MAKE) -C $(GNOME-DOC-UTILS_DIR) DESTDIR=$(GNOME-DOC-UTILS_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(GNOME-DOC-UTILS_VERSION)-$(GNOME-DOC-UTILS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh gnome-doc-utils $(GNOME-DOC-UTILS_IPKG_TMP)

	@$(call removedevfiles, $(GNOME-DOC-UTILS_IPKG_TMP))
	@$(call stripfiles, $(GNOME-DOC-UTILS_IPKG_TMP))
	mkdir -p $(GNOME-DOC-UTILS_IPKG_TMP)/CONTROL
	echo "Package: gnome-doc-utils" 						 >$(GNOME-DOC-UTILS_IPKG_TMP)/CONTROL/control
	echo "Source: $(GNOME-DOC-UTILS_URL)"						>>$(GNOME-DOC-UTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GNOME-DOC-UTILS_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome" 								>>$(GNOME-DOC-UTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GNOME-DOC-UTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GNOME-DOC-UTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GNOME-DOC-UTILS_VERSION)-$(GNOME-DOC-UTILS_VENDOR_VERSION)" 	>>$(GNOME-DOC-UTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(GNOME-DOC-UTILS_IPKG_TMP)/CONTROL/control
	echo "Description: GNOME Documentation Utilities"				>>$(GNOME-DOC-UTILS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(GNOME-DOC-UTILS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GNOME-DOC-UTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/gnome-doc-utils.imageinstall
endif

gnome-doc-utils_imageinstall_deps = $(STATEDIR)/gnome-doc-utils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gnome-doc-utils.imageinstall: $(gnome-doc-utils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gnome-doc-utils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gnome-doc-utils_clean:
	rm -rf $(STATEDIR)/gnome-doc-utils.*
	rm -rf $(GNOME-DOC-UTILS_DIR)

# vim: syntax=make
