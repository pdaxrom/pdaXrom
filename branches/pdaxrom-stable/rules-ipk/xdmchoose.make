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
ifdef PTXCONF_XDMCHOOSE
PACKAGES += xdmchoose
endif

#
# Paths and names
#
XDMCHOOSE_VENDOR_VERSION	= 1
XDMCHOOSE_VERSION		= 1.2.1
XDMCHOOSE			= xdmchoose-$(XDMCHOOSE_VERSION)
XDMCHOOSE_SUFFIX		= tar.gz
XDMCHOOSE_URL			= http://frmb.org/download/$(XDMCHOOSE).$(XDMCHOOSE_SUFFIX)
XDMCHOOSE_SOURCE		= $(SRCDIR)/$(XDMCHOOSE).$(XDMCHOOSE_SUFFIX)
XDMCHOOSE_DIR			= $(BUILDDIR)/$(XDMCHOOSE)
XDMCHOOSE_IPKG_TMP		= $(XDMCHOOSE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xdmchoose_get: $(STATEDIR)/xdmchoose.get

xdmchoose_get_deps = $(XDMCHOOSE_SOURCE)

$(STATEDIR)/xdmchoose.get: $(xdmchoose_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XDMCHOOSE))
	touch $@

$(XDMCHOOSE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XDMCHOOSE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xdmchoose_extract: $(STATEDIR)/xdmchoose.extract

xdmchoose_extract_deps = $(STATEDIR)/xdmchoose.get

$(STATEDIR)/xdmchoose.extract: $(xdmchoose_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XDMCHOOSE_DIR))
	@$(call extract, $(XDMCHOOSE_SOURCE))
	@$(call patchin, $(XDMCHOOSE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xdmchoose_prepare: $(STATEDIR)/xdmchoose.prepare

#
# dependencies
#
xdmchoose_prepare_deps = \
	$(STATEDIR)/xdmchoose.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

XDMCHOOSE_PATH	=  PATH=$(CROSS_PATH)
XDMCHOOSE_ENV 	=  $(CROSS_ENV)
#XDMCHOOSE_ENV	+=
XDMCHOOSE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XDMCHOOSE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XDMCHOOSE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XDMCHOOSE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XDMCHOOSE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xdmchoose.prepare: $(xdmchoose_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XDMCHOOSE_DIR)/config.cache)
	cd $(XDMCHOOSE_DIR) && \
		$(XDMCHOOSE_PATH) $(XDMCHOOSE_ENV) \
		./configure $(XDMCHOOSE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xdmchoose_compile: $(STATEDIR)/xdmchoose.compile

xdmchoose_compile_deps = $(STATEDIR)/xdmchoose.prepare

$(STATEDIR)/xdmchoose.compile: $(xdmchoose_compile_deps)
	@$(call targetinfo, $@)
	$(XDMCHOOSE_PATH) $(MAKE) -C $(XDMCHOOSE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xdmchoose_install: $(STATEDIR)/xdmchoose.install

$(STATEDIR)/xdmchoose.install: $(STATEDIR)/xdmchoose.compile
	@$(call targetinfo, $@)
	$(XDMCHOOSE_PATH) $(MAKE) -C $(XDMCHOOSE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xdmchoose_targetinstall: $(STATEDIR)/xdmchoose.targetinstall

xdmchoose_targetinstall_deps = $(STATEDIR)/xdmchoose.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/xdmchoose.targetinstall: $(xdmchoose_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XDMCHOOSE_PATH) $(MAKE) -C $(XDMCHOOSE_DIR) DESTDIR=$(XDMCHOOSE_IPKG_TMP) install
	rm -rf $(XDMCHOOSE_IPKG_TMP)/usr/man
	$(INSTALL) -m 644 -D $(XDMCHOOSE_DIR)/xdmchoose.conf $(XDMCHOOSE_IPKG_TMP)/etc/xdmchoose.conf
	$(CROSSSTRIP) $(XDMCHOOSE_IPKG_TMP)/usr/bin/*
	mkdir -p $(XDMCHOOSE_IPKG_TMP)/CONTROL
	echo "Package: xdmchoose" 										 >$(XDMCHOOSE_IPKG_TMP)/CONTROL/control
	echo "Source: $(XDMCHOOSE_URL)"						>>$(XDMCHOOSE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(XDMCHOOSE_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 											>>$(XDMCHOOSE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(XDMCHOOSE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(XDMCHOOSE_IPKG_TMP)/CONTROL/control
	echo "Version: $(XDMCHOOSE_VERSION)-$(XDMCHOOSE_VENDOR_VERSION)" 					>>$(XDMCHOOSE_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree" 										>>$(XDMCHOOSE_IPKG_TMP)/CONTROL/control
	echo "Description: A replacement chooser for XDM"							>>$(XDMCHOOSE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XDMCHOOSE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XDMCHOOSE_INSTALL
ROMPACKAGES += $(STATEDIR)/xdmchoose.imageinstall
endif

xdmchoose_imageinstall_deps = $(STATEDIR)/xdmchoose.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xdmchoose.imageinstall: $(xdmchoose_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xdmchoose
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xdmchoose_clean:
	rm -rf $(STATEDIR)/xdmchoose.*
	rm -rf $(XDMCHOOSE_DIR)

# vim: syntax=make
