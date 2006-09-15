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
ifdef PTXCONF_GPM
PACKAGES += gpm
endif

#
# Paths and names
#
GPM_VENDOR_VERSION	= 1
GPM_VERSION		= 1.20.1
GPM			= gpm-$(GPM_VERSION)
GPM_SUFFIX		= tar.bz2
GPM_URL			= ftp://arcana.linux.it/pub/gpm/$(GPM).$(GPM_SUFFIX)
GPM_SOURCE		= $(SRCDIR)/$(GPM).$(GPM_SUFFIX)
GPM_DIR			= $(BUILDDIR)/$(GPM)
GPM_IPKG_TMP		= $(GPM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gpm_get: $(STATEDIR)/gpm.get

gpm_get_deps = $(GPM_SOURCE)

$(STATEDIR)/gpm.get: $(gpm_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GPM))
	touch $@

$(GPM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GPM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gpm_extract: $(STATEDIR)/gpm.extract

gpm_extract_deps = $(STATEDIR)/gpm.get

$(STATEDIR)/gpm.extract: $(gpm_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GPM_DIR))
	@$(call extract, $(GPM_SOURCE))
	@$(call patchin, $(GPM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gpm_prepare: $(STATEDIR)/gpm.prepare

#
# dependencies
#
gpm_prepare_deps = \
	$(STATEDIR)/gpm.extract \
	$(STATEDIR)/virtual-xchain.install

GPM_PATH	=  PATH=$(CROSS_PATH)
GPM_ENV 	=  $(CROSS_ENV)
#GPM_ENV	+=
GPM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GPM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GPM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GPM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GPM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gpm.prepare: $(gpm_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GPM_DIR)/config.cache)
	cd $(GPM_DIR) && \
		$(GPM_PATH) $(GPM_ENV) \
		./configure $(GPM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gpm_compile: $(STATEDIR)/gpm.compile

gpm_compile_deps = $(STATEDIR)/gpm.prepare

$(STATEDIR)/gpm.compile: $(gpm_compile_deps)
	@$(call targetinfo, $@)
	$(GPM_PATH) $(MAKE) -C $(GPM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gpm_install: $(STATEDIR)/gpm.install

$(STATEDIR)/gpm.install: $(STATEDIR)/gpm.compile
	@$(call targetinfo, $@)
	$(GPM_PATH) $(MAKE) -C $(GPM_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gpm_targetinstall: $(STATEDIR)/gpm.targetinstall

gpm_targetinstall_deps = $(STATEDIR)/gpm.compile

$(STATEDIR)/gpm.targetinstall: $(gpm_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GPM_PATH) $(MAKE) -C $(GPM_DIR) DESTDIR=$(GPM_IPKG_TMP) install
	mkdir -p $(GPM_IPKG_TMP)/CONTROL
	echo "Package: gpm" 								 >$(GPM_IPKG_TMP)/CONTROL/control
	echo "Source: $(GPM_URL)"						>>$(GPM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPM_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(GPM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPM_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPM_VERSION)-$(GPM_VENDOR_VERSION)" 				>>$(GPM_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(GPM_IPKG_TMP)/CONTROL/control
	echo "Description: gpm means general purpose mouse and is the mouse support for linux in the console." >>$(GPM_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(GPM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GPM_INSTALL
ROMPACKAGES += $(STATEDIR)/gpm.imageinstall
endif

gpm_imageinstall_deps = $(STATEDIR)/gpm.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gpm.imageinstall: $(gpm_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gpm
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gpm_clean:
	rm -rf $(STATEDIR)/gpm.*
	rm -rf $(GPM_DIR)

# vim: syntax=make
