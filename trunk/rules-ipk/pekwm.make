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
ifdef PTXCONF_PEKWM
PACKAGES += pekwm
endif

#
# Paths and names
#
PEKWM_VENDOR_VERSION	= 1
PEKWM_VERSION		= 0.1.5
PEKWM			= pekwm-$(PEKWM_VERSION)
PEKWM_SUFFIX		= tar.bz2
PEKWM_URL		= http://www.pekwm.org/files/$(PEKWM).$(PEKWM_SUFFIX)
PEKWM_SOURCE		= $(SRCDIR)/$(PEKWM).$(PEKWM_SUFFIX)
PEKWM_DIR		= $(BUILDDIR)/$(PEKWM)
PEKWM_IPKG_TMP		= $(PEKWM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pekwm_get: $(STATEDIR)/pekwm.get

pekwm_get_deps = $(PEKWM_SOURCE)

$(STATEDIR)/pekwm.get: $(pekwm_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PEKWM))
	touch $@

$(PEKWM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PEKWM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pekwm_extract: $(STATEDIR)/pekwm.extract

pekwm_extract_deps = $(STATEDIR)/pekwm.get

$(STATEDIR)/pekwm.extract: $(pekwm_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PEKWM_DIR))
	@$(call extract, $(PEKWM_SOURCE))
	@$(call patchin, $(PEKWM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pekwm_prepare: $(STATEDIR)/pekwm.prepare

#
# dependencies
#
pekwm_prepare_deps = \
	$(STATEDIR)/pekwm.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

PEKWM_PATH	=  PATH=$(CROSS_PATH)
PEKWM_ENV 	=  $(CROSS_ENV)
#PEKWM_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
#PEKWM_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
PEKWM_ENV	+= CFLAGS="-g"
PEKWM_ENV	+= CXXFLAGS="-g"
PEKWM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PEKWM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PEKWM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-debug

ifdef PTXCONF_XFREE430
PEKWM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PEKWM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pekwm.prepare: $(pekwm_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PEKWM_DIR)/config.cache)
	cd $(PEKWM_DIR) && \
		$(PEKWM_PATH) $(PEKWM_ENV) \
		./configure $(PEKWM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pekwm_compile: $(STATEDIR)/pekwm.compile

pekwm_compile_deps = $(STATEDIR)/pekwm.prepare

$(STATEDIR)/pekwm.compile: $(pekwm_compile_deps)
	@$(call targetinfo, $@)
	$(PEKWM_PATH) $(MAKE) -C $(PEKWM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pekwm_install: $(STATEDIR)/pekwm.install

$(STATEDIR)/pekwm.install: $(STATEDIR)/pekwm.compile
	@$(call targetinfo, $@)
	#$(PEKWM_PATH) $(MAKE) -C $(PEKWM_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pekwm_targetinstall: $(STATEDIR)/pekwm.targetinstall

pekwm_targetinstall_deps = $(STATEDIR)/pekwm.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/pekwm.targetinstall: $(pekwm_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PEKWM_PATH) $(MAKE) -C $(PEKWM_DIR) DESTDIR=$(PEKWM_IPKG_TMP) install
	$(CROSSSTRIP) $(PEKWM_IPKG_TMP)/usr/bin/pekwm
	mkdir -p $(PEKWM_IPKG_TMP)/CONTROL
	echo "Package: pekwm" 								 >$(PEKWM_IPKG_TMP)/CONTROL/control
	echo "Source: $(PEKWM_URL)"							>>$(PEKWM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PEKWM_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(PEKWM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PEKWM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PEKWM_IPKG_TMP)/CONTROL/control
	echo "Version: $(PEKWM_VERSION)-$(PEKWM_VENDOR_VERSION)" 			>>$(PEKWM_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree" 								>>$(PEKWM_IPKG_TMP)/CONTROL/control
	echo "Description: Simply flexible window manager"				>>$(PEKWM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PEKWM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PEKWM_INSTALL
ROMPACKAGES += $(STATEDIR)/pekwm.imageinstall
endif

pekwm_imageinstall_deps = $(STATEDIR)/pekwm.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pekwm.imageinstall: $(pekwm_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pekwm
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pekwm_clean:
	rm -rf $(STATEDIR)/pekwm.*
	rm -rf $(PEKWM_DIR)

# vim: syntax=make
