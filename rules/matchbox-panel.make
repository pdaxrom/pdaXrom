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
PACKAGES-$(PTXCONF_MATCHBOX_PANEL) += matchbox-panel

#
# Paths and names
#
MATCHBOX_PANEL_VERSION	:= 0.9.3
MATCHBOX_PANEL		:= matchbox-panel-$(MATCHBOX_PANEL_VERSION)
MATCHBOX_PANEL_SUFFIX	:= tar.bz2
MATCHBOX_PANEL_URL	:= http://matchbox-project.org/sources/matchbox-panel/0.9/$(MATCHBOX_PANEL).$(MATCHBOX_PANEL_SUFFIX)
MATCHBOX_PANEL_SOURCE	:= $(SRCDIR)/$(MATCHBOX_PANEL).$(MATCHBOX_PANEL_SUFFIX)
MATCHBOX_PANEL_DIR	:= $(BUILDDIR)/$(MATCHBOX_PANEL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox-panel_get: $(STATEDIR)/matchbox-panel.get

$(STATEDIR)/matchbox-panel.get: $(matchbox-panel_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MATCHBOX_PANEL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MATCHBOX_PANEL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox-panel_extract: $(STATEDIR)/matchbox-panel.extract

$(STATEDIR)/matchbox-panel.extract: $(matchbox-panel_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_PANEL_DIR))
	@$(call extract, MATCHBOX_PANEL)
	@$(call patchin, MATCHBOX_PANEL)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox-panel_prepare: $(STATEDIR)/matchbox-panel.prepare

MATCHBOX_PANEL_PATH	:= PATH=$(CROSS_PATH)
MATCHBOX_PANEL_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MATCHBOX_PANEL_AUTOCONF := $(CROSS_AUTOCONF_USR) \
    --enable-startup-notification \
    --enable-dnotify

$(STATEDIR)/matchbox-panel.prepare: $(matchbox-panel_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_PANEL_DIR)/config.cache)
	cd $(MATCHBOX_PANEL_DIR) && \
		$(MATCHBOX_PANEL_PATH) $(MATCHBOX_PANEL_ENV) \
		./configure $(MATCHBOX_PANEL_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox-panel_compile: $(STATEDIR)/matchbox-panel.compile

$(STATEDIR)/matchbox-panel.compile: $(matchbox-panel_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MATCHBOX_PANEL_DIR) && $(MATCHBOX_PANEL_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox-panel_install: $(STATEDIR)/matchbox-panel.install

$(STATEDIR)/matchbox-panel.install: $(matchbox-panel_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox-panel_targetinstall: $(STATEDIR)/matchbox-panel.targetinstall

$(STATEDIR)/matchbox-panel.targetinstall: $(matchbox-panel_targetinstall_deps_default)
	@$(call targetinfo, $@)

	cd $(MATCHBOX_PANEL_DIR) && $(MATCHBOX_PANEL_PATH) $(MAKE) $(PARALLELMFLAGS) DESTDIR=$(MATCHBOX_PANEL_DIR)/fakeroot install

	@$(call install_init, matchbox-panel)
	@$(call install_fixup, matchbox-panel,PACKAGE,matchbox-panel)
	@$(call install_fixup, matchbox-panel,PRIORITY,optional)
	@$(call install_fixup, matchbox-panel,VERSION,$(MATCHBOX_PANEL_VERSION))
	@$(call install_fixup, matchbox-panel,SECTION,base)
	@$(call install_fixup, matchbox-panel,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, matchbox-panel,DEPENDS,"libmatchbox matchbox-common gtk")
	@$(call install_fixup, matchbox-panel,DESCRIPTION,missing)

	@$(call install_target, matchbox-panel, $(MATCHBOX_PANEL_DIR)/fakeroot/usr, /usr)

	@$(call install_finish, matchbox-panel)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox-panel_clean:
	rm -rf $(STATEDIR)/matchbox-panel.*
	rm -rf $(IMAGEDIR)/matchbox-panel_*
	rm -rf $(MATCHBOX_PANEL_DIR)

# vim: syntax=make
