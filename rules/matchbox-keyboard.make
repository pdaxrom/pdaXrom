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
PACKAGES-$(PTXCONF_MATCHBOX_KEYBOARD) += matchbox-keyboard

#
# Paths and names
#
MATCHBOX_KEYBOARD_VERSION	:= 0.1
MATCHBOX_KEYBOARD		:= matchbox-keyboard-$(MATCHBOX_KEYBOARD_VERSION)
MATCHBOX_KEYBOARD_SUFFIX	:= tar.bz2
MATCHBOX_KEYBOARD_URL		:= http://matchbox-project.org/sources/matchbox-keyboard/0.1/$(MATCHBOX_KEYBOARD).$(MATCHBOX_KEYBOARD_SUFFIX)
MATCHBOX_KEYBOARD_SOURCE	:= $(SRCDIR)/$(MATCHBOX_KEYBOARD).$(MATCHBOX_KEYBOARD_SUFFIX)
MATCHBOX_KEYBOARD_DIR		:= $(BUILDDIR)/$(MATCHBOX_KEYBOARD)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox-keyboard_get: $(STATEDIR)/matchbox-keyboard.get

$(STATEDIR)/matchbox-keyboard.get: $(matchbox-keyboard_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MATCHBOX_KEYBOARD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MATCHBOX_KEYBOARD)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox-keyboard_extract: $(STATEDIR)/matchbox-keyboard.extract

$(STATEDIR)/matchbox-keyboard.extract: $(matchbox-keyboard_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_KEYBOARD_DIR))
	@$(call extract, MATCHBOX_KEYBOARD)
	@$(call patchin, MATCHBOX_KEYBOARD)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox-keyboard_prepare: $(STATEDIR)/matchbox-keyboard.prepare

MATCHBOX_KEYBOARD_PATH	:= PATH=$(CROSS_PATH)
MATCHBOX_KEYBOARD_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MATCHBOX_KEYBOARD_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/matchbox-keyboard.prepare: $(matchbox-keyboard_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_KEYBOARD_DIR)/config.cache)
	cd $(MATCHBOX_KEYBOARD_DIR) && \
		$(MATCHBOX_KEYBOARD_PATH) $(MATCHBOX_KEYBOARD_ENV) \
		./configure $(MATCHBOX_KEYBOARD_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox-keyboard_compile: $(STATEDIR)/matchbox-keyboard.compile

$(STATEDIR)/matchbox-keyboard.compile: $(matchbox-keyboard_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MATCHBOX_KEYBOARD_DIR) && $(MATCHBOX_KEYBOARD_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox-keyboard_install: $(STATEDIR)/matchbox-keyboard.install

$(STATEDIR)/matchbox-keyboard.install: $(matchbox-keyboard_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox-keyboard_targetinstall: $(STATEDIR)/matchbox-keyboard.targetinstall

$(STATEDIR)/matchbox-keyboard.targetinstall: $(matchbox-keyboard_targetinstall_deps_default)
	@$(call targetinfo, $@)

	cd $(MATCHBOX_KEYBOARD_DIR) && $(MATCHBOX_KEYBOARD_PATH) $(MAKE) $(PARALLELMFLAGS) \
	    DESTDIR=$(MATCHBOX_KEYBOARD_DIR)/fakeroot install

	@$(call install_init, matchbox-keyboard)
	@$(call install_fixup, matchbox-keyboard,PACKAGE,matchbox-keyboard)
	@$(call install_fixup, matchbox-keyboard,PRIORITY,optional)
	@$(call install_fixup, matchbox-keyboard,VERSION,$(MATCHBOX_KEYBOARD_VERSION))
	@$(call install_fixup, matchbox-keyboard,SECTION,base)
	@$(call install_fixup, matchbox-keyboard,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, matchbox-keyboard,DEPENDS,"matchbox-panel libfakekey expat")
	@$(call install_fixup, matchbox-keyboard,DESCRIPTION,missing)

	@$(call install_target, matchbox-keyboard, $(MATCHBOX_KEYBOARD_DIR)/fakeroot/usr, /usr)

	@$(call install_finish, matchbox-keyboard)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox-keyboard_clean:
	rm -rf $(STATEDIR)/matchbox-keyboard.*
	rm -rf $(IMAGEDIR)/matchbox-keyboard_*
	rm -rf $(MATCHBOX_KEYBOARD_DIR)

# vim: syntax=make
