# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Adrian Crutchfield
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_GDM
PACKAGES += gdm
endif

#
# Paths and names
#
GDM_VENDOR_VERSION	= 1
GDM_VERSION	= 2.17.6
GDM		= gdm-$(GDM_VERSION)
GDM_SUFFIX		= tar.bz2
GDM_URL		= http://ftp.acc.umu.se/pub/GNOME/sources/gdm/2.17//$(GDM).$(GDM_SUFFIX)
GDM_SOURCE		= $(SRCDIR)/$(GDM).$(GDM_SUFFIX)
GDM_DIR		= $(BUILDDIR)/$(GDM)
GDM_IPKG_TMP	= $(GDM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gdm_get: $(STATEDIR)/gdm.get

gdm_get_deps = $(GDM_SOURCE)

$(STATEDIR)/gdm.get: $(gdm_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GDM))
	touch $@

$(GDM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GDM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gdm_extract: $(STATEDIR)/gdm.extract

gdm_extract_deps = $(STATEDIR)/gdm.get

$(STATEDIR)/gdm.extract: $(gdm_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GDM_DIR))
	@$(call extract, $(GDM_SOURCE))
	@$(call patchin, $(GDM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gdm_prepare: $(STATEDIR)/gdm.prepare

#
# dependencies
#
gdm_prepare_deps = \
	$(STATEDIR)/gdm.extract \
	$(STATEDIR)/virtual-xchain.install

GDM_PATH	=  PATH=$(CROSS_PATH)
GDM_ENV 	=  $(CROSS_ENV)
#GDM_ENV	+=
GDM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GDM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GDM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GDM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GDM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gdm.prepare: $(gdm_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GDM_DIR)/config.cache)
	cd $(GDM_DIR) && \
		$(GDM_PATH) $(GDM_ENV) \
		./configure $(GDM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gdm_compile: $(STATEDIR)/gdm.compile

gdm_compile_deps = $(STATEDIR)/gdm.prepare

$(STATEDIR)/gdm.compile: $(gdm_compile_deps)
	@$(call targetinfo, $@)
	$(GDM_PATH) $(MAKE) -C $(GDM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gdm_install: $(STATEDIR)/gdm.install

$(STATEDIR)/gdm.install: $(STATEDIR)/gdm.compile
	@$(call targetinfo, $@)
	rm -rf $(GDM_IPKG_TMP)
	$(GDM_PATH) $(MAKE) -C $(GDM_DIR) DESTDIR=$(GDM_IPKG_TMP) install
	@$(call copyincludes, $(GDM_IPKG_TMP))
	@$(call copylibraries,$(GDM_IPKG_TMP))
	@$(call copymiscfiles,$(GDM_IPKG_TMP))
	rm -rf $(GDM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gdm_targetinstall: $(STATEDIR)/gdm.targetinstall

gdm_targetinstall_deps = $(STATEDIR)/gdm.compile

GDM_DEPLIST = 

$(STATEDIR)/gdm.targetinstall: $(gdm_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GDM_PATH) $(MAKE) -C $(GDM_DIR) DESTDIR=$(GDM_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(GDM_VERSION)-$(GDM_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh gdm $(GDM_IPKG_TMP)

	@$(call removedevfiles, $(GDM_IPKG_TMP))
	@$(call stripfiles, $(GDM_IPKG_TMP))
	mkdir -p $(GDM_IPKG_TMP)/CONTROL
	echo "Package: gdm" 							 >$(GDM_IPKG_TMP)/CONTROL/control
	echo "Source: $(GDM_URL)"							>>$(GDM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GDM_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(GDM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(GDM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GDM_IPKG_TMP)/CONTROL/control
	echo "Version: $(GDM_VERSION)-$(GDM_VENDOR_VERSION)" 			>>$(GDM_IPKG_TMP)/CONTROL/control
	echo "Depends: $(GDM_DEPLIST)" 						>>$(GDM_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(GDM_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(GDM_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GDM_INSTALL
ROMPACKAGES += $(STATEDIR)/gdm.imageinstall
endif

gdm_imageinstall_deps = $(STATEDIR)/gdm.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gdm.imageinstall: $(gdm_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gdm
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gdm_clean:
	rm -rf $(STATEDIR)/gdm.*
	rm -rf $(GDM_DIR)

# vim: syntax=make
