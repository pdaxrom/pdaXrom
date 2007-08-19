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
ifdef PTXCONF_EKIGA
PACKAGES += ekiga
endif

#
# Paths and names
#
EKIGA_VENDOR_VERSION	= 1
EKIGA_VERSION		= 2.0.2
EKIGA			= ekiga-$(EKIGA_VERSION)
EKIGA_SUFFIX		= tar.gz
EKIGA_URL		= http://www.ekiga.org/admin/downloads/latest/sources/sources/$(EKIGA).$(EKIGA_SUFFIX)
EKIGA_SOURCE		= $(SRCDIR)/$(EKIGA).$(EKIGA_SUFFIX)
EKIGA_DIR		= $(BUILDDIR)/$(EKIGA)
EKIGA_IPKG_TMP		= $(EKIGA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ekiga_get: $(STATEDIR)/ekiga.get

ekiga_get_deps = $(EKIGA_SOURCE)

$(STATEDIR)/ekiga.get: $(ekiga_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(EKIGA))
	touch $@

$(EKIGA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(EKIGA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ekiga_extract: $(STATEDIR)/ekiga.extract

ekiga_extract_deps = $(STATEDIR)/ekiga.get

$(STATEDIR)/ekiga.extract: $(ekiga_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EKIGA_DIR))
	@$(call extract, $(EKIGA_SOURCE))
	@$(call patchin, $(EKIGA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ekiga_prepare: $(STATEDIR)/ekiga.prepare

#
# dependencies
#
ekiga_prepare_deps = \
	$(STATEDIR)/ekiga.extract \
	$(STATEDIR)/pwlib.install \
	$(STATEDIR)/opal.install \
	$(STATEDIR)/evolution-data-server.install \
	$(STATEDIR)/virtual-xchain.install

EKIGA_PATH	=  PATH=$(CROSS_PATH)
EKIGA_ENV 	=  $(CROSS_ENV)
#EKIGA_ENV	+=
EKIGA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#EKIGA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
EKIGA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-doc \
	--disable-scrollkeeper \
	--with-pwlib-dir=$(PWLIB_DIR) \
	--with-opal-dir=$(OPAL_DIR) \
	--disable-avahi \
	--disable-gnome

##	--disable-schemas-install

ifdef PTXCONF_XFREE430
EKIGA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
EKIGA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ekiga.prepare: $(ekiga_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EKIGA_DIR)/config.cache)
	cd $(EKIGA_DIR) && \
		$(EKIGA_PATH) $(EKIGA_ENV) \
		./configure $(EKIGA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ekiga_compile: $(STATEDIR)/ekiga.compile

ekiga_compile_deps = $(STATEDIR)/ekiga.prepare

$(STATEDIR)/ekiga.compile: $(ekiga_compile_deps)
	@$(call targetinfo, $@)
	$(EKIGA_PATH) $(MAKE) -C $(EKIGA_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ekiga_install: $(STATEDIR)/ekiga.install

$(STATEDIR)/ekiga.install: $(STATEDIR)/ekiga.compile
	@$(call targetinfo, $@)
	#rm -rf $(EKIGA_IPKG_TMP)
	#$(EKIGA_PATH) $(MAKE) -C $(EKIGA_DIR) DESTDIR=$(EKIGA_IPKG_TMP) install
	#@$(call copyincludes, $(EKIGA_IPKG_TMP))
	#@$(call copylibraries,$(EKIGA_IPKG_TMP))
	#@$(call copymiscfiles,$(EKIGA_IPKG_TMP))
	#rm -rf $(EKIGA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ekiga_targetinstall: $(STATEDIR)/ekiga.targetinstall

ekiga_targetinstall_deps = $(STATEDIR)/ekiga.compile \
	$(STATEDIR)/pwlib.targetinstall \
	$(STATEDIR)/evolution-data-server.targetinstall \
	$(STATEDIR)/opal.targetinstall

$(STATEDIR)/ekiga.targetinstall: $(ekiga_targetinstall_deps)
	@$(call targetinfo, $@)
	$(EKIGA_PATH) $(MAKE) -C $(EKIGA_DIR) DESTDIR=$(EKIGA_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(EKIGA_VERSION)-$(EKIGA_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh ekiga $(EKIGA_IPKG_TMP)

	@$(call removedevfiles, $(EKIGA_IPKG_TMP))
	@$(call stripfiles, $(EKIGA_IPKG_TMP))
	mkdir -p $(EKIGA_IPKG_TMP)/CONTROL
	echo "Package: ekiga" 								 >$(EKIGA_IPKG_TMP)/CONTROL/control
	echo "Source: $(EKIGA_URL)"							>>$(EKIGA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(EKIGA_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(EKIGA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(EKIGA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(EKIGA_IPKG_TMP)/CONTROL/control
	echo "Version: $(EKIGA_VERSION)-$(EKIGA_VENDOR_VERSION)" 			>>$(EKIGA_IPKG_TMP)/CONTROL/control
	echo "Depends: opal, pwlib, openldap, evolution-data-server" 			>>$(EKIGA_IPKG_TMP)/CONTROL/control
	echo "Description: Ekiga (formely known as GnomeMeeting) is an open source VoIP and video conferencing application for GNOME." >>$(EKIGA_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(EKIGA_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_EKIGA_INSTALL
ROMPACKAGES += $(STATEDIR)/ekiga.imageinstall
endif

ekiga_imageinstall_deps = $(STATEDIR)/ekiga.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ekiga.imageinstall: $(ekiga_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ekiga
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ekiga_clean:
	rm -rf $(STATEDIR)/ekiga.*
	rm -rf $(EKIGA_DIR)

# vim: syntax=make
