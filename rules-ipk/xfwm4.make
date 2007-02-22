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
ifdef PTXCONF_XFWM4
PACKAGES += xfwm4
endif

#
# Paths and names
#
XFWM4_VENDOR_VERSION	= 1
XFWM4_VERSION	= 4.4.0
XFWM4		= xfwm4-$(XFWM4_VERSION)
XFWM4_SUFFIX		= tar.bz2
XFWM4_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFWM4).$(XFWM4_SUFFIX)
XFWM4_SOURCE		= $(SRCDIR)/$(XFWM4).$(XFWM4_SUFFIX)
XFWM4_DIR		= $(BUILDDIR)/$(XFWM4)
XFWM4_IPKG_TMP	= $(XFWM4_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfwm4_get: $(STATEDIR)/xfwm4.get

xfwm4_get_deps = $(XFWM4_SOURCE)

$(STATEDIR)/xfwm4.get: $(xfwm4_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFWM4))
	touch $@

$(XFWM4_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFWM4_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfwm4_extract: $(STATEDIR)/xfwm4.extract

xfwm4_extract_deps = $(STATEDIR)/xfwm4.get

$(STATEDIR)/xfwm4.extract: $(xfwm4_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFWM4_DIR))
	@$(call extract, $(XFWM4_SOURCE))
	@$(call patchin, $(XFWM4))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfwm4_prepare: $(STATEDIR)/xfwm4.prepare

#
# dependencies
#
xfwm4_prepare_deps = \
	$(STATEDIR)/xfwm4.extract \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/virtual-xchain.install

XFWM4_PATH	=  PATH=$(CROSS_PATH)
XFWM4_ENV 	=  $(CROSS_ENV)
#XFWM4_ENV	+=
XFWM4_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFWM4_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFWM4_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFWM4_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFWM4_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfwm4.prepare: $(xfwm4_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFWM4_DIR)/config.cache)
	cd $(XFWM4_DIR) && \
		$(XFWM4_PATH) $(XFWM4_ENV) \
		./configure $(XFWM4_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfwm4_compile: $(STATEDIR)/xfwm4.compile

xfwm4_compile_deps = $(STATEDIR)/xfwm4.prepare

$(STATEDIR)/xfwm4.compile: $(xfwm4_compile_deps)
	@$(call targetinfo, $@)
	$(XFWM4_PATH) $(MAKE) -C $(XFWM4_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfwm4_install: $(STATEDIR)/xfwm4.install

$(STATEDIR)/xfwm4.install: $(STATEDIR)/xfwm4.compile
	@$(call targetinfo, $@)
	rm -rf $(XFWM4_IPKG_TMP)
	$(XFWM4_PATH) $(MAKE) -C $(XFWM4_DIR) DESTDIR=$(XFWM4_IPKG_TMP) install
	@$(call copyincludes, $(XFWM4_IPKG_TMP))
	@$(call copylibraries,$(XFWM4_IPKG_TMP))
	@$(call copymiscfiles,$(XFWM4_IPKG_TMP))
	rm -rf $(XFWM4_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfwm4_targetinstall: $(STATEDIR)/xfwm4.targetinstall

xfwm4_targetinstall_deps = $(STATEDIR)/xfwm4.compile

XFWM4_DEPLIST = 

$(STATEDIR)/xfwm4.targetinstall: $(xfwm4_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFWM4_PATH) $(MAKE) -C $(XFWM4_DIR) DESTDIR=$(XFWM4_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFWM4_VERSION)-$(XFWM4_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfwm4 $(XFWM4_IPKG_TMP)

	@$(call removedevfiles, $(XFWM4_IPKG_TMP))
	@$(call stripfiles, $(XFWM4_IPKG_TMP))
	mkdir -p $(XFWM4_IPKG_TMP)/CONTROL
	echo "Package: xfwm4" 							 >$(XFWM4_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFWM4_URL)"							>>$(XFWM4_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFWM4_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFWM4_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFWM4_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFWM4_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFWM4_VERSION)-$(XFWM4_VENDOR_VERSION)" 			>>$(XFWM4_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFWM4_DEPLIST)" 						>>$(XFWM4_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFWM4_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFWM4_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFWM4_INSTALL
ROMPACKAGES += $(STATEDIR)/xfwm4.imageinstall
endif

xfwm4_imageinstall_deps = $(STATEDIR)/xfwm4.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfwm4.imageinstall: $(xfwm4_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfwm4
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfwm4_clean:
	rm -rf $(STATEDIR)/xfwm4.*
	rm -rf $(XFWM4_DIR)

# vim: syntax=make
