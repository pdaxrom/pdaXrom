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
PACKAGES-$(PTXCONF_MATCHBOX_DESKTOP) += matchbox-desktop

#
# Paths and names
#
MATCHBOX_DESKTOP_VERSION	:= 2.0
MATCHBOX_DESKTOP		:= matchbox-desktop-$(MATCHBOX_DESKTOP_VERSION)
MATCHBOX_DESKTOP_SUFFIX		:= tar.bz2
MATCHBOX_DESKTOP_URL		:= http://matchbox-project.org/sources/matchbox-desktop/2.0/$(MATCHBOX_DESKTOP).$(MATCHBOX_DESKTOP_SUFFIX)
MATCHBOX_DESKTOP_SOURCE		:= $(SRCDIR)/$(MATCHBOX_DESKTOP).$(MATCHBOX_DESKTOP_SUFFIX)
MATCHBOX_DESKTOP_DIR		:= $(BUILDDIR)/$(MATCHBOX_DESKTOP)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox-desktop_get: $(STATEDIR)/matchbox-desktop.get

$(STATEDIR)/matchbox-desktop.get: $(matchbox-desktop_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MATCHBOX_DESKTOP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MATCHBOX_DESKTOP)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox-desktop_extract: $(STATEDIR)/matchbox-desktop.extract

$(STATEDIR)/matchbox-desktop.extract: $(matchbox-desktop_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_DESKTOP_DIR))
	@$(call extract, MATCHBOX_DESKTOP)
	@$(call patchin, MATCHBOX_DESKTOP)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox-desktop_prepare: $(STATEDIR)/matchbox-desktop.prepare

MATCHBOX_DESKTOP_PATH	:= PATH=$(CROSS_PATH)
MATCHBOX_DESKTOP_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MATCHBOX_DESKTOP_AUTOCONF := $(CROSS_AUTOCONF_USR) \
    --enable-startup-notification

$(STATEDIR)/matchbox-desktop.prepare: $(matchbox-desktop_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_DESKTOP_DIR)/config.cache)
	cd $(MATCHBOX_DESKTOP_DIR) && \
		$(MATCHBOX_DESKTOP_PATH) $(MATCHBOX_DESKTOP_ENV) \
		./configure $(MATCHBOX_DESKTOP_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox-desktop_compile: $(STATEDIR)/matchbox-desktop.compile

$(STATEDIR)/matchbox-desktop.compile: $(matchbox-desktop_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MATCHBOX_DESKTOP_DIR) && $(MATCHBOX_DESKTOP_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox-desktop_install: $(STATEDIR)/matchbox-desktop.install

$(STATEDIR)/matchbox-desktop.install: $(matchbox-desktop_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, MATCHBOX_DESKTOP)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox-desktop_targetinstall: $(STATEDIR)/matchbox-desktop.targetinstall

$(STATEDIR)/matchbox-desktop.targetinstall: $(matchbox-desktop_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, matchbox-desktop)
	@$(call install_fixup, matchbox-desktop,PACKAGE,matchbox-desktop)
	@$(call install_fixup, matchbox-desktop,PRIORITY,optional)
	@$(call install_fixup, matchbox-desktop,VERSION,$(MATCHBOX_DESKTOP_VERSION))
	@$(call install_fixup, matchbox-desktop,SECTION,base)
	@$(call install_fixup, matchbox-desktop,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, matchbox-desktop,DEPENDS, "libmatchbox matchbox-common gtk")
	@$(call install_fixup, matchbox-desktop,DESCRIPTION,missing)

	@$(call install_copy, matchbox-desktop, 0, 0, 0755, $(MATCHBOX_DESKTOP_DIR)/matchbox-desktop, /usr/bin/matchbox-desktop)

	@$(call install_finish, matchbox-desktop)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox-desktop_clean:
	rm -rf $(STATEDIR)/matchbox-desktop.*
	rm -rf $(IMAGEDIR)/matchbox-desktop_*
	rm -rf $(MATCHBOX_DESKTOP_DIR)

# vim: syntax=make
