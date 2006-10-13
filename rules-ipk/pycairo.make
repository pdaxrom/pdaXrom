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
ifdef PTXCONF_PYCAIRO
PACKAGES += pycairo
endif

#
# Paths and names
#
PYCAIRO_VENDOR_VERSION	= 1
PYCAIRO_VERSION		= 1.2.0
PYCAIRO			= pycairo-$(PYCAIRO_VERSION)
PYCAIRO_SUFFIX		= tar.gz
PYCAIRO_URL		= http://cairographics.org/releases/$(PYCAIRO).$(PYCAIRO_SUFFIX)
PYCAIRO_SOURCE		= $(SRCDIR)/$(PYCAIRO).$(PYCAIRO_SUFFIX)
PYCAIRO_DIR		= $(BUILDDIR)/$(PYCAIRO)
PYCAIRO_IPKG_TMP	= $(PYCAIRO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pycairo_get: $(STATEDIR)/pycairo.get

pycairo_get_deps = $(PYCAIRO_SOURCE)

$(STATEDIR)/pycairo.get: $(pycairo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PYCAIRO))
	touch $@

$(PYCAIRO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PYCAIRO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pycairo_extract: $(STATEDIR)/pycairo.extract

pycairo_extract_deps = $(STATEDIR)/pycairo.get

$(STATEDIR)/pycairo.extract: $(pycairo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYCAIRO_DIR))
	@$(call extract, $(PYCAIRO_SOURCE))
	@$(call patchin, $(PYCAIRO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pycairo_prepare: $(STATEDIR)/pycairo.prepare

#
# dependencies
#
pycairo_prepare_deps = \
	$(STATEDIR)/pycairo.extract \
	$(STATEDIR)/xchain-python.install \
	$(STATEDIR)/cairo.install \
	$(STATEDIR)/virtual-xchain.install

PYCAIRO_PATH	=  PATH=$(CROSS_PATH)
PYCAIRO_ENV 	=  $(CROSS_ENV)
#PYCAIRO_ENV	+=
PYCAIRO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PYCAIRO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PYCAIRO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
PYCAIRO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PYCAIRO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pycairo.prepare: $(pycairo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYCAIRO_DIR)/config.cache)
	cd $(PYCAIRO_DIR) && \
		$(PYCAIRO_PATH) $(PYCAIRO_ENV) \
		./configure $(PYCAIRO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pycairo_compile: $(STATEDIR)/pycairo.compile

pycairo_compile_deps = $(STATEDIR)/pycairo.prepare

$(STATEDIR)/pycairo.compile: $(pycairo_compile_deps)
	@$(call targetinfo, $@)
	$(PYCAIRO_PATH) $(MAKE) -C $(PYCAIRO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pycairo_install: $(STATEDIR)/pycairo.install

$(STATEDIR)/pycairo.install: $(STATEDIR)/pycairo.compile
	@$(call targetinfo, $@)
	rm -rf $(PYCAIRO_IPKG_TMP)
	$(PYCAIRO_PATH) $(MAKE) -C $(PYCAIRO_DIR) DESTDIR=$(PYCAIRO_IPKG_TMP) install
	@$(call copyincludes, $(PYCAIRO_IPKG_TMP))
	@$(call copylibraries,$(PYCAIRO_IPKG_TMP))
	@$(call copymiscfiles,$(PYCAIRO_IPKG_TMP))
	rm -rf $(PYCAIRO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pycairo_targetinstall: $(STATEDIR)/pycairo.targetinstall

pycairo_targetinstall_deps = $(STATEDIR)/pycairo.compile \
	$(STATEDIR)/cairo.targetinstall

$(STATEDIR)/pycairo.targetinstall: $(pycairo_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PYCAIRO_PATH) $(MAKE) -C $(PYCAIRO_DIR) DESTDIR=$(PYCAIRO_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(PYCAIRO_VERSION)-$(PYCAIRO_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh pycairo $(PYCAIRO_IPKG_TMP)

	@$(call removedevfiles, $(PYCAIRO_IPKG_TMP))
	@$(call stripfiles, $(PYCAIRO_IPKG_TMP))
	mkdir -p $(PYCAIRO_IPKG_TMP)/CONTROL
	echo "Package: pycairo" 							 >$(PYCAIRO_IPKG_TMP)/CONTROL/control
	echo "Source: $(PYCAIRO_URL)"							>>$(PYCAIRO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PYCAIRO_IPKG_TMP)/CONTROL/control
	echo "Section: ROX" 								>>$(PYCAIRO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PYCAIRO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PYCAIRO_IPKG_TMP)/CONTROL/control
	echo "Version: $(PYCAIRO_VERSION)-$(PYCAIRO_VENDOR_VERSION)" 			>>$(PYCAIRO_IPKG_TMP)/CONTROL/control
	echo "Depends: cairo" 								>>$(PYCAIRO_IPKG_TMP)/CONTROL/control
	echo "Description: python cairo binding"					>>$(PYCAIRO_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(PYCAIRO_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PYCAIRO_INSTALL
ROMPACKAGES += $(STATEDIR)/pycairo.imageinstall
endif

pycairo_imageinstall_deps = $(STATEDIR)/pycairo.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pycairo.imageinstall: $(pycairo_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pycairo
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pycairo_clean:
	rm -rf $(STATEDIR)/pycairo.*
	rm -rf $(PYCAIRO_DIR)

# vim: syntax=make
