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
ifdef PTXCONF_DBUS-GLIB
PACKAGES += dbus-glib
endif

#
# Paths and names
#
DBUS-GLIB_VENDOR_VERSION	= 1
DBUS-GLIB_VERSION		= 0.71
DBUS-GLIB			= dbus-glib-$(DBUS-GLIB_VERSION)
DBUS-GLIB_SUFFIX		= tar.gz
DBUS-GLIB_URL			= http://dbus.freedesktop.org/releases/$(DBUS-GLIB).$(DBUS-GLIB_SUFFIX)
DBUS-GLIB_SOURCE		= $(SRCDIR)/$(DBUS-GLIB).$(DBUS-GLIB_SUFFIX)
DBUS-GLIB_DIR			= $(BUILDDIR)/$(DBUS-GLIB)
DBUS-GLIB_IPKG_TMP		= $(DBUS-GLIB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dbus-glib_get: $(STATEDIR)/dbus-glib.get

dbus-glib_get_deps = $(DBUS-GLIB_SOURCE)

$(STATEDIR)/dbus-glib.get: $(dbus-glib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DBUS-GLIB))
	touch $@

$(DBUS-GLIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DBUS-GLIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dbus-glib_extract: $(STATEDIR)/dbus-glib.extract

dbus-glib_extract_deps = $(STATEDIR)/dbus-glib.get

$(STATEDIR)/dbus-glib.extract: $(dbus-glib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DBUS-GLIB_DIR))
	@$(call extract, $(DBUS-GLIB_SOURCE))
	@$(call patchin, $(DBUS-GLIB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dbus-glib_prepare: $(STATEDIR)/dbus-glib.prepare

#
# dependencies
#
dbus-glib_prepare_deps = \
	$(STATEDIR)/dbus-glib.extract \
	$(STATEDIR)/dbus.install \
	$(STATEDIR)/virtual-xchain.install

DBUS-GLIB_PATH	=  PATH=$(CROSS_PATH)
DBUS-GLIB_ENV 	=  $(CROSS_ENV)
#DBUS-GLIB_ENV	+=
DBUS-GLIB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DBUS-GLIB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
DBUS-GLIB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
DBUS-GLIB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DBUS-GLIB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dbus-glib.prepare: $(dbus-glib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DBUS-GLIB_DIR)/config.cache)
	cd $(DBUS-GLIB_DIR) && \
		$(DBUS-GLIB_PATH) $(DBUS-GLIB_ENV) \
		./configure $(DBUS-GLIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dbus-glib_compile: $(STATEDIR)/dbus-glib.compile

dbus-glib_compile_deps = $(STATEDIR)/dbus-glib.prepare

$(STATEDIR)/dbus-glib.compile: $(dbus-glib_compile_deps)
	@$(call targetinfo, $@)
	$(DBUS-GLIB_PATH) $(MAKE) -C $(DBUS-GLIB_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dbus-glib_install: $(STATEDIR)/dbus-glib.install

$(STATEDIR)/dbus-glib.install: $(STATEDIR)/dbus-glib.compile
	@$(call targetinfo, $@)
	rm -rf $(DBUS-GLIB_IPKG_TMP)
	$(DBUS-GLIB_PATH) $(MAKE) -C $(DBUS-GLIB_DIR) DESTDIR=$(DBUS-GLIB_IPKG_TMP) install
	@$(call copyincludes, $(DBUS-GLIB_IPKG_TMP))
	@$(call copylibraries,$(DBUS-GLIB_IPKG_TMP))
	@$(call copymiscfiles,$(DBUS-GLIB_IPKG_TMP))
	rm -rf $(DBUS-GLIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dbus-glib_targetinstall: $(STATEDIR)/dbus-glib.targetinstall

dbus-glib_targetinstall_deps = $(STATEDIR)/dbus-glib.compile \
	$(STATEDIR)/dbus.targetinstall

$(STATEDIR)/dbus-glib.targetinstall: $(dbus-glib_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DBUS-GLIB_PATH) $(MAKE) -C $(DBUS-GLIB_DIR) DESTDIR=$(DBUS-GLIB_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(DBUS-GLIB_VERSION)-$(DBUS-GLIB_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh dbus-glib $(DBUS-GLIB_IPKG_TMP)

	@$(call removedevfiles, $(DBUS-GLIB_IPKG_TMP))
	@$(call stripfiles, $(DBUS-GLIB_IPKG_TMP))
	mkdir -p $(DBUS-GLIB_IPKG_TMP)/CONTROL
	echo "Package: dbus-glib" 							 >$(DBUS-GLIB_IPKG_TMP)/CONTROL/control
	echo "Source: $(DBUS-GLIB_URL)"							>>$(DBUS-GLIB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DBUS-GLIB_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(DBUS-GLIB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DBUS-GLIB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DBUS-GLIB_IPKG_TMP)/CONTROL/control
	echo "Version: $(DBUS-GLIB_VERSION)-$(DBUS-GLIB_VENDOR_VERSION)" 		>>$(DBUS-GLIB_IPKG_TMP)/CONTROL/control
	echo "Depends: dbus" 								>>$(DBUS-GLIB_IPKG_TMP)/CONTROL/control
	echo "Description: glib dbus binding"						>>$(DBUS-GLIB_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DBUS-GLIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DBUS-GLIB_INSTALL
ROMPACKAGES += $(STATEDIR)/dbus-glib.imageinstall
endif

dbus-glib_imageinstall_deps = $(STATEDIR)/dbus-glib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dbus-glib.imageinstall: $(dbus-glib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dbus-glib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dbus-glib_clean:
	rm -rf $(STATEDIR)/dbus-glib.*
	rm -rf $(DBUS-GLIB_DIR)

# vim: syntax=make
