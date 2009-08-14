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
ifdef PTXCONF_LIBOGG
PACKAGES += libogg
endif

#
# Paths and names
#
LIBOGG_VENDOR_VERSION	= 1
LIBOGG_VERSION	= 1.1.3
LIBOGG		= libogg-$(LIBOGG_VERSION)
LIBOGG_SUFFIX		= tar.gz
LIBOGG_URL		= http://downloads.xiph.org/releases/ogg/$(LIBOGG).$(LIBOGG_SUFFIX)
LIBOGG_SOURCE		= $(SRCDIR)/$(LIBOGG).$(LIBOGG_SUFFIX)
LIBOGG_DIR		= $(BUILDDIR)/$(LIBOGG)
LIBOGG_IPKG_TMP	= $(LIBOGG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libogg_get: $(STATEDIR)/libogg.get

libogg_get_deps = $(LIBOGG_SOURCE)

$(STATEDIR)/libogg.get: $(libogg_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBOGG))
	touch $@

$(LIBOGG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBOGG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libogg_extract: $(STATEDIR)/libogg.extract

libogg_extract_deps = $(STATEDIR)/libogg.get

$(STATEDIR)/libogg.extract: $(libogg_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBOGG_DIR))
	@$(call extract, $(LIBOGG_SOURCE))
	@$(call patchin, $(LIBOGG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libogg_prepare: $(STATEDIR)/libogg.prepare

#
# dependencies
#
libogg_prepare_deps = \
	$(STATEDIR)/libogg.extract \
	$(STATEDIR)/virtual-xchain.install

LIBOGG_PATH	=  PATH=$(CROSS_PATH)
LIBOGG_ENV 	=  $(CROSS_ENV)
#LIBOGG_ENV	+=
LIBOGG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBOGG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBOGG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LIBOGG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBOGG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libogg.prepare: $(libogg_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBOGG_DIR)/config.cache)
	cd $(LIBOGG_DIR) && \
		$(LIBOGG_PATH) $(LIBOGG_ENV) \
		./configure $(LIBOGG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libogg_compile: $(STATEDIR)/libogg.compile

libogg_compile_deps = $(STATEDIR)/libogg.prepare

$(STATEDIR)/libogg.compile: $(libogg_compile_deps)
	@$(call targetinfo, $@)
	$(LIBOGG_PATH) $(MAKE) -C $(LIBOGG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libogg_install: $(STATEDIR)/libogg.install

$(STATEDIR)/libogg.install: $(STATEDIR)/libogg.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBOGG_IPKG_TMP)
	$(LIBOGG_PATH) $(MAKE) -C $(LIBOGG_DIR) DESTDIR=$(LIBOGG_IPKG_TMP) install
	@$(call copyincludes, $(LIBOGG_IPKG_TMP))
	@$(call copylibraries,$(LIBOGG_IPKG_TMP))
	@$(call copymiscfiles,$(LIBOGG_IPKG_TMP))
	rm -rf $(LIBOGG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libogg_targetinstall: $(STATEDIR)/libogg.targetinstall

libogg_targetinstall_deps = $(STATEDIR)/libogg.compile

$(STATEDIR)/libogg.targetinstall: $(libogg_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBOGG_PATH) $(MAKE) -C $(LIBOGG_DIR) DESTDIR=$(LIBOGG_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LIBOGG_VERSION)-$(LIBOGG_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh libogg $(LIBOGG_IPKG_TMP)

	@$(call removedevfiles, $(LIBOGG_IPKG_TMP))
	@$(call stripfiles, $(LIBOGG_IPKG_TMP))
	mkdir -p $(LIBOGG_IPKG_TMP)/CONTROL
	echo "Package: libogg" 							 	 >$(LIBOGG_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBOGG_URL)"							>>$(LIBOGG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBOGG_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LIBOGG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBOGG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBOGG_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBOGG_VERSION)-$(LIBOGG_VENDOR_VERSION)" 			>>$(LIBOGG_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LIBOGG_IPKG_TMP)/CONTROL/control
	echo "Description: ogg is a library for manipulating ogg bitstreams"		>>$(LIBOGG_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LIBOGG_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBOGG_INSTALL
ROMPACKAGES += $(STATEDIR)/libogg.imageinstall
endif

libogg_imageinstall_deps = $(STATEDIR)/libogg.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libogg.imageinstall: $(libogg_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libogg
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libogg_clean:
	rm -rf $(STATEDIR)/libogg.*
	rm -rf $(LIBOGG_DIR)

# vim: syntax=make
