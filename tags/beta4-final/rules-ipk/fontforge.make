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
ifdef PTXCONF_FONTFORGE
PACKAGES += fontforge
endif

#
# Paths and names
#
FONTFORGE_VENDOR_VERSION	= 1
FONTFORGE_VERSION		= 20060703
FONTFORGE			= fontforge_full-$(FONTFORGE_VERSION)
FONTFORGE_SUFFIX		= tar.bz2
FONTFORGE_URL			= http://superb-west.dl.sourceforge.net/sourceforge/fontforge/$(FONTFORGE).$(FONTFORGE_SUFFIX)
FONTFORGE_SOURCE		= $(SRCDIR)/$(FONTFORGE).$(FONTFORGE_SUFFIX)
FONTFORGE_DIR			= $(BUILDDIR)/fontforge-$(FONTFORGE_VERSION)
FONTFORGE_IPKG_TMP		= $(FONTFORGE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fontforge_get: $(STATEDIR)/fontforge.get

fontforge_get_deps = $(FONTFORGE_SOURCE)

$(STATEDIR)/fontforge.get: $(fontforge_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FONTFORGE))
	touch $@

$(FONTFORGE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FONTFORGE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fontforge_extract: $(STATEDIR)/fontforge.extract

fontforge_extract_deps = $(STATEDIR)/fontforge.get

$(STATEDIR)/fontforge.extract: $(fontforge_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(FONTFORGE_DIR))
	@$(call extract, $(FONTFORGE_SOURCE))
	@$(call patchin, $(FONTFORGE), $(FONTFORGE_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fontforge_prepare: $(STATEDIR)/fontforge.prepare

#
# dependencies
#
fontforge_prepare_deps = \
	$(STATEDIR)/fontforge.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

FONTFORGE_PATH	=  PATH=$(CROSS_PATH)
FONTFORGE_ENV 	=  $(CROSS_ENV)
#FONTFORGE_ENV	+=
FONTFORGE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FONTFORGE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
FONTFORGE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-freetype-bytecode \
	--with-freetype-src=$(FREETYPE_DIR)

ifdef PTXCONF_XFREE430
FONTFORGE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FONTFORGE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fontforge.prepare: $(fontforge_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FONTFORGE_DIR)/config.cache)
	cd $(FONTFORGE_DIR) && \
		$(FONTFORGE_PATH) $(FONTFORGE_ENV) \
		./configure $(FONTFORGE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fontforge_compile: $(STATEDIR)/fontforge.compile

fontforge_compile_deps = $(STATEDIR)/fontforge.prepare

$(STATEDIR)/fontforge.compile: $(fontforge_compile_deps)
	@$(call targetinfo, $@)
	$(FONTFORGE_PATH) $(MAKE) -C $(FONTFORGE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fontforge_install: $(STATEDIR)/fontforge.install

$(STATEDIR)/fontforge.install: $(STATEDIR)/fontforge.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fontforge_targetinstall: $(STATEDIR)/fontforge.targetinstall

fontforge_targetinstall_deps = $(STATEDIR)/fontforge.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/fontforge.targetinstall: $(fontforge_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FONTFORGE_PATH) $(MAKE) -C $(FONTFORGE_DIR) prefix=$(FONTFORGE_IPKG_TMP)/usr install
	rm -rf $(FONTFORGE_IPKG_TMP)/usr/man
	rm -rf $(FONTFORGE_IPKG_TMP)/usr/lib/pkgconfig
	rm  -f $(FONTFORGE_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(FONTFORGE_IPKG_TMP)/usr/share/locale
	$(CROSSSTRIP) $(FONTFORGE_IPKG_TMP)/usr/bin/fontforge
	$(CROSSSTRIP) $(FONTFORGE_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(FONTFORGE_IPKG_TMP)/CONTROL
	echo "Package: fontforge" 							 >$(FONTFORGE_IPKG_TMP)/CONTROL/control
	echo "Source: $(FONTFORGE_URL)"							>>$(FONTFORGE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(FONTFORGE_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 							>>$(FONTFORGE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(FONTFORGE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(FONTFORGE_IPKG_TMP)/CONTROL/control
	echo "Version: $(FONTFORGE_VERSION)-$(FONTFORGE_VENDOR_VERSION)" 		>>$(FONTFORGE_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree" 								>>$(FONTFORGE_IPKG_TMP)/CONTROL/control
	echo "Description: FontForge is an outline font editor that lets you create your own Postscript, TrueType, OpenType, CID-keyed, multi-master, CFF, SVG, and bitmap (BDF) fonts, or edit existing ones." >>$(FONTFORGE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FONTFORGE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FONTFORGE_INSTALL
ROMPACKAGES += $(STATEDIR)/fontforge.imageinstall
endif

fontforge_imageinstall_deps = $(STATEDIR)/fontforge.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fontforge.imageinstall: $(fontforge_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fontforge
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fontforge_clean:
	rm -rf $(STATEDIR)/fontforge.*
	rm -rf $(FONTFORGE_DIR)

# vim: syntax=make
