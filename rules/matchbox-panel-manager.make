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
PACKAGES-$(PTXCONF_MATCHBOX_PANEL_MANAGER) += matchbox-panel-manager

#
# Paths and names
#
MATCHBOX_PANEL_MANAGER_VERSION	:= 0.1
MATCHBOX_PANEL_MANAGER		:= matchbox-panel-manager-$(MATCHBOX_PANEL_MANAGER_VERSION)
MATCHBOX_PANEL_MANAGER_SUFFIX	:= tar.bz2
MATCHBOX_PANEL_MANAGER_URL	:= http://matchbox-project.org/sources/matchbox-panel-manager/0.1/$(MATCHBOX_PANEL_MANAGER).$(MATCHBOX_PANEL_MANAGER_SUFFIX)
MATCHBOX_PANEL_MANAGER_SOURCE	:= $(SRCDIR)/$(MATCHBOX_PANEL_MANAGER).$(MATCHBOX_PANEL_MANAGER_SUFFIX)
MATCHBOX_PANEL_MANAGER_DIR	:= $(BUILDDIR)/$(MATCHBOX_PANEL_MANAGER)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox-panel-manager_get: $(STATEDIR)/matchbox-panel-manager.get

$(STATEDIR)/matchbox-panel-manager.get: $(matchbox-panel-manager_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MATCHBOX_PANEL_MANAGER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MATCHBOX_PANEL_MANAGER)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox-panel-manager_extract: $(STATEDIR)/matchbox-panel-manager.extract

$(STATEDIR)/matchbox-panel-manager.extract: $(matchbox-panel-manager_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_PANEL_MANAGER_DIR))
	@$(call extract, MATCHBOX_PANEL_MANAGER)
	@$(call patchin, MATCHBOX_PANEL_MANAGER)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox-panel-manager_prepare: $(STATEDIR)/matchbox-panel-manager.prepare

MATCHBOX_PANEL_MANAGER_PATH	:= PATH=$(CROSS_PATH)
MATCHBOX_PANEL_MANAGER_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MATCHBOX_PANEL_MANAGER_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/matchbox-panel-manager.prepare: $(matchbox-panel-manager_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_PANEL_MANAGER_DIR)/config.cache)
	cd $(MATCHBOX_PANEL_MANAGER_DIR) && \
		$(MATCHBOX_PANEL_MANAGER_PATH) $(MATCHBOX_PANEL_MANAGER_ENV) \
		./configure $(MATCHBOX_PANEL_MANAGER_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox-panel-manager_compile: $(STATEDIR)/matchbox-panel-manager.compile

$(STATEDIR)/matchbox-panel-manager.compile: $(matchbox-panel-manager_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MATCHBOX_PANEL_MANAGER_DIR) && $(MATCHBOX_PANEL_MANAGER_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox-panel-manager_install: $(STATEDIR)/matchbox-panel-manager.install

$(STATEDIR)/matchbox-panel-manager.install: $(matchbox-panel-manager_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox-panel-manager_targetinstall: $(STATEDIR)/matchbox-panel-manager.targetinstall

$(STATEDIR)/matchbox-panel-manager.targetinstall: $(matchbox-panel-manager_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, matchbox-panel-manager)
	@$(call install_fixup, matchbox-panel-manager,PACKAGE,matchbox-panel-manager)
	@$(call install_fixup, matchbox-panel-manager,PRIORITY,optional)
	@$(call install_fixup, matchbox-panel-manager,VERSION,$(MATCHBOX_PANEL_MANAGER_VERSION))
	@$(call install_fixup, matchbox-panel-manager,SECTION,base)
	@$(call install_fixup, matchbox-panel-manager,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, matchbox-panel-manager,DEPENDS,)
	@$(call install_fixup, matchbox-panel-manager,DESCRIPTION,missing)

	@$(call install_copy, matchbox-panel-manager, 0, 0, 0755, $(MATCHBOX_PANEL_MANAGER_DIR)/matchbox-panel-manager, /usr/bin/matchbox-panel-manager)
	@$(call install_copy, matchbox-panel-manager, 0, 0, 0644, $(MATCHBOX_PANEL_MANAGER_DIR)/mb-panel-manager.desktop,/usr/share/applications/mb-panel-manager.desktop)
	@$(call install_copy, matchbox-panel-manager, 0, 0, 0644, $(MATCHBOX_PANEL_MANAGER_DIR)/mbpanelmgr.png, /usr/share/pixmaps/mbpanelmgr.png)	

	@$(call install_finish, matchbox-panel-manager)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox-panel-manager_clean:
	rm -rf $(STATEDIR)/matchbox-panel-manager.*
	rm -rf $(IMAGEDIR)/matchbox-panel-manager_*
	rm -rf $(MATCHBOX_PANEL_MANAGER_DIR)

# vim: syntax=make
