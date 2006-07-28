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
ifdef PTXCONF_SUBVERSION
PACKAGES += subversion
endif

#
# Paths and names
#
SUBVERSION_VENDOR_VERSION	= 1
SUBVERSION_VERSION		= 1.3.1
SUBVERSION			= subversion-$(SUBVERSION_VERSION)
SUBVERSION_SUFFIX		= tar.bz2
SUBVERSION_URL			= http://subversion.tigris.org/downloads/$(SUBVERSION).$(SUBVERSION_SUFFIX)
SUBVERSION_SOURCE		= $(SRCDIR)/$(SUBVERSION).$(SUBVERSION_SUFFIX)
SUBVERSION_DIR			= $(BUILDDIR)/$(SUBVERSION)
SUBVERSION_IPKG_TMP		= $(SUBVERSION_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

subversion_get: $(STATEDIR)/subversion.get

subversion_get_deps = $(SUBVERSION_SOURCE)

$(STATEDIR)/subversion.get: $(subversion_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SUBVERSION))
	touch $@

$(SUBVERSION_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SUBVERSION_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

subversion_extract: $(STATEDIR)/subversion.extract

subversion_extract_deps = $(STATEDIR)/subversion.get

$(STATEDIR)/subversion.extract: $(subversion_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SUBVERSION_DIR))
	@$(call extract, $(SUBVERSION_SOURCE))
	@$(call patchin, $(SUBVERSION))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

subversion_prepare: $(STATEDIR)/subversion.prepare

#
# dependencies
#
subversion_prepare_deps = \
	$(STATEDIR)/subversion.extract \
	$(STATEDIR)/virtual-xchain.install

SUBVERSION_PATH	=  PATH=$(CROSS_PATH)
SUBVERSION_ENV 	=  $(CROSS_ENV)
#SUBVERSION_ENV	+=
SUBVERSION_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SUBVERSION_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SUBVERSION_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--with-zlib \
	--with-ssl \
	--with-editor=/usr/bin/mcedit

ifdef PTXCONF_XFREE430
SUBVERSION_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SUBVERSION_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/subversion.prepare: $(subversion_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SUBVERSION_DIR)/config.cache)
	cd $(SUBVERSION_DIR) && \
		$(SUBVERSION_PATH) $(SUBVERSION_ENV) \
		./configure $(SUBVERSION_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

subversion_compile: $(STATEDIR)/subversion.compile

subversion_compile_deps = $(STATEDIR)/subversion.prepare

$(STATEDIR)/subversion.compile: $(subversion_compile_deps)
	@$(call targetinfo, $@)
	$(SUBVERSION_PATH) $(MAKE) -C $(SUBVERSION_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

subversion_install: $(STATEDIR)/subversion.install

$(STATEDIR)/subversion.install: $(STATEDIR)/subversion.compile
	@$(call targetinfo, $@)
	##$(SUBVERSION_PATH) $(MAKE) -C $(SUBVERSION_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

subversion_targetinstall: $(STATEDIR)/subversion.targetinstall

subversion_targetinstall_deps = $(STATEDIR)/subversion.compile

$(STATEDIR)/subversion.targetinstall: $(subversion_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SUBVERSION_PATH) $(MAKE) -C $(SUBVERSION_DIR) DESTDIR=$(SUBVERSION_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(SUBVERSION_VERSION)			 		\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh subversion $(SUBVERSION_IPKG_TMP)

	rm -f  $(SUBVERSION_IPKG_TMP)/usr/bin/*-config
	rm -rf $(SUBVERSION_IPKG_TMP)/usr/lib/pkgconfig
	rm -f  $(SUBVERSION_IPKG_TMP)/usr/lib/*.{exp,la}
	
	$(CROSSSTRIP) $(SUBVERSION_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(SUBVERSION_IPKG_TMP)/usr/lib/*.so*
	
	rm -rf $(SUBVERSION_IPKG_TMP)/usr/{include,build}
	rm -rf $(SUBVERSION_IPKG_TMP)/usr/man
	rm -rf $(SUBVERSION_IPKG_TMP)/usr/share
	
	mkdir -p $(SUBVERSION_IPKG_TMP)/CONTROL
	echo "Package: subversion" 							 >$(SUBVERSION_IPKG_TMP)/CONTROL/control
	echo "Source: $(SUBVERSION_URL)"						>>$(SUBVERSION_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SUBVERSION_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 							>>$(SUBVERSION_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SUBVERSION_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SUBVERSION_IPKG_TMP)/CONTROL/control
	echo "Version: $(SUBVERSION_VERSION)-$(SUBVERSION_VENDOR_VERSION)" 		>>$(SUBVERSION_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(SUBVERSION_IPKG_TMP)/CONTROL/control
	echo "Description: version control system"					>>$(SUBVERSION_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SUBVERSION_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SUBVERSION_INSTALL
ROMPACKAGES += $(STATEDIR)/subversion.imageinstall
endif

subversion_imageinstall_deps = $(STATEDIR)/subversion.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/subversion.imageinstall: $(subversion_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install subversion
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

subversion_clean:
	rm -rf $(STATEDIR)/subversion.*
	rm -rf $(SUBVERSION_DIR)

# vim: syntax=make
