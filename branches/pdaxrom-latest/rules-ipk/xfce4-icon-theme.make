# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Adrian Crutchfield
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_XFCE4-ICON-THEME
PACKAGES += xfce4-icon-theme
endif

#
# Paths and names
#
XFCE4-ICON-THEME_VENDOR_VERSION	= 1
XFCE4-ICON-THEME_VERSION	= 4.4.0
XFCE4-ICON-THEME		= xfce4-icon-theme-$(XFCE4-ICON-THEME_VERSION)
XFCE4-ICON-THEME_SUFFIX		= tar.bz2
XFCE4-ICON-THEME_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFCE4-ICON-THEME).$(XFCE4-ICON-THEME_SUFFIX)
XFCE4-ICON-THEME_SOURCE		= $(SRCDIR)/$(XFCE4-ICON-THEME).$(XFCE4-ICON-THEME_SUFFIX)
XFCE4-ICON-THEME_DIR		= $(BUILDDIR)/$(XFCE4-ICON-THEME)
XFCE4-ICON-THEME_IPKG_TMP	= $(XFCE4-ICON-THEME_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfce4-icon-theme_get: $(STATEDIR)/xfce4-icon-theme.get

xfce4-icon-theme_get_deps = $(XFCE4-ICON-THEME_SOURCE)

$(STATEDIR)/xfce4-icon-theme.get: $(xfce4-icon-theme_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFCE4-ICON-THEME))
	touch $@

$(XFCE4-ICON-THEME_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFCE4-ICON-THEME_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfce4-icon-theme_extract: $(STATEDIR)/xfce4-icon-theme.extract

xfce4-icon-theme_extract_deps = $(STATEDIR)/xfce4-icon-theme.get

$(STATEDIR)/xfce4-icon-theme.extract: $(xfce4-icon-theme_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-ICON-THEME_DIR))
	@$(call extract, $(XFCE4-ICON-THEME_SOURCE))
	@$(call patchin, $(XFCE4-ICON-THEME))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfce4-icon-theme_prepare: $(STATEDIR)/xfce4-icon-theme.prepare

#
# dependencies
#
xfce4-icon-theme_prepare_deps = \
	$(STATEDIR)/xfce4-icon-theme.extract \
	$(STATEDIR)/virtual-xchain.install

XFCE4-ICON-THEME_PATH	=  PATH=$(CROSS_PATH)
XFCE4-ICON-THEME_ENV 	=  $(CROSS_ENV)
#XFCE4-ICON-THEME_ENV	+=
XFCE4-ICON-THEME_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFCE4-ICON-THEME_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFCE4-ICON-THEME_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFCE4-ICON-THEME_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFCE4-ICON-THEME_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfce4-icon-theme.prepare: $(xfce4-icon-theme_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-ICON-THEME_DIR)/config.cache)
	cd $(XFCE4-ICON-THEME_DIR) && \
		$(XFCE4-ICON-THEME_PATH) $(XFCE4-ICON-THEME_ENV) \
		./configure $(XFCE4-ICON-THEME_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfce4-icon-theme_compile: $(STATEDIR)/xfce4-icon-theme.compile

xfce4-icon-theme_compile_deps = $(STATEDIR)/xfce4-icon-theme.prepare

$(STATEDIR)/xfce4-icon-theme.compile: $(xfce4-icon-theme_compile_deps)
	@$(call targetinfo, $@)
	$(XFCE4-ICON-THEME_PATH) $(MAKE) -C $(XFCE4-ICON-THEME_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfce4-icon-theme_install: $(STATEDIR)/xfce4-icon-theme.install

$(STATEDIR)/xfce4-icon-theme.install: $(STATEDIR)/xfce4-icon-theme.compile
	@$(call targetinfo, $@)
	rm -rf $(XFCE4-ICON-THEME_IPKG_TMP)
	$(XFCE4-ICON-THEME_PATH) $(MAKE) -C $(XFCE4-ICON-THEME_DIR) DESTDIR=$(XFCE4-ICON-THEME_IPKG_TMP) install
	@$(call copyincludes, $(XFCE4-ICON-THEME_IPKG_TMP))
	@$(call copylibraries,$(XFCE4-ICON-THEME_IPKG_TMP))
	@$(call copymiscfiles,$(XFCE4-ICON-THEME_IPKG_TMP))
	rm -rf $(XFCE4-ICON-THEME_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfce4-icon-theme_targetinstall: $(STATEDIR)/xfce4-icon-theme.targetinstall

xfce4-icon-theme_targetinstall_deps = $(STATEDIR)/xfce4-icon-theme.compile

XFCE4-ICON-THEME_DEPLIST = 

$(STATEDIR)/xfce4-icon-theme.targetinstall: $(xfce4-icon-theme_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFCE4-ICON-THEME_PATH) $(MAKE) -C $(XFCE4-ICON-THEME_DIR) DESTDIR=$(XFCE4-ICON-THEME_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFCE4-ICON-THEME_VERSION)-$(XFCE4-ICON-THEME_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfce4-icon-theme $(XFCE4-ICON-THEME_IPKG_TMP)

	@$(call removedevfiles, $(XFCE4-ICON-THEME_IPKG_TMP))
	@$(call stripfiles, $(XFCE4-ICON-THEME_IPKG_TMP))
	mkdir -p $(XFCE4-ICON-THEME_IPKG_TMP)/CONTROL
	echo "Package: xfce4-icon-theme" 							 >$(XFCE4-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFCE4-ICON-THEME_URL)"							>>$(XFCE4-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFCE4-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFCE4-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFCE4-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFCE4-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFCE4-ICON-THEME_VERSION)-$(XFCE4-ICON-THEME_VENDOR_VERSION)" 			>>$(XFCE4-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFCE4-ICON-THEME_DEPLIST)" 						>>$(XFCE4-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFCE4-ICON-THEME_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFCE4-ICON-THEME_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFCE4-ICON-THEME_INSTALL
ROMPACKAGES += $(STATEDIR)/xfce4-icon-theme.imageinstall
endif

xfce4-icon-theme_imageinstall_deps = $(STATEDIR)/xfce4-icon-theme.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfce4-icon-theme.imageinstall: $(xfce4-icon-theme_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfce4-icon-theme
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfce4-icon-theme_clean:
	rm -rf $(STATEDIR)/xfce4-icon-theme.*
	rm -rf $(XFCE4-ICON-THEME_DIR)

# vim: syntax=make
