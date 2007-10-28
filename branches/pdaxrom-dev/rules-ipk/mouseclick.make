# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by hdluc
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_MOUSECLICK
PACKAGES += mouseclick
endif

#
# Paths and names
#
MOUSECLICK_VENDOR_VERSION	= 1
MOUSECLICK_VERSION	= 1.0.0
MOUSECLICK		= mouseclick-$(MOUSECLICK_VERSION)
MOUSECLICK_SUFFIX		= tar.gz
MOUSECLICK_URL		= /mnt/src/$(MOUSECLICK).$(MOUSECLICK_SUFFIX)
MOUSECLICK_SOURCE		= $(SRCDIR)/$(MOUSECLICK).$(MOUSECLICK_SUFFIX)
MOUSECLICK_DIR		= $(BUILDDIR)/$(MOUSECLICK)
MOUSECLICK_IPKG_TMP	= $(MOUSECLICK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mouseclick_get: $(STATEDIR)/mouseclick.get

mouseclick_get_deps = $(MOUSECLICK_SOURCE)

$(STATEDIR)/mouseclick.get: $(mouseclick_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MOUSECLICK))
	touch $@

$(MOUSECLICK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MOUSECLICK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mouseclick_extract: $(STATEDIR)/mouseclick.extract

mouseclick_extract_deps = $(STATEDIR)/mouseclick.get

$(STATEDIR)/mouseclick.extract: $(mouseclick_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MOUSECLICK_DIR))
	@$(call extract, $(MOUSECLICK_SOURCE))
	@$(call patchin, $(MOUSECLICK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mouseclick_prepare: $(STATEDIR)/mouseclick.prepare

#
# dependencies
#
mouseclick_prepare_deps = \
	$(STATEDIR)/mouseclick.extract \
	$(STATEDIR)/virtual-xchain.install

MOUSECLICK_PATH	=  PATH=$(CROSS_PATH)
MOUSECLICK_ENV 	=  $(CROSS_ENV)
#MOUSECLICK_ENV	+=
MOUSECLICK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MOUSECLICK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MOUSECLICK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
MOUSECLICK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MOUSECLICK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mouseclick.prepare: $(mouseclick_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MOUSECLICK_DIR)/config.cache)
	cd $(MOUSECLICK_DIR) && \
		$(MOUSECLICK_PATH) $(MOUSECLICK_ENV) \
		./configure $(MOUSECLICK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mouseclick_compile: $(STATEDIR)/mouseclick.compile

mouseclick_compile_deps = $(STATEDIR)/mouseclick.prepare

$(STATEDIR)/mouseclick.compile: $(mouseclick_compile_deps)
	@$(call targetinfo, $@)
	$(MOUSECLICK_PATH) $(MAKE) -C $(MOUSECLICK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mouseclick_install: $(STATEDIR)/mouseclick.install

$(STATEDIR)/mouseclick.install: $(STATEDIR)/mouseclick.compile
	@$(call targetinfo, $@)
	rm -rf $(MOUSECLICK_IPKG_TMP)
	$(MOUSECLICK_PATH) $(MAKE) -C $(MOUSECLICK_DIR) DESTDIR=$(MOUSECLICK_IPKG_TMP) install
	@$(call copyincludes, $(MOUSECLICK_IPKG_TMP))
	@$(call copylibraries,$(MOUSECLICK_IPKG_TMP))
	@$(call copymiscfiles,$(MOUSECLICK_IPKG_TMP))
	rm -rf $(MOUSECLICK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mouseclick_targetinstall: $(STATEDIR)/mouseclick.targetinstall

mouseclick_targetinstall_deps = $(STATEDIR)/mouseclick.compile

MOUSECLICK_DEPLIST = 

$(STATEDIR)/mouseclick.targetinstall: $(mouseclick_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MOUSECLICK_PATH) $(MAKE) -C $(MOUSECLICK_DIR) DESTDIR=$(MOUSECLICK_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(MOUSECLICK_VERSION)-$(MOUSECLICK_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh mouseclick $(MOUSECLICK_IPKG_TMP)

	@$(call removedevfiles, $(MOUSECLICK_IPKG_TMP))
	@$(call stripfiles, $(MOUSECLICK_IPKG_TMP))
	mkdir -p $(MOUSECLICK_IPKG_TMP)/CONTROL
	echo "Package: mouseclick" 							 >$(MOUSECLICK_IPKG_TMP)/CONTROL/control
	echo "Source: $(MOUSECLICK_URL)"							>>$(MOUSECLICK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MOUSECLICK_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(MOUSECLICK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: hdluc" 							>>$(MOUSECLICK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MOUSECLICK_IPKG_TMP)/CONTROL/control
	echo "Version: $(MOUSECLICK_VERSION)-$(MOUSECLICK_VENDOR_VERSION)" 			>>$(MOUSECLICK_IPKG_TMP)/CONTROL/control
	echo "Depends: $(MOUSECLICK_DEPLIST)" 						>>$(MOUSECLICK_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(MOUSECLICK_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(MOUSECLICK_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MOUSECLICK_INSTALL
ROMPACKAGES += $(STATEDIR)/mouseclick.imageinstall
endif

mouseclick_imageinstall_deps = $(STATEDIR)/mouseclick.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mouseclick.imageinstall: $(mouseclick_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mouseclick
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mouseclick_clean:
	rm -rf $(STATEDIR)/mouseclick.*
	rm -rf $(MOUSECLICK_DIR)

# vim: syntax=make
