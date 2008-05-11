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
HOST_PACKAGES-$(PTXCONF_HOST_LIBIDL_2) += host-libidl-2

#
# Paths and names
#
HOST_LIBIDL_2_DIR	= $(HOST_BUILDDIR)/$(LIBIDL_2)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

host-libidl-2_get: $(STATEDIR)/host-libidl-2.get

$(STATEDIR)/host-libidl-2.get: $(STATEDIR)/libidl-2.get
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

host-libidl-2_extract: $(STATEDIR)/host-libidl-2.extract

$(STATEDIR)/host-libidl-2.extract: $(host-libidl-2_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(HOST_LIBIDL_2_DIR))
	@$(call extract, LIBIDL_2, $(HOST_BUILDDIR))
	@$(call patchin, LIBIDL_2, $(HOST_LIBIDL_2_DIR))
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

host-libidl-2_prepare: $(STATEDIR)/host-libidl-2.prepare

HOST_LIBIDL_2_PATH	:= PATH=$(HOST_PATH)
HOST_LIBIDL_2_ENV 	:= $(HOST_ENV)

#
# autoconf
#
HOST_LIBIDL_2_AUTOCONF	:= $(HOST_AUTOCONF)

$(STATEDIR)/host-libidl-2.prepare: $(host-libidl-2_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(HOST_LIBIDL_2_DIR)/config.cache)
	cd $(HOST_LIBIDL_2_DIR) && \
		$(HOST_LIBIDL_2_PATH) $(HOST_LIBIDL_2_ENV) \
		./configure $(HOST_LIBIDL_2_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

host-libidl-2_compile: $(STATEDIR)/host-libidl-2.compile

$(STATEDIR)/host-libidl-2.compile: $(host-libidl-2_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(HOST_LIBIDL_2_DIR) && $(HOST_LIBIDL_2_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

host-libidl-2_install: $(STATEDIR)/host-libidl-2.install

$(STATEDIR)/host-libidl-2.install: $(host-libidl-2_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, HOST_LIBIDL_2,,h)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

host-libidl-2_clean:
	rm -rf $(STATEDIR)/host-libidl-2.*
	rm -rf $(HOST_LIBIDL_2_DIR)

# vim: syntax=make
