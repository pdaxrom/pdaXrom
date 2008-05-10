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
HOST_PACKAGES-$(PTXCONF_HOST_SHARED_MIME_INFO) += host-shared-mime-info

#
# Paths and names
#
HOST_SHARED_MIME_INFO_DIR	= $(HOST_BUILDDIR)/$(SHARED_MIME_INFO)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

host-shared-mime-info_get: $(STATEDIR)/host-shared-mime-info.get

$(STATEDIR)/host-shared-mime-info.get: $(STATEDIR)/shared-mime-info.get
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

host-shared-mime-info_extract: $(STATEDIR)/host-shared-mime-info.extract

$(STATEDIR)/host-shared-mime-info.extract: $(host-shared-mime-info_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(HOST_SHARED_MIME_INFO_DIR))
	@$(call extract, SHARED_MIME_INFO, $(HOST_BUILDDIR))
	@$(call patchin, SHARED_MIME_INFO, $(HOST_SHARED_MIME_INFO_DIR))
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

host-shared-mime-info_prepare: $(STATEDIR)/host-shared-mime-info.prepare

HOST_SHARED_MIME_INFO_PATH	:= PATH=$(HOST_PATH)
HOST_SHARED_MIME_INFO_ENV 	:= $(HOST_ENV)

#
# autoconf
#
HOST_SHARED_MIME_INFO_AUTOCONF	:= $(HOST_AUTOCONF)

$(STATEDIR)/host-shared-mime-info.prepare: $(host-shared-mime-info_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(HOST_SHARED_MIME_INFO_DIR)/config.cache)
	cd $(HOST_SHARED_MIME_INFO_DIR) && \
		$(HOST_SHARED_MIME_INFO_PATH) $(HOST_SHARED_MIME_INFO_ENV) \
		./configure $(HOST_SHARED_MIME_INFO_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

host-shared-mime-info_compile: $(STATEDIR)/host-shared-mime-info.compile

$(STATEDIR)/host-shared-mime-info.compile: $(host-shared-mime-info_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(HOST_SHARED_MIME_INFO_DIR) && $(HOST_SHARED_MIME_INFO_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

host-shared-mime-info_install: $(STATEDIR)/host-shared-mime-info.install

$(STATEDIR)/host-shared-mime-info.install: $(host-shared-mime-info_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, HOST_SHARED_MIME_INFO,,h)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

host-shared-mime-info_clean:
	rm -rf $(STATEDIR)/host-shared-mime-info.*
	rm -rf $(HOST_SHARED_MIME_INFO_DIR)

# vim: syntax=make
