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
ifdef PTXCONF_LIBBONOBO
PACKAGES += libbonobo
endif

#
# Paths and names
#
LIBBONOBO_VENDOR_VERSION	= 1
LIBBONOBO_VERSION		= 2.15.3
LIBBONOBO			= libbonobo-$(LIBBONOBO_VERSION)
LIBBONOBO_SUFFIX		= tar.bz2
LIBBONOBO_URL			= http://ftp.acc.umu.se/pub/gnome/sources/libbonobo/2.15/$(LIBBONOBO).$(LIBBONOBO_SUFFIX)
LIBBONOBO_SOURCE		= $(SRCDIR)/$(LIBBONOBO).$(LIBBONOBO_SUFFIX)
LIBBONOBO_DIR			= $(BUILDDIR)/$(LIBBONOBO)
LIBBONOBO_IPKG_TMP		= $(LIBBONOBO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libbonobo_get: $(STATEDIR)/libbonobo.get

libbonobo_get_deps = $(LIBBONOBO_SOURCE)

$(STATEDIR)/libbonobo.get: $(libbonobo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBBONOBO))
	touch $@

$(LIBBONOBO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBBONOBO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libbonobo_extract: $(STATEDIR)/libbonobo.extract

libbonobo_extract_deps = $(STATEDIR)/libbonobo.get

$(STATEDIR)/libbonobo.extract: $(libbonobo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBBONOBO_DIR))
	@$(call extract, $(LIBBONOBO_SOURCE))
	@$(call patchin, $(LIBBONOBO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libbonobo_prepare: $(STATEDIR)/libbonobo.prepare

#
# dependencies
#
libbonobo_prepare_deps = \
	$(STATEDIR)/libbonobo.extract \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/ORBit2.install \
	$(STATEDIR)/virtual-xchain.install

LIBBONOBO_PATH	=  PATH=$(CROSS_PATH)
LIBBONOBO_ENV 	=  $(CROSS_ENV)
LIBBONOBO_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBBONOBO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBBONOBO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBBONOBO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-shared \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
LIBBONOBO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBBONOBO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libbonobo.prepare: $(libbonobo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBBONOBO_DIR)/config.cache)
	cd $(LIBBONOBO_DIR) && \
		$(LIBBONOBO_PATH) $(LIBBONOBO_ENV) \
		./configure $(LIBBONOBO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libbonobo_compile: $(STATEDIR)/libbonobo.compile

libbonobo_compile_deps = $(STATEDIR)/libbonobo.prepare

$(STATEDIR)/libbonobo.compile: $(libbonobo_compile_deps)
	@$(call targetinfo, $@)
	$(LIBBONOBO_PATH) $(MAKE) -C $(LIBBONOBO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libbonobo_install: $(STATEDIR)/libbonobo.install

$(STATEDIR)/libbonobo.install: $(STATEDIR)/libbonobo.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBBONOBO_IPKG_TMP)
	$(LIBBONOBO_PATH) $(MAKE) -C $(LIBBONOBO_DIR) DESTDIR=$(LIBBONOBO_IPKG_TMP) install
	@$(call copyincludes, $(LIBBONOBO_IPKG_TMP))
	@$(call copylibraries,$(LIBBONOBO_IPKG_TMP))
	@$(call copymiscfiles,$(LIBBONOBO_IPKG_TMP))
	rm -rf $(LIBBONOBO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libbonobo_targetinstall: $(STATEDIR)/libbonobo.targetinstall

libbonobo_targetinstall_deps = $(STATEDIR)/libbonobo.compile \
	$(STATEDIR)/glib22.targetinstall \
	$(STATEDIR)/ORBit2.targetinstall

$(STATEDIR)/libbonobo.targetinstall: $(libbonobo_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBBONOBO_PATH) $(MAKE) -C $(LIBBONOBO_DIR) DESTDIR=$(LIBBONOBO_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LIBBONOBO_VERSION)-$(LIBBONOBO_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh libbonobo $(LIBBONOBO_IPKG_TMP)

	@$(call removedevfiles, $(LIBBONOBO_IPKG_TMP))
	@$(call stripfiles, $(LIBBONOBO_IPKG_TMP))
	mkdir -p $(LIBBONOBO_IPKG_TMP)/CONTROL
	echo "Package: libbonobo" 							 >$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBBONOBO_URL)"							>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome" 								>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBBONOBO_VERSION)-$(LIBBONOBO_VENDOR_VERSION)" 		>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, orbit2" 							>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Description: Bonobo is a set of language and system independant CORBA interfaces for creating reusable components, controls and creating compound documents.">>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBBONOBO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBBONOBO_INSTALL
ROMPACKAGES += $(STATEDIR)/libbonobo.imageinstall
endif

libbonobo_imageinstall_deps = $(STATEDIR)/libbonobo.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libbonobo.imageinstall: $(libbonobo_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libbonobo
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libbonobo_clean:
	rm -rf $(STATEDIR)/libbonobo.*
	rm -rf $(LIBBONOBO_DIR)

# vim: syntax=make
