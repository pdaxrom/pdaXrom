# -*-makefile-*-
# $Id$
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
HOST_PACKAGES-$(PTXCONF_HOST_ICU) += host-icu

#
# Paths and names
#
HOST_ICU_DIR	= $(HOST_BUILDDIR)/icu/source

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

host-icu_get: $(STATEDIR)/host-icu.get

$(STATEDIR)/host-icu.get: $(STATEDIR)/icu.get
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

host-icu_extract: $(STATEDIR)/host-icu.extract

$(STATEDIR)/host-icu.extract: $(host-icu_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(HOST_ICU_DIR))
	@$(call extract, ICU, $(HOST_BUILDDIR))
	@$(call patchin, ICU, $(HOST_ICU_DIR))
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

host-icu_prepare: $(STATEDIR)/host-icu.prepare

HOST_ICU_PATH	:= PATH=$(HOST_PATH)
HOST_ICU_ENV 	:= $(HOST_ENV)

#
# autoconf
#
HOST_ICU_AUTOCONF	:= $(HOST_AUTOCONF)

$(STATEDIR)/host-icu.prepare: $(host-icu_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(HOST_ICU_DIR)/config.cache)
	cd $(HOST_ICU_DIR) && \
		$(HOST_ICU_PATH) $(HOST_ICU_ENV) \
		./configure $(HOST_ICU_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

host-icu_compile: $(STATEDIR)/host-icu.compile

$(STATEDIR)/host-icu.compile: $(host-icu_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(HOST_ICU_DIR) && $(HOST_ICU_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

host-icu_install: $(STATEDIR)/host-icu.install

$(STATEDIR)/host-icu.install: $(host-icu_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, HOST_ICU,,h)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

host-icu_clean:
	rm -rf $(STATEDIR)/host-icu.*
	rm -rf $(HOST_ICU_DIR)

# vim: syntax=make
