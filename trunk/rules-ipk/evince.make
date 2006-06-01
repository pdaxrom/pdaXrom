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
ifdef PTXCONF_EVINCE
PACKAGES += evince
endif

#
# Paths and names
#
EVINCE_VENDOR_VERSION	= 1
EVINCE_VERSION		= 0.2.1
EVINCE			= evince-$(EVINCE_VERSION)
EVINCE_SUFFIX		= tar.bz2
EVINCE_URL		= http://ftp.gnome.org/pub/GNOME/sources/evince/0.2/$(EVINCE).$(EVINCE_SUFFIX)
EVINCE_SOURCE		= $(SRCDIR)/$(EVINCE).$(EVINCE_SUFFIX)
EVINCE_DIR		= $(BUILDDIR)/$(EVINCE)
EVINCE_IPKG_TMP		= $(EVINCE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

evince_get: $(STATEDIR)/evince.get

evince_get_deps = $(EVINCE_SOURCE)

$(STATEDIR)/evince.get: $(evince_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(EVINCE))
	touch $@

$(EVINCE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(EVINCE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

evince_extract: $(STATEDIR)/evince.extract

evince_extract_deps = $(STATEDIR)/evince.get

$(STATEDIR)/evince.extract: $(evince_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EVINCE_DIR))
	@$(call extract, $(EVINCE_SOURCE))
	@$(call patchin, $(EVINCE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

evince_prepare: $(STATEDIR)/evince.prepare

#
# dependencies
#
evince_prepare_deps = \
	$(STATEDIR)/evince.extract \
	$(STATEDIR)/poppler.install \
	$(STATEDIR)/virtual-xchain.install

EVINCE_PATH	=  PATH=$(CROSS_PATH)
EVINCE_ENV 	=  $(CROSS_ENV)
EVINCE_ENV	+= CFLAGS="-O3 -fomit-frame-pointer"
EVINCE_ENV	+= CXXFLAGS="-O3 -fomit-frame-pointer"
EVINCE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#EVINCE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
EVINCE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
EVINCE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
EVINCE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/evince.prepare: $(evince_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EVINCE_DIR)/config.cache)
	cd $(EVINCE_DIR) && \
		$(EVINCE_PATH) $(EVINCE_ENV) \
		./configure $(EVINCE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

evince_compile: $(STATEDIR)/evince.compile

evince_compile_deps = $(STATEDIR)/evince.prepare

$(STATEDIR)/evince.compile: $(evince_compile_deps)
	@$(call targetinfo, $@)
	$(EVINCE_PATH) $(MAKE) -C $(EVINCE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

evince_install: $(STATEDIR)/evince.install

$(STATEDIR)/evince.install: $(STATEDIR)/evince.compile
	@$(call targetinfo, $@)
	$(EVINCE_PATH) $(MAKE) -C $(EVINCE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

evince_targetinstall: $(STATEDIR)/evince.targetinstall

evince_targetinstall_deps = $(STATEDIR)/evince.compile \
	$(STATEDIR)/poppler.targetinstall

$(STATEDIR)/evince.targetinstall: $(evince_targetinstall_deps)
	@$(call targetinfo, $@)
	$(EVINCE_PATH) $(MAKE) -C $(EVINCE_DIR) DESTDIR=$(EVINCE_IPKG_TMP) install
	mkdir -p $(EVINCE_IPKG_TMP)/CONTROL
	echo "Package: evince" 											 >$(EVINCE_IPKG_TMP)/CONTROL/control
	echo "Source: $(EVINCE_URL)"										>>$(EVINCE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(EVINCE_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 											>>$(EVINCE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(EVINCE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(EVINCE_IPKG_TMP)/CONTROL/control
	echo "Version: $(EVINCE_VERSION)-$(EVINCE_VENDOR_VERSION)" 						>>$(EVINCE_IPKG_TMP)/CONTROL/control
	echo "Depends: poppler" 										>>$(EVINCE_IPKG_TMP)/CONTROL/control
	echo "Description: Evince is a document viewer for multiple document formats like pdf, postscript, and many others."	>>$(EVINCE_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(EVINCE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_EVINCE_INSTALL
ROMPACKAGES += $(STATEDIR)/evince.imageinstall
endif

evince_imageinstall_deps = $(STATEDIR)/evince.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/evince.imageinstall: $(evince_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install evince
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

evince_clean:
	rm -rf $(STATEDIR)/evince.*
	rm -rf $(EVINCE_DIR)

# vim: syntax=make
