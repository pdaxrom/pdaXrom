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
ifdef PTXCONF_FBPANEL
PACKAGES += fbpanel
endif

#
# Paths and names
#
FBPANEL_VENDOR_VERSION	= 2
FBPANEL_VERSION		= 4.3
FBPANEL			= fbpanel-$(FBPANEL_VERSION)
FBPANEL_SUFFIX		= tgz
FBPANEL_URL		= http://citkit.dl.sourceforge.net/sourceforge/fbpanel/$(FBPANEL).$(FBPANEL_SUFFIX)
FBPANEL_SOURCE		= $(SRCDIR)/$(FBPANEL).$(FBPANEL_SUFFIX)
FBPANEL_DIR		= $(BUILDDIR)/$(FBPANEL)
FBPANEL_IPKG_TMP	= $(FBPANEL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fbpanel_get: $(STATEDIR)/fbpanel.get

fbpanel_get_deps = $(FBPANEL_SOURCE)

$(STATEDIR)/fbpanel.get: $(fbpanel_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FBPANEL))
	touch $@

$(FBPANEL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FBPANEL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fbpanel_extract: $(STATEDIR)/fbpanel.extract

fbpanel_extract_deps = $(STATEDIR)/fbpanel.get

$(STATEDIR)/fbpanel.extract: $(fbpanel_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FBPANEL_DIR))
	@$(call extract, $(FBPANEL_SOURCE))
	@$(call patchin, $(FBPANEL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fbpanel_prepare: $(STATEDIR)/fbpanel.prepare

#
# dependencies
#
fbpanel_prepare_deps = \
	$(STATEDIR)/fbpanel.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/virtual-xchain.install

FBPANEL_PATH	=  PATH=$(CROSS_PATH)
FBPANEL_ENV 	=  $(CROSS_ENV)
#FBPANEL_ENV	+=
FBPANEL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FBPANEL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
FBPANEL_AUTOCONF = \
	--prefix=/usr \
	--cpu=on

#	--build=$(GNU_HOST)
#	--host=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/fbpanel.prepare: $(fbpanel_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FBPANEL_DIR)/config.cache)
	cd $(FBPANEL_DIR) && \
		$(FBPANEL_PATH) $(FBPANEL_ENV) \
		./configure $(FBPANEL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fbpanel_compile: $(STATEDIR)/fbpanel.compile

fbpanel_compile_deps = $(STATEDIR)/fbpanel.prepare

$(STATEDIR)/fbpanel.compile: $(fbpanel_compile_deps)
	@$(call targetinfo, $@)
	$(FBPANEL_PATH) $(FBPANEL_ENV) $(MAKE) -C $(FBPANEL_DIR) $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fbpanel_install: $(STATEDIR)/fbpanel.install

$(STATEDIR)/fbpanel.install: $(STATEDIR)/fbpanel.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fbpanel_targetinstall: $(STATEDIR)/fbpanel.targetinstall

fbpanel_targetinstall_deps = $(STATEDIR)/fbpanel.compile \
	$(STATEDIR)/startup-notification.targetinstall \
	$(STATEDIR)/gtk22.install

$(STATEDIR)/fbpanel.targetinstall: $(fbpanel_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FBPANEL_PATH) $(MAKE) -C $(FBPANEL_DIR) PREFIX=$(FBPANEL_IPKG_TMP)/usr install
	$(CROSSSTRIP) $(FBPANEL_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(FBPANEL_IPKG_TMP)/usr/share/fbpanel/plugins/*.so
	cp -a $(TOPDIR)/config/pdaXrom/fbpanel/default $(FBPANEL_IPKG_TMP)/usr/share/fbpanel/
	cp -a $(TOPDIR)/config/pdaXrom/fbpanel/{fbpanel-setup,fbpanel-session} $(FBPANEL_IPKG_TMP)/usr/bin/
	mkdir -p $(FBPANEL_IPKG_TMP)/usr/share/pixmaps/
	cp -a $(TOPDIR)/config/pdaXrom/fbpanel/kmix.png $(FBPANEL_IPKG_TMP)/usr/share/pixmaps/
	rm -rf $(FBPANEL_IPKG_TMP)/usr/share/man
	mkdir -p $(FBPANEL_IPKG_TMP)/CONTROL
	echo "Package: fbpanel" 							 >$(FBPANEL_IPKG_TMP)/CONTROL/control
	echo "Source: $(FBPANEL_URL)"							>>$(FBPANEL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(FBPANEL_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(FBPANEL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(FBPANEL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(FBPANEL_IPKG_TMP)/CONTROL/control
	echo "Version: $(FBPANEL_VERSION)-$(FBPANEL_VENDOR_VERSION)" 			>>$(FBPANEL_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, startup-notification" 					>>$(FBPANEL_IPKG_TMP)/CONTROL/control
	echo "Description: fbpanel is a lightweight, NETWM compliant desktop panel. It works with any NETWM compliant window manager." >>$(FBPANEL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FBPANEL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FBPANEL_INSTALL
ROMPACKAGES += $(STATEDIR)/fbpanel.imageinstall
endif

fbpanel_imageinstall_deps = $(STATEDIR)/fbpanel.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fbpanel.imageinstall: $(fbpanel_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fbpanel
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fbpanel_clean:
	rm -rf $(STATEDIR)/fbpanel.*
	rm -rf $(FBPANEL_DIR)

# vim: syntax=make
