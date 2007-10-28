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
ifdef PTXCONF_PWLIB
PACKAGES += pwlib
endif

#
# Paths and names
#
PWLIB_VENDOR_VERSION	= 1
PWLIB_VERSION		= 1.10.1
PWLIB			= pwlib-$(PWLIB_VERSION)
PWLIB_SUFFIX		= tar.gz
PWLIB_URL		= http://www.ekiga.org/admin/downloads/latest/sources/sources/$(PWLIB).$(PWLIB_SUFFIX)
PWLIB_SOURCE		= $(SRCDIR)/$(PWLIB).$(PWLIB_SUFFIX)
PWLIB_DIR		= $(BUILDDIR)/$(PWLIB)
PWLIB_IPKG_TMP		= $(PWLIB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pwlib_get: $(STATEDIR)/pwlib.get

pwlib_get_deps = $(PWLIB_SOURCE)

$(STATEDIR)/pwlib.get: $(pwlib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PWLIB))
	touch $@

$(PWLIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PWLIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pwlib_extract: $(STATEDIR)/pwlib.extract

pwlib_extract_deps = $(STATEDIR)/pwlib.get

$(STATEDIR)/pwlib.extract: $(pwlib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PWLIB_DIR))
	@$(call extract, $(PWLIB_SOURCE))
	@$(call patchin, $(PWLIB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pwlib_prepare: $(STATEDIR)/pwlib.prepare

#
# dependencies
#
pwlib_prepare_deps = \
	$(STATEDIR)/pwlib.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/openldap.install \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/virtual-xchain.install

PWLIB_PATH	=  PATH=$(CROSS_PATH)
PWLIB_ENV 	=  $(CROSS_ENV)
#PWLIB_ENV	+=
PWLIB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PWLIB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PWLIB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-plugins \
	--enable-opal \
	--enable-openh323

#	--disable-openldap

ifdef PTXCONF_XFREE430
PWLIB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PWLIB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pwlib.prepare: $(pwlib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PWLIB_DIR)/config.cache)
	cd $(PWLIB_DIR) && \
		$(PWLIB_PATH) $(PWLIB_ENV) \
		./configure $(PWLIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pwlib_compile: $(STATEDIR)/pwlib.compile

pwlib_compile_deps = $(STATEDIR)/pwlib.prepare

$(STATEDIR)/pwlib.compile: $(pwlib_compile_deps)
	@$(call targetinfo, $@)
	$(PWLIB_PATH) $(MAKE) -C $(PWLIB_DIR) $(CROSS_ENV_CC) $(CROSS_ENV_CXX)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pwlib_install: $(STATEDIR)/pwlib.install

$(STATEDIR)/pwlib.install: $(STATEDIR)/pwlib.compile
	@$(call targetinfo, $@)
	rm -rf $(PWLIB_IPKG_TMP)
	$(PWLIB_PATH) $(MAKE) -C $(PWLIB_DIR) DESTDIR=$(PWLIB_IPKG_TMP) install
	@$(call copyincludes, $(PWLIB_IPKG_TMP))
	@$(call copylibraries,$(PWLIB_IPKG_TMP))
	@$(call copymiscfiles,$(PWLIB_IPKG_TMP))
	rm -rf $(PWLIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pwlib_targetinstall: $(STATEDIR)/pwlib.targetinstall

pwlib_targetinstall_deps = $(STATEDIR)/pwlib.compile \
	$(STATEDIR)/openldap.targetinstall \
	$(STATEDIR)/SDL.targetinstall \
	$(STATEDIR)/openssl.targetinstall

$(STATEDIR)/pwlib.targetinstall: $(pwlib_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PWLIB_PATH) $(MAKE) -C $(PWLIB_DIR) DESTDIR=$(PWLIB_IPKG_TMP) install

	chmod 644 $(PWLIB_IPKG_TMP)/usr/lib/*.so*
	chmod 644 $(PWLIB_IPKG_TMP)/usr/lib/pwlib/devices/sound/*.so*
	chmod 644 $(PWLIB_IPKG_TMP)/usr/lib/pwlib/devices/videoinput/*.so*

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(PWLIB_VERSION)-$(PWLIB_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh pwlib $(PWLIB_IPKG_TMP)

	@$(call removedevfiles, $(PWLIB_IPKG_TMP))
	@$(call stripfiles, $(PWLIB_IPKG_TMP))
	mkdir -p $(PWLIB_IPKG_TMP)/CONTROL
	echo "Package: pwlib" 								 >$(PWLIB_IPKG_TMP)/CONTROL/control
	echo "Source: $(PWLIB_URL)"							>>$(PWLIB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PWLIB_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(PWLIB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PWLIB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PWLIB_IPKG_TMP)/CONTROL/control
	echo "Version: $(PWLIB_VERSION)-$(PWLIB_VENDOR_VERSION)" 			>>$(PWLIB_IPKG_TMP)/CONTROL/control
	echo "Depends: openssl, openldap, sdl" 						>>$(PWLIB_IPKG_TMP)/CONTROL/control
	echo "Description: Portable Windows Libary"					>>$(PWLIB_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(PWLIB_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PWLIB_INSTALL
ROMPACKAGES += $(STATEDIR)/pwlib.imageinstall
endif

pwlib_imageinstall_deps = $(STATEDIR)/pwlib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pwlib.imageinstall: $(pwlib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pwlib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pwlib_clean:
	rm -rf $(STATEDIR)/pwlib.*
	rm -rf $(PWLIB_DIR)

# vim: syntax=make
