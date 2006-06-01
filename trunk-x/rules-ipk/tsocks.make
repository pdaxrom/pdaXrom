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
ifdef PTXCONF_TSOCKS
PACKAGES += tsocks
endif

#
# Paths and names
#
TSOCKS_VENDOR_VERSION	= 1
TSOCKS_VERSION		= 1.8beta5
TSOCKS			= tsocks-$(TSOCKS_VERSION)
TSOCKS_SUFFIX		= tar.gz
TSOCKS_URL		= http://citkit.dl.sourceforge.net/sourceforge/tsocks/$(TSOCKS).$(TSOCKS_SUFFIX)
TSOCKS_SOURCE		= $(SRCDIR)/$(TSOCKS).$(TSOCKS_SUFFIX)
TSOCKS_DIR		= $(BUILDDIR)/tsocks-1.8
TSOCKS_IPKG_TMP		= $(TSOCKS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tsocks_get: $(STATEDIR)/tsocks.get

tsocks_get_deps = $(TSOCKS_SOURCE)

$(STATEDIR)/tsocks.get: $(tsocks_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TSOCKS))
	touch $@

$(TSOCKS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TSOCKS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tsocks_extract: $(STATEDIR)/tsocks.extract

tsocks_extract_deps = $(STATEDIR)/tsocks.get

$(STATEDIR)/tsocks.extract: $(tsocks_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TSOCKS_DIR))
	@$(call extract, $(TSOCKS_SOURCE))
	@$(call patchin, $(TSOCKS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tsocks_prepare: $(STATEDIR)/tsocks.prepare

#
# dependencies
#
tsocks_prepare_deps = \
	$(STATEDIR)/tsocks.extract \
	$(STATEDIR)/virtual-xchain.install

TSOCKS_PATH	=  PATH=$(CROSS_PATH)
TSOCKS_ENV 	=  $(CROSS_ENV)
#TSOCKS_ENV	+=
TSOCKS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TSOCKS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
TSOCKS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
TSOCKS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TSOCKS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/tsocks.prepare: $(tsocks_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TSOCKS_DIR)/config.cache)
	cd $(TSOCKS_DIR) && \
		$(TSOCKS_PATH) $(TSOCKS_ENV) \
		./configure $(TSOCKS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tsocks_compile: $(STATEDIR)/tsocks.compile

tsocks_compile_deps = $(STATEDIR)/tsocks.prepare

$(STATEDIR)/tsocks.compile: $(tsocks_compile_deps)
	@$(call targetinfo, $@)
	$(TSOCKS_PATH) $(MAKE) -C $(TSOCKS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tsocks_install: $(STATEDIR)/tsocks.install

$(STATEDIR)/tsocks.install: $(STATEDIR)/tsocks.compile
	@$(call targetinfo, $@)
	#$(TSOCKS_PATH) $(MAKE) -C $(TSOCKS_DIR) install
	sdfsd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tsocks_targetinstall: $(STATEDIR)/tsocks.targetinstall

tsocks_targetinstall_deps = $(STATEDIR)/tsocks.compile

$(STATEDIR)/tsocks.targetinstall: $(tsocks_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TSOCKS_PATH) $(MAKE) -C $(TSOCKS_DIR) DESTDIR=$(TSOCKS_IPKG_TMP) install
	rm -rf $(TSOCKS_IPKG_TMP)/usr/man
	mkdir -p $(TSOCKS_IPKG_TMP)/etc
	cp -a $(TSOCKS_DIR)/tsocks.conf.*.example $(TSOCKS_IPKG_TMP)/etc
	$(CROSSSTRIP) $(TSOCKS_IPKG_TMP)/lib/*.so*
	mkdir -p $(TSOCKS_IPKG_TMP)/CONTROL
	echo "Package: tsocks" 								 >$(TSOCKS_IPKG_TMP)/CONTROL/control
	echo "Source: $(TSOCKS_URL)"							>>$(TSOCKS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(TSOCKS_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(TSOCKS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(TSOCKS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(TSOCKS_IPKG_TMP)/CONTROL/control
	echo "Version: $(TSOCKS_VERSION)-$(TSOCKS_VENDOR_VERSION)" 			>>$(TSOCKS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(TSOCKS_IPKG_TMP)/CONTROL/control
	echo "Description: transparent SOCKS proxying library."				>>$(TSOCKS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TSOCKS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TSOCKS_INSTALL
ROMPACKAGES += $(STATEDIR)/tsocks.imageinstall
endif

tsocks_imageinstall_deps = $(STATEDIR)/tsocks.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tsocks.imageinstall: $(tsocks_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tsocks
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tsocks_clean:
	rm -rf $(STATEDIR)/tsocks.*
	rm -rf $(TSOCKS_DIR)

# vim: syntax=make
