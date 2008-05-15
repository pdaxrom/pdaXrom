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
HOST_PACKAGES-$(PTXCONF_HOST_LZO) += host-lzo

#
# Paths and names
#
HOST_LZO_DIR	= $(HOST_BUILDDIR)/$(LZO)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

host-lzo_get: $(STATEDIR)/host-lzo.get

$(STATEDIR)/host-lzo.get: $(STATEDIR)/lzo.get
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

host-lzo_extract: $(STATEDIR)/host-lzo.extract

$(STATEDIR)/host-lzo.extract: $(host-lzo_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(HOST_LZO_DIR))
	@$(call extract, LZO, $(HOST_BUILDDIR))
	@$(call patchin, LZO, $(HOST_LZO_DIR))
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

host-lzo_prepare: $(STATEDIR)/host-lzo.prepare

HOST_LZO_PATH	:= PATH=$(HOST_PATH)
HOST_LZO_ENV 	:= $(HOST_ENV)

#
# autoconf
#
HOST_LZO_AUTOCONF	:= $(HOST_AUTOCONF) \
    --enable-shared

$(STATEDIR)/host-lzo.prepare: $(host-lzo_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(HOST_LZO_DIR)/config.cache)
	cd $(HOST_LZO_DIR) && \
		$(HOST_LZO_PATH) $(HOST_LZO_ENV) \
		./configure $(HOST_LZO_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

host-lzo_compile: $(STATEDIR)/host-lzo.compile

$(STATEDIR)/host-lzo.compile: $(host-lzo_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(HOST_LZO_DIR) && $(HOST_LZO_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

host-lzo_install: $(STATEDIR)/host-lzo.install

$(STATEDIR)/host-lzo.install: $(host-lzo_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, HOST_LZO,,h)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

host-lzo_clean:
	rm -rf $(STATEDIR)/host-lzo.*
	rm -rf $(HOST_LZO_DIR)

# vim: syntax=make
