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
ifdef PTXCONF_MADWIFI-NG
PACKAGES += madwifi-ng
endif

#
# Paths and names
#
MADWIFI-NG_VENDOR_VERSION	= 1
MADWIFI-NG_VERSION		= r1491-20060404
MADWIFI-NG			= madwifi-ng-$(MADWIFI-NG_VERSION)
MADWIFI-NG_SUFFIX		= tar.gz
MADWIFI-NG_URL			= http://www.pdaXrom.org/src/$(MADWIFI-NG).$(MADWIFI-NG_SUFFIX)
MADWIFI-NG_SOURCE		= $(SRCDIR)/$(MADWIFI-NG).$(MADWIFI-NG_SUFFIX)
MADWIFI-NG_DIR			= $(BUILDDIR)/$(MADWIFI-NG)
MADWIFI-NG_IPKG_TMP		= $(MADWIFI-NG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

madwifi-ng_get: $(STATEDIR)/madwifi-ng.get

madwifi-ng_get_deps = $(MADWIFI-NG_SOURCE)

$(STATEDIR)/madwifi-ng.get: $(madwifi-ng_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MADWIFI-NG))
	touch $@

$(MADWIFI-NG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MADWIFI-NG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

madwifi-ng_extract: $(STATEDIR)/madwifi-ng.extract

madwifi-ng_extract_deps = $(STATEDIR)/madwifi-ng.get

$(STATEDIR)/madwifi-ng.extract: $(madwifi-ng_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MADWIFI-NG_DIR))
	@$(call extract, $(MADWIFI-NG_SOURCE))
	@$(call patchin, $(MADWIFI-NG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

madwifi-ng_prepare: $(STATEDIR)/madwifi-ng.prepare

#
# dependencies
#
madwifi-ng_prepare_deps = \
	$(STATEDIR)/madwifi-ng.extract \
	$(STATEDIR)/virtual-xchain.install

MADWIFI-NG_PATH	=  PATH=$(CROSS_PATH)
MADWIFI-NG_ENV 	=  $(CROSS_ENV)
#MADWIFI-NG_ENV	+=
MADWIFI-NG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MADWIFI-NG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MADWIFI-NG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MADWIFI-NG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MADWIFI-NG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/madwifi-ng.prepare: $(madwifi-ng_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MADWIFI-NG_DIR)/config.cache)
	#cd $(MADWIFI-NG_DIR) && \
	#	$(MADWIFI-NG_PATH) $(MADWIFI-NG_ENV) \
	#	./configure $(MADWIFI-NG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

madwifi-ng_compile: $(STATEDIR)/madwifi-ng.compile

madwifi-ng_compile_deps = $(STATEDIR)/madwifi-ng.prepare

$(STATEDIR)/madwifi-ng.compile: $(madwifi-ng_compile_deps)
	@$(call targetinfo, $@)
	$(MADWIFI-NG_PATH) $(MAKE) -C $(MADWIFI-NG_DIR) \
	    KERNELPATH=$(KERNEL_DIR) $(CROSS_ENV_STRIP) BINDIR=/usr/bin MANDIR=/usr/man \
	    $(KERNEL_MAKEVARS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

madwifi-ng_install: $(STATEDIR)/madwifi-ng.install

$(STATEDIR)/madwifi-ng.install: $(STATEDIR)/madwifi-ng.compile
	@$(call targetinfo, $@)
	###$(MADWIFI-NG_PATH) $(MAKE) -C $(MADWIFI-NG_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

madwifi-ng_targetinstall: $(STATEDIR)/madwifi-ng.targetinstall

madwifi-ng_targetinstall_deps = $(STATEDIR)/madwifi-ng.compile

$(STATEDIR)/madwifi-ng.targetinstall: $(madwifi-ng_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MADWIFI-NG_PATH) $(MAKE) -C $(MADWIFI-NG_DIR) DESTDIR=$(MADWIFI-NG_IPKG_TMP) install KERNELPATH=$(KERNEL_DIR) $(CROSS_ENV_CC) $(CROSS_ENV_STRIP) BINDIR=/usr/bin MANDIR=/usr/man
	$(CROSSSTRIP) $(MADWIFI-NG_IPKG_TMP)/usr/bin/*
	rm -rf $(MADWIFI-NG_IPKG_TMP)/usr/man
	mkdir -p $(MADWIFI-NG_IPKG_TMP)/CONTROL
	echo "Package: madwifi-ng" 							 >$(MADWIFI-NG_IPKG_TMP)/CONTROL/control
	echo "Source: $(MADWIFI-NG_URL)"						>>$(MADWIFI-NG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MADWIFI-NG_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(MADWIFI-NG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(MADWIFI-NG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MADWIFI-NG_IPKG_TMP)/CONTROL/control
	echo "Version: $(MADWIFI-NG_VERSION)-$(MADWIFI-NG_VENDOR_VERSION)" 		>>$(MADWIFI-NG_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(MADWIFI-NG_IPKG_TMP)/CONTROL/control
	echo "Description: Atheros chipset drivers"					>>$(MADWIFI-NG_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(MADWIFI-NG_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MADWIFI-NG_INSTALL
ROMPACKAGES += $(STATEDIR)/madwifi-ng.imageinstall
endif

madwifi-ng_imageinstall_deps = $(STATEDIR)/madwifi-ng.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/madwifi-ng.imageinstall: $(madwifi-ng_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install madwifi-ng
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

madwifi-ng_clean:
	rm -rf $(STATEDIR)/madwifi-ng.*
	rm -rf $(MADWIFI-NG_DIR)

# vim: syntax=make
