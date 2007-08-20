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
ifdef PTXCONF_XFWM4-THEMES
PACKAGES += xfwm4-themes
endif

#
# Paths and names
#
XFWM4-THEMES_VENDOR_VERSION	= 1
XFWM4-THEMES_VERSION	= 4.4.0
XFWM4-THEMES		= xfwm4-themes-$(XFWM4-THEMES_VERSION)
XFWM4-THEMES_SUFFIX		= tar.bz2
XFWM4-THEMES_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFWM4-THEMES).$(XFWM4-THEMES_SUFFIX)
XFWM4-THEMES_SOURCE		= $(SRCDIR)/$(XFWM4-THEMES).$(XFWM4-THEMES_SUFFIX)
XFWM4-THEMES_DIR		= $(BUILDDIR)/$(XFWM4-THEMES)
XFWM4-THEMES_IPKG_TMP	= $(XFWM4-THEMES_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfwm4-themes_get: $(STATEDIR)/xfwm4-themes.get

xfwm4-themes_get_deps = $(XFWM4-THEMES_SOURCE)

$(STATEDIR)/xfwm4-themes.get: $(xfwm4-themes_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFWM4-THEMES))
	touch $@

$(XFWM4-THEMES_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFWM4-THEMES_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfwm4-themes_extract: $(STATEDIR)/xfwm4-themes.extract

xfwm4-themes_extract_deps = $(STATEDIR)/xfwm4-themes.get

$(STATEDIR)/xfwm4-themes.extract: $(xfwm4-themes_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFWM4-THEMES_DIR))
	@$(call extract, $(XFWM4-THEMES_SOURCE))
	@$(call patchin, $(XFWM4-THEMES))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfwm4-themes_prepare: $(STATEDIR)/xfwm4-themes.prepare

#
# dependencies
#
xfwm4-themes_prepare_deps = \
	$(STATEDIR)/xfwm4-themes.extract \
	$(STATEDIR)/virtual-xchain.install

XFWM4-THEMES_PATH	=  PATH=$(CROSS_PATH)
XFWM4-THEMES_ENV 	=  $(CROSS_ENV)
#XFWM4-THEMES_ENV	+=
XFWM4-THEMES_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFWM4-THEMES_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFWM4-THEMES_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFWM4-THEMES_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFWM4-THEMES_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfwm4-themes.prepare: $(xfwm4-themes_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFWM4-THEMES_DIR)/config.cache)
	cd $(XFWM4-THEMES_DIR) && \
		$(XFWM4-THEMES_PATH) $(XFWM4-THEMES_ENV) \
		./configure $(XFWM4-THEMES_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfwm4-themes_compile: $(STATEDIR)/xfwm4-themes.compile

xfwm4-themes_compile_deps = $(STATEDIR)/xfwm4-themes.prepare

$(STATEDIR)/xfwm4-themes.compile: $(xfwm4-themes_compile_deps)
	@$(call targetinfo, $@)
	$(XFWM4-THEMES_PATH) $(MAKE) -C $(XFWM4-THEMES_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfwm4-themes_install: $(STATEDIR)/xfwm4-themes.install

$(STATEDIR)/xfwm4-themes.install: $(STATEDIR)/xfwm4-themes.compile
	@$(call targetinfo, $@)
	rm -rf $(XFWM4-THEMES_IPKG_TMP)
	$(XFWM4-THEMES_PATH) $(MAKE) -C $(XFWM4-THEMES_DIR) DESTDIR=$(XFWM4-THEMES_IPKG_TMP) install
	@$(call copyincludes, $(XFWM4-THEMES_IPKG_TMP))
	@$(call copylibraries,$(XFWM4-THEMES_IPKG_TMP))
	@$(call copymiscfiles,$(XFWM4-THEMES_IPKG_TMP))
	rm -rf $(XFWM4-THEMES_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfwm4-themes_targetinstall: $(STATEDIR)/xfwm4-themes.targetinstall

xfwm4-themes_targetinstall_deps = $(STATEDIR)/xfwm4-themes.compile

XFWM4-THEMES_DEPLIST = 

$(STATEDIR)/xfwm4-themes.targetinstall: $(xfwm4-themes_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFWM4-THEMES_PATH) $(MAKE) -C $(XFWM4-THEMES_DIR) DESTDIR=$(XFWM4-THEMES_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFWM4-THEMES_VERSION)-$(XFWM4-THEMES_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfwm4-themes $(XFWM4-THEMES_IPKG_TMP)

	@$(call removedevfiles, $(XFWM4-THEMES_IPKG_TMP))
	@$(call stripfiles, $(XFWM4-THEMES_IPKG_TMP))
	mkdir -p $(XFWM4-THEMES_IPKG_TMP)/CONTROL
	echo "Package: xfwm4-themes" 							 >$(XFWM4-THEMES_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFWM4-THEMES_URL)"							>>$(XFWM4-THEMES_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFWM4-THEMES_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFWM4-THEMES_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFWM4-THEMES_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFWM4-THEMES_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFWM4-THEMES_VERSION)-$(XFWM4-THEMES_VENDOR_VERSION)" 			>>$(XFWM4-THEMES_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFWM4-THEMES_DEPLIST)" 						>>$(XFWM4-THEMES_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFWM4-THEMES_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFWM4-THEMES_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFWM4-THEMES_INSTALL
ROMPACKAGES += $(STATEDIR)/xfwm4-themes.imageinstall
endif

xfwm4-themes_imageinstall_deps = $(STATEDIR)/xfwm4-themes.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfwm4-themes.imageinstall: $(xfwm4-themes_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfwm4-themes
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfwm4-themes_clean:
	rm -rf $(STATEDIR)/xfwm4-themes.*
	rm -rf $(XFWM4-THEMES_DIR)

# vim: syntax=make
