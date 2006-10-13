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
ifdef PTXCONF_HOSTAP-UTILS
PACKAGES += hostap-utils
endif

#
# Paths and names
#
HOSTAP-UTILS_VENDOR_VERSION	= 1
HOSTAP-UTILS_VERSION		= 0.4.7
HOSTAP-UTILS			= hostap-utils-$(HOSTAP-UTILS_VERSION)
HOSTAP-UTILS_SUFFIX		= tar.gz
HOSTAP-UTILS_URL		= http://hostap.epitest.fi/releases/$(HOSTAP-UTILS).$(HOSTAP-UTILS_SUFFIX)
HOSTAP-UTILS_SOURCE		= $(SRCDIR)/$(HOSTAP-UTILS).$(HOSTAP-UTILS_SUFFIX)
HOSTAP-UTILS_DIR		= $(BUILDDIR)/$(HOSTAP-UTILS)
HOSTAP-UTILS_IPKG_TMP		= $(HOSTAP-UTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

hostap-utils_get: $(STATEDIR)/hostap-utils.get

hostap-utils_get_deps = $(HOSTAP-UTILS_SOURCE)

$(STATEDIR)/hostap-utils.get: $(hostap-utils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(HOSTAP-UTILS))
	touch $@

$(HOSTAP-UTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(HOSTAP-UTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

hostap-utils_extract: $(STATEDIR)/hostap-utils.extract

hostap-utils_extract_deps = $(STATEDIR)/hostap-utils.get

$(STATEDIR)/hostap-utils.extract: $(hostap-utils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HOSTAP-UTILS_DIR))
	@$(call extract, $(HOSTAP-UTILS_SOURCE))
	@$(call patchin, $(HOSTAP-UTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

hostap-utils_prepare: $(STATEDIR)/hostap-utils.prepare

#
# dependencies
#
hostap-utils_prepare_deps = \
	$(STATEDIR)/hostap-utils.extract \
	$(STATEDIR)/hostap-driver.targetinstall \
	$(STATEDIR)/virtual-xchain.install

HOSTAP-UTILS_PATH	=  PATH=$(CROSS_PATH)
HOSTAP-UTILS_ENV 	=  $(CROSS_ENV)
#HOSTAP-UTILS_ENV	+=
HOSTAP-UTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#HOSTAP-UTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
HOSTAP-UTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
HOSTAP-UTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
HOSTAP-UTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/hostap-utils.prepare: $(hostap-utils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HOSTAP-UTILS_DIR)/config.cache)
	#cd $(HOSTAP-UTILS_DIR) && \
	#	$(HOSTAP-UTILS_PATH) $(HOSTAP-UTILS_ENV) \
	#	./configure $(HOSTAP-UTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

hostap-utils_compile: $(STATEDIR)/hostap-utils.compile

hostap-utils_compile_deps = $(STATEDIR)/hostap-utils.prepare

$(STATEDIR)/hostap-utils.compile: $(hostap-utils_compile_deps)
	@$(call targetinfo, $@)
	$(HOSTAP-UTILS_PATH) $(HOSTAP-UTILS_ENV) $(MAKE) -C $(HOSTAP-UTILS_DIR) CFLAGS="-O2 -Wall -I$(HOSTAP-DRIVER)/driver/modules"
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

hostap-utils_install: $(STATEDIR)/hostap-utils.install

$(STATEDIR)/hostap-utils.install: $(STATEDIR)/hostap-utils.compile
	@$(call targetinfo, $@)
	##$(HOSTAP-UTILS_PATH) $(MAKE) -C $(HOSTAP-UTILS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

hostap-utils_targetinstall: $(STATEDIR)/hostap-utils.targetinstall

hostap-utils_targetinstall_deps = $(STATEDIR)/hostap-utils.compile

$(STATEDIR)/hostap-utils.targetinstall: $(hostap-utils_targetinstall_deps)
	@$(call targetinfo, $@)
	##$(HOSTAP-UTILS_PATH) $(MAKE) -C $(HOSTAP-UTILS_DIR) DESTDIR=$(HOSTAP-UTILS_IPKG_TMP) install
	mkdir -p $(HOSTAP-UTILS_IPKG_TMP)/usr/bin
	cp -a $(HOSTAP-UTILS_DIR)/{hostap_crypt_conf,hostap_diag,hostap_fw_load,hostap_io_debug,hostap_rid,prism2_param,prism2_srec,split_combined_hex} \
		$(HOSTAP-UTILS_IPKG_TMP)/usr/bin
	$(CROSSSTRIP) $(HOSTAP-UTILS_IPKG_TMP)/usr/bin/{hostap_crypt_conf,hostap_diag,hostap_io_debug,hostap_rid,prism2_srec}
	mkdir -p $(HOSTAP-UTILS_IPKG_TMP)/CONTROL
	echo "Package: hostap-utils" 							 >$(HOSTAP-UTILS_IPKG_TMP)/CONTROL/control
	echo "Source: $(HOSTAP-UTILS_URL)"						>>$(HOSTAP-UTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(HOSTAP-UTILS_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(HOSTAP-UTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(HOSTAP-UTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(HOSTAP-UTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(HOSTAP-UTILS_VERSION)-$(HOSTAP-UTILS_VENDOR_VERSION)" 		>>$(HOSTAP-UTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: hostap-driver" 							>>$(HOSTAP-UTILS_IPKG_TMP)/CONTROL/control
	echo "Description: hostap wireless utils"					>>$(HOSTAP-UTILS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(HOSTAP-UTILS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_HOSTAP-UTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/hostap-utils.imageinstall
endif

hostap-utils_imageinstall_deps = $(STATEDIR)/hostap-utils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/hostap-utils.imageinstall: $(hostap-utils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install hostap-utils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

hostap-utils_clean:
	rm -rf $(STATEDIR)/hostap-utils.*
	rm -rf $(HOSTAP-UTILS_DIR)

# vim: syntax=make
