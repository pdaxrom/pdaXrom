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
ifdef PTXCONF_BASILISKII
PACKAGES += BasiliskII
endif

#
# Paths and names
#
BASILISKII_VENDOR_VERSION	= 1
BASILISKII_VERSION		= 22032005
BASILISKII			= BasiliskII_src_$(BASILISKII_VERSION)
BASILISKII_SUFFIX		= tar.bz2
BASILISKII_URL			= http://gwenole.beauchesne.online.fr/basilisk2/files/$(BASILISKII).$(BASILISKII_SUFFIX)
BASILISKII_SOURCE		= $(SRCDIR)/$(BASILISKII).$(BASILISKII_SUFFIX)
BASILISKII_DIR			= $(BUILDDIR)/BasiliskII-1.0
BASILISKII_IPKG_TMP		= $(BASILISKII_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

BasiliskII_get: $(STATEDIR)/BasiliskII.get

BasiliskII_get_deps = $(BASILISKII_SOURCE)

$(STATEDIR)/BasiliskII.get: $(BasiliskII_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BASILISKII))
	touch $@

$(BASILISKII_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BASILISKII_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

BasiliskII_extract: $(STATEDIR)/BasiliskII.extract

BasiliskII_extract_deps = $(STATEDIR)/BasiliskII.get

$(STATEDIR)/BasiliskII.extract: $(BasiliskII_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(BASILISKII_DIR))
	@$(call extract, $(BASILISKII_SOURCE))
	@$(call patchin, $(BASILISKII), $(BASILISKII_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

BasiliskII_prepare: $(STATEDIR)/BasiliskII.prepare

#
# dependencies
#
BasiliskII_prepare_deps = \
	$(STATEDIR)/BasiliskII.extract \
	$(STATEDIR)/virtual-xchain.install

BASILISKII_PATH	=  PATH=$(CROSS_PATH)
BASILISKII_ENV 	=  $(CROSS_ENV)
BASILISKII_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
BASILISKII_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
BASILISKII_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BASILISKII_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
BASILISKII_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-sdl-video \
	--without-esd \
	--enable-vosf=yes \
	--enable-addressing=direct

ifdef PTXCONF_XFREE430
BASILISKII_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BASILISKII_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/BasiliskII.prepare: $(BasiliskII_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BASILISKII_DIR)/config.cache)
	cd $(BASILISKII_DIR)/src/Unix && \
		$(BASILISKII_PATH) $(BASILISKII_ENV) \
		./configure $(BASILISKII_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

BasiliskII_compile: $(STATEDIR)/BasiliskII.compile

BasiliskII_compile_deps = $(STATEDIR)/BasiliskII.prepare

$(STATEDIR)/BasiliskII.compile: $(BasiliskII_compile_deps)
	@$(call targetinfo, $@)
	$(BASILISKII_PATH) $(MAKE) -C $(BASILISKII_DIR)/src/Unix
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

BasiliskII_install: $(STATEDIR)/BasiliskII.install

$(STATEDIR)/BasiliskII.install: $(STATEDIR)/BasiliskII.compile
	@$(call targetinfo, $@)
	$(BASILISKII_PATH) $(MAKE) -C $(BASILISKII_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

BasiliskII_targetinstall: $(STATEDIR)/BasiliskII.targetinstall

BasiliskII_targetinstall_deps = $(STATEDIR)/BasiliskII.compile

$(STATEDIR)/BasiliskII.targetinstall: $(BasiliskII_targetinstall_deps)
	@$(call targetinfo, $@)
	$(BASILISKII_PATH) $(MAKE) -C $(BASILISKII_DIR) DESTDIR=$(BASILISKII_IPKG_TMP) install
	mkdir -p $(BASILISKII_IPKG_TMP)/CONTROL
	echo "Package: basiliskii" 							 >$(BASILISKII_IPKG_TMP)/CONTROL/control
	echo "Source: $(BASILISKII_URL)"						>>$(BASILISKII_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(BASILISKII_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(BASILISKII_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(BASILISKII_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(BASILISKII_IPKG_TMP)/CONTROL/control
	echo "Version: $(BASILISKII_VERSION)-$(BASILISKII_VENDOR_VERSION)" 		>>$(BASILISKII_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(BASILISKII_IPKG_TMP)/CONTROL/control
	echo "Description: Basilisk II is an Open Source 680x0 Macintosh emulator developed by Christian Bauer." >>$(BASILISKII_IPKG_TMP)/CONTROL/control
	asasd
	cd $(FEEDDIR) && $(XMKIPKG) $(BASILISKII_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BASILISKII_INSTALL
ROMPACKAGES += $(STATEDIR)/BasiliskII.imageinstall
endif

BasiliskII_imageinstall_deps = $(STATEDIR)/BasiliskII.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/BasiliskII.imageinstall: $(BasiliskII_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install basiliskii
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

BasiliskII_clean:
	rm -rf $(STATEDIR)/BasiliskII.*
	rm -rf $(BASILISKII_DIR)

# vim: syntax=make
