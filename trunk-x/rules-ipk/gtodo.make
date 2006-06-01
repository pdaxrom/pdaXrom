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
ifdef PTXCONF_GTODO
PACKAGES += gtodo
endif

#
# Paths and names
#
GTODO_VENDOR_VERSION	= 1
GTODO_VERSION		= 0.14
GTODO			= gtodo-$(GTODO_VERSION)
GTODO_SUFFIX		= tar.gz
GTODO_URL		= http://download.qballcow.nl/programs/gtodo/$(GTODO).$(GTODO_SUFFIX)
GTODO_SOURCE		= $(SRCDIR)/$(GTODO).$(GTODO_SUFFIX)
GTODO_DIR		= $(BUILDDIR)/$(GTODO)
GTODO_IPKG_TMP		= $(GTODO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gtodo_get: $(STATEDIR)/gtodo.get

gtodo_get_deps = $(GTODO_SOURCE)

$(STATEDIR)/gtodo.get: $(gtodo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GTODO))
	touch $@

$(GTODO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GTODO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gtodo_extract: $(STATEDIR)/gtodo.extract

gtodo_extract_deps = $(STATEDIR)/gtodo.get

$(STATEDIR)/gtodo.extract: $(gtodo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTODO_DIR))
	@$(call extract, $(GTODO_SOURCE))
	@$(call patchin, $(GTODO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gtodo_prepare: $(STATEDIR)/gtodo.prepare

#
# dependencies
#
gtodo_prepare_deps = \
	$(STATEDIR)/gtodo.extract \
	$(STATEDIR)/GConf.install \
	$(STATEDIR)/gnome-vfs.install \
	$(STATEDIR)/virtual-xchain.install

GTODO_PATH	=  PATH=$(CROSS_PATH)
GTODO_ENV 	=  $(CROSS_ENV)
#GTODO_ENV	+=
GTODO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GTODO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GTODO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-schemas-install \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GTODO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GTODO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gtodo.prepare: $(gtodo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTODO_DIR)/config.cache)
	cd $(GTODO_DIR) && \
		$(GTODO_PATH) $(GTODO_ENV) \
		./configure $(GTODO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gtodo_compile: $(STATEDIR)/gtodo.compile

gtodo_compile_deps = $(STATEDIR)/gtodo.prepare

$(STATEDIR)/gtodo.compile: $(gtodo_compile_deps)
	@$(call targetinfo, $@)
	$(GTODO_PATH) $(MAKE) -C $(GTODO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gtodo_install: $(STATEDIR)/gtodo.install

$(STATEDIR)/gtodo.install: $(STATEDIR)/gtodo.compile
	@$(call targetinfo, $@)
	$(GTODO_PATH) $(MAKE) -C $(GTODO_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gtodo_targetinstall: $(STATEDIR)/gtodo.targetinstall

gtodo_targetinstall_deps = $(STATEDIR)/gtodo.compile \
	$(STATEDIR)/GConf.targetinstall \
	$(STATEDIR)/gnome-vfs.targetinstall

$(STATEDIR)/gtodo.targetinstall: $(gtodo_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GTODO_PATH) $(MAKE) -C $(GTODO_DIR) DESTDIR=$(GTODO_IPKG_TMP) install
	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(GTODO_VERSION)-$(GTODO_VENDOR_VERSION) 		\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh gtodo $(GTODO_IPKG_TMP)
	$(CROSSSTRIP) $(GTODO_IPKG_TMP)/usr/bin/*
	rm -rf $(GTODO_IPKG_TMP)/usr/share/locale
	mkdir -p $(GTODO_IPKG_TMP)/CONTROL
	echo "Package: gtodo" 											 >$(GTODO_IPKG_TMP)/CONTROL/control
	echo "Source: $(GTODO_URL)"										>>$(GTODO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(GTODO_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 											>>$(GTODO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(GTODO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(GTODO_IPKG_TMP)/CONTROL/control
	echo "Version: $(GTODO_VERSION)-$(GTODO_VENDOR_VERSION)" 						>>$(GTODO_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libxml2, gconf, gnome-vfs" 							>>$(GTODO_IPKG_TMP)/CONTROL/control
	echo "Description: Todo list manager"									>>$(GTODO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GTODO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GTODO_INSTALL
ROMPACKAGES += $(STATEDIR)/gtodo.imageinstall
endif

gtodo_imageinstall_deps = $(STATEDIR)/gtodo.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gtodo.imageinstall: $(gtodo_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gtodo
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gtodo_clean:
	rm -rf $(STATEDIR)/gtodo.*
	rm -rf $(GTODO_DIR)

# vim: syntax=make
