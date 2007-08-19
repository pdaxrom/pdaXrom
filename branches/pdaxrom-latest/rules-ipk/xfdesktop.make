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
ifdef PTXCONF_XFDESKTOP
PACKAGES += xfdesktop
endif

#
# Paths and names
#
XFDESKTOP_VENDOR_VERSION	= 1
XFDESKTOP_VERSION	= 4.4.0
XFDESKTOP		= xfdesktop-$(XFDESKTOP_VERSION)
XFDESKTOP_SUFFIX		= tar.bz2
XFDESKTOP_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFDESKTOP).$(XFDESKTOP_SUFFIX)
XFDESKTOP_SOURCE		= $(SRCDIR)/$(XFDESKTOP).$(XFDESKTOP_SUFFIX)
XFDESKTOP_DIR		= $(BUILDDIR)/$(XFDESKTOP)
XFDESKTOP_IPKG_TMP	= $(XFDESKTOP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfdesktop_get: $(STATEDIR)/xfdesktop.get

xfdesktop_get_deps = $(XFDESKTOP_SOURCE)

$(STATEDIR)/xfdesktop.get: $(xfdesktop_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFDESKTOP))
	touch $@

$(XFDESKTOP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFDESKTOP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfdesktop_extract: $(STATEDIR)/xfdesktop.extract

xfdesktop_extract_deps = $(STATEDIR)/xfdesktop.get

$(STATEDIR)/xfdesktop.extract: $(xfdesktop_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFDESKTOP_DIR))
	@$(call extract, $(XFDESKTOP_SOURCE))
	@$(call patchin, $(XFDESKTOP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfdesktop_prepare: $(STATEDIR)/xfdesktop.prepare

#
# dependencies
#
xfdesktop_prepare_deps = \
	$(STATEDIR)/xfdesktop.extract \
	$(STATEDIR)/virtual-xchain.install

XFDESKTOP_PATH	=  PATH=$(CROSS_PATH)
XFDESKTOP_ENV 	=  $(CROSS_ENV)
#XFDESKTOP_ENV	+=
XFDESKTOP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFDESKTOP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFDESKTOP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFDESKTOP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFDESKTOP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfdesktop.prepare: $(xfdesktop_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFDESKTOP_DIR)/config.cache)
	cd $(XFDESKTOP_DIR) && \
		$(XFDESKTOP_PATH) $(XFDESKTOP_ENV) \
		./configure $(XFDESKTOP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfdesktop_compile: $(STATEDIR)/xfdesktop.compile

xfdesktop_compile_deps = $(STATEDIR)/xfdesktop.prepare

$(STATEDIR)/xfdesktop.compile: $(xfdesktop_compile_deps)
	@$(call targetinfo, $@)
	$(XFDESKTOP_PATH) $(MAKE) -C $(XFDESKTOP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfdesktop_install: $(STATEDIR)/xfdesktop.install

$(STATEDIR)/xfdesktop.install: $(STATEDIR)/xfdesktop.compile
	@$(call targetinfo, $@)
	rm -rf $(XFDESKTOP_IPKG_TMP)
	$(XFDESKTOP_PATH) $(MAKE) -C $(XFDESKTOP_DIR) DESTDIR=$(XFDESKTOP_IPKG_TMP) install
	@$(call copyincludes, $(XFDESKTOP_IPKG_TMP))
	@$(call copylibraries,$(XFDESKTOP_IPKG_TMP))
	@$(call copymiscfiles,$(XFDESKTOP_IPKG_TMP))
	rm -rf $(XFDESKTOP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfdesktop_targetinstall: $(STATEDIR)/xfdesktop.targetinstall

xfdesktop_targetinstall_deps = $(STATEDIR)/xfdesktop.compile

XFDESKTOP_DEPLIST = 

$(STATEDIR)/xfdesktop.targetinstall: $(xfdesktop_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFDESKTOP_PATH) $(MAKE) -C $(XFDESKTOP_DIR) DESTDIR=$(XFDESKTOP_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFDESKTOP_VERSION)-$(XFDESKTOP_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfdesktop $(XFDESKTOP_IPKG_TMP)

	@$(call removedevfiles, $(XFDESKTOP_IPKG_TMP))
	@$(call stripfiles, $(XFDESKTOP_IPKG_TMP))
	mkdir -p $(XFDESKTOP_IPKG_TMP)/CONTROL
	echo "Package: xfdesktop" 							 >$(XFDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFDESKTOP_URL)"							>>$(XFDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFDESKTOP_VERSION)-$(XFDESKTOP_VENDOR_VERSION)" 			>>$(XFDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFDESKTOP_DEPLIST)" 						>>$(XFDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFDESKTOP_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFDESKTOP_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFDESKTOP_INSTALL
ROMPACKAGES += $(STATEDIR)/xfdesktop.imageinstall
endif

xfdesktop_imageinstall_deps = $(STATEDIR)/xfdesktop.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfdesktop.imageinstall: $(xfdesktop_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfdesktop
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfdesktop_clean:
	rm -rf $(STATEDIR)/xfdesktop.*
	rm -rf $(XFDESKTOP_DIR)

# vim: syntax=make
