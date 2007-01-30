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
ifdef PTXCONF_XFCE-MCS-MANAGER
PACKAGES += xfce-mcs-manager
endif

#
# Paths and names
#
XFCE-MCS-MANAGER_VENDOR_VERSION	= 1
XFCE-MCS-MANAGER_VERSION	= 4.4.0
XFCE-MCS-MANAGER		= xfce-mcs-manager-$(XFCE-MCS-MANAGER_VERSION)
XFCE-MCS-MANAGER_SUFFIX		= tar.bz2
XFCE-MCS-MANAGER_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFCE-MCS-MANAGER).$(XFCE-MCS-MANAGER_SUFFIX)
XFCE-MCS-MANAGER_SOURCE		= $(SRCDIR)/$(XFCE-MCS-MANAGER).$(XFCE-MCS-MANAGER_SUFFIX)
XFCE-MCS-MANAGER_DIR		= $(BUILDDIR)/$(XFCE-MCS-MANAGER)
XFCE-MCS-MANAGER_IPKG_TMP	= $(XFCE-MCS-MANAGER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfce-mcs-manager_get: $(STATEDIR)/xfce-mcs-manager.get

xfce-mcs-manager_get_deps = $(XFCE-MCS-MANAGER_SOURCE)

$(STATEDIR)/xfce-mcs-manager.get: $(xfce-mcs-manager_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFCE-MCS-MANAGER))
	touch $@

$(XFCE-MCS-MANAGER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFCE-MCS-MANAGER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfce-mcs-manager_extract: $(STATEDIR)/xfce-mcs-manager.extract

xfce-mcs-manager_extract_deps = $(STATEDIR)/xfce-mcs-manager.get

$(STATEDIR)/xfce-mcs-manager.extract: $(xfce-mcs-manager_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE-MCS-MANAGER_DIR))
	@$(call extract, $(XFCE-MCS-MANAGER_SOURCE))
	@$(call patchin, $(XFCE-MCS-MANAGER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfce-mcs-manager_prepare: $(STATEDIR)/xfce-mcs-manager.prepare

#
# dependencies
#
xfce-mcs-manager_prepare_deps = \
	$(STATEDIR)/xfce-mcs-manager.extract \
	$(STATEDIR)/virtual-xchain.install

XFCE-MCS-MANAGER_PATH	=  PATH=$(CROSS_PATH)
XFCE-MCS-MANAGER_ENV 	=  $(CROSS_ENV)
#XFCE-MCS-MANAGER_ENV	+=
XFCE-MCS-MANAGER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFCE-MCS-MANAGER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFCE-MCS-MANAGER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFCE-MCS-MANAGER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFCE-MCS-MANAGER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfce-mcs-manager.prepare: $(xfce-mcs-manager_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE-MCS-MANAGER_DIR)/config.cache)
	cd $(XFCE-MCS-MANAGER_DIR) && \
		$(XFCE-MCS-MANAGER_PATH) $(XFCE-MCS-MANAGER_ENV) \
		./configure $(XFCE-MCS-MANAGER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfce-mcs-manager_compile: $(STATEDIR)/xfce-mcs-manager.compile

xfce-mcs-manager_compile_deps = $(STATEDIR)/xfce-mcs-manager.prepare

$(STATEDIR)/xfce-mcs-manager.compile: $(xfce-mcs-manager_compile_deps)
	@$(call targetinfo, $@)
	$(XFCE-MCS-MANAGER_PATH) $(MAKE) -C $(XFCE-MCS-MANAGER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfce-mcs-manager_install: $(STATEDIR)/xfce-mcs-manager.install

$(STATEDIR)/xfce-mcs-manager.install: $(STATEDIR)/xfce-mcs-manager.compile
	@$(call targetinfo, $@)
	rm -rf $(XFCE-MCS-MANAGER_IPKG_TMP)
	$(XFCE-MCS-MANAGER_PATH) $(MAKE) -C $(XFCE-MCS-MANAGER_DIR) DESTDIR=$(XFCE-MCS-MANAGER_IPKG_TMP) install
	@$(call copyincludes, $(XFCE-MCS-MANAGER_IPKG_TMP))
	@$(call copylibraries,$(XFCE-MCS-MANAGER_IPKG_TMP))
	@$(call copymiscfiles,$(XFCE-MCS-MANAGER_IPKG_TMP))
	rm -rf $(XFCE-MCS-MANAGER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfce-mcs-manager_targetinstall: $(STATEDIR)/xfce-mcs-manager.targetinstall

xfce-mcs-manager_targetinstall_deps = $(STATEDIR)/xfce-mcs-manager.compile

XFCE-MCS-MANAGER_DEPLIST = 

$(STATEDIR)/xfce-mcs-manager.targetinstall: $(xfce-mcs-manager_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFCE-MCS-MANAGER_PATH) $(MAKE) -C $(XFCE-MCS-MANAGER_DIR) DESTDIR=$(XFCE-MCS-MANAGER_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFCE-MCS-MANAGER_VERSION)-$(XFCE-MCS-MANAGER_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfce-mcs-manager $(XFCE-MCS-MANAGER_IPKG_TMP)

	@$(call removedevfiles, $(XFCE-MCS-MANAGER_IPKG_TMP))
	@$(call stripfiles, $(XFCE-MCS-MANAGER_IPKG_TMP))
	mkdir -p $(XFCE-MCS-MANAGER_IPKG_TMP)/CONTROL
	echo "Package: xfce-mcs-manager" 							 >$(XFCE-MCS-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFCE-MCS-MANAGER_URL)"							>>$(XFCE-MCS-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFCE-MCS-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFCE-MCS-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFCE-MCS-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFCE-MCS-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFCE-MCS-MANAGER_VERSION)-$(XFCE-MCS-MANAGER_VENDOR_VERSION)" 			>>$(XFCE-MCS-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFCE-MCS-MANAGER_DEPLIST)" 						>>$(XFCE-MCS-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFCE-MCS-MANAGER_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFCE-MCS-MANAGER_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFCE-MCS-MANAGER_INSTALL
ROMPACKAGES += $(STATEDIR)/xfce-mcs-manager.imageinstall
endif

xfce-mcs-manager_imageinstall_deps = $(STATEDIR)/xfce-mcs-manager.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfce-mcs-manager.imageinstall: $(xfce-mcs-manager_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfce-mcs-manager
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfce-mcs-manager_clean:
	rm -rf $(STATEDIR)/xfce-mcs-manager.*
	rm -rf $(XFCE-MCS-MANAGER_DIR)

# vim: syntax=make
