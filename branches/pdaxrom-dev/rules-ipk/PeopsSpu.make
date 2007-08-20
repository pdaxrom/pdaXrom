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
ifdef PTXCONF_PEOPSSPU
PACKAGES += PeopsSpu
endif

#
# Paths and names
#
PEOPSSPU_VENDOR_VERSION	= 1
PEOPSSPU_VERSION	= 109
PEOPSSPU		= PeopsSpu$(PEOPSSPU_VERSION)
PEOPSSPU_SUFFIX		= tar.gz
PEOPSSPU_URL		= http://citkit.dl.sourceforge.net/sourceforge/peops/$(PEOPSSPU).$(PEOPSSPU_SUFFIX)
PEOPSSPU_SOURCE		= $(SRCDIR)/$(PEOPSSPU).$(PEOPSSPU_SUFFIX)
PEOPSSPU_DIR		= $(BUILDDIR)/$(PEOPSSPU)
PEOPSSPU_IPKG_TMP	= $(PEOPSSPU_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

PeopsSpu_get: $(STATEDIR)/PeopsSpu.get

PeopsSpu_get_deps = $(PEOPSSPU_SOURCE)

$(STATEDIR)/PeopsSpu.get: $(PeopsSpu_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PEOPSSPU))
	touch $@

$(PEOPSSPU_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PEOPSSPU_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

PeopsSpu_extract: $(STATEDIR)/PeopsSpu.extract

PeopsSpu_extract_deps = $(STATEDIR)/PeopsSpu.get

$(STATEDIR)/PeopsSpu.extract: $(PeopsSpu_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(PEOPSSPU_DIR))
	@$(call extract, $(PEOPSSPU_SOURCE), $(PEOPSSPU_DIR))
	@$(call patchin, $(PEOPSSPU), $(PEOPSSPU_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PeopsSpu_prepare: $(STATEDIR)/PeopsSpu.prepare

#
# dependencies
#
PeopsSpu_prepare_deps = \
	$(STATEDIR)/PeopsSpu.extract \
	$(STATEDIR)/gtk1210.install \
	$(STATEDIR)/virtual-xchain.install

PEOPSSPU_PATH	=  PATH=$(CROSS_PATH)
PEOPSSPU_ENV 	=  $(CROSS_ENV)
#PEOPSSPU_ENV	+=
PEOPSSPU_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PEOPSSPU_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PEOPSSPU_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PEOPSSPU_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PEOPSSPU_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/PeopsSpu.prepare: $(PeopsSpu_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PEOPSSPU_DIR)/config.cache)
	#cd $(PEOPSSPU_DIR) && \
	#	$(PEOPSSPU_PATH) $(PEOPSSPU_ENV) \
	#	./configure $(PEOPSSPU_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

PeopsSpu_compile: $(STATEDIR)/PeopsSpu.compile

PeopsSpu_compile_deps = $(STATEDIR)/PeopsSpu.prepare

$(STATEDIR)/PeopsSpu.compile: $(PeopsSpu_compile_deps)
	@$(call targetinfo, $@)
	$(PEOPSSPU_PATH) $(PEOPSSPU_ENV) $(MAKE) -C $(PEOPSSPU_DIR)/src $(CROSS_ENV_CC) $(CROSS_ENV_STRIP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

PeopsSpu_install: $(STATEDIR)/PeopsSpu.install

$(STATEDIR)/PeopsSpu.install: $(STATEDIR)/PeopsSpu.compile
	@$(call targetinfo, $@)
	##$(PEOPSSPU_PATH) $(MAKE) -C $(PEOPSSPU_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

PeopsSpu_targetinstall: $(STATEDIR)/PeopsSpu.targetinstall

PeopsSpu_targetinstall_deps = $(STATEDIR)/PeopsSpu.compile

$(STATEDIR)/PeopsSpu.targetinstall: $(PeopsSpu_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(PEOPSSPU_PATH) $(MAKE) -C $(PEOPSSPU_DIR) DESTDIR=$(PEOPSSPU_IPKG_TMP) install
	mkdir -p $(PEOPSSPU_IPKG_TMP)/usr/share/pcsx/Plugin
	cp -a $(PEOPSSPU_DIR)/src/libspuPeopsOSS.so.1.0.9	$(PEOPSSPU_IPKG_TMP)/usr/share/pcsx/Plugin/
	$(CROSSSTRIP) $(PEOPSSPU_IPKG_TMP)/usr/share/pcsx/Plugin/libspuPeopsOSS.so.1.0.9
	mkdir -p $(PEOPSSPU_IPKG_TMP)/CONTROL
	echo "Package: peopsspu" 							 >$(PEOPSSPU_IPKG_TMP)/CONTROL/control
	echo "Source: $(PEOPSSPU_URL)"							>>$(PEOPSSPU_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PEOPSSPU_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(PEOPSSPU_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PEOPSSPU_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PEOPSSPU_IPKG_TMP)/CONTROL/control
	echo "Version: $(PEOPSSPU_VERSION)-$(PEOPSSPU_VENDOR_VERSION)" 			>>$(PEOPSSPU_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk" 								>>$(PEOPSSPU_IPKG_TMP)/CONTROL/control
	echo "Description: Peops SPU"							>>$(PEOPSSPU_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(PEOPSSPU_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PEOPSSPU_INSTALL
ROMPACKAGES += $(STATEDIR)/PeopsSpu.imageinstall
endif

PeopsSpu_imageinstall_deps = $(STATEDIR)/PeopsSpu.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/PeopsSpu.imageinstall: $(PeopsSpu_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install peopsspu
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

PeopsSpu_clean:
	rm -rf $(STATEDIR)/PeopsSpu.*
	rm -rf $(PEOPSSPU_DIR)

# vim: syntax=make
