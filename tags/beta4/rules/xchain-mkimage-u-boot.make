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
ifdef PTXCONF_XCHAIN_MKIMAGE-U-BOOT
PACKAGES += xchain-mkimage-u-boot
endif

#
# Paths and names
#
XCHAIN_MKIMAGE-U-BOOT_VERSION		= 1.1.4
XCHAIN_MKIMAGE-U-BOOT			= mkimage-u-boot-$(XCHAIN_MKIMAGE-U-BOOT_VERSION)
XCHAIN_MKIMAGE-U-BOOT_SUFFIX		= tar.bz2
XCHAIN_MKIMAGE-U-BOOT_URL		= http://www.pdaXrom.org/src/$(XCHAIN_MKIMAGE-U-BOOT).$(XCHAIN_MKIMAGE-U-BOOT_SUFFIX)
XCHAIN_MKIMAGE-U-BOOT_SOURCE		= $(SRCDIR)/$(XCHAIN_MKIMAGE-U-BOOT).$(XCHAIN_MKIMAGE-U-BOOT_SUFFIX)
XCHAIN_MKIMAGE-U-BOOT_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_MKIMAGE-U-BOOT)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-mkimage-u-boot_get: $(STATEDIR)/xchain-mkimage-u-boot.get

xchain-mkimage-u-boot_get_deps = $(XCHAIN_MKIMAGE-U-BOOT_SOURCE)

$(STATEDIR)/xchain-mkimage-u-boot.get: $(xchain-mkimage-u-boot_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_MKIMAGE-U-BOOT))
	touch $@

$(XCHAIN_MKIMAGE-U-BOOT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_MKIMAGE-U-BOOT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-mkimage-u-boot_extract: $(STATEDIR)/xchain-mkimage-u-boot.extract

xchain-mkimage-u-boot_extract_deps = $(STATEDIR)/xchain-mkimage-u-boot.get

$(STATEDIR)/xchain-mkimage-u-boot.extract: $(xchain-mkimage-u-boot_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_MKIMAGE-U-BOOT_DIR))
	@$(call extract, $(XCHAIN_MKIMAGE-U-BOOT_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_MKIMAGE-U-BOOT), $(XCHAIN_MKIMAGE-U-BOOT_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-mkimage-u-boot_prepare: $(STATEDIR)/xchain-mkimage-u-boot.prepare

#
# dependencies
#
xchain-mkimage-u-boot_prepare_deps = \
	$(STATEDIR)/xchain-mkimage-u-boot.extract

XCHAIN_MKIMAGE-U-BOOT_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_MKIMAGE-U-BOOT_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_MKIMAGE-U-BOOT_ENV	+=

#
# autoconf
#
XCHAIN_MKIMAGE-U-BOOT_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-mkimage-u-boot.prepare: $(xchain-mkimage-u-boot_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_MKIMAGE-U-BOOT_DIR)/config.cache)
	#cd $(XCHAIN_MKIMAGE-U-BOOT_DIR) && \
	#	$(XCHAIN_MKIMAGE-U-BOOT_PATH) $(XCHAIN_MKIMAGE-U-BOOT_ENV) \
	#	./configure $(XCHAIN_MKIMAGE-U-BOOT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-mkimage-u-boot_compile: $(STATEDIR)/xchain-mkimage-u-boot.compile

xchain-mkimage-u-boot_compile_deps = $(STATEDIR)/xchain-mkimage-u-boot.prepare

$(STATEDIR)/xchain-mkimage-u-boot.compile: $(xchain-mkimage-u-boot_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_MKIMAGE-U-BOOT_PATH) $(MAKE) -C $(XCHAIN_MKIMAGE-U-BOOT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-mkimage-u-boot_install: $(STATEDIR)/xchain-mkimage-u-boot.install

$(STATEDIR)/xchain-mkimage-u-boot.install: $(STATEDIR)/xchain-mkimage-u-boot.compile
	@$(call targetinfo, $@)
	#$(XCHAIN_MKIMAGE-U-BOOT_PATH) $(MAKE) -C $(XCHAIN_MKIMAGE-U-BOOT_DIR) install
	cp -a $(XCHAIN_MKIMAGE-U-BOOT_DIR)/mkimage $(PTXCONF_PREFIX)/bin
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-mkimage-u-boot_targetinstall: $(STATEDIR)/xchain-mkimage-u-boot.targetinstall

xchain-mkimage-u-boot_targetinstall_deps = $(STATEDIR)/xchain-mkimage-u-boot.compile

$(STATEDIR)/xchain-mkimage-u-boot.targetinstall: $(xchain-mkimage-u-boot_targetinstall_deps)
	@$(call targetinfo, $@)
	cp -a $(XCHAIN_MKIMAGE-U-BOOT_DIR)/mkimage $(PTXCONF_PREFIX)/bin
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-mkimage-u-boot_clean:
	rm -rf $(STATEDIR)/xchain-mkimage-u-boot.*
	rm -rf $(XCHAIN_MKIMAGE-U-BOOT_DIR)

# vim: syntax=make
