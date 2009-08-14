# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_SIEFS
PACKAGES += siefs
endif

#
# Paths and names
#
SIEFS_VENDOR_VERSION	= 1
SIEFS_VERSION		= 0.5
SIEFS			= siefs-$(SIEFS_VERSION)
SIEFS_SUFFIX		= tar.gz
SIEFS_URL		= http://chaos.allsiemens.com/download/$(SIEFS).$(SIEFS_SUFFIX)
SIEFS_SOURCE		= $(SRCDIR)/$(SIEFS).$(SIEFS_SUFFIX)
SIEFS_DIR		= $(BUILDDIR)/$(SIEFS)
SIEFS_IPKG_TMP		= $(SIEFS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

siefs_get: $(STATEDIR)/siefs.get

siefs_get_deps = $(SIEFS_SOURCE)

$(STATEDIR)/siefs.get: $(siefs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SIEFS))
	touch $@

$(SIEFS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SIEFS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

siefs_extract: $(STATEDIR)/siefs.extract

siefs_extract_deps = $(STATEDIR)/siefs.get

$(STATEDIR)/siefs.extract: $(siefs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SIEFS_DIR))
	@$(call extract, $(SIEFS_SOURCE))
	@$(call patchin, $(SIEFS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

siefs_prepare: $(STATEDIR)/siefs.prepare

#
# dependencies
#
siefs_prepare_deps = \
	$(STATEDIR)/siefs.extract \
	$(STATEDIR)/fuse.install \
	$(STATEDIR)/virtual-xchain.install

SIEFS_PATH	=  PATH=$(CROSS_PATH)
SIEFS_ENV 	=  $(CROSS_ENV)
#SIEFS_ENV	+=
SIEFS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SIEFS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SIEFS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--with-fuse=$(CROSS_LIB_DIR)

ifdef PTXCONF_XFREE430
SIEFS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SIEFS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/siefs.prepare: $(siefs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SIEFS_DIR)/config.cache)
	cd $(SIEFS_DIR) && \
		$(SIEFS_PATH) $(SIEFS_ENV) \
		./configure $(SIEFS_AUTOCONF)
	sed -i "s/FUSEINST.*/FUSEINST \"\/usr\"/" $(SIEFS_DIR)/config.h
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

siefs_compile: $(STATEDIR)/siefs.compile

siefs_compile_deps = $(STATEDIR)/siefs.prepare

$(STATEDIR)/siefs.compile: $(siefs_compile_deps)
	@$(call targetinfo, $@)
	$(SIEFS_PATH) $(MAKE) -C $(SIEFS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

siefs_install: $(STATEDIR)/siefs.install

$(STATEDIR)/siefs.install: $(STATEDIR)/siefs.compile
	@$(call targetinfo, $@)
	rm -rf $(SIEFS_IPKG_TMP)
	$(SIEFS_PATH) $(MAKE) -C $(SIEFS_DIR) DESTDIR=$(SIEFS_IPKG_TMP) install
	@$(call copyincludes, $(SIEFS_IPKG_TMP))
	@$(call copylibraries,$(SIEFS_IPKG_TMP))
	@$(call copymiscfiles,$(SIEFS_IPKG_TMP))
	rm -rf $(SIEFS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

siefs_targetinstall: $(STATEDIR)/siefs.targetinstall

siefs_targetinstall_deps = $(STATEDIR)/siefs.compile \
	$(STATEDIR)/fuse.targetinstall

SIEFS_DEPLIST = 

$(STATEDIR)/siefs.targetinstall: $(siefs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SIEFS_PATH) $(MAKE) -C $(SIEFS_DIR) DESTDIR=$(SIEFS_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(SIEFS_VERSION)-$(SIEFS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh siefs $(SIEFS_IPKG_TMP)

	@$(call removedevfiles, $(SIEFS_IPKG_TMP))
	@$(call stripfiles, $(SIEFS_IPKG_TMP))
	mkdir -p $(SIEFS_IPKG_TMP)/CONTROL
	echo "Package: siefs" 								 >$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Source: $(SIEFS_URL)"							>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Version: $(SIEFS_VERSION)-$(SIEFS_VENDOR_VERSION)" 			>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(SIEFS_DEPLIST)" 						>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Description: SieFS is a virtual filesystem for accessing Siemens mobile phones' memory (flexmem or MultiMediaCard) from Linux." >>$(SIEFS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(SIEFS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SIEFS_INSTALL
ROMPACKAGES += $(STATEDIR)/siefs.imageinstall
endif

siefs_imageinstall_deps = $(STATEDIR)/siefs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/siefs.imageinstall: $(siefs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install siefs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

siefs_clean:
	rm -rf $(STATEDIR)/siefs.*
	rm -rf $(SIEFS_DIR)

# vim: syntax=make
