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
ifdef PTXCONF_VISUALBOYADVANCE
PACKAGES += VisualBoyAdvance
endif

#
# Paths and names
#
VISUALBOYADVANCE_VENDOR_VERSION	= 1
VISUALBOYADVANCE_VERSION	= 1.7.2
VISUALBOYADVANCE		= VisualBoyAdvance-src-$(VISUALBOYADVANCE_VERSION)
VISUALBOYADVANCE_SUFFIX		= tar.gz
VISUALBOYADVANCE_URL		= http://citkit.dl.sourceforge.net/sourceforge/vba/$(VISUALBOYADVANCE).$(VISUALBOYADVANCE_SUFFIX)
VISUALBOYADVANCE_SOURCE		= $(SRCDIR)/$(VISUALBOYADVANCE).$(VISUALBOYADVANCE_SUFFIX)
VISUALBOYADVANCE_DIR		= $(BUILDDIR)/VisualBoyAdvance-$(VISUALBOYADVANCE_VERSION)
VISUALBOYADVANCE_IPKG_TMP	= $(VISUALBOYADVANCE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

VisualBoyAdvance_get: $(STATEDIR)/VisualBoyAdvance.get

VisualBoyAdvance_get_deps = $(VISUALBOYADVANCE_SOURCE)

$(STATEDIR)/VisualBoyAdvance.get: $(VisualBoyAdvance_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(VISUALBOYADVANCE))
	touch $@

$(VISUALBOYADVANCE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(VISUALBOYADVANCE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

VisualBoyAdvance_extract: $(STATEDIR)/VisualBoyAdvance.extract

VisualBoyAdvance_extract_deps = $(STATEDIR)/VisualBoyAdvance.get

$(STATEDIR)/VisualBoyAdvance.extract: $(VisualBoyAdvance_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VISUALBOYADVANCE_DIR))
	@$(call extract, $(VISUALBOYADVANCE_SOURCE))
	@$(call patchin, $(VISUALBOYADVANCE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

VisualBoyAdvance_prepare: $(STATEDIR)/VisualBoyAdvance.prepare

#
# dependencies
#
VisualBoyAdvance_prepare_deps = \
	$(STATEDIR)/VisualBoyAdvance.extract \
	$(STATEDIR)/virtual-xchain.install

VISUALBOYADVANCE_PATH	=  PATH=$(CROSS_PATH)
VISUALBOYADVANCE_ENV 	=  $(CROSS_ENV)
VISUALBOYADVANCE_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
VISUALBOYADVANCE_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
VISUALBOYADVANCE_ENV	+= LDFLAGS="-lm"
VISUALBOYADVANCE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#VISUALBOYADVANCE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
VISUALBOYADVANCE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-dev \
	--disable-profiling \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
VISUALBOYADVANCE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
VISUALBOYADVANCE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/VisualBoyAdvance.prepare: $(VisualBoyAdvance_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VISUALBOYADVANCE_DIR)/config.cache)
	cd $(VISUALBOYADVANCE_DIR) && \
		$(VISUALBOYADVANCE_PATH) $(VISUALBOYADVANCE_ENV) \
		./configure $(VISUALBOYADVANCE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

VisualBoyAdvance_compile: $(STATEDIR)/VisualBoyAdvance.compile

VisualBoyAdvance_compile_deps = $(STATEDIR)/VisualBoyAdvance.prepare

$(STATEDIR)/VisualBoyAdvance.compile: $(VisualBoyAdvance_compile_deps)
	@$(call targetinfo, $@)
	$(VISUALBOYADVANCE_PATH) $(MAKE) -C $(VISUALBOYADVANCE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

VisualBoyAdvance_install: $(STATEDIR)/VisualBoyAdvance.install

$(STATEDIR)/VisualBoyAdvance.install: $(STATEDIR)/VisualBoyAdvance.compile
	@$(call targetinfo, $@)
	$(VISUALBOYADVANCE_PATH) $(MAKE) -C $(VISUALBOYADVANCE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

VisualBoyAdvance_targetinstall: $(STATEDIR)/VisualBoyAdvance.targetinstall

VisualBoyAdvance_targetinstall_deps = $(STATEDIR)/VisualBoyAdvance.compile

$(STATEDIR)/VisualBoyAdvance.targetinstall: $(VisualBoyAdvance_targetinstall_deps)
	@$(call targetinfo, $@)
	$(VISUALBOYADVANCE_PATH) $(MAKE) -C $(VISUALBOYADVANCE_DIR) DESTDIR=$(VISUALBOYADVANCE_IPKG_TMP) install
	$(CROSSSTRIP) $(VISUALBOYADVANCE_IPKG_TMP)/usr/bin/*
	mkdir -p $(VISUALBOYADVANCE_IPKG_TMP)/CONTROL
	echo "Package: visualboyadvance" 						 >$(VISUALBOYADVANCE_IPKG_TMP)/CONTROL/control
	echo "Source: $(VISUALBOYADVANCE_URL)"						>>$(VISUALBOYADVANCE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(VISUALBOYADVANCE_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(VISUALBOYADVANCE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(VISUALBOYADVANCE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(VISUALBOYADVANCE_IPKG_TMP)/CONTROL/control
	echo "Version: $(VISUALBOYADVANCE_VERSION)-$(VISUALBOYADVANCE_VENDOR_VERSION)" 	>>$(VISUALBOYADVANCE_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl" 								>>$(VISUALBOYADVANCE_IPKG_TMP)/CONTROL/control
	echo "Description: VisualBoyAdvance emulator"					>>$(VISUALBOYADVANCE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(VISUALBOYADVANCE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_VISUALBOYADVANCE_INSTALL
ROMPACKAGES += $(STATEDIR)/VisualBoyAdvance.imageinstall
endif

VisualBoyAdvance_imageinstall_deps = $(STATEDIR)/VisualBoyAdvance.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/VisualBoyAdvance.imageinstall: $(VisualBoyAdvance_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install visualboyadvance
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

VisualBoyAdvance_clean:
	rm -rf $(STATEDIR)/VisualBoyAdvance.*
	rm -rf $(VISUALBOYADVANCE_DIR)

# vim: syntax=make
