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
ifdef PTXCONF_XFPRINT
PACKAGES += xfprint
endif

#
# Paths and names
#
XFPRINT_VENDOR_VERSION	= 1
XFPRINT_VERSION	= 4.4.0
XFPRINT		= xfprint-$(XFPRINT_VERSION)
XFPRINT_SUFFIX		= tar.bz2
XFPRINT_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFPRINT).$(XFPRINT_SUFFIX)
XFPRINT_SOURCE		= $(SRCDIR)/$(XFPRINT).$(XFPRINT_SUFFIX)
XFPRINT_DIR		= $(BUILDDIR)/$(XFPRINT)
XFPRINT_IPKG_TMP	= $(XFPRINT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfprint_get: $(STATEDIR)/xfprint.get

xfprint_get_deps = $(XFPRINT_SOURCE)

$(STATEDIR)/xfprint.get: $(xfprint_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFPRINT))
	touch $@

$(XFPRINT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFPRINT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfprint_extract: $(STATEDIR)/xfprint.extract

xfprint_extract_deps = $(STATEDIR)/xfprint.get

$(STATEDIR)/xfprint.extract: $(xfprint_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFPRINT_DIR))
	@$(call extract, $(XFPRINT_SOURCE))
	@$(call patchin, $(XFPRINT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfprint_prepare: $(STATEDIR)/xfprint.prepare

#
# dependencies
#
xfprint_prepare_deps = \
	$(STATEDIR)/xfprint.extract \
	$(STATEDIR)/virtual-xchain.install

XFPRINT_PATH	=  PATH=$(CROSS_PATH)
XFPRINT_ENV 	=  $(CROSS_ENV)
#XFPRINT_ENV	+=
XFPRINT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFPRINT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFPRINT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFPRINT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFPRINT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfprint.prepare: $(xfprint_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFPRINT_DIR)/config.cache)
	cd $(XFPRINT_DIR) && \
		$(XFPRINT_PATH) $(XFPRINT_ENV) \
		./configure $(XFPRINT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfprint_compile: $(STATEDIR)/xfprint.compile

xfprint_compile_deps = $(STATEDIR)/xfprint.prepare

$(STATEDIR)/xfprint.compile: $(xfprint_compile_deps)
	@$(call targetinfo, $@)
	$(XFPRINT_PATH) $(MAKE) -C $(XFPRINT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfprint_install: $(STATEDIR)/xfprint.install

$(STATEDIR)/xfprint.install: $(STATEDIR)/xfprint.compile
	@$(call targetinfo, $@)
	rm -rf $(XFPRINT_IPKG_TMP)
	$(XFPRINT_PATH) $(MAKE) -C $(XFPRINT_DIR) DESTDIR=$(XFPRINT_IPKG_TMP) install
	@$(call copyincludes, $(XFPRINT_IPKG_TMP))
	@$(call copylibraries,$(XFPRINT_IPKG_TMP))
	@$(call copymiscfiles,$(XFPRINT_IPKG_TMP))
	rm -rf $(XFPRINT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfprint_targetinstall: $(STATEDIR)/xfprint.targetinstall

xfprint_targetinstall_deps = $(STATEDIR)/xfprint.compile

XFPRINT_DEPLIST = 

$(STATEDIR)/xfprint.targetinstall: $(xfprint_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFPRINT_PATH) $(MAKE) -C $(XFPRINT_DIR) DESTDIR=$(XFPRINT_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFPRINT_VERSION)-$(XFPRINT_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfprint $(XFPRINT_IPKG_TMP)

	@$(call removedevfiles, $(XFPRINT_IPKG_TMP))
	@$(call stripfiles, $(XFPRINT_IPKG_TMP))
	mkdir -p $(XFPRINT_IPKG_TMP)/CONTROL
	echo "Package: xfprint" 							 >$(XFPRINT_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFPRINT_URL)"							>>$(XFPRINT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFPRINT_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFPRINT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFPRINT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFPRINT_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFPRINT_VERSION)-$(XFPRINT_VENDOR_VERSION)" 			>>$(XFPRINT_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFPRINT_DEPLIST)" 						>>$(XFPRINT_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFPRINT_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFPRINT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFPRINT_INSTALL
ROMPACKAGES += $(STATEDIR)/xfprint.imageinstall
endif

xfprint_imageinstall_deps = $(STATEDIR)/xfprint.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfprint.imageinstall: $(xfprint_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfprint
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfprint_clean:
	rm -rf $(STATEDIR)/xfprint.*
	rm -rf $(XFPRINT_DIR)

# vim: syntax=make
