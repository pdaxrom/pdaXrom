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
PACKAGES-$(PTXCONF_MB_APPLET_INPUT_MANAGER) += mb-applet-input-manager

#
# Paths and names
#
MB_APPLET_INPUT_MANAGER_VERSION	:= 0.6
MB_APPLET_INPUT_MANAGER		:= mb-applet-input-manager-$(MB_APPLET_INPUT_MANAGER_VERSION)
MB_APPLET_INPUT_MANAGER_SUFFIX	:= tar.bz2
MB_APPLET_INPUT_MANAGER_URL	:= http://matchbox-project.org/sources/mb-applet-input-manager/0.6/$(MB_APPLET_INPUT_MANAGER).$(MB_APPLET_INPUT_MANAGER_SUFFIX)
MB_APPLET_INPUT_MANAGER_SOURCE	:= $(SRCDIR)/$(MB_APPLET_INPUT_MANAGER).$(MB_APPLET_INPUT_MANAGER_SUFFIX)
MB_APPLET_INPUT_MANAGER_DIR	:= $(BUILDDIR)/$(MB_APPLET_INPUT_MANAGER)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-applet-input-manager_get: $(STATEDIR)/mb-applet-input-manager.get

$(STATEDIR)/mb-applet-input-manager.get: $(mb-applet-input-manager_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MB_APPLET_INPUT_MANAGER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MB_APPLET_INPUT_MANAGER)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-applet-input-manager_extract: $(STATEDIR)/mb-applet-input-manager.extract

$(STATEDIR)/mb-applet-input-manager.extract: $(mb-applet-input-manager_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MB_APPLET_INPUT_MANAGER_DIR))
	@$(call extract, MB_APPLET_INPUT_MANAGER)
	@$(call patchin, MB_APPLET_INPUT_MANAGER)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-applet-input-manager_prepare: $(STATEDIR)/mb-applet-input-manager.prepare

MB_APPLET_INPUT_MANAGER_PATH	:= PATH=$(CROSS_PATH)
MB_APPLET_INPUT_MANAGER_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MB_APPLET_INPUT_MANAGER_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/mb-applet-input-manager.prepare: $(mb-applet-input-manager_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MB_APPLET_INPUT_MANAGER_DIR)/config.cache)
	cd $(MB_APPLET_INPUT_MANAGER_DIR) && \
		$(MB_APPLET_INPUT_MANAGER_PATH) $(MB_APPLET_INPUT_MANAGER_ENV) \
		./configure $(MB_APPLET_INPUT_MANAGER_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-applet-input-manager_compile: $(STATEDIR)/mb-applet-input-manager.compile

$(STATEDIR)/mb-applet-input-manager.compile: $(mb-applet-input-manager_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MB_APPLET_INPUT_MANAGER_DIR) && $(MB_APPLET_INPUT_MANAGER_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-applet-input-manager_install: $(STATEDIR)/mb-applet-input-manager.install

$(STATEDIR)/mb-applet-input-manager.install: $(mb-applet-input-manager_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-applet-input-manager_targetinstall: $(STATEDIR)/mb-applet-input-manager.targetinstall

$(STATEDIR)/mb-applet-input-manager.targetinstall: $(mb-applet-input-manager_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, mb-applet-input-manager)
	@$(call install_fixup, mb-applet-input-manager,PACKAGE,mb-applet-input-manager)
	@$(call install_fixup, mb-applet-input-manager,PRIORITY,optional)
	@$(call install_fixup, mb-applet-input-manager,VERSION,$(MB_APPLET_INPUT_MANAGER_VERSION))
	@$(call install_fixup, mb-applet-input-manager,SECTION,base)
	@$(call install_fixup, mb-applet-input-manager,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, mb-applet-input-manager,DEPENDS,matchbox-panel)
	@$(call install_fixup, mb-applet-input-manager,DESCRIPTION,missing)

	@$(call install_copy, mb-applet-input-manager, 0, 0, 0755, $(MB_APPLET_INPUT_MANAGER_DIR)/mbinputmgr, 		/usr/bin/mbinputmgr)
	@$(call install_copy, mb-applet-input-manager, 0, 0, 0644, $(MB_APPLET_INPUT_MANAGER_DIR)/mbinputmgr.desktop, 	/usr/share/applications/mbinputmgr.desktop)
	@$(call install_copy, mb-applet-input-manager, 0, 0, 0644, $(MB_APPLET_INPUT_MANAGER_DIR)/mbinputmgr.png, 	/usr/share/pixmaps/mbinputmgr.png)

	@$(call install_finish, mb-applet-input-manager)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-applet-input-manager_clean:
	rm -rf $(STATEDIR)/mb-applet-input-manager.*
	rm -rf $(IMAGEDIR)/mb-applet-input-manager_*
	rm -rf $(MB_APPLET_INPUT_MANAGER_DIR)

# vim: syntax=make
