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
PACKAGES-$(PTXCONF_MATCHBOX_WINDOW_MANAGER) += matchbox-window-manager

#
# Paths and names
#
MATCHBOX_WINDOW_MANAGER_VERSION	:= 1.2
MATCHBOX_WINDOW_MANAGER		:= matchbox-window-manager-$(MATCHBOX_WINDOW_MANAGER_VERSION)
MATCHBOX_WINDOW_MANAGER_SUFFIX	:= tar.bz2
MATCHBOX_WINDOW_MANAGER_URL	:= http://matchbox-project.org/sources/matchbox-window-manager/1.2/$(MATCHBOX_WINDOW_MANAGER).$(MATCHBOX_WINDOW_MANAGER_SUFFIX)
MATCHBOX_WINDOW_MANAGER_SOURCE	:= $(SRCDIR)/$(MATCHBOX_WINDOW_MANAGER).$(MATCHBOX_WINDOW_MANAGER_SUFFIX)
MATCHBOX_WINDOW_MANAGER_DIR	:= $(BUILDDIR)/$(MATCHBOX_WINDOW_MANAGER)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox-window-manager_get: $(STATEDIR)/matchbox-window-manager.get

$(STATEDIR)/matchbox-window-manager.get: $(matchbox-window-manager_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MATCHBOX_WINDOW_MANAGER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MATCHBOX_WINDOW_MANAGER)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox-window-manager_extract: $(STATEDIR)/matchbox-window-manager.extract

$(STATEDIR)/matchbox-window-manager.extract: $(matchbox-window-manager_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_WINDOW_MANAGER_DIR))
	@$(call extract, MATCHBOX_WINDOW_MANAGER)
	@$(call patchin, MATCHBOX_WINDOW_MANAGER)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox-window-manager_prepare: $(STATEDIR)/matchbox-window-manager.prepare

MATCHBOX_WINDOW_MANAGER_PATH	:= PATH=$(CROSS_PATH)
MATCHBOX_WINDOW_MANAGER_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MATCHBOX_WINDOW_MANAGER_AUTOCONF := $(CROSS_AUTOCONF_USR) \
    --enable-startup-notification

$(STATEDIR)/matchbox-window-manager.prepare: $(matchbox-window-manager_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_WINDOW_MANAGER_DIR)/config.cache)
	cd $(MATCHBOX_WINDOW_MANAGER_DIR) && \
		$(MATCHBOX_WINDOW_MANAGER_PATH) $(MATCHBOX_WINDOW_MANAGER_ENV) \
		./configure $(MATCHBOX_WINDOW_MANAGER_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox-window-manager_compile: $(STATEDIR)/matchbox-window-manager.compile

$(STATEDIR)/matchbox-window-manager.compile: $(matchbox-window-manager_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MATCHBOX_WINDOW_MANAGER_DIR) && $(MATCHBOX_WINDOW_MANAGER_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox-window-manager_install: $(STATEDIR)/matchbox-window-manager.install

$(STATEDIR)/matchbox-window-manager.install: $(matchbox-window-manager_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox-window-manager_targetinstall: $(STATEDIR)/matchbox-window-manager.targetinstall

$(STATEDIR)/matchbox-window-manager.targetinstall: $(matchbox-window-manager_targetinstall_deps_default)
	@$(call targetinfo, $@)

	cd $(MATCHBOX_WINDOW_MANAGER_DIR) && $(MATCHBOX_WINDOW_MANAGER_PATH) $(MAKE) $(PARALLELMFLAGS) \
	    DESTDIR=$(MATCHBOX_WINDOW_MANAGER_DIR)/fakeroot install

	@$(call install_init, matchbox-window-manager)
	@$(call install_fixup, matchbox-window-manager,PACKAGE,matchbox-window-manager)
	@$(call install_fixup, matchbox-window-manager,PRIORITY,optional)
	@$(call install_fixup, matchbox-window-manager,VERSION,$(MATCHBOX_WINDOW_MANAGER_VERSION))
	@$(call install_fixup, matchbox-window-manager,SECTION,base)
	@$(call install_fixup, matchbox-window-manager,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, matchbox-window-manager,DEPENDS,"libmatchbox matchbox-common gtk")
	@$(call install_fixup, matchbox-window-manager,DESCRIPTION,missing)

	@$(call install_target, matchbox-window-manager, $(MATCHBOX_WINDOW_MANAGER_DIR)/fakeroot, /)

	@$(call install_finish, matchbox-window-manager)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox-window-manager_clean:
	rm -rf $(STATEDIR)/matchbox-window-manager.*
	rm -rf $(IMAGEDIR)/matchbox-window-manager_*
	rm -rf $(MATCHBOX_WINDOW_MANAGER_DIR)

# vim: syntax=make
