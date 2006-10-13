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
ifdef PTXCONF_RP-PPPOE
PACKAGES += rp-pppoe
endif

#
# Paths and names
#
RP-PPPOE_VENDOR_VERSION	= 1
RP-PPPOE_VERSION	= 3.5
RP-PPPOE		= rp-pppoe-$(RP-PPPOE_VERSION)
RP-PPPOE_SUFFIX		= tar.gz
RP-PPPOE_URL		= http://www.roaringpenguin.com/penguin/pppoe/$(RP-PPPOE).$(RP-PPPOE_SUFFIX)
RP-PPPOE_SOURCE		= $(SRCDIR)/$(RP-PPPOE).$(RP-PPPOE_SUFFIX)
RP-PPPOE_DIR		= $(BUILDDIR)/$(RP-PPPOE)
RP-PPPOE_IPKG_TMP	= $(RP-PPPOE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rp-pppoe_get: $(STATEDIR)/rp-pppoe.get

rp-pppoe_get_deps = $(RP-PPPOE_SOURCE)

$(STATEDIR)/rp-pppoe.get: $(rp-pppoe_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(RP-PPPOE))
	touch $@

$(RP-PPPOE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(RP-PPPOE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rp-pppoe_extract: $(STATEDIR)/rp-pppoe.extract

rp-pppoe_extract_deps = $(STATEDIR)/rp-pppoe.get

$(STATEDIR)/rp-pppoe.extract: $(rp-pppoe_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RP-PPPOE_DIR))
	@$(call extract, $(RP-PPPOE_SOURCE))
	@$(call patchin, $(RP-PPPOE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rp-pppoe_prepare: $(STATEDIR)/rp-pppoe.prepare

#
# dependencies
#
rp-pppoe_prepare_deps = \
	$(STATEDIR)/rp-pppoe.extract \
	$(STATEDIR)/virtual-xchain.install

RP-PPPOE_PATH	=  PATH=$(CROSS_PATH)
RP-PPPOE_ENV 	=  $(CROSS_ENV)
#RP-PPPOE_ENV	+=
RP-PPPOE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#RP-PPPOE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
RP-PPPOE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
RP-PPPOE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
RP-PPPOE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/rp-pppoe.prepare: $(rp-pppoe_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RP-PPPOE_DIR)/config.cache)
	cd $(RP-PPPOE_DIR)/src && \
		$(RP-PPPOE_PATH) $(RP-PPPOE_ENV) \
		./configure $(RP-PPPOE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rp-pppoe_compile: $(STATEDIR)/rp-pppoe.compile

rp-pppoe_compile_deps = $(STATEDIR)/rp-pppoe.prepare

$(STATEDIR)/rp-pppoe.compile: $(rp-pppoe_compile_deps)
	@$(call targetinfo, $@)
	$(RP-PPPOE_PATH) $(MAKE) -C $(RP-PPPOE_DIR)/src
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rp-pppoe_install: $(STATEDIR)/rp-pppoe.install

$(STATEDIR)/rp-pppoe.install: $(STATEDIR)/rp-pppoe.compile
	@$(call targetinfo, $@)
	$(RP-PPPOE_PATH) $(MAKE) -C $(RP-PPPOE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rp-pppoe_targetinstall: $(STATEDIR)/rp-pppoe.targetinstall

rp-pppoe_targetinstall_deps = $(STATEDIR)/rp-pppoe.compile

$(STATEDIR)/rp-pppoe.targetinstall: $(rp-pppoe_targetinstall_deps)
	@$(call targetinfo, $@)
	$(RP-PPPOE_PATH) $(MAKE) -C $(RP-PPPOE_DIR) DESTDIR=$(RP-PPPOE_IPKG_TMP) install
	mkdir -p $(RP-PPPOE_IPKG_TMP)/CONTROL
	echo "Package: rp-pppoe" 								 >$(RP-PPPOE_IPKG_TMP)/CONTROL/control
	echo "Source: $(RP-PPPOE_URL)"						>>$(RP-PPPOE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(RP-PPPOE_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 								>>$(RP-PPPOE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(RP-PPPOE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(RP-PPPOE_IPKG_TMP)/CONTROL/control
	echo "Version: $(RP-PPPOE_VERSION)-$(RP-PPPOE_VENDOR_VERSION)" 				>>$(RP-PPPOE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 									>>$(RP-PPPOE_IPKG_TMP)/CONTROL/control
	echo "Description: PPPoE (Point-to-Point Protocol over Ethernet) is a protocol used by many ADSL Internet Service Providers. Roaring Penguin has a free PPPoE client for Linux and Solaris systems to connect to PPPoE service providers." >>$(RP-PPPOE_IPKG_TMP)/CONTROL/control
	asdasd
	@$(call makeipkg, $(RP-PPPOE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_RP-PPPOE_INSTALL
ROMPACKAGES += $(STATEDIR)/rp-pppoe.imageinstall
endif

rp-pppoe_imageinstall_deps = $(STATEDIR)/rp-pppoe.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/rp-pppoe.imageinstall: $(rp-pppoe_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install rp-pppoe
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rp-pppoe_clean:
	rm -rf $(STATEDIR)/rp-pppoe.*
	rm -rf $(RP-PPPOE_DIR)

# vim: syntax=make
