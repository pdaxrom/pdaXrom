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
PACKAGES-$(PTXCONF_LEAFPAD) += leafpad

#
# Paths and names
#
LEAFPAD_VERSION	:= 0.8.14
LEAFPAD		:= leafpad-$(LEAFPAD_VERSION)
LEAFPAD_SUFFIX	:= tar.gz
LEAFPAD_URL	:= http://savannah.nongnu.org/download/leafpad/$(LEAFPAD).$(LEAFPAD_SUFFIX)
LEAFPAD_SOURCE	:= $(SRCDIR)/$(LEAFPAD).$(LEAFPAD_SUFFIX)
LEAFPAD_DIR	:= $(BUILDDIR)/$(LEAFPAD)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

leafpad_get: $(STATEDIR)/leafpad.get

$(STATEDIR)/leafpad.get: $(leafpad_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(LEAFPAD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, LEAFPAD)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

leafpad_extract: $(STATEDIR)/leafpad.extract

$(STATEDIR)/leafpad.extract: $(leafpad_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LEAFPAD_DIR))
	@$(call extract, LEAFPAD)
	@$(call patchin, LEAFPAD)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

leafpad_prepare: $(STATEDIR)/leafpad.prepare

LEAFPAD_PATH	:= PATH=$(CROSS_PATH)
LEAFPAD_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
LEAFPAD_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/leafpad.prepare: $(leafpad_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LEAFPAD_DIR)/config.cache)
	cd $(LEAFPAD_DIR) && \
		$(LEAFPAD_PATH) $(LEAFPAD_ENV) \
		./configure $(LEAFPAD_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

leafpad_compile: $(STATEDIR)/leafpad.compile

$(STATEDIR)/leafpad.compile: $(leafpad_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(LEAFPAD_DIR) && $(LEAFPAD_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

leafpad_install: $(STATEDIR)/leafpad.install

$(STATEDIR)/leafpad.install: $(leafpad_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

leafpad_targetinstall: $(STATEDIR)/leafpad.targetinstall

$(STATEDIR)/leafpad.targetinstall: $(leafpad_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, leafpad)
	@$(call install_fixup, leafpad,PACKAGE,leafpad)
	@$(call install_fixup, leafpad,PRIORITY,optional)
	@$(call install_fixup, leafpad,VERSION,$(LEAFPAD_VERSION))
	@$(call install_fixup, leafpad,SECTION,base)
	@$(call install_fixup, leafpad,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, leafpad,DEPENDS,)
	@$(call install_fixup, leafpad,DESCRIPTION,missing)

	@$(call install_copy, leafpad, 0, 0, 0755, $(LEAFPAD_DIR)/src/leafpad, /usr/bin/leafpad)
	@$(call install_copy, leafpad, 0, 0, 0644, $(LEAFPAD_DIR)/data/leafpad.desktop, /usr/share/applications/leafpad.desktop)
	@$(call install_copy, leafpad, 0, 0, 0644, $(LEAFPAD_DIR)/data/leafpad.png, /usr/share/pixmaps/leafpad.png)

	@$(call install_finish, leafpad)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

leafpad_clean:
	rm -rf $(STATEDIR)/leafpad.*
	rm -rf $(IMAGEDIR)/leafpad_*
	rm -rf $(LEAFPAD_DIR)

# vim: syntax=make
