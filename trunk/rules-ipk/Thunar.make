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
ifdef PTXCONF_THUNAR
PACKAGES += Thunar
endif

#
# Paths and names
#
THUNAR_VENDOR_VERSION	= 1
THUNAR_VERSION	= 0.8.0
THUNAR		= Thunar-$(THUNAR_VERSION)
THUNAR_SUFFIX		= tar.bz2
THUNAR_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(THUNAR).$(THUNAR_SUFFIX)
THUNAR_SOURCE		= $(SRCDIR)/$(THUNAR).$(THUNAR_SUFFIX)
THUNAR_DIR		= $(BUILDDIR)/$(THUNAR)
THUNAR_IPKG_TMP	= $(THUNAR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

Thunar_get: $(STATEDIR)/Thunar.get

Thunar_get_deps = $(THUNAR_SOURCE)

$(STATEDIR)/Thunar.get: $(Thunar_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(THUNAR))
	touch $@

$(THUNAR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(THUNAR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

Thunar_extract: $(STATEDIR)/Thunar.extract

Thunar_extract_deps = $(STATEDIR)/Thunar.get

$(STATEDIR)/Thunar.extract: $(Thunar_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(THUNAR_DIR))
	@$(call extract, $(THUNAR_SOURCE))
	@$(call patchin, $(THUNAR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

Thunar_prepare: $(STATEDIR)/Thunar.prepare

#
# dependencies
#
Thunar_prepare_deps = \
	$(STATEDIR)/Thunar.extract \
	$(STATEDIR)/virtual-xchain.install

THUNAR_PATH	=  PATH=$(CROSS_PATH)
THUNAR_ENV 	=  $(CROSS_ENV)
#THUNAR_ENV	+=
THUNAR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#THUNAR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
THUNAR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
THUNAR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
THUNAR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/Thunar.prepare: $(Thunar_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(THUNAR_DIR)/config.cache)
	cd $(THUNAR_DIR) && \
		$(THUNAR_PATH) $(THUNAR_ENV) \
		./configure $(THUNAR_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

Thunar_compile: $(STATEDIR)/Thunar.compile

Thunar_compile_deps = $(STATEDIR)/Thunar.prepare

$(STATEDIR)/Thunar.compile: $(Thunar_compile_deps)
	@$(call targetinfo, $@)
	$(THUNAR_PATH) $(MAKE) -C $(THUNAR_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

Thunar_install: $(STATEDIR)/Thunar.install

$(STATEDIR)/Thunar.install: $(STATEDIR)/Thunar.compile
	@$(call targetinfo, $@)
	rm -rf $(THUNAR_IPKG_TMP)
	$(THUNAR_PATH) $(MAKE) -C $(THUNAR_DIR) DESTDIR=$(THUNAR_IPKG_TMP) install
	@$(call copyincludes, $(THUNAR_IPKG_TMP))
	@$(call copylibraries,$(THUNAR_IPKG_TMP))
	@$(call copymiscfiles,$(THUNAR_IPKG_TMP))
	rm -rf $(THUNAR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

Thunar_targetinstall: $(STATEDIR)/Thunar.targetinstall

Thunar_targetinstall_deps = $(STATEDIR)/Thunar.compile

THUNAR_DEPLIST = 

$(STATEDIR)/Thunar.targetinstall: $(Thunar_targetinstall_deps)
	@$(call targetinfo, $@)
	$(THUNAR_PATH) $(MAKE) -C $(THUNAR_DIR) DESTDIR=$(THUNAR_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(THUNAR_VERSION)-$(THUNAR_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh thunar $(THUNAR_IPKG_TMP)

	@$(call removedevfiles, $(THUNAR_IPKG_TMP))
	@$(call stripfiles, $(THUNAR_IPKG_TMP))
	mkdir -p $(THUNAR_IPKG_TMP)/CONTROL
	echo "Package: thunar" 							 >$(THUNAR_IPKG_TMP)/CONTROL/control
	echo "Source: $(THUNAR_URL)"							>>$(THUNAR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(THUNAR_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(THUNAR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(THUNAR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(THUNAR_IPKG_TMP)/CONTROL/control
	echo "Version: $(THUNAR_VERSION)-$(THUNAR_VENDOR_VERSION)" 			>>$(THUNAR_IPKG_TMP)/CONTROL/control
	echo "Depends: $(THUNAR_DEPLIST)" 						>>$(THUNAR_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(THUNAR_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(THUNAR_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_THUNAR_INSTALL
ROMPACKAGES += $(STATEDIR)/Thunar.imageinstall
endif

Thunar_imageinstall_deps = $(STATEDIR)/Thunar.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/Thunar.imageinstall: $(Thunar_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install thunar
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

Thunar_clean:
	rm -rf $(STATEDIR)/Thunar.*
	rm -rf $(THUNAR_DIR)

# vim: syntax=make
