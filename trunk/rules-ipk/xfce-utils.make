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
ifdef PTXCONF_XFCE-UTILS
PACKAGES += xfce-utils
endif

#
# Paths and names
#
XFCE-UTILS_VENDOR_VERSION	= 1
XFCE-UTILS_VERSION	= 4.4.0
XFCE-UTILS		= xfce-utils-$(XFCE-UTILS_VERSION)
XFCE-UTILS_SUFFIX		= tar.bz2
XFCE-UTILS_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFCE-UTILS).$(XFCE-UTILS_SUFFIX)
XFCE-UTILS_SOURCE		= $(SRCDIR)/$(XFCE-UTILS).$(XFCE-UTILS_SUFFIX)
XFCE-UTILS_DIR		= $(BUILDDIR)/$(XFCE-UTILS)
XFCE-UTILS_IPKG_TMP	= $(XFCE-UTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfce-utils_get: $(STATEDIR)/xfce-utils.get

xfce-utils_get_deps = $(XFCE-UTILS_SOURCE)

$(STATEDIR)/xfce-utils.get: $(xfce-utils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFCE-UTILS))
	touch $@

$(XFCE-UTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFCE-UTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfce-utils_extract: $(STATEDIR)/xfce-utils.extract

xfce-utils_extract_deps = $(STATEDIR)/xfce-utils.get

$(STATEDIR)/xfce-utils.extract: $(xfce-utils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE-UTILS_DIR))
	@$(call extract, $(XFCE-UTILS_SOURCE))
	@$(call patchin, $(XFCE-UTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfce-utils_prepare: $(STATEDIR)/xfce-utils.prepare

#
# dependencies
#
xfce-utils_prepare_deps = \
	$(STATEDIR)/xfce-utils.extract \
	$(STATEDIR)/virtual-xchain.install

XFCE-UTILS_PATH	=  PATH=$(CROSS_PATH)
XFCE-UTILS_ENV 	=  $(CROSS_ENV)
#XFCE-UTILS_ENV	+=
XFCE-UTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFCE-UTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFCE-UTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFCE-UTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFCE-UTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfce-utils.prepare: $(xfce-utils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE-UTILS_DIR)/config.cache)
	cd $(XFCE-UTILS_DIR) && \
		$(XFCE-UTILS_PATH) $(XFCE-UTILS_ENV) \
		./configure $(XFCE-UTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfce-utils_compile: $(STATEDIR)/xfce-utils.compile

xfce-utils_compile_deps = $(STATEDIR)/xfce-utils.prepare

$(STATEDIR)/xfce-utils.compile: $(xfce-utils_compile_deps)
	@$(call targetinfo, $@)
	$(XFCE-UTILS_PATH) $(MAKE) -C $(XFCE-UTILS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfce-utils_install: $(STATEDIR)/xfce-utils.install

$(STATEDIR)/xfce-utils.install: $(STATEDIR)/xfce-utils.compile
	@$(call targetinfo, $@)
	rm -rf $(XFCE-UTILS_IPKG_TMP)
	$(XFCE-UTILS_PATH) $(MAKE) -C $(XFCE-UTILS_DIR) DESTDIR=$(XFCE-UTILS_IPKG_TMP) install
	@$(call copyincludes, $(XFCE-UTILS_IPKG_TMP))
	@$(call copylibraries,$(XFCE-UTILS_IPKG_TMP))
	@$(call copymiscfiles,$(XFCE-UTILS_IPKG_TMP))
	rm -rf $(XFCE-UTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfce-utils_targetinstall: $(STATEDIR)/xfce-utils.targetinstall

xfce-utils_targetinstall_deps = $(STATEDIR)/xfce-utils.compile

XFCE-UTILS_DEPLIST = 

$(STATEDIR)/xfce-utils.targetinstall: $(xfce-utils_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFCE-UTILS_PATH) $(MAKE) -C $(XFCE-UTILS_DIR) DESTDIR=$(XFCE-UTILS_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFCE-UTILS_VERSION)-$(XFCE-UTILS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfce-utils $(XFCE-UTILS_IPKG_TMP)

	@$(call removedevfiles, $(XFCE-UTILS_IPKG_TMP))
	@$(call stripfiles, $(XFCE-UTILS_IPKG_TMP))
	mkdir -p $(XFCE-UTILS_IPKG_TMP)/CONTROL
	echo "Package: xfce-utils" 							 >$(XFCE-UTILS_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFCE-UTILS_URL)"							>>$(XFCE-UTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFCE-UTILS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFCE-UTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFCE-UTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFCE-UTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFCE-UTILS_VERSION)-$(XFCE-UTILS_VENDOR_VERSION)" 			>>$(XFCE-UTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFCE-UTILS_DEPLIST)" 						>>$(XFCE-UTILS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFCE-UTILS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFCE-UTILS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFCE-UTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/xfce-utils.imageinstall
endif

xfce-utils_imageinstall_deps = $(STATEDIR)/xfce-utils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfce-utils.imageinstall: $(xfce-utils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfce-utils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfce-utils_clean:
	rm -rf $(STATEDIR)/xfce-utils.*
	rm -rf $(XFCE-UTILS_DIR)

# vim: syntax=make
