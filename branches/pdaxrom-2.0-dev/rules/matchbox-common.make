# -*-makefile-*-
# $Id: template-make 7626 2007-11-26 10:27:03Z mkl $
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
PACKAGES-$(PTXCONF_MATCHBOX_COMMON) += matchbox-common

#
# Paths and names
#
MATCHBOX_COMMON_VERSION	:= 0.9.1
MATCHBOX_COMMON		:= matchbox-common-$(MATCHBOX_COMMON_VERSION)
MATCHBOX_COMMON_SUFFIX	:= tar.bz2
MATCHBOX_COMMON_URL	:= http://matchbox-project.org/sources/matchbox-common/0.9/$(MATCHBOX_COMMON).$(MATCHBOX_COMMON_SUFFIX)
MATCHBOX_COMMON_SOURCE	:= $(SRCDIR)/$(MATCHBOX_COMMON).$(MATCHBOX_COMMON_SUFFIX)
MATCHBOX_COMMON_DIR	:= $(BUILDDIR)/$(MATCHBOX_COMMON)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox-common_get: $(STATEDIR)/matchbox-common.get

$(STATEDIR)/matchbox-common.get: $(matchbox-common_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MATCHBOX_COMMON_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MATCHBOX_COMMON)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox-common_extract: $(STATEDIR)/matchbox-common.extract

$(STATEDIR)/matchbox-common.extract: $(matchbox-common_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_COMMON_DIR))
	@$(call extract, MATCHBOX_COMMON)
	@$(call patchin, MATCHBOX_COMMON)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox-common_prepare: $(STATEDIR)/matchbox-common.prepare

MATCHBOX_COMMON_PATH	:= PATH=$(CROSS_PATH)
MATCHBOX_COMMON_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MATCHBOX_COMMON_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/matchbox-common.prepare: $(matchbox-common_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_COMMON_DIR)/config.cache)
	cd $(MATCHBOX_COMMON_DIR) && \
		$(MATCHBOX_COMMON_PATH) $(MATCHBOX_COMMON_ENV) \
		./configure $(MATCHBOX_COMMON_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox-common_compile: $(STATEDIR)/matchbox-common.compile

$(STATEDIR)/matchbox-common.compile: $(matchbox-common_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MATCHBOX_COMMON_DIR) && $(MATCHBOX_COMMON_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox-common_install: $(STATEDIR)/matchbox-common.install

$(STATEDIR)/matchbox-common.install: $(matchbox-common_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, MATCHBOX_COMMON)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox-common_targetinstall: $(STATEDIR)/matchbox-common.targetinstall

$(STATEDIR)/matchbox-common.targetinstall: $(matchbox-common_targetinstall_deps_default)
	@$(call targetinfo, $@)

	cd $(MATCHBOX_COMMON_DIR) && $(MATCHBOX_COMMON_PATH) $(MAKE) $(PARALLELMFLAGS) DESTDIR=$(MATCHBOX_COMMON_DIR)/fakeroot install

	@$(call install_init, matchbox-common)
	@$(call install_fixup, matchbox-common,PACKAGE,matchbox-common)
	@$(call install_fixup, matchbox-common,PRIORITY,optional)
	@$(call install_fixup, matchbox-common,VERSION,$(MATCHBOX_COMMON_VERSION))
	@$(call install_fixup, matchbox-common,SECTION,base)
	@$(call install_fixup, matchbox-common,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, matchbox-common,DEPENDS, libmatchbox)
	@$(call install_fixup, matchbox-common,DESCRIPTION,missing)

	@$(call install_target, matchbox-common, $(MATCHBOX_COMMON_DIR)/fakeroot/usr, /usr)
	
	@$(call install_finish, matchbox-common)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox-common_clean:
	rm -rf $(STATEDIR)/matchbox-common.*
	rm -rf $(IMAGEDIR)/matchbox-common_*
	rm -rf $(MATCHBOX_COMMON_DIR)

# vim: syntax=make
