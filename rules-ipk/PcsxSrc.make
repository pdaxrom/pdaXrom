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
ifdef PTXCONF_PCSXSRC
PACKAGES += PcsxSrc
endif

#
# Paths and names
#
PCSXSRC_VENDOR_VERSION	= 1
PCSXSRC_VERSION		= 1.5
PCSXSRC			= PcsxSrc-$(PCSXSRC_VERSION)
PCSXSRC_SUFFIX		= tgz
PCSXSRC_URL		= http://www.pcsx.net/downloads/$(PCSXSRC).$(PCSXSRC_SUFFIX)
PCSXSRC_SOURCE		= $(SRCDIR)/$(PCSXSRC).$(PCSXSRC_SUFFIX)
PCSXSRC_DIR		= $(BUILDDIR)/$(PCSXSRC)
PCSXSRC_IPKG_TMP	= $(PCSXSRC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

PcsxSrc_get: $(STATEDIR)/PcsxSrc.get

PcsxSrc_get_deps = $(PCSXSRC_SOURCE)

$(STATEDIR)/PcsxSrc.get: $(PcsxSrc_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PCSXSRC))
	touch $@

$(PCSXSRC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PCSXSRC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

PcsxSrc_extract: $(STATEDIR)/PcsxSrc.extract

PcsxSrc_extract_deps = $(STATEDIR)/PcsxSrc.get

$(STATEDIR)/PcsxSrc.extract: $(PcsxSrc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PCSXSRC_DIR))
	@$(call extract, $(PCSXSRC_SOURCE))
	@$(call patchin, $(PCSXSRC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PcsxSrc_prepare: $(STATEDIR)/PcsxSrc.prepare

#
# dependencies
#
PcsxSrc_prepare_deps = \
	$(STATEDIR)/PcsxSrc.extract \
	$(STATEDIR)/gtk1210.install \
	$(STATEDIR)/virtual-xchain.install

PCSXSRC_PATH	=  PATH=$(CROSS_PATH)
PCSXSRC_ENV 	=  $(CROSS_ENV)
#PCSXSRC_ENV	+=
PCSXSRC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PCSXSRC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PCSXSRC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr/share/pcsx

ifdef PTXCONF_XFREE430
PCSXSRC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PCSXSRC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/PcsxSrc.prepare: $(PcsxSrc_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PCSXSRC_DIR)/config.cache)
	cd $(PCSXSRC_DIR)/Linux && \
		$(PCSXSRC_PATH) $(PCSXSRC_ENV) \
		./configure $(PCSXSRC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

PcsxSrc_compile: $(STATEDIR)/PcsxSrc.compile

PcsxSrc_compile_deps = $(STATEDIR)/PcsxSrc.prepare

$(STATEDIR)/PcsxSrc.compile: $(PcsxSrc_compile_deps)
	@$(call targetinfo, $@)
	$(PCSXSRC_PATH) $(MAKE) -C $(PCSXSRC_DIR)/Linux
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

PcsxSrc_install: $(STATEDIR)/PcsxSrc.install

$(STATEDIR)/PcsxSrc.install: $(STATEDIR)/PcsxSrc.compile
	@$(call targetinfo, $@)
	###$(PCSXSRC_PATH) $(MAKE) -C $(PCSXSRC_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

PcsxSrc_targetinstall: $(STATEDIR)/PcsxSrc.targetinstall

PcsxSrc_targetinstall_deps = $(STATEDIR)/PcsxSrc.compile \
	$(STATEDIR)/PeopsSoftGpu.targetinstall \
	$(STATEDIR)/PeopsSpu.targetinstall \
	$(STATEDIR)/cdriso.targetinstall \
	$(STATEDIR)/padXwin.targetinstall \
	$(STATEDIR)/gtk1210.targetinstall

$(STATEDIR)/PcsxSrc.targetinstall: $(PcsxSrc_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(PCSXSRC_IPKG_TMP)/usr/share/pcsx
	cp -a $(PCSXSRC_DIR)/Linux/pcsx $(PCSXSRC_IPKG_TMP)/usr/share/pcsx/
	mkdir -p $(PCSXSRC_IPKG_TMP)/usr/share/pcsx/Bios
	mkdir -p $(PCSXSRC_IPKG_TMP)/usr/share/pcsx/Plugin
	mkdir -p $(PCSXSRC_IPKG_TMP)/usr/share/pcsx/memcards
	mkdir -p $(PCSXSRC_IPKG_TMP)/usr/bin
	echo "#!/bin/sh"		 >$(PCSXSRC_IPKG_TMP)/usr/bin/pcsx.sh
	echo "cd /usr/share/pcsx" 	>>$(PCSXSRC_IPKG_TMP)/usr/bin/pcsx.sh
	echo "./pcsx"			>>$(PCSXSRC_IPKG_TMP)/usr/bin/pcsx.sh
	chmod 755 			  $(PCSXSRC_IPKG_TMP)/usr/bin/pcsx.sh
	##$(PCSXSRC_PATH) $(MAKE) -C $(PCSXSRC_DIR)/Linux DESTDIR=$(PCSXSRC_IPKG_TMP) install
	mkdir -p $(PCSXSRC_IPKG_TMP)/CONTROL
	echo "Package: pcsx" 								 >$(PCSXSRC_IPKG_TMP)/CONTROL/control
	echo "Source: $(PCSXSRC_URL)"							>>$(PCSXSRC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PCSXSRC_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(PCSXSRC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PCSXSRC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PCSXSRC_IPKG_TMP)/CONTROL/control
	echo "Version: $(PCSXSRC_VERSION)-$(PCSXSRC_VENDOR_VERSION)" 			>>$(PCSXSRC_IPKG_TMP)/CONTROL/control
	echo "Depends: peopssoftgpu, peopsspu, cdriso, padxwin, gtk" 			>>$(PCSXSRC_IPKG_TMP)/CONTROL/control
	echo "Description: PlayStation Emulation for the PC"				>>$(PCSXSRC_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(PCSXSRC_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PCSXSRC_INSTALL
ROMPACKAGES += $(STATEDIR)/PcsxSrc.imageinstall
endif

PcsxSrc_imageinstall_deps = $(STATEDIR)/PcsxSrc.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/PcsxSrc.imageinstall: $(PcsxSrc_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pcsx
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

PcsxSrc_clean:
	rm -rf $(STATEDIR)/PcsxSrc.*
	rm -rf $(PCSXSRC_DIR)

# vim: syntax=make
