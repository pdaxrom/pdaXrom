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
ifdef PTXCONF_XCHAIN_EFLTK
PACKAGES += xchain-efltk
endif

#
# Paths and names
#
XCHAIN_EFLTK			= efltk-$(EFLTK)
XCHAIN_EFLTK_DIR		= $(XCHAIN_BUILDDIR)/efltk

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-efltk_extract: $(STATEDIR)/xchain-efltk.extract

xchain-efltk_extract_deps = $(STATEDIR)/efltk.get

$(STATEDIR)/xchain-efltk.extract: $(xchain-efltk_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_EFLTK_DIR))
	@$(call extract, $(EFLTK_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_EFLTK), $(XCHAIN_EFLTK_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-efltk_prepare: $(STATEDIR)/xchain-efltk.prepare

#
# dependencies
#
xchain-efltk_prepare_deps = \
	$(STATEDIR)/xchain-efltk.extract

XCHAIN_EFLTK_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_EFLTK_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_EFLTK_ENV	+=

#
# autoconf
#
XCHAIN_EFLTK_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST) \
	--disable-shared \
	--enable-static \
	--enable-xft
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-efltk.prepare: $(xchain-efltk_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_EFLTK_DIR)/config.cache)
	cd $(XCHAIN_EFLTK_DIR) && \
		$(XCHAIN_EFLTK_PATH) $(XCHAIN_EFLTK_ENV) \
		./configure $(XCHAIN_EFLTK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-efltk_compile: $(STATEDIR)/xchain-efltk.compile

xchain-efltk_compile_deps = $(STATEDIR)/xchain-efltk.prepare

$(STATEDIR)/xchain-efltk.compile: $(xchain-efltk_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_EFLTK_PATH) $(MAKE) -C $(XCHAIN_EFLTK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-efltk_install: $(STATEDIR)/xchain-efltk.install

$(STATEDIR)/xchain-efltk.install: $(STATEDIR)/xchain-efltk.compile
	@$(call targetinfo, $@)
	cp -a $(XCHAIN_EFLTK_DIR)/bin/{efluid,etranslate} $(PTXCONF_PREFIX)/bin
	###$(XCHAIN_EFLTK_PATH) $(MAKE) -C $(XCHAIN_EFLTK_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-efltk_targetinstall: $(STATEDIR)/xchain-efltk.targetinstall

xchain-efltk_targetinstall_deps = $(STATEDIR)/xchain-efltk.compile

$(STATEDIR)/xchain-efltk.targetinstall: $(xchain-efltk_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-efltk_clean:
	rm -rf $(STATEDIR)/xchain-efltk.*
	rm -rf $(XCHAIN_EFLTK_DIR)

# vim: syntax=make
