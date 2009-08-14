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
ifdef PTXCONF_VPNC
PACKAGES += vpnc
endif

#
# Paths and names
#
VPNC_VENDOR_VERSION	= 1
VPNC_VERSION		= 0.3.3
VPNC			= vpnc-$(VPNC_VERSION)
VPNC_SUFFIX		= tar.gz
VPNC_URL		= http://www.unix-ag.uni-kl.de/~massar/vpnc/$(VPNC).$(VPNC_SUFFIX)
VPNC_SOURCE		= $(SRCDIR)/$(VPNC).$(VPNC_SUFFIX)
VPNC_DIR		= $(BUILDDIR)/$(VPNC)
VPNC_IPKG_TMP		= $(VPNC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

vpnc_get: $(STATEDIR)/vpnc.get

vpnc_get_deps = $(VPNC_SOURCE)

$(STATEDIR)/vpnc.get: $(vpnc_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(VPNC))
	touch $@

$(VPNC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(VPNC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

vpnc_extract: $(STATEDIR)/vpnc.extract

vpnc_extract_deps = $(STATEDIR)/vpnc.get

$(STATEDIR)/vpnc.extract: $(vpnc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VPNC_DIR))
	@$(call extract, $(VPNC_SOURCE))
	@$(call patchin, $(VPNC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

vpnc_prepare: $(STATEDIR)/vpnc.prepare

#
# dependencies
#
vpnc_prepare_deps = \
	$(STATEDIR)/vpnc.extract \
	$(STATEDIR)/libgcrypt.install \
	$(STATEDIR)/virtual-xchain.install

VPNC_PATH	=  PATH=$(CROSS_PATH)
VPNC_ENV 	=  $(CROSS_ENV)
#VPNC_ENV	+=
VPNC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#VPNC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
VPNC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
VPNC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
VPNC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/vpnc.prepare: $(vpnc_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VPNC_DIR)/config.cache)
	#cd $(VPNC_DIR) && \
	#	$(VPNC_PATH) $(VPNC_ENV) \
	#	./configure $(VPNC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

vpnc_compile: $(STATEDIR)/vpnc.compile

vpnc_compile_deps = $(STATEDIR)/vpnc.prepare

$(STATEDIR)/vpnc.compile: $(vpnc_compile_deps)
	@$(call targetinfo, $@)
	$(VPNC_PATH) $(VPNC_ENV) $(MAKE) -C $(VPNC_DIR) PREFIX=/usr $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

vpnc_install: $(STATEDIR)/vpnc.install

$(STATEDIR)/vpnc.install: $(STATEDIR)/vpnc.compile
	@$(call targetinfo, $@)
	#$(VPNC_PATH) $(MAKE) -C $(VPNC_DIR) install
	asd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

vpnc_targetinstall: $(STATEDIR)/vpnc.targetinstall

vpnc_targetinstall_deps = $(STATEDIR)/vpnc.compile \
	$(STATEDIR)/libgcrypt.targetinstall

$(STATEDIR)/vpnc.targetinstall: $(vpnc_targetinstall_deps)
	@$(call targetinfo, $@)
	$(VPNC_PATH) $(VPNC_ENV) $(MAKE) -C $(VPNC_DIR) PREFIX=/usr $(CROSS_ENV_CC) DESTDIR=$(VPNC_IPKG_TMP) install
	##$(VPNC_PATH) $(MAKE) -C $(VPNC_DIR)  install
	$(CROSSSTRIP) $(VPNC_IPKG_TMP)/usr/sbin/vpnc
	rm -rf $(VPNC_IPKG_TMP)/usr/share/man
	mkdir -p $(VPNC_IPKG_TMP)/CONTROL
	echo "Package: vpnc" 								 >$(VPNC_IPKG_TMP)/CONTROL/control
	echo "Source: $(VPNC_URL)"							>>$(VPNC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(VPNC_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(VPNC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(VPNC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(VPNC_IPKG_TMP)/CONTROL/control
	echo "Version: $(VPNC_VERSION)-$(VPNC_VENDOR_VERSION)" 				>>$(VPNC_IPKG_TMP)/CONTROL/control
	echo "Depends: libgcrypt" 							>>$(VPNC_IPKG_TMP)/CONTROL/control
	echo "Description: client for cisco3000 VPN Concentrator"			>>$(VPNC_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(VPNC_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_VPNC_INSTALL
ROMPACKAGES += $(STATEDIR)/vpnc.imageinstall
endif

vpnc_imageinstall_deps = $(STATEDIR)/vpnc.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/vpnc.imageinstall: $(vpnc_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install vpnc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

vpnc_clean:
	rm -rf $(STATEDIR)/vpnc.*
	rm -rf $(VPNC_DIR)

# vim: syntax=make
