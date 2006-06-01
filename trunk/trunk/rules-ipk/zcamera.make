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
ifdef PTXCONF_ZCAMERA
PACKAGES += zcamera
endif

#
# Paths and names
#
ZCAMERA_VENDOR_VERSION	= 2
ZCAMERA_VERSION		= 0.0.1
ZCAMERA			= zcamera-$(ZCAMERA_VERSION)
ZCAMERA_SUFFIX		= tar.bz2
ZCAMERA_URL		= http://www.pdaXrom.org/src/$(ZCAMERA).$(ZCAMERA_SUFFIX)
ZCAMERA_SOURCE		= $(SRCDIR)/$(ZCAMERA).$(ZCAMERA_SUFFIX)
ZCAMERA_DIR		= $(BUILDDIR)/$(ZCAMERA)
ZCAMERA_IPKG_TMP	= $(ZCAMERA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

zcamera_get: $(STATEDIR)/zcamera.get

zcamera_get_deps = $(ZCAMERA_SOURCE)

$(STATEDIR)/zcamera.get: $(zcamera_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ZCAMERA))
	touch $@

$(ZCAMERA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ZCAMERA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

zcamera_extract: $(STATEDIR)/zcamera.extract

zcamera_extract_deps = $(STATEDIR)/zcamera.get

$(STATEDIR)/zcamera.extract: $(zcamera_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ZCAMERA_DIR))
	@$(call extract, $(ZCAMERA_SOURCE))
	@$(call patchin, $(ZCAMERA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

zcamera_prepare: $(STATEDIR)/zcamera.prepare

#
# dependencies
#
zcamera_prepare_deps = \
	$(STATEDIR)/zcamera.extract \
	$(STATEDIR)/virtual-xchain.install

ZCAMERA_PATH	=  PATH=$(CROSS_PATH)
ZCAMERA_ENV 	=  $(CROSS_ENV)
#ZCAMERA_ENV	+=
ZCAMERA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ZCAMERA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ZCAMERA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ZCAMERA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ZCAMERA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/zcamera.prepare: $(zcamera_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ZCAMERA_DIR)/config.cache)
	#cd $(ZCAMERA_DIR) && \
	#	$(ZCAMERA_PATH) $(ZCAMERA_ENV) \
	#	./configure $(ZCAMERA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

zcamera_compile: $(STATEDIR)/zcamera.compile

zcamera_compile_deps = $(STATEDIR)/zcamera.prepare

$(STATEDIR)/zcamera.compile: $(zcamera_compile_deps)
	@$(call targetinfo, $@)
	$(ZCAMERA_PATH) $(MAKE) -C $(ZCAMERA_DIR) $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

zcamera_install: $(STATEDIR)/zcamera.install

$(STATEDIR)/zcamera.install: $(STATEDIR)/zcamera.compile
	@$(call targetinfo, $@)
	##$(ZCAMERA_PATH) $(MAKE) -C $(ZCAMERA_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

zcamera_targetinstall: $(STATEDIR)/zcamera.targetinstall

zcamera_targetinstall_deps = $(STATEDIR)/zcamera.compile

$(STATEDIR)/zcamera.targetinstall: $(zcamera_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ZCAMERA_PATH) $(MAKE) -C $(ZCAMERA_DIR) DESTDIR=$(ZCAMERA_IPKG_TMP) install $(CROSS_ENV_CC)

ifeq ("sharp-corgi", $(PTXCONF_VENDORTWEAKS_USERCONFIG))
	cd $(FEEDDIR) && $(XMKIPKG) $(ZCAMERA_DIR)/corgi
endif

ifeq ("sharp-akita", $(PTXCONF_VENDORTWEAKS_USERCONFIG))
	cd $(FEEDDIR) && $(XMKIPKG) $(ZCAMERA_DIR)/akita
endif

ifeq ("sharp-collie", $(PTXCONF_VENDORTWEAKS_USERCONFIG))
	not redy yet
	cd $(FEEDDIR) && $(XMKIPKG) $(ZCAMERA_DIR)/collie
endif

ifeq ("sharp-tosa", $(PTXCONF_VENDORTWEAKS_USERCONFIG))
	cd $(FEEDDIR) && $(XMKIPKG) $(ZCAMERA_DIR)/tosa
endif

	mkdir -p $(ZCAMERA_IPKG_TMP)/CONTROL
	echo "Package: zcamera" 							 >$(ZCAMERA_IPKG_TMP)/CONTROL/control
	echo "Source: $(ZCAMERA_URL)"							>>$(ZCAMERA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ZCAMERA_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(ZCAMERA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ZCAMERA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ZCAMERA_IPKG_TMP)/CONTROL/control
	echo "Version: $(ZCAMERA_VERSION)-$(ZCAMERA_VENDOR_VERSION)" 			>>$(ZCAMERA_IPKG_TMP)/CONTROL/control
	echo "Depends: sharpzdc-cs, sdl" 						>>$(ZCAMERA_IPKG_TMP)/CONTROL/control
	echo "Description: SHARP CF CE-AG06 digital camera grabber"			>>$(ZCAMERA_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ZCAMERA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ZCAMERA_INSTALL
ROMPACKAGES += $(STATEDIR)/zcamera.imageinstall
endif

zcamera_imageinstall_deps = $(STATEDIR)/zcamera.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/zcamera.imageinstall: $(zcamera_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install zcamera
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

zcamera_clean:
	rm -rf $(STATEDIR)/zcamera.*
	rm -rf $(ZCAMERA_DIR)

# vim: syntax=make
