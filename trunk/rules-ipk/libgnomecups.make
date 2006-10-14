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
ifdef PTXCONF_LIBGNOMECUPS
PACKAGES += libgnomecups
endif

#
# Paths and names
#
LIBGNOMECUPS_VENDOR_VERSION	= 1
LIBGNOMECUPS_VERSION		= 0.2.2
LIBGNOMECUPS			= libgnomecups-$(LIBGNOMECUPS_VERSION)
LIBGNOMECUPS_SUFFIX		= tar.bz2
LIBGNOMECUPS_URL		= ftp://ftp.acc.umu.se/pub/GNOME/sources/libgnomecups/0.2/$(LIBGNOMECUPS).$(LIBGNOMECUPS_SUFFIX)
LIBGNOMECUPS_SOURCE		= $(SRCDIR)/$(LIBGNOMECUPS).$(LIBGNOMECUPS_SUFFIX)
LIBGNOMECUPS_DIR		= $(BUILDDIR)/$(LIBGNOMECUPS)
LIBGNOMECUPS_IPKG_TMP		= $(LIBGNOMECUPS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libgnomecups_get: $(STATEDIR)/libgnomecups.get

libgnomecups_get_deps = $(LIBGNOMECUPS_SOURCE)

$(STATEDIR)/libgnomecups.get: $(libgnomecups_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBGNOMECUPS))
	touch $@

$(LIBGNOMECUPS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBGNOMECUPS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libgnomecups_extract: $(STATEDIR)/libgnomecups.extract

libgnomecups_extract_deps = $(STATEDIR)/libgnomecups.get

$(STATEDIR)/libgnomecups.extract: $(libgnomecups_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOMECUPS_DIR))
	@$(call extract, $(LIBGNOMECUPS_SOURCE))
	@$(call patchin, $(LIBGNOMECUPS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libgnomecups_prepare: $(STATEDIR)/libgnomecups.prepare

#
# dependencies
#
libgnomecups_prepare_deps = \
	$(STATEDIR)/libgnomecups.extract \
	$(STATEDIR)/cups.install \
	$(STATEDIR)/virtual-xchain.install

LIBGNOMECUPS_PATH	=  PATH=$(CROSS_PATH)
LIBGNOMECUPS_ENV 	=  $(CROSS_ENV)
#LIBGNOMECUPS_ENV	+=
LIBGNOMECUPS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBGNOMECUPS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBGNOMECUPS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
LIBGNOMECUPS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBGNOMECUPS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libgnomecups.prepare: $(libgnomecups_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOMECUPS_DIR)/config.cache)
	cd $(LIBGNOMECUPS_DIR) && \
		$(LIBGNOMECUPS_PATH) $(LIBGNOMECUPS_ENV) \
		./configure $(LIBGNOMECUPS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libgnomecups_compile: $(STATEDIR)/libgnomecups.compile

libgnomecups_compile_deps = $(STATEDIR)/libgnomecups.prepare

$(STATEDIR)/libgnomecups.compile: $(libgnomecups_compile_deps)
	@$(call targetinfo, $@)
	$(LIBGNOMECUPS_PATH) $(MAKE) -C $(LIBGNOMECUPS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libgnomecups_install: $(STATEDIR)/libgnomecups.install

$(STATEDIR)/libgnomecups.install: $(STATEDIR)/libgnomecups.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBGNOMECUPS_IPKG_TMP)
	$(LIBGNOMECUPS_PATH) $(MAKE) -C $(LIBGNOMECUPS_DIR) DESTDIR=$(LIBGNOMECUPS_IPKG_TMP) install
	@$(call copyincludes, $(LIBGNOMECUPS_IPKG_TMP))
	@$(call copylibraries,$(LIBGNOMECUPS_IPKG_TMP))
	@$(call copymiscfiles,$(LIBGNOMECUPS_IPKG_TMP))
	rm -rf $(LIBGNOMECUPS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libgnomecups_targetinstall: $(STATEDIR)/libgnomecups.targetinstall

libgnomecups_targetinstall_deps = $(STATEDIR)/libgnomecups.compile \
	$(STATEDIR)/cups.targetinstall

LIBGNOMECUPS_DEPLIST = 

$(STATEDIR)/libgnomecups.targetinstall: $(libgnomecups_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBGNOMECUPS_PATH) $(MAKE) -C $(LIBGNOMECUPS_DIR) DESTDIR=$(LIBGNOMECUPS_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LIBGNOMECUPS_VERSION)-$(LIBGNOMECUPS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh libgnomecups $(LIBGNOMECUPS_IPKG_TMP)

	@$(call removedevfiles, $(LIBGNOMECUPS_IPKG_TMP))
	@$(call stripfiles, $(LIBGNOMECUPS_IPKG_TMP))
	mkdir -p $(LIBGNOMECUPS_IPKG_TMP)/CONTROL
	echo "Package: libgnomecups" 								 >$(LIBGNOMECUPS_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBGNOMECUPS_URL)"							>>$(LIBGNOMECUPS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(LIBGNOMECUPS_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome" 									>>$(LIBGNOMECUPS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(LIBGNOMECUPS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(LIBGNOMECUPS_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBGNOMECUPS_VERSION)-$(LIBGNOMECUPS_VENDOR_VERSION)" 			>>$(LIBGNOMECUPS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(LIBGNOMECUPS_DEPLIST)" 						>>$(LIBGNOMECUPS_IPKG_TMP)/CONTROL/control
	echo "Description: Gnome cups support"							>>$(LIBGNOMECUPS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LIBGNOMECUPS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBGNOMECUPS_INSTALL
ROMPACKAGES += $(STATEDIR)/libgnomecups.imageinstall
endif

libgnomecups_imageinstall_deps = $(STATEDIR)/libgnomecups.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libgnomecups.imageinstall: $(libgnomecups_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libgnomecups
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libgnomecups_clean:
	rm -rf $(STATEDIR)/libgnomecups.*
	rm -rf $(LIBGNOMECUPS_DIR)

# vim: syntax=make
