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
ifdef PTXCONF_ORAGE
PACKAGES += orage
endif

#
# Paths and names
#
ORAGE_VENDOR_VERSION	= 1
ORAGE_VERSION	= 4.4.0
ORAGE		= orage-$(ORAGE_VERSION)
ORAGE_SUFFIX		= tar.bz2
ORAGE_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(ORAGE).$(ORAGE_SUFFIX)
ORAGE_SOURCE		= $(SRCDIR)/$(ORAGE).$(ORAGE_SUFFIX)
ORAGE_DIR		= $(BUILDDIR)/$(ORAGE)
ORAGE_IPKG_TMP	= $(ORAGE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

orage_get: $(STATEDIR)/orage.get

orage_get_deps = $(ORAGE_SOURCE)

$(STATEDIR)/orage.get: $(orage_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ORAGE))
	touch $@

$(ORAGE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ORAGE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

orage_extract: $(STATEDIR)/orage.extract

orage_extract_deps = $(STATEDIR)/orage.get

$(STATEDIR)/orage.extract: $(orage_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ORAGE_DIR))
	@$(call extract, $(ORAGE_SOURCE))
	@$(call patchin, $(ORAGE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

orage_prepare: $(STATEDIR)/orage.prepare

#
# dependencies
#
orage_prepare_deps = \
	$(STATEDIR)/orage.extract \
	$(STATEDIR)/virtual-xchain.install

ORAGE_PATH	=  PATH=$(CROSS_PATH)
ORAGE_ENV 	=  $(CROSS_ENV)
#ORAGE_ENV	+=
ORAGE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ORAGE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ORAGE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
ORAGE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ORAGE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/orage.prepare: $(orage_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ORAGE_DIR)/config.cache)
	cd $(ORAGE_DIR) && \
		$(ORAGE_PATH) $(ORAGE_ENV) \
		./configure $(ORAGE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

orage_compile: $(STATEDIR)/orage.compile

orage_compile_deps = $(STATEDIR)/orage.prepare

$(STATEDIR)/orage.compile: $(orage_compile_deps)
	@$(call targetinfo, $@)
	$(ORAGE_PATH) $(MAKE) -C $(ORAGE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

orage_install: $(STATEDIR)/orage.install

$(STATEDIR)/orage.install: $(STATEDIR)/orage.compile
	@$(call targetinfo, $@)
	rm -rf $(ORAGE_IPKG_TMP)
	$(ORAGE_PATH) $(MAKE) -C $(ORAGE_DIR) DESTDIR=$(ORAGE_IPKG_TMP) install
	@$(call copyincludes, $(ORAGE_IPKG_TMP))
	@$(call copylibraries,$(ORAGE_IPKG_TMP))
	@$(call copymiscfiles,$(ORAGE_IPKG_TMP))
	rm -rf $(ORAGE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

orage_targetinstall: $(STATEDIR)/orage.targetinstall

orage_targetinstall_deps = $(STATEDIR)/orage.compile

ORAGE_DEPLIST = 

$(STATEDIR)/orage.targetinstall: $(orage_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ORAGE_PATH) $(MAKE) -C $(ORAGE_DIR) DESTDIR=$(ORAGE_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(ORAGE_VERSION)-$(ORAGE_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh orage $(ORAGE_IPKG_TMP)

	@$(call removedevfiles, $(ORAGE_IPKG_TMP))
	@$(call stripfiles, $(ORAGE_IPKG_TMP))
	mkdir -p $(ORAGE_IPKG_TMP)/CONTROL
	echo "Package: orage" 							 >$(ORAGE_IPKG_TMP)/CONTROL/control
	echo "Source: $(ORAGE_URL)"							>>$(ORAGE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ORAGE_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(ORAGE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(ORAGE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ORAGE_IPKG_TMP)/CONTROL/control
	echo "Version: $(ORAGE_VERSION)-$(ORAGE_VENDOR_VERSION)" 			>>$(ORAGE_IPKG_TMP)/CONTROL/control
	echo "Depends: $(ORAGE_DEPLIST)" 						>>$(ORAGE_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(ORAGE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(ORAGE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ORAGE_INSTALL
ROMPACKAGES += $(STATEDIR)/orage.imageinstall
endif

orage_imageinstall_deps = $(STATEDIR)/orage.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/orage.imageinstall: $(orage_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install orage
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

orage_clean:
	rm -rf $(STATEDIR)/orage.*
	rm -rf $(ORAGE_DIR)

# vim: syntax=make
