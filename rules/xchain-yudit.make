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
ifdef PTXCONF_XCHAIN_YUDIT
PACKAGES += xchain-yudit
endif

#
# Paths and names
#
XCHAIN_YUDIT			= yudit-$(YUDIT_VERSION)
XCHAIN_YUDIT_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_YUDIT)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-yudit_get: $(STATEDIR)/xchain-yudit.get

xchain-yudit_get_deps = $(XCHAIN_YUDIT_SOURCE)

$(STATEDIR)/xchain-yudit.get: $(yudit_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_YUDIT))
	touch $@

$(XCHAIN_YUDIT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_YUDIT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-yudit_extract: $(STATEDIR)/xchain-yudit.extract

xchain-yudit_extract_deps = $(STATEDIR)/xchain-yudit.get

$(STATEDIR)/xchain-yudit.extract: $(yudit_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_YUDIT_DIR))
	@$(call extract, $(YUDIT_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_YUDIT), $(XCHAIN_YUDIT_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-yudit_prepare: $(STATEDIR)/xchain-yudit.prepare

#
# dependencies
#
xchain-yudit_prepare_deps = \
	$(STATEDIR)/xchain-yudit.extract

XCHAIN_YUDIT_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_YUDIT_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_YUDIT_ENV	+=

#
# autoconf
#
XCHAIN_YUDIT_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-yudit.prepare: $(xchain-yudit_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_YUDIT_DIR)/config.cache)
	cd $(XCHAIN_YUDIT_DIR) && \
		$(XCHAIN_YUDIT_PATH) $(XCHAIN_YUDIT_ENV) \
		./configure $(XCHAIN_YUDIT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-yudit_compile: $(STATEDIR)/xchain-yudit.compile

xchain-yudit_compile_deps = $(STATEDIR)/xchain-yudit.prepare

$(STATEDIR)/xchain-yudit.compile: $(xchain-yudit_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_YUDIT_PATH) $(MAKE) -C $(XCHAIN_YUDIT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-yudit_install: $(STATEDIR)/xchain-yudit.install

$(STATEDIR)/xchain-yudit.install: $(STATEDIR)/xchain-yudit.compile
	@$(call targetinfo, $@)
	#$(XCHAIN_YUDIT_PATH) $(MAKE) -C $(XCHAIN_YUDIT_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-yudit_targetinstall: $(STATEDIR)/xchain-yudit.targetinstall

xchain-yudit_targetinstall_deps = $(STATEDIR)/xchain-yudit.compile

$(STATEDIR)/xchain-yudit.targetinstall: $(xchain-yudit_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-yudit_clean:
	rm -rf $(STATEDIR)/xchain-yudit.*
	rm -rf $(XCHAIN_YUDIT_DIR)

# vim: syntax=make
