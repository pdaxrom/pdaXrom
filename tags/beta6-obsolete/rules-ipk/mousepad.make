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
ifdef PTXCONF_MOUSEPAD
PACKAGES += mousepad
endif

#
# Paths and names
#
MOUSEPAD_VENDOR_VERSION	= 1
MOUSEPAD_VERSION	= 0.2.12
MOUSEPAD		= mousepad-$(MOUSEPAD_VERSION)
MOUSEPAD_SUFFIX		= tar.bz2
MOUSEPAD_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(MOUSEPAD).$(MOUSEPAD_SUFFIX)
MOUSEPAD_SOURCE		= $(SRCDIR)/$(MOUSEPAD).$(MOUSEPAD_SUFFIX)
MOUSEPAD_DIR		= $(BUILDDIR)/$(MOUSEPAD)
MOUSEPAD_IPKG_TMP	= $(MOUSEPAD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mousepad_get: $(STATEDIR)/mousepad.get

mousepad_get_deps = $(MOUSEPAD_SOURCE)

$(STATEDIR)/mousepad.get: $(mousepad_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MOUSEPAD))
	touch $@

$(MOUSEPAD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MOUSEPAD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mousepad_extract: $(STATEDIR)/mousepad.extract

mousepad_extract_deps = $(STATEDIR)/mousepad.get

$(STATEDIR)/mousepad.extract: $(mousepad_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MOUSEPAD_DIR))
	@$(call extract, $(MOUSEPAD_SOURCE))
	@$(call patchin, $(MOUSEPAD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mousepad_prepare: $(STATEDIR)/mousepad.prepare

#
# dependencies
#
mousepad_prepare_deps = \
	$(STATEDIR)/mousepad.extract \
	$(STATEDIR)/virtual-xchain.install

MOUSEPAD_PATH	=  PATH=$(CROSS_PATH)
MOUSEPAD_ENV 	=  $(CROSS_ENV)
#MOUSEPAD_ENV	+=
MOUSEPAD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MOUSEPAD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MOUSEPAD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
MOUSEPAD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MOUSEPAD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mousepad.prepare: $(mousepad_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MOUSEPAD_DIR)/config.cache)
	cd $(MOUSEPAD_DIR) && \
		$(MOUSEPAD_PATH) $(MOUSEPAD_ENV) \
		./configure $(MOUSEPAD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mousepad_compile: $(STATEDIR)/mousepad.compile

mousepad_compile_deps = $(STATEDIR)/mousepad.prepare

$(STATEDIR)/mousepad.compile: $(mousepad_compile_deps)
	@$(call targetinfo, $@)
	$(MOUSEPAD_PATH) $(MAKE) -C $(MOUSEPAD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mousepad_install: $(STATEDIR)/mousepad.install

$(STATEDIR)/mousepad.install: $(STATEDIR)/mousepad.compile
	@$(call targetinfo, $@)
	rm -rf $(MOUSEPAD_IPKG_TMP)
	$(MOUSEPAD_PATH) $(MAKE) -C $(MOUSEPAD_DIR) DESTDIR=$(MOUSEPAD_IPKG_TMP) install
	@$(call copyincludes, $(MOUSEPAD_IPKG_TMP))
	@$(call copylibraries,$(MOUSEPAD_IPKG_TMP))
	@$(call copymiscfiles,$(MOUSEPAD_IPKG_TMP))
	rm -rf $(MOUSEPAD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mousepad_targetinstall: $(STATEDIR)/mousepad.targetinstall

mousepad_targetinstall_deps = $(STATEDIR)/mousepad.compile

MOUSEPAD_DEPLIST = 

$(STATEDIR)/mousepad.targetinstall: $(mousepad_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MOUSEPAD_PATH) $(MAKE) -C $(MOUSEPAD_DIR) DESTDIR=$(MOUSEPAD_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(MOUSEPAD_VERSION)-$(MOUSEPAD_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh mousepad $(MOUSEPAD_IPKG_TMP)

	@$(call removedevfiles, $(MOUSEPAD_IPKG_TMP))
	@$(call stripfiles, $(MOUSEPAD_IPKG_TMP))
	mkdir -p $(MOUSEPAD_IPKG_TMP)/CONTROL
	echo "Package: mousepad" 							 >$(MOUSEPAD_IPKG_TMP)/CONTROL/control
	echo "Source: $(MOUSEPAD_URL)"							>>$(MOUSEPAD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MOUSEPAD_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(MOUSEPAD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(MOUSEPAD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MOUSEPAD_IPKG_TMP)/CONTROL/control
	echo "Version: $(MOUSEPAD_VERSION)-$(MOUSEPAD_VENDOR_VERSION)" 			>>$(MOUSEPAD_IPKG_TMP)/CONTROL/control
	echo "Depends: $(MOUSEPAD_DEPLIST)" 						>>$(MOUSEPAD_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(MOUSEPAD_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(MOUSEPAD_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MOUSEPAD_INSTALL
ROMPACKAGES += $(STATEDIR)/mousepad.imageinstall
endif

mousepad_imageinstall_deps = $(STATEDIR)/mousepad.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mousepad.imageinstall: $(mousepad_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mousepad
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mousepad_clean:
	rm -rf $(STATEDIR)/mousepad.*
	rm -rf $(MOUSEPAD_DIR)

# vim: syntax=make
