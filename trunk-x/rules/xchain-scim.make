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
ifdef PTXCONF_XCHAIN_SCIM
PACKAGES += xchain-scim
endif

#
# Paths and names
#
XCHAIN_SCIM		= scim-$(SCIM_VERSION)
XCHAIN_SCIM_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_SCIM)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-scim_extract: $(STATEDIR)/xchain-scim.extract

xchain-scim_extract_deps = $(STATEDIR)/scim.get

$(STATEDIR)/xchain-scim.extract: $(xchain-scim_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_SCIM_DIR))
	@$(call extract, $(SCIM_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_SCIM), $(XCHAIN_SCIM_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-scim_prepare: $(STATEDIR)/xchain-scim.prepare

#
# dependencies
#
xchain-scim_prepare_deps = \
	$(STATEDIR)/xchain-scim.extract

XCHAIN_SCIM_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_SCIM_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_SCIM_ENV		+= LDFLAGS="-lstdc++"

#
# autoconf
#
XCHAIN_SCIM_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST) \
	--disable-debug \
	--disable-shared \
	--enable-static \
	--disable-gtk2-immodule \
	--disable-panel-gtk \
	--disable-setup-ui

# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-scim.prepare: $(xchain-scim_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_SCIM_DIR)/config.cache)
	cd $(XCHAIN_SCIM_DIR) && \
		$(XCHAIN_SCIM_PATH) $(XCHAIN_SCIM_ENV) \
		./configure $(XCHAIN_SCIM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-scim_compile: $(STATEDIR)/xchain-scim.compile

xchain-scim_compile_deps = $(STATEDIR)/xchain-scim.prepare

$(STATEDIR)/xchain-scim.compile: $(xchain-scim_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_SCIM_PATH) $(MAKE) -C $(XCHAIN_SCIM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-scim_install: $(STATEDIR)/xchain-scim.install

$(STATEDIR)/xchain-scim.install: $(STATEDIR)/xchain-scim.compile
	@$(call targetinfo, $@)
	$(XCHAIN_SCIM_PATH) $(MAKE) -C $(XCHAIN_SCIM_DIR)/src install
	$(XCHAIN_SCIM_PATH) $(MAKE) -C $(XCHAIN_SCIM_DIR) install-pkgconfigDATA
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-scim_targetinstall: $(STATEDIR)/xchain-scim.targetinstall

xchain-scim_targetinstall_deps = $(STATEDIR)/xchain-scim.compile

$(STATEDIR)/xchain-scim.targetinstall: $(xchain-scim_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-scim_clean:
	rm -rf $(STATEDIR)/xchain-scim.*
	rm -rf $(XCHAIN_SCIM_DIR)

# vim: syntax=make
