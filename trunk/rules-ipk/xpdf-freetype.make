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
ifdef PTXCONF_XPDF-FREETYPE
PACKAGES += xpdf-freetype
endif

#
# Paths and names
#
XPDF-FREETYPE_VENDOR_VERSION	= 1
XPDF-FREETYPE_VERSION		= 2.1.3
XPDF-FREETYPE			= freetype-$(XPDF-FREETYPE_VERSION)
XPDF-FREETYPE_SUFFIX		= tar.gz
XPDF-FREETYPE_URL		= ftp://ftp.foolabs.com/pub/xpdf/$(XPDF-FREETYPE).$(XPDF-FREETYPE_SUFFIX)
XPDF-FREETYPE_SOURCE		= $(SRCDIR)/$(XPDF-FREETYPE).$(XPDF-FREETYPE_SUFFIX)
XPDF-FREETYPE_DIR		= $(BUILDDIR)/$(XPDF-FREETYPE)
XPDF-FREETYPE_IPKG_TMP		= $(XPDF-FREETYPE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xpdf-freetype_get: $(STATEDIR)/xpdf-freetype.get

xpdf-freetype_get_deps = $(XPDF-FREETYPE_SOURCE)

$(STATEDIR)/xpdf-freetype.get: $(xpdf-freetype_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XPDF-FREETYPE))
	touch $@

$(XPDF-FREETYPE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XPDF-FREETYPE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xpdf-freetype_extract: $(STATEDIR)/xpdf-freetype.extract

xpdf-freetype_extract_deps = $(STATEDIR)/xpdf-freetype.get

$(STATEDIR)/xpdf-freetype.extract: $(xpdf-freetype_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XPDF-FREETYPE_DIR))
	@$(call extract, $(XPDF-FREETYPE_SOURCE))
	@$(call patchin, $(FREETYPE), $(XPDF-FREETYPE_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xpdf-freetype_prepare: $(STATEDIR)/xpdf-freetype.prepare

#
# dependencies
#
xpdf-freetype_prepare_deps = \
	$(STATEDIR)/xpdf-freetype.extract \
	$(STATEDIR)/virtual-xchain.install

XPDF-FREETYPE_PATH	=  PATH=$(CROSS_PATH)
XPDF-FREETYPE_ENV 	=  $(CROSS_ENV)
XPDF-FREETYPE_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
XPDF-FREETYPE_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
XPDF-FREETYPE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XPDF-FREETYPE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XPDF-FREETYPE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-static \
	--disable-shared

ifdef PTXCONF_XFREE430
XPDF-FREETYPE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XPDF-FREETYPE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xpdf-freetype.prepare: $(xpdf-freetype_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XPDF-FREETYPE_DIR)/config.cache)
	cd $(XPDF-FREETYPE_DIR) && \
		$(XPDF-FREETYPE_PATH) $(XPDF-FREETYPE_ENV) \
		./configure $(XPDF-FREETYPE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xpdf-freetype_compile: $(STATEDIR)/xpdf-freetype.compile

xpdf-freetype_compile_deps = $(STATEDIR)/xpdf-freetype.prepare

$(STATEDIR)/xpdf-freetype.compile: $(xpdf-freetype_compile_deps)
	@$(call targetinfo, $@)
	$(XPDF-FREETYPE_PATH) $(MAKE) -C $(XPDF-FREETYPE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xpdf-freetype_install: $(STATEDIR)/xpdf-freetype.install

$(STATEDIR)/xpdf-freetype.install: $(STATEDIR)/xpdf-freetype.compile
	@$(call targetinfo, $@)
	$(XPDF-FREETYPE_PATH) $(MAKE) -C $(XPDF-FREETYPE_DIR) DESTDIR=$(XPDF-FREETYPE_IPKG_TMP) install
	perl -i -p -e "s,/usr,$(XPDF-FREETYPE_IPKG_TMP)/usr,g" $(XPDF-FREETYPE_IPKG_TMP)/usr/bin/freetype-config
	perl -i -p -e "s,/usr/lib,$(XPDF-FREETYPE_IPKG_TMP)/usr/lib,g" $(XPDF-FREETYPE_IPKG_TMP)/usr/lib/libfreetype.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xpdf-freetype_targetinstall: $(STATEDIR)/xpdf-freetype.targetinstall

xpdf-freetype_targetinstall_deps = $(STATEDIR)/xpdf-freetype.compile

$(STATEDIR)/xpdf-freetype.targetinstall: $(xpdf-freetype_targetinstall_deps)
	@$(call targetinfo, $@)
	asasd
	$(XPDF-FREETYPE_PATH) $(MAKE) -C $(XPDF-FREETYPE_DIR) DESTDIR=$(XPDF-FREETYPE_IPKG_TMP) install
	mkdir -p $(XPDF-FREETYPE_IPKG_TMP)/CONTROL
	echo "Package: xpdf-freetype" 							 >$(XPDF-FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Source: $(XPDF-FREETYPE_URL)"						>>$(XPDF-FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XPDF-FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XPDF-FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(XPDF-FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XPDF-FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Version: $(XPDF-FREETYPE_VERSION)-$(XPDF-FREETYPE_VENDOR_VERSION)" 			>>$(XPDF-FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(XPDF-FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XPDF-FREETYPE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XPDF-FREETYPE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XPDF-FREETYPE_INSTALL
ROMPACKAGES += $(STATEDIR)/xpdf-freetype.imageinstall
endif

xpdf-freetype_imageinstall_deps = $(STATEDIR)/xpdf-freetype.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xpdf-freetype.imageinstall: $(xpdf-freetype_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xpdf-freetype
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xpdf-freetype_clean:
	rm -rf $(STATEDIR)/xpdf-freetype.*
	rm -rf $(XPDF-FREETYPE_DIR)

# vim: syntax=make
