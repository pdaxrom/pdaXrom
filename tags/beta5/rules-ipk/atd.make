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
ifdef PTXCONF_ATD
PACKAGES += atd
endif

#
# Paths and names
#
ATD_VENDOR_VERSION	= 1
ATD_VERSION		= 0.0.1
ATD			= atd-$(ATD_VERSION)
ATD_SUFFIX		= tar.bz2
ATD_URL			= http://www.pdaXrom.org/src/$(ATD).$(ATD_SUFFIX)
ATD_SOURCE		= $(SRCDIR)/$(ATD).$(ATD_SUFFIX)
ATD_DIR			= $(BUILDDIR)/$(ATD)
ATD_IPKG_TMP		= $(ATD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

atd_get: $(STATEDIR)/atd.get

atd_get_deps = $(ATD_SOURCE)

$(STATEDIR)/atd.get: $(atd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ATD))
	touch $@

$(ATD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ATD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

atd_extract: $(STATEDIR)/atd.extract

atd_extract_deps = $(STATEDIR)/atd.get

$(STATEDIR)/atd.extract: $(atd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ATD_DIR))
	@$(call extract, $(ATD_SOURCE))
	@$(call patchin, $(ATD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

atd_prepare: $(STATEDIR)/atd.prepare

#
# dependencies
#
atd_prepare_deps = \
	$(STATEDIR)/atd.extract \
	$(STATEDIR)/virtual-xchain.install

ATD_PATH	=  PATH=$(CROSS_PATH)
ATD_ENV 	=  $(CROSS_ENV)
#ATD_ENV	+=
ATD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ATD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ATD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ATD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ATD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/atd.prepare: $(atd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ATD_DIR)/config.cache)
	#cd $(ATD_DIR) && \
	#	$(ATD_PATH) $(ATD_ENV) \
	#	./configure $(ATD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

atd_compile: $(STATEDIR)/atd.compile

atd_compile_deps = $(STATEDIR)/atd.prepare

$(STATEDIR)/atd.compile: $(atd_compile_deps)
	@$(call targetinfo, $@)
	$(ATD_PATH) $(MAKE) -C $(ATD_DIR) $(CROSS_ENV_CXX) KERNEL_DIR=$(KERNEL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

atd_install: $(STATEDIR)/atd.install

$(STATEDIR)/atd.install: $(STATEDIR)/atd.compile
	@$(call targetinfo, $@)
	##$(ATD_PATH) $(MAKE) -C $(ATD_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

atd_targetinstall: $(STATEDIR)/atd.targetinstall

atd_targetinstall_deps = $(STATEDIR)/atd.compile

$(STATEDIR)/atd.targetinstall: $(atd_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ATD_PATH) $(MAKE) -C $(ATD_DIR) DESTDIR=$(ATD_IPKG_TMP) install
	###$(CROSSSTRIP) $(ATD_IPKG_TMP)/usr/sbin/*
	mkdir -p $(ATD_IPKG_TMP)/CONTROL
	echo "Package: atd" 								 >$(ATD_IPKG_TMP)/CONTROL/control
	echo "Source: $(ATD_URL)"							>>$(ATD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ATD_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(ATD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ATD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ATD_IPKG_TMP)/CONTROL/control
	echo "Version: $(ATD_VERSION)-$(ATD_VENDOR_VERSION)" 				>>$(ATD_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(ATD_IPKG_TMP)/CONTROL/control
	echo "Description: run jobs queued for later execution."			>>$(ATD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ATD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ATD_INSTALL
ROMPACKAGES += $(STATEDIR)/atd.imageinstall
endif

atd_imageinstall_deps = $(STATEDIR)/atd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/atd.imageinstall: $(atd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install atd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

atd_clean:
	rm -rf $(STATEDIR)/atd.*
	rm -rf $(ATD_DIR)

# vim: syntax=make
