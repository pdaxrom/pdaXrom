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
ifdef PTXCONF_PEOPSSOFTGPU
PACKAGES += PeopsSoftGpu
endif

#
# Paths and names
#
PEOPSSOFTGPU_VENDOR_VERSION	= 1
PEOPSSOFTGPU_VERSION		= 117
PEOPSSOFTGPU			= PeopsSoftGpu$(PEOPSSOFTGPU_VERSION)
PEOPSSOFTGPU_SUFFIX		= tar.gz
PEOPSSOFTGPU_URL		= http://citkit.dl.sourceforge.net/sourceforge/peops/$(PEOPSSOFTGPU).$(PEOPSSOFTGPU_SUFFIX)
PEOPSSOFTGPU_SOURCE		= $(SRCDIR)/$(PEOPSSOFTGPU).$(PEOPSSOFTGPU_SUFFIX)
PEOPSSOFTGPU_DIR		= $(BUILDDIR)/$(PEOPSSOFTGPU)/
PEOPSSOFTGPU_IPKG_TMP		= $(PEOPSSOFTGPU_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

PeopsSoftGpu_get: $(STATEDIR)/PeopsSoftGpu.get

PeopsSoftGpu_get_deps = $(PEOPSSOFTGPU_SOURCE)

$(STATEDIR)/PeopsSoftGpu.get: $(PeopsSoftGpu_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PEOPSSOFTGPU))
	touch $@

$(PEOPSSOFTGPU_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PEOPSSOFTGPU_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

PeopsSoftGpu_extract: $(STATEDIR)/PeopsSoftGpu.extract

PeopsSoftGpu_extract_deps = $(STATEDIR)/PeopsSoftGpu.get

$(STATEDIR)/PeopsSoftGpu.extract: $(PeopsSoftGpu_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(PEOPSSOFTGPU_DIR))
	@$(call extract, $(PEOPSSOFTGPU_SOURCE), $(PEOPSSOFTGPU_DIR))
	@$(call patchin, $(PEOPSSOFTGPU), $(PEOPSSOFTGPU_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PeopsSoftGpu_prepare: $(STATEDIR)/PeopsSoftGpu.prepare

#
# dependencies
#
PeopsSoftGpu_prepare_deps = \
	$(STATEDIR)/PeopsSoftGpu.extract \
	$(STATEDIR)/virtual-xchain.install

ifndef PTXCONF_ARCH_X86
PeopsSoftGpu_prepare_deps += $(STATEDIR)/MesaLib.install
endif

PEOPSSOFTGPU_PATH	=  PATH=$(CROSS_PATH)
PEOPSSOFTGPU_ENV 	=  $(CROSS_ENV)
#PEOPSSOFTGPU_ENV	+=
PEOPSSOFTGPU_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PEOPSSOFTGPU_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PEOPSSOFTGPU_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PEOPSSOFTGPU_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PEOPSSOFTGPU_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/PeopsSoftGpu.prepare: $(PeopsSoftGpu_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PEOPSSOFTGPU_DIR)/config.cache)
	#cd $(PEOPSSOFTGPU_DIR) && \
	#	$(PEOPSSOFTGPU_PATH) $(PEOPSSOFTGPU_ENV) \
	#	./configure $(PEOPSSOFTGPU_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

PeopsSoftGpu_compile: $(STATEDIR)/PeopsSoftGpu.compile

PeopsSoftGpu_compile_deps = $(STATEDIR)/PeopsSoftGpu.prepare

$(STATEDIR)/PeopsSoftGpu.compile: $(PeopsSoftGpu_compile_deps)
	@$(call targetinfo, $@)
	$(PEOPSSOFTGPU_PATH) $(PEOPSSOFTGPU_ENV) $(MAKE) -C $(PEOPSSOFTGPU_DIR)/src $(CROSS_ENV_CC) $(CROSS_ENV_STRIP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

PeopsSoftGpu_install: $(STATEDIR)/PeopsSoftGpu.install

$(STATEDIR)/PeopsSoftGpu.install: $(STATEDIR)/PeopsSoftGpu.compile
	@$(call targetinfo, $@)
	##$(PEOPSSOFTGPU_PATH) $(MAKE) -C $(PEOPSSOFTGPU_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

PeopsSoftGpu_targetinstall: $(STATEDIR)/PeopsSoftGpu.targetinstall

PeopsSoftGpu_targetinstall_deps = $(STATEDIR)/PeopsSoftGpu.compile

$(STATEDIR)/PeopsSoftGpu.targetinstall: $(PeopsSoftGpu_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(PEOPSSOFTGPU_PATH) $(PEOPSSOFTGPU_ENV) $(MAKE) -C $(PEOPSSOFTGPU_DIR) DESTDIR=$(PEOPSSOFTGPU_IPKG_TMP) install
	mkdir -p $(PEOPSSOFTGPU_IPKG_TMP)/usr/share/pcsx/Plugin
	cp -a $(PEOPSSOFTGPU_DIR)/src/cfgPeopsSoft			$(PEOPSSOFTGPU_IPKG_TMP)/usr/share/pcsx/
	cp -a $(PEOPSSOFTGPU_DIR)/src/libgpuPeopsSoftX.so.1.0.17	$(PEOPSSOFTGPU_IPKG_TMP)/usr/share/pcsx/Plugin/
	$(CROSSSTRIP) $(PEOPSSOFTGPU_IPKG_TMP)/usr/share/pcsx/cfgPeopsSoft
	$(CROSSSTRIP) $(PEOPSSOFTGPU_IPKG_TMP)/usr/share/pcsx/Plugin/libgpuPeopsSoftX.so.1.0.17
	mkdir -p $(PEOPSSOFTGPU_IPKG_TMP)/CONTROL
	echo "Package: peopssoftgpu" 							 >$(PEOPSSOFTGPU_IPKG_TMP)/CONTROL/control
	echo "Source: $(PEOPSSOFTGPU_URL)"						>>$(PEOPSSOFTGPU_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PEOPSSOFTGPU_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(PEOPSSOFTGPU_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PEOPSSOFTGPU_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PEOPSSOFTGPU_IPKG_TMP)/CONTROL/control
	echo "Version: $(PEOPSSOFTGPU_VERSION)-$(PEOPSSOFTGPU_VENDOR_VERSION)" 		>>$(PEOPSSOFTGPU_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk" 								>>$(PEOPSSOFTGPU_IPKG_TMP)/CONTROL/control
	echo "Description: Software GPU"						>>$(PEOPSSOFTGPU_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(PEOPSSOFTGPU_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PEOPSSOFTGPU_INSTALL
ROMPACKAGES += $(STATEDIR)/PeopsSoftGpu.imageinstall
endif

PeopsSoftGpu_imageinstall_deps = $(STATEDIR)/PeopsSoftGpu.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/PeopsSoftGpu.imageinstall: $(PeopsSoftGpu_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install peopssoftgpu
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

PeopsSoftGpu_clean:
	rm -rf $(STATEDIR)/PeopsSoftGpu.*
	rm -rf $(PEOPSSOFTGPU_DIR)

# vim: syntax=make
