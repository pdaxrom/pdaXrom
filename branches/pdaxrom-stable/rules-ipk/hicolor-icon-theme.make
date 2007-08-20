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
ifdef PTXCONF_HICOLOR-ICON-THEME
PACKAGES += hicolor-icon-theme
endif

#
# Paths and names
#
HICOLOR-ICON-THEME_VENDOR_VERSION	= 1
HICOLOR-ICON-THEME_VERSION		= 0.9
HICOLOR-ICON-THEME			= hicolor-icon-theme-$(HICOLOR-ICON-THEME_VERSION)
HICOLOR-ICON-THEME_SUFFIX		= tar.gz
HICOLOR-ICON-THEME_URL			= http://icon-theme.freedesktop.org/releases/$(HICOLOR-ICON-THEME).$(HICOLOR-ICON-THEME_SUFFIX)
HICOLOR-ICON-THEME_SOURCE		= $(SRCDIR)/$(HICOLOR-ICON-THEME).$(HICOLOR-ICON-THEME_SUFFIX)
HICOLOR-ICON-THEME_DIR			= $(BUILDDIR)/$(HICOLOR-ICON-THEME)
HICOLOR-ICON-THEME_IPKG_TMP		= $(HICOLOR-ICON-THEME_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

hicolor-icon-theme_get: $(STATEDIR)/hicolor-icon-theme.get

hicolor-icon-theme_get_deps = $(HICOLOR-ICON-THEME_SOURCE)

$(STATEDIR)/hicolor-icon-theme.get: $(hicolor-icon-theme_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(HICOLOR-ICON-THEME))
	touch $@

$(HICOLOR-ICON-THEME_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(HICOLOR-ICON-THEME_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

hicolor-icon-theme_extract: $(STATEDIR)/hicolor-icon-theme.extract

hicolor-icon-theme_extract_deps = $(STATEDIR)/hicolor-icon-theme.get

$(STATEDIR)/hicolor-icon-theme.extract: $(hicolor-icon-theme_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HICOLOR-ICON-THEME_DIR))
	@$(call extract, $(HICOLOR-ICON-THEME_SOURCE))
	@$(call patchin, $(HICOLOR-ICON-THEME))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

hicolor-icon-theme_prepare: $(STATEDIR)/hicolor-icon-theme.prepare

#
# dependencies
#
hicolor-icon-theme_prepare_deps = \
	$(STATEDIR)/hicolor-icon-theme.extract \
	$(STATEDIR)/virtual-xchain.install

HICOLOR-ICON-THEME_PATH	=  PATH=$(CROSS_PATH)
HICOLOR-ICON-THEME_ENV 	=  $(CROSS_ENV)
#HICOLOR-ICON-THEME_ENV	+=
HICOLOR-ICON-THEME_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#HICOLOR-ICON-THEME_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
HICOLOR-ICON-THEME_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
HICOLOR-ICON-THEME_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
HICOLOR-ICON-THEME_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/hicolor-icon-theme.prepare: $(hicolor-icon-theme_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HICOLOR-ICON-THEME_DIR)/config.cache)
	cd $(HICOLOR-ICON-THEME_DIR) && \
		$(HICOLOR-ICON-THEME_PATH) $(HICOLOR-ICON-THEME_ENV) \
		./configure $(HICOLOR-ICON-THEME_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

hicolor-icon-theme_compile: $(STATEDIR)/hicolor-icon-theme.compile

hicolor-icon-theme_compile_deps = $(STATEDIR)/hicolor-icon-theme.prepare

$(STATEDIR)/hicolor-icon-theme.compile: $(hicolor-icon-theme_compile_deps)
	@$(call targetinfo, $@)
	$(HICOLOR-ICON-THEME_PATH) $(MAKE) -C $(HICOLOR-ICON-THEME_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

hicolor-icon-theme_install: $(STATEDIR)/hicolor-icon-theme.install

$(STATEDIR)/hicolor-icon-theme.install: $(STATEDIR)/hicolor-icon-theme.compile
	@$(call targetinfo, $@)
	rm -rf $(HICOLOR-ICON-THEME_IPKG_TMP)
	$(HICOLOR-ICON-THEME_PATH) $(MAKE) -C $(HICOLOR-ICON-THEME_DIR) DESTDIR=$(HICOLOR-ICON-THEME_IPKG_TMP) install
	@$(call copyincludes, $(HICOLOR-ICON-THEME_IPKG_TMP))
	@$(call copylibraries,$(HICOLOR-ICON-THEME_IPKG_TMP))
	@$(call copymiscfiles,$(HICOLOR-ICON-THEME_IPKG_TMP))
	rm -rf $(HICOLOR-ICON-THEME_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

hicolor-icon-theme_targetinstall: $(STATEDIR)/hicolor-icon-theme.targetinstall

hicolor-icon-theme_targetinstall_deps = $(STATEDIR)/hicolor-icon-theme.compile

$(STATEDIR)/hicolor-icon-theme.targetinstall: $(hicolor-icon-theme_targetinstall_deps)
	@$(call targetinfo, $@)
	$(HICOLOR-ICON-THEME_PATH) $(MAKE) -C $(HICOLOR-ICON-THEME_DIR) DESTDIR=$(HICOLOR-ICON-THEME_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(HICOLOR-ICON-THEME_VERSION)-$(HICOLOR-ICON-THEME_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh hicolor-icon-theme $(HICOLOR-ICON-THEME_IPKG_TMP)

	@$(call removedevfiles, $(HICOLOR-ICON-THEME_IPKG_TMP))
	@$(call stripfiles, $(HICOLOR-ICON-THEME_IPKG_TMP))
	mkdir -p $(HICOLOR-ICON-THEME_IPKG_TMP)/CONTROL
	echo "Package: hicolor-icon-theme" 						 >$(HICOLOR-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Source: $(HICOLOR-ICON-THEME_URL)"					>>$(HICOLOR-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(HICOLOR-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(HICOLOR-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(HICOLOR-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(HICOLOR-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Version: $(HICOLOR-ICON-THEME_VERSION)-$(HICOLOR-ICON-THEME_VENDOR_VERSION)" >>$(HICOLOR-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(HICOLOR-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Description: This is the default fallback theme used by implementations of the icon theme specification."	>>$(HICOLOR-ICON-THEME_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(HICOLOR-ICON-THEME_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_HICOLOR-ICON-THEME_INSTALL
ROMPACKAGES += $(STATEDIR)/hicolor-icon-theme.imageinstall
endif

hicolor-icon-theme_imageinstall_deps = $(STATEDIR)/hicolor-icon-theme.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/hicolor-icon-theme.imageinstall: $(hicolor-icon-theme_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install hicolor-icon-theme
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

hicolor-icon-theme_clean:
	rm -rf $(STATEDIR)/hicolor-icon-theme.*
	rm -rf $(HICOLOR-ICON-THEME_DIR)

# vim: syntax=make
