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
ifdef PTXCONF_XFCE4-PANEL
PACKAGES += xfce4-panel
endif

#
# Paths and names
#
XFCE4-PANEL_VENDOR_VERSION	= 1
XFCE4-PANEL_VERSION	= 4.4.0
XFCE4-PANEL		= xfce4-panel-$(XFCE4-PANEL_VERSION)
XFCE4-PANEL_SUFFIX		= tar.bz2
XFCE4-PANEL_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFCE4-PANEL).$(XFCE4-PANEL_SUFFIX)
XFCE4-PANEL_SOURCE		= $(SRCDIR)/$(XFCE4-PANEL).$(XFCE4-PANEL_SUFFIX)
XFCE4-PANEL_DIR		= $(BUILDDIR)/$(XFCE4-PANEL)
XFCE4-PANEL_IPKG_TMP	= $(XFCE4-PANEL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfce4-panel_get: $(STATEDIR)/xfce4-panel.get

xfce4-panel_get_deps = $(XFCE4-PANEL_SOURCE)

$(STATEDIR)/xfce4-panel.get: $(xfce4-panel_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFCE4-PANEL))
	touch $@

$(XFCE4-PANEL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFCE4-PANEL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfce4-panel_extract: $(STATEDIR)/xfce4-panel.extract

xfce4-panel_extract_deps = $(STATEDIR)/xfce4-panel.get

$(STATEDIR)/xfce4-panel.extract: $(xfce4-panel_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-PANEL_DIR))
	@$(call extract, $(XFCE4-PANEL_SOURCE))
	@$(call patchin, $(XFCE4-PANEL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfce4-panel_prepare: $(STATEDIR)/xfce4-panel.prepare

#
# dependencies
#
xfce4-panel_prepare_deps = \
	$(STATEDIR)/xfce4-panel.extract \
	$(STATEDIR)/virtual-xchain.install

XFCE4-PANEL_PATH	=  PATH=$(CROSS_PATH)
XFCE4-PANEL_ENV 	=  $(CROSS_ENV)
#XFCE4-PANEL_ENV	+=
XFCE4-PANEL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFCE4-PANEL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFCE4-PANEL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFCE4-PANEL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFCE4-PANEL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfce4-panel.prepare: $(xfce4-panel_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-PANEL_DIR)/config.cache)
	cd $(XFCE4-PANEL_DIR) && \
		$(XFCE4-PANEL_PATH) $(XFCE4-PANEL_ENV) \
		./configure $(XFCE4-PANEL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfce4-panel_compile: $(STATEDIR)/xfce4-panel.compile

xfce4-panel_compile_deps = $(STATEDIR)/xfce4-panel.prepare

$(STATEDIR)/xfce4-panel.compile: $(xfce4-panel_compile_deps)
	@$(call targetinfo, $@)
	$(XFCE4-PANEL_PATH) $(MAKE) -C $(XFCE4-PANEL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfce4-panel_install: $(STATEDIR)/xfce4-panel.install

$(STATEDIR)/xfce4-panel.install: $(STATEDIR)/xfce4-panel.compile
	@$(call targetinfo, $@)
	rm -rf $(XFCE4-PANEL_IPKG_TMP)
	$(XFCE4-PANEL_PATH) $(MAKE) -C $(XFCE4-PANEL_DIR) DESTDIR=$(XFCE4-PANEL_IPKG_TMP) install
	@$(call copyincludes, $(XFCE4-PANEL_IPKG_TMP))
	@$(call copylibraries,$(XFCE4-PANEL_IPKG_TMP))
	@$(call copymiscfiles,$(XFCE4-PANEL_IPKG_TMP))
	rm -rf $(XFCE4-PANEL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfce4-panel_targetinstall: $(STATEDIR)/xfce4-panel.targetinstall

xfce4-panel_targetinstall_deps = $(STATEDIR)/xfce4-panel.compile

XFCE4-PANEL_DEPLIST = 

$(STATEDIR)/xfce4-panel.targetinstall: $(xfce4-panel_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFCE4-PANEL_PATH) $(MAKE) -C $(XFCE4-PANEL_DIR) DESTDIR=$(XFCE4-PANEL_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFCE4-PANEL_VERSION)-$(XFCE4-PANEL_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfce4-panel $(XFCE4-PANEL_IPKG_TMP)

	@$(call removedevfiles, $(XFCE4-PANEL_IPKG_TMP))
	@$(call stripfiles, $(XFCE4-PANEL_IPKG_TMP))
	mkdir -p $(XFCE4-PANEL_IPKG_TMP)/CONTROL
	echo "Package: xfce4-panel" 							 >$(XFCE4-PANEL_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFCE4-PANEL_URL)"							>>$(XFCE4-PANEL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFCE4-PANEL_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFCE4-PANEL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFCE4-PANEL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFCE4-PANEL_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFCE4-PANEL_VERSION)-$(XFCE4-PANEL_VENDOR_VERSION)" 			>>$(XFCE4-PANEL_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFCE4-PANEL_DEPLIST)" 						>>$(XFCE4-PANEL_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFCE4-PANEL_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFCE4-PANEL_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFCE4-PANEL_INSTALL
ROMPACKAGES += $(STATEDIR)/xfce4-panel.imageinstall
endif

xfce4-panel_imageinstall_deps = $(STATEDIR)/xfce4-panel.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfce4-panel.imageinstall: $(xfce4-panel_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfce4-panel
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfce4-panel_clean:
	rm -rf $(STATEDIR)/xfce4-panel.*
	rm -rf $(XFCE4-PANEL_DIR)

# vim: syntax=make
