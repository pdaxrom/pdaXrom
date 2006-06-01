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
ifdef PTXCONF_XCHAIN_WRT-UTILS
PACKAGES += xchain-wrt-utils
endif

#
# Paths and names
#
XCHAIN_WRT-UTILS_VERSION	= 1.0.0
XCHAIN_WRT-UTILS		= wrt-utils-$(XCHAIN_WRT-UTILS_VERSION)
XCHAIN_WRT-UTILS_SUFFIX		= tar.bz2
XCHAIN_WRT-UTILS_URL		= http://mail.pdaXrom.org/src/$(XCHAIN_WRT-UTILS).$(XCHAIN_WRT-UTILS_SUFFIX)
XCHAIN_WRT-UTILS_SOURCE		= $(SRCDIR)/$(XCHAIN_WRT-UTILS).$(XCHAIN_WRT-UTILS_SUFFIX)
XCHAIN_WRT-UTILS_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_WRT-UTILS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-wrt-utils_get: $(STATEDIR)/xchain-wrt-utils.get

xchain-wrt-utils_get_deps = $(XCHAIN_WRT-UTILS_SOURCE)

$(STATEDIR)/xchain-wrt-utils.get: $(xchain-wrt-utils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_WRT-UTILS))
	touch $@

$(XCHAIN_WRT-UTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_WRT-UTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-wrt-utils_extract: $(STATEDIR)/xchain-wrt-utils.extract

xchain-wrt-utils_extract_deps = $(STATEDIR)/xchain-wrt-utils.get

$(STATEDIR)/xchain-wrt-utils.extract: $(xchain-wrt-utils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_WRT-UTILS_DIR))
	@$(call extract, $(XCHAIN_WRT-UTILS_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_WRT-UTILS), $(XCHAIN_WRT-UTILS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-wrt-utils_prepare: $(STATEDIR)/xchain-wrt-utils.prepare

#
# dependencies
#
xchain-wrt-utils_prepare_deps = \
	$(STATEDIR)/xchain-wrt-utils.extract

XCHAIN_WRT-UTILS_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_WRT-UTILS_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_WRT-UTILS_ENV	+=

#
# autoconf
#
XCHAIN_WRT-UTILS_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-wrt-utils.prepare: $(xchain-wrt-utils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_WRT-UTILS_DIR)/config.cache)
	#cd $(XCHAIN_WRT-UTILS_DIR) && \
	#	$(XCHAIN_WRT-UTILS_PATH) $(XCHAIN_WRT-UTILS_ENV) \
	#	./configure $(XCHAIN_WRT-UTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-wrt-utils_compile: $(STATEDIR)/xchain-wrt-utils.compile

xchain-wrt-utils_compile_deps = $(STATEDIR)/xchain-wrt-utils.prepare

$(STATEDIR)/xchain-wrt-utils.compile: $(xchain-wrt-utils_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_WRT-UTILS_PATH) $(MAKE) -C $(XCHAIN_WRT-UTILS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-wrt-utils_install: $(STATEDIR)/xchain-wrt-utils.install

$(STATEDIR)/xchain-wrt-utils.install: $(STATEDIR)/xchain-wrt-utils.compile
	@$(call targetinfo, $@)
	#$(XCHAIN_WRT-UTILS_PATH) $(MAKE) -C $(XCHAIN_WRT-UTILS_DIR) install
	cp -a $(XCHAIN_WRT-UTILS_DIR)/{addpattern,motorola-bin,scanner,trx} $(PTXCONF_PREFIX)/bin
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-wrt-utils_targetinstall: $(STATEDIR)/xchain-wrt-utils.targetinstall

xchain-wrt-utils_targetinstall_deps = $(STATEDIR)/xchain-wrt-utils.compile

$(STATEDIR)/xchain-wrt-utils.targetinstall: $(xchain-wrt-utils_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-wrt-utils_clean:
	rm -rf $(STATEDIR)/xchain-wrt-utils.*
	rm -rf $(XCHAIN_WRT-UTILS_DIR)

# vim: syntax=make
