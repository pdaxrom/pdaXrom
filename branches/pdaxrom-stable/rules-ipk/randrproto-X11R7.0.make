# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Adrian Crutchfield (InSearchOf@pdaxrom.org)
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_RANDRPROTO-X11R7.0
PACKAGES += randrproto-X11R7.0
endif

#
# Paths and names
#
RANDRPROTO-X11R7.0_VENDOR_VERSION	= 1
RANDRPROTO-X11R7.0_VERSION	= 1.1.2
RANDRPROTO-X11R7.0		= randrproto-X11R7.0-$(RANDRPROTO-X11R7.0_VERSION)
RANDRPROTO-X11R7.0_SUFFIX		= tar.bz2
RANDRPROTO-X11R7.0_URL		= http://xorg.freedesktop.org/releases/X11R7.2/src/everything/$(RANDRPROTO-X11R7.0).$(RANDRPROTO-X11R7.0_SUFFIX)
RANDRPROTO-X11R7.0_SOURCE		= $(SRCDIR)/$(RANDRPROTO-X11R7.0).$(RANDRPROTO-X11R7.0_SUFFIX)
RANDRPROTO-X11R7.0_DIR		= $(BUILDDIR)/$(RANDRPROTO-X11R7.0)
RANDRPROTO-X11R7.0_IPKG_TMP	= $(RANDRPROTO-X11R7.0_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

randrproto-X11R7.0_get: $(STATEDIR)/randrproto-X11R7.0.get

randrproto-X11R7.0_get_deps = $(RANDRPROTO-X11R7.0_SOURCE)

$(STATEDIR)/randrproto-X11R7.0.get: $(randrproto-X11R7.0_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(RANDRPROTO-X11R7.0))
	touch $@

$(RANDRPROTO-X11R7.0_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(RANDRPROTO-X11R7.0_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

randrproto-X11R7.0_extract: $(STATEDIR)/randrproto-X11R7.0.extract

randrproto-X11R7.0_extract_deps = $(STATEDIR)/randrproto-X11R7.0.get

$(STATEDIR)/randrproto-X11R7.0.extract: $(randrproto-X11R7.0_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RANDRPROTO-X11R7.0_DIR))
	@$(call extract, $(RANDRPROTO-X11R7.0_SOURCE))
	@$(call patchin, $(RANDRPROTO-X11R7.0))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

randrproto-X11R7.0_prepare: $(STATEDIR)/randrproto-X11R7.0.prepare

#
# dependencies
#
randrproto-X11R7.0_prepare_deps = \
	$(STATEDIR)/randrproto-X11R7.0.extract \
	$(STATEDIR)/virtual-xchain.install

RANDRPROTO-X11R7.0_PATH	=  PATH=$(CROSS_PATH)
RANDRPROTO-X11R7.0_ENV 	=  $(CROSS_ENV)
#RANDRPROTO-X11R7.0_ENV	+=
RANDRPROTO-X11R7.0_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#RANDRPROTO-X11R7.0_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
RANDRPROTO-X11R7.0_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
RANDRPROTO-X11R7.0_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
RANDRPROTO-X11R7.0_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/randrproto-X11R7.0.prepare: $(randrproto-X11R7.0_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RANDRPROTO-X11R7.0_DIR)/config.cache)
	cd $(RANDRPROTO-X11R7.0_DIR) && \
		$(RANDRPROTO-X11R7.0_PATH) $(RANDRPROTO-X11R7.0_ENV) \
		./configure $(RANDRPROTO-X11R7.0_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

randrproto-X11R7.0_compile: $(STATEDIR)/randrproto-X11R7.0.compile

randrproto-X11R7.0_compile_deps = $(STATEDIR)/randrproto-X11R7.0.prepare

$(STATEDIR)/randrproto-X11R7.0.compile: $(randrproto-X11R7.0_compile_deps)
	@$(call targetinfo, $@)
	$(RANDRPROTO-X11R7.0_PATH) $(MAKE) -C $(RANDRPROTO-X11R7.0_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

randrproto-X11R7.0_install: $(STATEDIR)/randrproto-X11R7.0.install

$(STATEDIR)/randrproto-X11R7.0.install: $(STATEDIR)/randrproto-X11R7.0.compile
	@$(call targetinfo, $@)
	rm -rf $(RANDRPROTO-X11R7.0_IPKG_TMP)
	$(RANDRPROTO-X11R7.0_PATH) $(MAKE) -C $(RANDRPROTO-X11R7.0_DIR) DESTDIR=$(RANDRPROTO-X11R7.0_IPKG_TMP) install
	@$(call copyincludes, $(RANDRPROTO-X11R7.0_IPKG_TMP))
	@$(call copylibraries,$(RANDRPROTO-X11R7.0_IPKG_TMP))
	@$(call copymiscfiles,$(RANDRPROTO-X11R7.0_IPKG_TMP))
	rm -rf $(RANDRPROTO-X11R7.0_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

randrproto-X11R7.0_targetinstall: $(STATEDIR)/randrproto-X11R7.0.targetinstall

randrproto-X11R7.0_targetinstall_deps = $(STATEDIR)/randrproto-X11R7.0.compile

RANDRPROTO-X11R7.0_DEPLIST = 

$(STATEDIR)/randrproto-X11R7.0.targetinstall: $(randrproto-X11R7.0_targetinstall_deps)
	@$(call targetinfo, $@)
	$(RANDRPROTO-X11R7.0_PATH) $(MAKE) -C $(RANDRPROTO-X11R7.0_DIR) DESTDIR=$(RANDRPROTO-X11R7.0_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(RANDRPROTO-X11R7.0_VERSION)-$(RANDRPROTO-X11R7.0_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh randrproto-x11r7.0 $(RANDRPROTO-X11R7.0_IPKG_TMP)

	@$(call removedevfiles, $(RANDRPROTO-X11R7.0_IPKG_TMP))
	@$(call stripfiles, $(RANDRPROTO-X11R7.0_IPKG_TMP))
	mkdir -p $(RANDRPROTO-X11R7.0_IPKG_TMP)/CONTROL
	echo "Package: randrproto-x11r7.0" 							 >$(RANDRPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Source: $(RANDRPROTO-X11R7.0_URL)"							>>$(RANDRPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(RANDRPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(RANDRPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield (InSearchOf@pdaxrom.org)" 							>>$(RANDRPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(RANDRPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Version: $(RANDRPROTO-X11R7.0_VERSION)-$(RANDRPROTO-X11R7.0_VENDOR_VERSION)" 			>>$(RANDRPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Depends: $(RANDRPROTO-X11R7.0_DEPLIST)" 						>>$(RANDRPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(RANDRPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(RANDRPROTO-X11R7.0_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_RANDRPROTO-X11R7.0_INSTALL
ROMPACKAGES += $(STATEDIR)/randrproto-X11R7.0.imageinstall
endif

randrproto-X11R7.0_imageinstall_deps = $(STATEDIR)/randrproto-X11R7.0.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/randrproto-X11R7.0.imageinstall: $(randrproto-X11R7.0_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install randrproto-x11r7.0
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

randrproto-X11R7.0_clean:
	rm -rf $(STATEDIR)/randrproto-X11R7.0.*
	rm -rf $(RANDRPROTO-X11R7.0_DIR)

# vim: syntax=make
