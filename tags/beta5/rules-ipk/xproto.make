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
ifdef PTXCONF_XPROTO
PACKAGES += xproto
endif

#
# Paths and names
#
XPROTO_VENDOR_VERSION	= 1
XPROTO_VERSION		= 7.0.7
XPROTO			= xproto-$(XPROTO_VERSION)
XPROTO_SUFFIX		= tar.bz2
XPROTO_URL		= http://xorg.freedesktop.org/releases/individual/proto/$(XPROTO).$(XPROTO_SUFFIX)
XPROTO_SOURCE		= $(SRCDIR)/$(XPROTO).$(XPROTO_SUFFIX)
XPROTO_DIR		= $(BUILDDIR)/$(XPROTO)
XPROTO_IPKG_TMP		= $(XPROTO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xproto_get: $(STATEDIR)/xproto.get

xproto_get_deps = $(XPROTO_SOURCE)

$(STATEDIR)/xproto.get: $(xproto_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XPROTO))
	touch $@

$(XPROTO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XPROTO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xproto_extract: $(STATEDIR)/xproto.extract

xproto_extract_deps = $(STATEDIR)/xproto.get

$(STATEDIR)/xproto.extract: $(xproto_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XPROTO_DIR))
	@$(call extract, $(XPROTO_SOURCE))
	@$(call patchin, $(XPROTO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xproto_prepare: $(STATEDIR)/xproto.prepare

#
# dependencies
#
xproto_prepare_deps = \
	$(STATEDIR)/xproto.extract \
	$(STATEDIR)/virtual-xchain.install

XPROTO_PATH	=  PATH=$(CROSS_PATH)
XPROTO_ENV 	=  $(CROSS_ENV)
#XPROTO_ENV	+=
XPROTO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XPROTO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XPROTO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XPROTO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XPROTO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xproto.prepare: $(xproto_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XPROTO_DIR)/config.cache)
	cd $(XPROTO_DIR) && \
		$(XPROTO_PATH) $(XPROTO_ENV) \
		./configure $(XPROTO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xproto_compile: $(STATEDIR)/xproto.compile

xproto_compile_deps = $(STATEDIR)/xproto.prepare

$(STATEDIR)/xproto.compile: $(xproto_compile_deps)
	@$(call targetinfo, $@)
	$(XPROTO_PATH) $(MAKE) -C $(XPROTO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xproto_install: $(STATEDIR)/xproto.install

$(STATEDIR)/xproto.install: $(STATEDIR)/xproto.compile
	@$(call targetinfo, $@)
	rm -rf $(XPROTO_IPKG_TMP)
	$(XPROTO_PATH) $(MAKE) -C $(XPROTO_DIR) DESTDIR=$(XPROTO_IPKG_TMP) install
	@$(call copyincludes, $(XPROTO_IPKG_TMP))
	@$(call copylibraries,$(XPROTO_IPKG_TMP))
	@$(call copymiscfiles,$(XPROTO_IPKG_TMP))
	rm -rf $(XPROTO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xproto_targetinstall: $(STATEDIR)/xproto.targetinstall

xproto_targetinstall_deps = $(STATEDIR)/xproto.compile

$(STATEDIR)/xproto.targetinstall: $(xproto_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XPROTO_PATH) $(MAKE) -C $(XPROTO_DIR) DESTDIR=$(XPROTO_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XPROTO_VERSION)-$(XPROTO_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xproto $(XPROTO_IPKG_TMP)

	@$(call removedevfiles, $(XPROTO_IPKG_TMP))
	@$(call stripfiles, $(XPROTO_IPKG_TMP))
	mkdir -p $(XPROTO_IPKG_TMP)/CONTROL
	echo "Package: xproto" 								 >$(XPROTO_IPKG_TMP)/CONTROL/control
	echo "Source: $(XPROTO_URL)"							>>$(XPROTO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XPROTO_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(XPROTO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(XPROTO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XPROTO_IPKG_TMP)/CONTROL/control
	echo "Version: $(XPROTO_VERSION)-$(XPROTO_VENDOR_VERSION)" 			>>$(XPROTO_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(XPROTO_IPKG_TMP)/CONTROL/control
	echo "Description: X protocol and ancillary headers"				>>$(XPROTO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XPROTO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XPROTO_INSTALL
ROMPACKAGES += $(STATEDIR)/xproto.imageinstall
endif

xproto_imageinstall_deps = $(STATEDIR)/xproto.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xproto.imageinstall: $(xproto_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xproto
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xproto_clean:
	rm -rf $(STATEDIR)/xproto.*
	rm -rf $(XPROTO_DIR)

# vim: syntax=make
