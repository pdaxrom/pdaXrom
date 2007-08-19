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
ifdef PTXCONF_XCHAIN_KDE-PIM
PACKAGES += xchain-kde-pim
endif

#
# Paths and names
#
XCHAIN_KDE-PIM			= $(KDE-PIM)
XCHAIN_KDE-PIM_SUFFIX		= tar.bz2
XCHAIN_KDE-PIM_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_KDE-PIM)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-kde-pim_get: $(STATEDIR)/xchain-kde-pim.get

xchain-kde-pim_get_deps = $(XCHAIN_KDE-PIM_SOURCE)

$(STATEDIR)/xchain-kde-pim.get: $(xchain-kde-pim_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_KDE-PIM))
	touch $@

$(XCHAIN_KDE-PIM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_KDE-PIM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-kde-pim_extract: $(STATEDIR)/xchain-kde-pim.extract

xchain-kde-pim_extract_deps = $(STATEDIR)/kde-pim.get

$(STATEDIR)/xchain-kde-pim.extract: $(xchain-kde-pim_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_KDE-PIM_DIR))
	@$(call extract, $(KDE-PIM_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_KDE-PIM), $(XCHAIN_KDE-PIM_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-kde-pim_prepare: $(STATEDIR)/xchain-kde-pim.prepare

#
# dependencies
#
xchain-kde-pim_prepare_deps = \
	$(STATEDIR)/xchain-kde-pim.extract \
	$(STATEDIR)/xchain-kdelibs.install

XCHAIN_KDE-PIM_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_KDE-PIM_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_KDE-PIM_ENV	+=

#
# autoconf
#
XCHAIN_KDE-PIM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--without-arts \
	--with-extra-includes=$(NATIVE_SDK_FILES_PREFIX)/include \
	--prefix=$(XCHAIN_KDELIBS_DIR)/kde-fake-root
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-kde-pim.prepare: $(xchain-kde-pim_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_KDE-PIM_DIR)/config.cache)
	cd $(XCHAIN_KDE-PIM_DIR) && \
		$(XCHAIN_KDE-PIM_PATH) $(XCHAIN_KDE-PIM_ENV) \
		./configure $(XCHAIN_KDE-PIM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-kde-pim_compile: $(STATEDIR)/xchain-kde-pim.compile

xchain-kde-pim_compile_deps = $(STATEDIR)/xchain-kde-pim.prepare

$(STATEDIR)/xchain-kde-pim.compile: $(xchain-kde-pim_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_KDE-PIM_PATH) $(MAKE) -C $(XCHAIN_KDE-PIM_DIR)/kode
	#$(XCHAIN_KDE-PIM_PATH) $(MAKE) -C $(XCHAIN_KDE-PIM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-kde-pim_install: $(STATEDIR)/xchain-kde-pim.install

$(STATEDIR)/xchain-kde-pim.install: $(STATEDIR)/xchain-kde-pim.compile
	@$(call targetinfo, $@)
	$(XCHAIN_KDE-PIM_PATH) $(MAKE) -C $(XCHAIN_KDE-PIM_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-kde-pim_targetinstall: $(STATEDIR)/xchain-kde-pim.targetinstall

xchain-kde-pim_targetinstall_deps = $(STATEDIR)/xchain-kde-pim.compile

$(STATEDIR)/xchain-kde-pim.targetinstall: $(xchain-kde-pim_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-kde-pim_clean:
	rm -rf $(STATEDIR)/xchain-kde-pim.*
	rm -rf $(XCHAIN_KDE-PIM_DIR)

# vim: syntax=make
