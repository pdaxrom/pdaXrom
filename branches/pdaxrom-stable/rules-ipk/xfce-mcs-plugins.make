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
ifdef PTXCONF_XFCE-MCS-PLUGINS
PACKAGES += xfce-mcs-plugins
endif

#
# Paths and names
#
XFCE-MCS-PLUGINS_VENDOR_VERSION	= 1
XFCE-MCS-PLUGINS_VERSION	= 4.4.0
XFCE-MCS-PLUGINS		= xfce-mcs-plugins-$(XFCE-MCS-PLUGINS_VERSION)
XFCE-MCS-PLUGINS_SUFFIX		= tar.bz2
XFCE-MCS-PLUGINS_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFCE-MCS-PLUGINS).$(XFCE-MCS-PLUGINS_SUFFIX)
XFCE-MCS-PLUGINS_SOURCE		= $(SRCDIR)/$(XFCE-MCS-PLUGINS).$(XFCE-MCS-PLUGINS_SUFFIX)
XFCE-MCS-PLUGINS_DIR		= $(BUILDDIR)/$(XFCE-MCS-PLUGINS)
XFCE-MCS-PLUGINS_IPKG_TMP	= $(XFCE-MCS-PLUGINS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfce-mcs-plugins_get: $(STATEDIR)/xfce-mcs-plugins.get

xfce-mcs-plugins_get_deps = $(XFCE-MCS-PLUGINS_SOURCE)

$(STATEDIR)/xfce-mcs-plugins.get: $(xfce-mcs-plugins_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFCE-MCS-PLUGINS))
	touch $@

$(XFCE-MCS-PLUGINS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFCE-MCS-PLUGINS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfce-mcs-plugins_extract: $(STATEDIR)/xfce-mcs-plugins.extract

xfce-mcs-plugins_extract_deps = $(STATEDIR)/xfce-mcs-plugins.get

$(STATEDIR)/xfce-mcs-plugins.extract: $(xfce-mcs-plugins_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE-MCS-PLUGINS_DIR))
	@$(call extract, $(XFCE-MCS-PLUGINS_SOURCE))
	@$(call patchin, $(XFCE-MCS-PLUGINS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfce-mcs-plugins_prepare: $(STATEDIR)/xfce-mcs-plugins.prepare

#
# dependencies
#
xfce-mcs-plugins_prepare_deps = \
	$(STATEDIR)/xfce-mcs-plugins.extract \
	$(STATEDIR)/virtual-xchain.install

XFCE-MCS-PLUGINS_PATH	=  PATH=$(CROSS_PATH)
XFCE-MCS-PLUGINS_ENV 	=  $(CROSS_ENV)
#XFCE-MCS-PLUGINS_ENV	+=
XFCE-MCS-PLUGINS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFCE-MCS-PLUGINS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFCE-MCS-PLUGINS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFCE-MCS-PLUGINS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFCE-MCS-PLUGINS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfce-mcs-plugins.prepare: $(xfce-mcs-plugins_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE-MCS-PLUGINS_DIR)/config.cache)
	cd $(XFCE-MCS-PLUGINS_DIR) && \
		$(XFCE-MCS-PLUGINS_PATH) $(XFCE-MCS-PLUGINS_ENV) \
		./configure $(XFCE-MCS-PLUGINS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfce-mcs-plugins_compile: $(STATEDIR)/xfce-mcs-plugins.compile

xfce-mcs-plugins_compile_deps = $(STATEDIR)/xfce-mcs-plugins.prepare

$(STATEDIR)/xfce-mcs-plugins.compile: $(xfce-mcs-plugins_compile_deps)
	@$(call targetinfo, $@)
	$(XFCE-MCS-PLUGINS_PATH) $(MAKE) -C $(XFCE-MCS-PLUGINS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfce-mcs-plugins_install: $(STATEDIR)/xfce-mcs-plugins.install

$(STATEDIR)/xfce-mcs-plugins.install: $(STATEDIR)/xfce-mcs-plugins.compile
	@$(call targetinfo, $@)
	rm -rf $(XFCE-MCS-PLUGINS_IPKG_TMP)
	$(XFCE-MCS-PLUGINS_PATH) $(MAKE) -C $(XFCE-MCS-PLUGINS_DIR) DESTDIR=$(XFCE-MCS-PLUGINS_IPKG_TMP) install
	@$(call copyincludes, $(XFCE-MCS-PLUGINS_IPKG_TMP))
	@$(call copylibraries,$(XFCE-MCS-PLUGINS_IPKG_TMP))
	@$(call copymiscfiles,$(XFCE-MCS-PLUGINS_IPKG_TMP))
	rm -rf $(XFCE-MCS-PLUGINS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfce-mcs-plugins_targetinstall: $(STATEDIR)/xfce-mcs-plugins.targetinstall

xfce-mcs-plugins_targetinstall_deps = $(STATEDIR)/xfce-mcs-plugins.compile

XFCE-MCS-PLUGINS_DEPLIST = 

$(STATEDIR)/xfce-mcs-plugins.targetinstall: $(xfce-mcs-plugins_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFCE-MCS-PLUGINS_PATH) $(MAKE) -C $(XFCE-MCS-PLUGINS_DIR) DESTDIR=$(XFCE-MCS-PLUGINS_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFCE-MCS-PLUGINS_VERSION)-$(XFCE-MCS-PLUGINS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfce-mcs-plugins $(XFCE-MCS-PLUGINS_IPKG_TMP)

	@$(call removedevfiles, $(XFCE-MCS-PLUGINS_IPKG_TMP))
	@$(call stripfiles, $(XFCE-MCS-PLUGINS_IPKG_TMP))
	mkdir -p $(XFCE-MCS-PLUGINS_IPKG_TMP)/CONTROL
	echo "Package: xfce-mcs-plugins" 							 >$(XFCE-MCS-PLUGINS_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFCE-MCS-PLUGINS_URL)"							>>$(XFCE-MCS-PLUGINS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFCE-MCS-PLUGINS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFCE-MCS-PLUGINS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFCE-MCS-PLUGINS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFCE-MCS-PLUGINS_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFCE-MCS-PLUGINS_VERSION)-$(XFCE-MCS-PLUGINS_VENDOR_VERSION)" 			>>$(XFCE-MCS-PLUGINS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFCE-MCS-PLUGINS_DEPLIST)" 						>>$(XFCE-MCS-PLUGINS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFCE-MCS-PLUGINS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFCE-MCS-PLUGINS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFCE-MCS-PLUGINS_INSTALL
ROMPACKAGES += $(STATEDIR)/xfce-mcs-plugins.imageinstall
endif

xfce-mcs-plugins_imageinstall_deps = $(STATEDIR)/xfce-mcs-plugins.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfce-mcs-plugins.imageinstall: $(xfce-mcs-plugins_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfce-mcs-plugins
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfce-mcs-plugins_clean:
	rm -rf $(STATEDIR)/xfce-mcs-plugins.*
	rm -rf $(XFCE-MCS-PLUGINS_DIR)

# vim: syntax=make
