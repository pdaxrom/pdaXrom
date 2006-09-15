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
ifdef PTXCONF_QEMU
PACKAGES += qemu
endif

#
# Paths and names
#
QEMU_VENDOR_VERSION	= 1
#QEMU_VERSION		= 0.7.2
QEMU_VERSION		= 0.8.2
QEMU			= qemu-$(QEMU_VERSION)
QEMU_SUFFIX		= tar.gz
QEMU_URL		= http://fabrice.bellard.free.fr/qemu/$(QEMU).$(QEMU_SUFFIX)
QEMU_SOURCE		= $(SRCDIR)/$(QEMU).$(QEMU_SUFFIX)
QEMU_DIR		= $(BUILDDIR)/$(QEMU)
QEMU_IPKG_TMP		= $(QEMU_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

qemu_get: $(STATEDIR)/qemu.get

qemu_get_deps = $(QEMU_SOURCE)

$(STATEDIR)/qemu.get: $(qemu_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QEMU))
	touch $@

$(QEMU_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QEMU_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

qemu_extract: $(STATEDIR)/qemu.extract

qemu_extract_deps = $(STATEDIR)/qemu.get

$(STATEDIR)/qemu.extract: $(qemu_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QEMU_DIR))
	@$(call extract, $(QEMU_SOURCE))
	@$(call patchin, $(QEMU))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

qemu_prepare: $(STATEDIR)/qemu.prepare

#
# dependencies
#
qemu_prepare_deps = \
	$(STATEDIR)/qemu.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_ALSA-UTILS
qemu_prepare_deps += $(STATEDIR)/alsa-lib.install
endif

QEMU_PATH	=  PATH=$(CROSS_PATH)
QEMU_ENV 	=  $(CROSS_ENV)
#QEMU_ENV	+=
QEMU_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#QEMU_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
QEMU_AUTOCONF = \
	--build=$(GNU_HOST) \
	--cross-prefix=$(PTXCONF_GNU_TARGET)- \
	--prefix=/usr \
	--kernel-path=$(KERNEL_DIR)

ifdef PTXCONF_ALSA-UTILS
QEMU_AUTOCONF += --enable-alsa
endif

#ifdef PTXCONF_XFREE430
#QEMU_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
#QEMU_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
#endif

$(STATEDIR)/qemu.prepare: $(qemu_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QEMU_DIR)/config.cache)
	cd $(QEMU_DIR) && \
		$(QEMU_PATH) $(QEMU_ENV) \
		./configure $(QEMU_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

qemu_compile: $(STATEDIR)/qemu.compile

qemu_compile_deps = $(STATEDIR)/qemu.prepare

$(STATEDIR)/qemu.compile: $(qemu_compile_deps)
	@$(call targetinfo, $@)
	$(QEMU_PATH) $(QEMU_ENV) $(MAKE) -C $(QEMU_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

qemu_install: $(STATEDIR)/qemu.install

$(STATEDIR)/qemu.install: $(STATEDIR)/qemu.compile
	@$(call targetinfo, $@)
	##$(QEMU_PATH) $(MAKE) -C $(QEMU_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

qemu_targetinstall: $(STATEDIR)/qemu.targetinstall

qemu_targetinstall_deps = $(STATEDIR)/qemu.compile \
	$(STATEDIR)/SDL.targetinstall

ifdef PTXCONF_ALSA-UTILS
qemu_targetinstall_deps += $(STATEDIR)/alsa-lib.targetinstall
QEMU-ALSA-UTILS-DEP = ", alsa-lib"
endif

$(STATEDIR)/qemu.targetinstall: $(qemu_targetinstall_deps)
	@$(call targetinfo, $@)
	$(QEMU_PATH) $(QEMU_ENV) $(MAKE) -C $(QEMU_DIR) DESTDIR=$(QEMU_IPKG_TMP) install
	mkdir -p $(QEMU_IPKG_TMP)/usr/gnemul
	mkdir -p $(QEMU_IPKG_TMP)/CONTROL
	echo "Package: qemu" 										 >$(QEMU_IPKG_TMP)/CONTROL/control
	echo "Source: $(QEMU_URL)"									>>$(QEMU_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(QEMU_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 									>>$(QEMU_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 						>>$(QEMU_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(QEMU_IPKG_TMP)/CONTROL/control
	echo "Version: $(QEMU_VERSION)-$(QEMU_VENDOR_VERSION)" 						>>$(QEMU_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl$(QEMU-ALSA-UTILS-DEP)" 							>>$(QEMU_IPKG_TMP)/CONTROL/control
	echo "Description: QEMU is a generic and open source processor emulator which achieves a good emulation speed by using dynamic translation." >>$(QEMU_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(QEMU_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QEMU_INSTALL
ROMPACKAGES += $(STATEDIR)/qemu.imageinstall
endif

qemu_imageinstall_deps = $(STATEDIR)/qemu.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/qemu.imageinstall: $(qemu_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install qemu
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

qemu_clean:
	rm -rf $(STATEDIR)/qemu.*
	rm -rf $(QEMU_DIR)

# vim: syntax=make
