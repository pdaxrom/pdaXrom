# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Adrian Crutchfield (InSearchOf@pdaxrom.org)
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_FIXESPROTO-X11R7.1
PACKAGES += fixesproto-X11R7.1
endif

#
# Paths and names
#
FIXESPROTO-X11R7.1_VENDOR_VERSION	= 1
FIXESPROTO-X11R7.1_VERSION	= 4.0
FIXESPROTO-X11R7.1		= fixesproto-X11R7.1-$(FIXESPROTO-X11R7.1_VERSION)
FIXESPROTO-X11R7.1_SUFFIX		= tar.bz2
FIXESPROTO-X11R7.1_URL		= http://xorg.freedesktop.org/releases/X11R7.2/src/everything/$(FIXESPROTO-X11R7.1).$(FIXESPROTO-X11R7.1_SUFFIX)
FIXESPROTO-X11R7.1_SOURCE		= $(SRCDIR)/$(FIXESPROTO-X11R7.1).$(FIXESPROTO-X11R7.1_SUFFIX)
FIXESPROTO-X11R7.1_DIR		= $(BUILDDIR)/$(FIXESPROTO-X11R7.1)
FIXESPROTO-X11R7.1_IPKG_TMP	= $(FIXESPROTO-X11R7.1_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fixesproto-X11R7.1_get: $(STATEDIR)/fixesproto-X11R7.1.get

fixesproto-X11R7.1_get_deps = $(FIXESPROTO-X11R7.1_SOURCE)

$(STATEDIR)/fixesproto-X11R7.1.get: $(fixesproto-X11R7.1_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FIXESPROTO-X11R7.1))
	touch $@

$(FIXESPROTO-X11R7.1_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FIXESPROTO-X11R7.1_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fixesproto-X11R7.1_extract: $(STATEDIR)/fixesproto-X11R7.1.extract

fixesproto-X11R7.1_extract_deps = $(STATEDIR)/fixesproto-X11R7.1.get

$(STATEDIR)/fixesproto-X11R7.1.extract: $(fixesproto-X11R7.1_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FIXESPROTO-X11R7.1_DIR))
	@$(call extract, $(FIXESPROTO-X11R7.1_SOURCE))
	@$(call patchin, $(FIXESPROTO-X11R7.1))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fixesproto-X11R7.1_prepare: $(STATEDIR)/fixesproto-X11R7.1.prepare

#
# dependencies
#
fixesproto-X11R7.1_prepare_deps = \
	$(STATEDIR)/fixesproto-X11R7.1.extract \
	$(STATEDIR)/virtual-xchain.install

FIXESPROTO-X11R7.1_PATH	=  PATH=$(CROSS_PATH)
FIXESPROTO-X11R7.1_ENV 	=  $(CROSS_ENV)
#FIXESPROTO-X11R7.1_ENV	+=
FIXESPROTO-X11R7.1_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FIXESPROTO-X11R7.1_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
FIXESPROTO-X11R7.1_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
FIXESPROTO-X11R7.1_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FIXESPROTO-X11R7.1_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fixesproto-X11R7.1.prepare: $(fixesproto-X11R7.1_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FIXESPROTO-X11R7.1_DIR)/config.cache)
	cd $(FIXESPROTO-X11R7.1_DIR) && \
		$(FIXESPROTO-X11R7.1_PATH) $(FIXESPROTO-X11R7.1_ENV) \
		./configure $(FIXESPROTO-X11R7.1_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fixesproto-X11R7.1_compile: $(STATEDIR)/fixesproto-X11R7.1.compile

fixesproto-X11R7.1_compile_deps = $(STATEDIR)/fixesproto-X11R7.1.prepare

$(STATEDIR)/fixesproto-X11R7.1.compile: $(fixesproto-X11R7.1_compile_deps)
	@$(call targetinfo, $@)
	$(FIXESPROTO-X11R7.1_PATH) $(MAKE) -C $(FIXESPROTO-X11R7.1_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fixesproto-X11R7.1_install: $(STATEDIR)/fixesproto-X11R7.1.install

$(STATEDIR)/fixesproto-X11R7.1.install: $(STATEDIR)/fixesproto-X11R7.1.compile
	@$(call targetinfo, $@)
	rm -rf $(FIXESPROTO-X11R7.1_IPKG_TMP)
	$(FIXESPROTO-X11R7.1_PATH) $(MAKE) -C $(FIXESPROTO-X11R7.1_DIR) DESTDIR=$(FIXESPROTO-X11R7.1_IPKG_TMP) install
	@$(call copyincludes, $(FIXESPROTO-X11R7.1_IPKG_TMP))
	@$(call copylibraries,$(FIXESPROTO-X11R7.1_IPKG_TMP))
	@$(call copymiscfiles,$(FIXESPROTO-X11R7.1_IPKG_TMP))
	rm -rf $(FIXESPROTO-X11R7.1_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fixesproto-X11R7.1_targetinstall: $(STATEDIR)/fixesproto-X11R7.1.targetinstall

fixesproto-X11R7.1_targetinstall_deps = $(STATEDIR)/fixesproto-X11R7.1.compile

FIXESPROTO-X11R7.1_DEPLIST = 

$(STATEDIR)/fixesproto-X11R7.1.targetinstall: $(fixesproto-X11R7.1_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FIXESPROTO-X11R7.1_PATH) $(MAKE) -C $(FIXESPROTO-X11R7.1_DIR) DESTDIR=$(FIXESPROTO-X11R7.1_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(FIXESPROTO-X11R7.1_VERSION)-$(FIXESPROTO-X11R7.1_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh fixesproto-x11r7.1 $(FIXESPROTO-X11R7.1_IPKG_TMP)

	@$(call removedevfiles, $(FIXESPROTO-X11R7.1_IPKG_TMP))
	@$(call stripfiles, $(FIXESPROTO-X11R7.1_IPKG_TMP))
	mkdir -p $(FIXESPROTO-X11R7.1_IPKG_TMP)/CONTROL
	echo "Package: fixesproto-x11r7.1" 							 >$(FIXESPROTO-X11R7.1_IPKG_TMP)/CONTROL/control
	echo "Source: $(FIXESPROTO-X11R7.1_URL)"							>>$(FIXESPROTO-X11R7.1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(FIXESPROTO-X11R7.1_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(FIXESPROTO-X11R7.1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield (InSearchOf@pdaxrom.org)" 							>>$(FIXESPROTO-X11R7.1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(FIXESPROTO-X11R7.1_IPKG_TMP)/CONTROL/control
	echo "Version: $(FIXESPROTO-X11R7.1_VERSION)-$(FIXESPROTO-X11R7.1_VENDOR_VERSION)" 			>>$(FIXESPROTO-X11R7.1_IPKG_TMP)/CONTROL/control
	echo "Depends: $(FIXESPROTO-X11R7.1_DEPLIST)" 						>>$(FIXESPROTO-X11R7.1_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(FIXESPROTO-X11R7.1_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(FIXESPROTO-X11R7.1_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FIXESPROTO-X11R7.1_INSTALL
ROMPACKAGES += $(STATEDIR)/fixesproto-X11R7.1.imageinstall
endif

fixesproto-X11R7.1_imageinstall_deps = $(STATEDIR)/fixesproto-X11R7.1.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fixesproto-X11R7.1.imageinstall: $(fixesproto-X11R7.1_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fixesproto-x11r7.1
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fixesproto-X11R7.1_clean:
	rm -rf $(STATEDIR)/fixesproto-X11R7.1.*
	rm -rf $(FIXESPROTO-X11R7.1_DIR)

# vim: syntax=make
