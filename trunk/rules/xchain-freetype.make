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
ifdef PTXCONF_XCHAIN_FREETYPE
PACKAGES += xchain-freetype
endif

#
# Paths and names
#
XCHAIN_FREETYPE		= freetype-$(FREETYPE_VERSION)
XCHAIN_FREETYPE_DIR	= $(XCHAIN_BUILDDIR)/$(XCHAIN_FREETYPE)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-freetype_get: $(STATEDIR)/xchain-freetype.get

xchain-freetype_get_deps = $(XCHAIN_FREETYPE_SOURCE)

$(STATEDIR)/xchain-freetype.get: $(xchain-freetype_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_FREETYPE))
	touch $@

$(XCHAIN_FREETYPE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_FREETYPE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-freetype_extract: $(STATEDIR)/xchain-freetype.extract

xchain-freetype_extract_deps = $(STATEDIR)/freetype.get

$(STATEDIR)/xchain-freetype.extract: $(xchain-freetype_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_FREETYPE_DIR))
	@$(call extract, $(FREETYPE_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(FREETYPE), $(XCHAIN_FREETYPE_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-freetype_prepare: $(STATEDIR)/xchain-freetype.prepare

#
# dependencies
#
xchain-freetype_prepare_deps = \
	$(STATEDIR)/xchain-freetype.extract

XCHAIN_FREETYPE_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_FREETYPE_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_FREETYPE_ENV	+=

#
# autoconf
#
XCHAIN_FREETYPE_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-freetype.prepare: $(xchain-freetype_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_FREETYPE_DIR)/config.cache)
	cd $(XCHAIN_FREETYPE_DIR) && \
		$(XCHAIN_FREETYPE_PATH) $(XCHAIN_FREETYPE_ENV) \
		./configure $(XCHAIN_FREETYPE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-freetype_compile: $(STATEDIR)/xchain-freetype.compile

xchain-freetype_compile_deps = $(STATEDIR)/xchain-freetype.prepare

$(STATEDIR)/xchain-freetype.compile: $(xchain-freetype_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_FREETYPE_PATH) $(MAKE) -C $(XCHAIN_FREETYPE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-freetype_install: $(STATEDIR)/xchain-freetype.install

$(STATEDIR)/xchain-freetype.install: $(STATEDIR)/xchain-freetype.compile
	@$(call targetinfo, $@)
	$(XCHAIN_FREETYPE_PATH) $(MAKE) -C $(XCHAIN_FREETYPE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-freetype_targetinstall: $(STATEDIR)/xchain-freetype.targetinstall

xchain-freetype_targetinstall_deps = $(STATEDIR)/xchain-freetype.compile

$(STATEDIR)/xchain-freetype.targetinstall: $(xchain-freetype_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-freetype_clean:
	rm -rf $(STATEDIR)/xchain-freetype.*
	rm -rf $(XCHAIN_FREETYPE_DIR)

# vim: syntax=make
