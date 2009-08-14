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
ifdef PTXCONF_PYGOBJECT
PACKAGES += pygobject
endif

#
# Paths and names
#
PYGOBJECT_VENDOR_VERSION	= 1
PYGOBJECT_VERSION		= 2.11.2
PYGOBJECT			= pygobject-$(PYGOBJECT_VERSION)
PYGOBJECT_SUFFIX		= tar.bz2
PYGOBJECT_URL			= http://ftp.acc.umu.se/pub/gnome/sources/pygobject/2.11/$(PYGOBJECT).$(PYGOBJECT_SUFFIX)
PYGOBJECT_SOURCE		= $(SRCDIR)/$(PYGOBJECT).$(PYGOBJECT_SUFFIX)
PYGOBJECT_DIR			= $(BUILDDIR)/$(PYGOBJECT)
PYGOBJECT_IPKG_TMP		= $(PYGOBJECT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pygobject_get: $(STATEDIR)/pygobject.get

pygobject_get_deps = $(PYGOBJECT_SOURCE)

$(STATEDIR)/pygobject.get: $(pygobject_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PYGOBJECT))
	touch $@

$(PYGOBJECT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PYGOBJECT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pygobject_extract: $(STATEDIR)/pygobject.extract

pygobject_extract_deps = $(STATEDIR)/pygobject.get

$(STATEDIR)/pygobject.extract: $(pygobject_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYGOBJECT_DIR))
	@$(call extract, $(PYGOBJECT_SOURCE))
	@$(call patchin, $(PYGOBJECT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pygobject_prepare: $(STATEDIR)/pygobject.prepare

#
# dependencies
#
pygobject_prepare_deps = \
	$(STATEDIR)/pygobject.extract \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/python.install \
	$(STATEDIR)/xchain-python.install \
	$(STATEDIR)/virtual-xchain.install

PYGOBJECT_PATH	=  PATH=$(CROSS_PATH)
PYGOBJECT_ENV 	=  $(CROSS_ENV)
#PYGOBJECT_ENV	+=
PYGOBJECT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PYGOBJECT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PYGOBJECT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-shared \
	--disable-static \
	--libexecdir=/usr/bin \
	--disable-debug \
	--disable-docs

ifdef PTXCONF_XFREE430
PYGOBJECT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PYGOBJECT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pygobject.prepare: $(pygobject_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYGOBJECT_DIR)/config.cache)
	cd $(PYGOBJECT_DIR) && \
		$(PYGOBJECT_PATH) $(PYGOBJECT_ENV) \
		./configure $(PYGOBJECT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pygobject_compile: $(STATEDIR)/pygobject.compile

pygobject_compile_deps = $(STATEDIR)/pygobject.prepare

$(STATEDIR)/pygobject.compile: $(pygobject_compile_deps)
	@$(call targetinfo, $@)
	$(PYGOBJECT_PATH) $(MAKE) -C $(PYGOBJECT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pygobject_install: $(STATEDIR)/pygobject.install

$(STATEDIR)/pygobject.install: $(STATEDIR)/pygobject.compile
	@$(call targetinfo, $@)
	rm -rf $(PYGOBJECT_IPKG_TMP)
	$(PYGOBJECT_PATH) $(MAKE) -C $(PYGOBJECT_DIR) DESTDIR=$(PYGOBJECT_IPKG_TMP) install
	@$(call copyincludes, $(PYGOBJECT_IPKG_TMP))
	@$(call copylibraries,$(PYGOBJECT_IPKG_TMP))
	@$(call copymiscfiles,$(PYGOBJECT_IPKG_TMP))
	rm -rf $(PYGOBJECT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pygobject_targetinstall: $(STATEDIR)/pygobject.targetinstall

pygobject_targetinstall_deps = $(STATEDIR)/pygobject.compile \
	$(STATEDIR)/glib22.targetinstall \
	$(STATEDIR)/python.targetinstall

$(STATEDIR)/pygobject.targetinstall: $(pygobject_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PYGOBJECT_PATH) $(MAKE) -C $(PYGOBJECT_DIR) DESTDIR=$(PYGOBJECT_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(PYGOBJECT_VERSION)-$(PYGOBJECT_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh pygobject $(PYGOBJECT_IPKG_TMP)

	@$(call removedevfiles, $(PYGOBJECT_IPKG_TMP))
	@$(call stripfiles, $(PYGOBJECT_IPKG_TMP))
	mkdir -p $(PYGOBJECT_IPKG_TMP)/CONTROL
	echo "Package: pygobject" 							 >$(PYGOBJECT_IPKG_TMP)/CONTROL/control
	echo "Source: $(PYGOBJECT_URL)"							>>$(PYGOBJECT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PYGOBJECT_IPKG_TMP)/CONTROL/control
	echo "Section: ROX" 								>>$(PYGOBJECT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PYGOBJECT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PYGOBJECT_IPKG_TMP)/CONTROL/control
	echo "Version: $(PYGOBJECT_VERSION)-$(PYGOBJECT_VENDOR_VERSION)" 		>>$(PYGOBJECT_IPKG_TMP)/CONTROL/control
	echo "Depends: glib2"	 							>>$(PYGOBJECT_IPKG_TMP)/CONTROL/control
	echo "Description: python glib binding"						>>$(PYGOBJECT_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(PYGOBJECT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PYGOBJECT_INSTALL
ROMPACKAGES += $(STATEDIR)/pygobject.imageinstall
endif

pygobject_imageinstall_deps = $(STATEDIR)/pygobject.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pygobject.imageinstall: $(pygobject_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pygobject
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pygobject_clean:
	rm -rf $(STATEDIR)/pygobject.*
	rm -rf $(PYGOBJECT_DIR)

# vim: syntax=make
