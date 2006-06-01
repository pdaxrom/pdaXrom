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
ifdef PTXCONF_SHEEPSHAVER
PACKAGES += SheepShaver
endif

#
# Paths and names
#
SHEEPSHAVER_VENDOR_VERSION	= 1
SHEEPSHAVER_VERSION		= 2.2.20050321
SHEEPSHAVER			= SheepShaver-$(SHEEPSHAVER_VERSION)
SHEEPSHAVER_SUFFIX		= tar.bz2
SHEEPSHAVER_URL			= http://gwenole.beauchesne.free.fr/sheepshaver/files/$(SHEEPSHAVER).$(SHEEPSHAVER_SUFFIX)
SHEEPSHAVER_SOURCE		= $(SRCDIR)/$(SHEEPSHAVER).$(SHEEPSHAVER_SUFFIX)
SHEEPSHAVER_DIR			= $(BUILDDIR)/$(SHEEPSHAVER)
SHEEPSHAVER_IPKG_TMP		= $(SHEEPSHAVER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

SheepShaver_get: $(STATEDIR)/SheepShaver.get

SheepShaver_get_deps = $(SHEEPSHAVER_SOURCE)

$(STATEDIR)/SheepShaver.get: $(SheepShaver_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SHEEPSHAVER))
	touch $@

$(SHEEPSHAVER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SHEEPSHAVER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

SheepShaver_extract: $(STATEDIR)/SheepShaver.extract

SheepShaver_extract_deps = $(STATEDIR)/SheepShaver.get

$(STATEDIR)/SheepShaver.extract: $(SheepShaver_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SHEEPSHAVER_DIR))
	@$(call extract, $(SHEEPSHAVER_SOURCE))
	@$(call patchin, $(SHEEPSHAVER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

SheepShaver_prepare: $(STATEDIR)/SheepShaver.prepare

#
# dependencies
#
SheepShaver_prepare_deps = \
	$(STATEDIR)/SheepShaver.extract \
	$(STATEDIR)/virtual-xchain.install

SHEEPSHAVER_PATH	=  PATH=$(CROSS_PATH)
SHEEPSHAVER_ENV 	=  $(CROSS_ENV)
#SHEEPSHAVER_ENV	+=
SHEEPSHAVER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SHEEPSHAVER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SHEEPSHAVER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
SHEEPSHAVER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SHEEPSHAVER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/SheepShaver.prepare: $(SheepShaver_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SHEEPSHAVER_DIR)/config.cache)
	cd $(SHEEPSHAVER_DIR) && \
		$(SHEEPSHAVER_PATH) $(SHEEPSHAVER_ENV) \
		./configure $(SHEEPSHAVER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

SheepShaver_compile: $(STATEDIR)/SheepShaver.compile

SheepShaver_compile_deps = $(STATEDIR)/SheepShaver.prepare

$(STATEDIR)/SheepShaver.compile: $(SheepShaver_compile_deps)
	@$(call targetinfo, $@)
	$(SHEEPSHAVER_PATH) $(MAKE) -C $(SHEEPSHAVER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

SheepShaver_install: $(STATEDIR)/SheepShaver.install

$(STATEDIR)/SheepShaver.install: $(STATEDIR)/SheepShaver.compile
	@$(call targetinfo, $@)
	$(SHEEPSHAVER_PATH) $(MAKE) -C $(SHEEPSHAVER_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

SheepShaver_targetinstall: $(STATEDIR)/SheepShaver.targetinstall

SheepShaver_targetinstall_deps = $(STATEDIR)/SheepShaver.compile

$(STATEDIR)/SheepShaver.targetinstall: $(SheepShaver_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SHEEPSHAVER_PATH) $(MAKE) -C $(SHEEPSHAVER_DIR) DESTDIR=$(SHEEPSHAVER_IPKG_TMP) install
	mkdir -p $(SHEEPSHAVER_IPKG_TMP)/CONTROL
	echo "Package: sheepshaver" 							 >$(SHEEPSHAVER_IPKG_TMP)/CONTROL/control
	echo "Source: $(SHEEPSHAVER_URL)"						>>$(SHEEPSHAVER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SHEEPSHAVER_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(SHEEPSHAVER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SHEEPSHAVER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SHEEPSHAVER_IPKG_TMP)/CONTROL/control
	echo "Version: $(SHEEPSHAVER_VERSION)-$(SHEEPSHAVER_VENDOR_VERSION)" 		>>$(SHEEPSHAVER_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree, gtk2, sdl" 						>>$(SHEEPSHAVER_IPKG_TMP)/CONTROL/control
	echo "Description:  SheepShaver is a MacOS run-time environment for BeOS and Linux that allows you to run classic MacOS applications inside the BeOS/Linux multitasking environment." >>$(SHEEPSHAVER_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(SHEEPSHAVER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SHEEPSHAVER_INSTALL
ROMPACKAGES += $(STATEDIR)/SheepShaver.imageinstall
endif

SheepShaver_imageinstall_deps = $(STATEDIR)/SheepShaver.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/SheepShaver.imageinstall: $(SheepShaver_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sheepshaver
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

SheepShaver_clean:
	rm -rf $(STATEDIR)/SheepShaver.*
	rm -rf $(SHEEPSHAVER_DIR)

# vim: syntax=make
