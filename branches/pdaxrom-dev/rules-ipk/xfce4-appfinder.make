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
ifdef PTXCONF_XFCE4-APPFINDER
PACKAGES += xfce4-appfinder
endif

#
# Paths and names
#
XFCE4-APPFINDER_VENDOR_VERSION	= 1
XFCE4-APPFINDER_VERSION	= 4.4.0
XFCE4-APPFINDER		= xfce4-appfinder-$(XFCE4-APPFINDER_VERSION)
XFCE4-APPFINDER_SUFFIX		= tar.bz2
XFCE4-APPFINDER_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFCE4-APPFINDER).$(XFCE4-APPFINDER_SUFFIX)
XFCE4-APPFINDER_SOURCE		= $(SRCDIR)/$(XFCE4-APPFINDER).$(XFCE4-APPFINDER_SUFFIX)
XFCE4-APPFINDER_DIR		= $(BUILDDIR)/$(XFCE4-APPFINDER)
XFCE4-APPFINDER_IPKG_TMP	= $(XFCE4-APPFINDER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfce4-appfinder_get: $(STATEDIR)/xfce4-appfinder.get

xfce4-appfinder_get_deps = $(XFCE4-APPFINDER_SOURCE)

$(STATEDIR)/xfce4-appfinder.get: $(xfce4-appfinder_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFCE4-APPFINDER))
	touch $@

$(XFCE4-APPFINDER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFCE4-APPFINDER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfce4-appfinder_extract: $(STATEDIR)/xfce4-appfinder.extract

xfce4-appfinder_extract_deps = $(STATEDIR)/xfce4-appfinder.get

$(STATEDIR)/xfce4-appfinder.extract: $(xfce4-appfinder_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-APPFINDER_DIR))
	@$(call extract, $(XFCE4-APPFINDER_SOURCE))
	@$(call patchin, $(XFCE4-APPFINDER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfce4-appfinder_prepare: $(STATEDIR)/xfce4-appfinder.prepare

#
# dependencies
#
xfce4-appfinder_prepare_deps = \
	$(STATEDIR)/xfce4-appfinder.extract \
	$(STATEDIR)/virtual-xchain.install

XFCE4-APPFINDER_PATH	=  PATH=$(CROSS_PATH)
XFCE4-APPFINDER_ENV 	=  $(CROSS_ENV)
#XFCE4-APPFINDER_ENV	+=
XFCE4-APPFINDER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFCE4-APPFINDER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFCE4-APPFINDER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFCE4-APPFINDER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFCE4-APPFINDER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfce4-appfinder.prepare: $(xfce4-appfinder_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-APPFINDER_DIR)/config.cache)
	cd $(XFCE4-APPFINDER_DIR) && \
		$(XFCE4-APPFINDER_PATH) $(XFCE4-APPFINDER_ENV) \
		./configure $(XFCE4-APPFINDER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfce4-appfinder_compile: $(STATEDIR)/xfce4-appfinder.compile

xfce4-appfinder_compile_deps = $(STATEDIR)/xfce4-appfinder.prepare

$(STATEDIR)/xfce4-appfinder.compile: $(xfce4-appfinder_compile_deps)
	@$(call targetinfo, $@)
	$(XFCE4-APPFINDER_PATH) $(MAKE) -C $(XFCE4-APPFINDER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfce4-appfinder_install: $(STATEDIR)/xfce4-appfinder.install

$(STATEDIR)/xfce4-appfinder.install: $(STATEDIR)/xfce4-appfinder.compile
	@$(call targetinfo, $@)
	rm -rf $(XFCE4-APPFINDER_IPKG_TMP)
	$(XFCE4-APPFINDER_PATH) $(MAKE) -C $(XFCE4-APPFINDER_DIR) DESTDIR=$(XFCE4-APPFINDER_IPKG_TMP) install
	@$(call copyincludes, $(XFCE4-APPFINDER_IPKG_TMP))
	@$(call copylibraries,$(XFCE4-APPFINDER_IPKG_TMP))
	@$(call copymiscfiles,$(XFCE4-APPFINDER_IPKG_TMP))
	rm -rf $(XFCE4-APPFINDER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfce4-appfinder_targetinstall: $(STATEDIR)/xfce4-appfinder.targetinstall

xfce4-appfinder_targetinstall_deps = $(STATEDIR)/xfce4-appfinder.compile

XFCE4-APPFINDER_DEPLIST = 

$(STATEDIR)/xfce4-appfinder.targetinstall: $(xfce4-appfinder_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFCE4-APPFINDER_PATH) $(MAKE) -C $(XFCE4-APPFINDER_DIR) DESTDIR=$(XFCE4-APPFINDER_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFCE4-APPFINDER_VERSION)-$(XFCE4-APPFINDER_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfce4-appfinder $(XFCE4-APPFINDER_IPKG_TMP)

	@$(call removedevfiles, $(XFCE4-APPFINDER_IPKG_TMP))
	@$(call stripfiles, $(XFCE4-APPFINDER_IPKG_TMP))
	mkdir -p $(XFCE4-APPFINDER_IPKG_TMP)/CONTROL
	echo "Package: xfce4-appfinder" 							 >$(XFCE4-APPFINDER_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFCE4-APPFINDER_URL)"							>>$(XFCE4-APPFINDER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFCE4-APPFINDER_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFCE4-APPFINDER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFCE4-APPFINDER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFCE4-APPFINDER_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFCE4-APPFINDER_VERSION)-$(XFCE4-APPFINDER_VENDOR_VERSION)" 			>>$(XFCE4-APPFINDER_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFCE4-APPFINDER_DEPLIST)" 						>>$(XFCE4-APPFINDER_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFCE4-APPFINDER_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFCE4-APPFINDER_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFCE4-APPFINDER_INSTALL
ROMPACKAGES += $(STATEDIR)/xfce4-appfinder.imageinstall
endif

xfce4-appfinder_imageinstall_deps = $(STATEDIR)/xfce4-appfinder.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfce4-appfinder.imageinstall: $(xfce4-appfinder_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfce4-appfinder
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfce4-appfinder_clean:
	rm -rf $(STATEDIR)/xfce4-appfinder.*
	rm -rf $(XFCE4-APPFINDER_DIR)

# vim: syntax=make
