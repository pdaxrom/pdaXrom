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
ifdef PTXCONF_SYSLINUX
PACKAGES += syslinux
endif

#
# Paths and names
#
SYSLINUX_VENDOR_VERSION	= 1
SYSLINUX_VERSION	= 3.11
SYSLINUX		= syslinux-$(SYSLINUX_VERSION)
SYSLINUX_SUFFIX		= tar.bz2
SYSLINUX_URL		= http://www.kernel.org/pub/linux/utils/boot/syslinux/$(SYSLINUX).$(SYSLINUX_SUFFIX)
SYSLINUX_SOURCE		= $(SRCDIR)/$(SYSLINUX).$(SYSLINUX_SUFFIX)
SYSLINUX_DIR		= $(BUILDDIR)/$(SYSLINUX)
SYSLINUX_IPKG_TMP	= $(SYSLINUX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

syslinux_get: $(STATEDIR)/syslinux.get

syslinux_get_deps = $(SYSLINUX_SOURCE)

$(STATEDIR)/syslinux.get: $(syslinux_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SYSLINUX))
	touch $@

$(SYSLINUX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SYSLINUX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

syslinux_extract: $(STATEDIR)/syslinux.extract

syslinux_extract_deps = $(STATEDIR)/syslinux.get

$(STATEDIR)/syslinux.extract: $(syslinux_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SYSLINUX_DIR))
	@$(call extract, $(SYSLINUX_SOURCE))
	@$(call patchin, $(SYSLINUX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

syslinux_prepare: $(STATEDIR)/syslinux.prepare

#
# dependencies
#
syslinux_prepare_deps = \
	$(STATEDIR)/syslinux.extract \
	$(STATEDIR)/xchain-nasm.install \
	$(STATEDIR)/virtual-xchain.install

SYSLINUX_PATH	=  PATH=$(CROSS_PATH)
SYSLINUX_ENV 	=  $(CROSS_ENV)
#SYSLINUX_ENV	+=
SYSLINUX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SYSLINUX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SYSLINUX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
SYSLINUX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SYSLINUX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/syslinux.prepare: $(syslinux_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SYSLINUX_DIR)/config.cache)
	#cd $(SYSLINUX_DIR) && \
	#	$(SYSLINUX_PATH) $(SYSLINUX_ENV) \
	#	./configure $(SYSLINUX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

syslinux_compile: $(STATEDIR)/syslinux.compile

syslinux_compile_deps = $(STATEDIR)/syslinux.prepare

$(STATEDIR)/syslinux.compile: $(syslinux_compile_deps)
	@$(call targetinfo, $@)
	$(SYSLINUX_PATH) $(MAKE) -C $(SYSLINUX_DIR) \
	    $(CROSS_ENV_CC) $(CROSS_ENV_AR) $(CROSS_ENV_RANLIB) $(CROSS_ENV_LD) \
	    $(CROSS_ENV_OBJCOPY) $(CROSS_ENV_STRIP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

syslinux_install: $(STATEDIR)/syslinux.install

$(STATEDIR)/syslinux.install: $(STATEDIR)/syslinux.compile
	@$(call targetinfo, $@)
	$(SYSLINUX_PATH) $(MAKE) -C $(SYSLINUX_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

syslinux_targetinstall: $(STATEDIR)/syslinux.targetinstall

syslinux_targetinstall_deps = $(STATEDIR)/syslinux.compile

$(STATEDIR)/syslinux.targetinstall: $(syslinux_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SYSLINUX_PATH) $(MAKE) -C $(SYSLINUX_DIR) INSTALLROOT=$(SYSLINUX_IPKG_TMP) install
	cp -a $(SYSLINUX_DIR)/unix/syslinux $(SYSLINUX_IPKG_TMP)/usr/bin/
	rm -rf $(SYSLINUX_IPKG_TMP)/usr/lib/syslinux/com32

	for FILE in `find $(SYSLINUX_IPKG_TMP)/ -type f`; do			\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;				\
	    if [  "$$ZZZ" != "" ]; then						\
		$(CROSSSTRIP) $$FILE;						\
	    fi;									\
	done

	mkdir -p $(SYSLINUX_IPKG_TMP)/CONTROL
	echo "Package: syslinux" 							 >$(SYSLINUX_IPKG_TMP)/CONTROL/control
	echo "Source: $(SYSLINUX_URL)"							>>$(SYSLINUX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SYSLINUX_IPKG_TMP)/CONTROL/control
	echo "Section: System"	 							>>$(SYSLINUX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SYSLINUX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SYSLINUX_IPKG_TMP)/CONTROL/control
	echo "Version: $(SYSLINUX_VERSION)-$(SYSLINUX_VENDOR_VERSION)" 			>>$(SYSLINUX_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(SYSLINUX_IPKG_TMP)/CONTROL/control
	echo "Description: The SYSLINUX Project covers lightweight bootloaders for floppy media (SYSLINUX), network booting (PXELINUX), and bootable "El Torito" CD-ROMs (ISOLINUX)." >>$(SYSLINUX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SYSLINUX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SYSLINUX_INSTALL
ROMPACKAGES += $(STATEDIR)/syslinux.imageinstall
endif

syslinux_imageinstall_deps = $(STATEDIR)/syslinux.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/syslinux.imageinstall: $(syslinux_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install syslinux
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

syslinux_clean:
	rm -rf $(STATEDIR)/syslinux.*
	rm -rf $(SYSLINUX_DIR)

# vim: syntax=make
