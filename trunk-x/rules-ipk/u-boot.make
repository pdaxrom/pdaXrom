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
ifdef PTXCONF_U-BOOT
PACKAGES += u-boot
endif

#
# Paths and names
#
U-BOOT_VENDOR_VERSION	= 1
U-BOOT_VERSION		= 2006-04-18-1106
U-BOOT			= u-boot-$(U-BOOT_VERSION)
U-BOOT_SUFFIX		= tar.bz2
U-BOOT_URL		= http://mail.pdaXrom.org/src/$(U-BOOT).$(U-BOOT_SUFFIX)
U-BOOT_SOURCE		= $(SRCDIR)/$(U-BOOT).$(U-BOOT_SUFFIX)
U-BOOT_DIR		= $(BUILDDIR)/$(U-BOOT)
U-BOOT_IPKG_TMP		= $(U-BOOT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

u-boot_get: $(STATEDIR)/u-boot.get

u-boot_get_deps = $(U-BOOT_SOURCE)

$(STATEDIR)/u-boot.get: $(u-boot_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(U-BOOT))
	touch $@

$(U-BOOT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(U-BOOT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

u-boot_extract: $(STATEDIR)/u-boot.extract

u-boot_extract_deps = $(STATEDIR)/u-boot.get

$(STATEDIR)/u-boot.extract: $(u-boot_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(U-BOOT_DIR))
	@$(call extract, $(U-BOOT_SOURCE))
	@$(call patchin, $(U-BOOT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

u-boot_prepare: $(STATEDIR)/u-boot.prepare

#
# dependencies
#
u-boot_prepare_deps = \
	$(STATEDIR)/u-boot.extract \
	$(STATEDIR)/virtual-xchain.install

U-BOOT_PATH	=  PATH=$(CROSS_PATH)
U-BOOT_ENV 	=  $(CROSS_ENV)
#U-BOOT_ENV	+=
U-BOOT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#U-BOOT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
U-BOOT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
U-BOOT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
U-BOOT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/u-boot.prepare: $(u-boot_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(U-BOOT_DIR)/config.cache)
	#cd $(U-BOOT_DIR) && \
	#	$(U-BOOT_PATH) $(U-BOOT_ENV) \
	#	./configure $(U-BOOT_AUTOCONF)
	cd $(U-BOOT_DIR) && $(U-BOOT_PATH) $(MAKE) $(PTXCONF_U-BOOT_CONFIG)_config
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

u-boot_compile: $(STATEDIR)/u-boot.compile

u-boot_compile_deps = $(STATEDIR)/u-boot.prepare

$(STATEDIR)/u-boot.compile: $(u-boot_compile_deps)
	@$(call targetinfo, $@)
	$(U-BOOT_PATH) $(MAKE) -C $(U-BOOT_DIR) CROSS_COMPILE=$(PTXCONF_GNU_TARGET)-
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

u-boot_install: $(STATEDIR)/u-boot.install

$(STATEDIR)/u-boot.install: $(STATEDIR)/u-boot.compile
	@$(call targetinfo, $@)
	##$(U-BOOT_PATH) $(MAKE) -C $(U-BOOT_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

u-boot_targetinstall: $(STATEDIR)/u-boot.targetinstall

u-boot_targetinstall_deps = $(STATEDIR)/u-boot.compile

$(STATEDIR)/u-boot.targetinstall: $(u-boot_targetinstall_deps)
	@$(call targetinfo, $@)
	cp -a $(U-BOOT_DIR)/{u-boot.bin,u-boot.srec} $(TOPDIR)/bootdisk/
	md5sum $(TOPDIR)/bootdisk/u-boot.bin  >$(TOPDIR)/bootdisk/u-boot.bin.md5sum
	md5sum $(TOPDIR)/bootdisk/u-boot.srec >$(TOPDIR)/bootdisk/u-boot.srec.md5sum
	#$(U-BOOT_PATH) $(MAKE) -C $(U-BOOT_DIR) DESTDIR=$(U-BOOT_IPKG_TMP) install
	#mkdir -p $(U-BOOT_IPKG_TMP)/CONTROL
	#echo "Package: u-boot" 								 >$(U-BOOT_IPKG_TMP)/CONTROL/control
	#echo "Source: $(U-BOOT_URL)"							>>$(U-BOOT_IPKG_TMP)/CONTROL/control
	#echo "Priority: optional" 							>>$(U-BOOT_IPKG_TMP)/CONTROL/control
	#echo "Section: System" 								>>$(U-BOOT_IPKG_TMP)/CONTROL/control
	#echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(U-BOOT_IPKG_TMP)/CONTROL/control
	#echo "Architecture: $(SHORT_TARGET)" 						>>$(U-BOOT_IPKG_TMP)/CONTROL/control
	#echo "Version: $(U-BOOT_VERSION)-$(U-BOOT_VENDOR_VERSION)" 			>>$(U-BOOT_IPKG_TMP)/CONTROL/control
	#echo "Depends: " 								>>$(U-BOOT_IPKG_TMP)/CONTROL/control
	#echo "Description: generated with pdaXrom builder"				>>$(U-BOOT_IPKG_TMP)/CONTROL/control
	#cd $(FEEDDIR) && $(XMKIPKG) $(U-BOOT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_U-BOOT_INSTALL
ROMPACKAGES += $(STATEDIR)/u-boot.imageinstall
endif

u-boot_imageinstall_deps = $(STATEDIR)/u-boot.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/u-boot.imageinstall: $(u-boot_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install u-boot
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

u-boot_clean:
	rm -rf $(STATEDIR)/u-boot.*
	rm -rf $(U-BOOT_DIR)

# vim: syntax=make
