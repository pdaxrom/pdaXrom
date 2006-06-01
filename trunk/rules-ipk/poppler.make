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
ifdef PTXCONF_POPPLER
PACKAGES += poppler
endif

#
# Paths and names
#
POPPLER_VENDOR_VERSION	= 1
POPPLER_VERSION		= 0.3.1
POPPLER			= poppler-$(POPPLER_VERSION)
POPPLER_SUFFIX		= tar.gz
POPPLER_URL		= http://poppler.freedesktop.org/$(POPPLER).$(POPPLER_SUFFIX)
POPPLER_SOURCE		= $(SRCDIR)/$(POPPLER).$(POPPLER_SUFFIX)
POPPLER_DIR		= $(BUILDDIR)/$(POPPLER)
POPPLER_IPKG_TMP	= $(POPPLER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

poppler_get: $(STATEDIR)/poppler.get

poppler_get_deps = $(POPPLER_SOURCE)

$(STATEDIR)/poppler.get: $(poppler_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(POPPLER))
	touch $@

$(POPPLER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(POPPLER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

poppler_extract: $(STATEDIR)/poppler.extract

poppler_extract_deps = $(STATEDIR)/poppler.get

$(STATEDIR)/poppler.extract: $(poppler_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(POPPLER_DIR))
	@$(call extract, $(POPPLER_SOURCE))
	@$(call patchin, $(POPPLER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

poppler_prepare: $(STATEDIR)/poppler.prepare

#
# dependencies
#
poppler_prepare_deps = \
	$(STATEDIR)/poppler.extract \
	$(STATEDIR)/virtual-xchain.install

POPPLER_PATH	=  PATH=$(CROSS_PATH)
POPPLER_ENV 	=  $(CROSS_ENV)
POPPLER_ENV	+= CFLAGS="-O3 -fomit-frame-pointer"
POPPLER_ENV	+= CXXFLAGS="-O3 -fomit-frame-pointer"
POPPLER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#POPPLER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
POPPLER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-cairo-output \
	--disable-poppler-qt \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
POPPLER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
POPPLER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/poppler.prepare: $(poppler_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(POPPLER_DIR)/config.cache)
	cd $(POPPLER_DIR) && \
		$(POPPLER_PATH) $(POPPLER_ENV) \
		./configure $(POPPLER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

poppler_compile: $(STATEDIR)/poppler.compile

poppler_compile_deps = $(STATEDIR)/poppler.prepare

$(STATEDIR)/poppler.compile: $(poppler_compile_deps)
	@$(call targetinfo, $@)
	$(POPPLER_PATH) $(MAKE) -C $(POPPLER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

poppler_install: $(STATEDIR)/poppler.install

$(STATEDIR)/poppler.install: $(STATEDIR)/poppler.compile
	@$(call targetinfo, $@)
	rm -rf $(POPPLER_IPKG_TMP)
	$(POPPLER_PATH) $(MAKE) -C $(POPPLER_DIR) DESTDIR=$(POPPLER_IPKG_TMP) install
	cp -a $(POPPLER_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(POPPLER_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g"	$(CROSS_LIB_DIR)/lib/libpoppler-glib.la
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g"	$(CROSS_LIB_DIR)/lib/libpoppler.la
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/poppler-glib.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/poppler-splash.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/poppler.pc
	rm -rf $(POPPLER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

poppler_targetinstall: $(STATEDIR)/poppler.targetinstall

poppler_targetinstall_deps = $(STATEDIR)/poppler.compile

$(STATEDIR)/poppler.targetinstall: $(poppler_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(POPPLER_IPKG_TMP)
	$(POPPLER_PATH) $(MAKE) -C $(POPPLER_DIR) DESTDIR=$(POPPLER_IPKG_TMP) install
	rm -rf $(POPPLER_IPKG_TMP)/usr/include
	rm -rf $(POPPLER_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(POPPLER_IPKG_TMP)/usr/lib/pkgconfig
	$(CROSSSTRIP) $(POPPLER_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(POPPLER_IPKG_TMP)/CONTROL
	echo "Package: poppler" 									 >$(POPPLER_IPKG_TMP)/CONTROL/control
	echo "Source: $(POPPLER_URL)"						>>$(POPPLER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(POPPLER_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome" 										>>$(POPPLER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 						>>$(POPPLER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(POPPLER_IPKG_TMP)/CONTROL/control
	echo "Version: $(POPPLER_VERSION)-$(POPPLER_VENDOR_VERSION)" 					>>$(POPPLER_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 										>>$(POPPLER_IPKG_TMP)/CONTROL/control
	echo "Description: Poppler is a PDF rendering library based on the xpdf-3.0 code base."		>>$(POPPLER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(POPPLER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_POPPLER_INSTALL
ROMPACKAGES += $(STATEDIR)/poppler.imageinstall
endif

poppler_imageinstall_deps = $(STATEDIR)/poppler.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/poppler.imageinstall: $(poppler_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install poppler
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

poppler_clean:
	rm -rf $(STATEDIR)/poppler.*
	rm -rf $(POPPLER_DIR)

# vim: syntax=make
