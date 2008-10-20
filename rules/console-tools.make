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
PACKAGES-$(PTXCONF_CONSOLE_TOOLS) += console-tools

#
# Paths and names
#
CONSOLE_TOOLS_VERSION	:= 0.3.2
CONSOLE_TOOLS		:= console-tools-$(CONSOLE_TOOLS_VERSION)
CONSOLE_TOOLS_SUFFIX	:= tar.gz
CONSOLE_TOOLS_URL	:= http://downloads.sourceforge.net/lct/$(CONSOLE_TOOLS).$(CONSOLE_TOOLS_SUFFIX)
CONSOLE_TOOLS_SOURCE	:= $(SRCDIR)/$(CONSOLE_TOOLS).$(CONSOLE_TOOLS_SUFFIX)
CONSOLE_TOOLS_DIR	:= $(BUILDDIR)/$(CONSOLE_TOOLS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

console-tools_get: $(STATEDIR)/console-tools.get

$(STATEDIR)/console-tools.get: $(console-tools_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(CONSOLE_TOOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, CONSOLE_TOOLS)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

console-tools_extract: $(STATEDIR)/console-tools.extract

$(STATEDIR)/console-tools.extract: $(console-tools_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(CONSOLE_TOOLS_DIR))
	@$(call extract, CONSOLE_TOOLS)
	@$(call patchin, CONSOLE_TOOLS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

console-tools_prepare: $(STATEDIR)/console-tools.prepare

CONSOLE_TOOLS_PATH	:= PATH=$(CROSS_PATH)
CONSOLE_TOOLS_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
CONSOLE_TOOLS_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/console-tools.prepare: $(console-tools_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(CONSOLE_TOOLS_DIR)/config.cache)
	cd $(CONSOLE_TOOLS_DIR) && \
		$(CONSOLE_TOOLS_PATH) $(CONSOLE_TOOLS_ENV) \
		./configure $(CONSOLE_TOOLS_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

console-tools_compile: $(STATEDIR)/console-tools.compile

$(STATEDIR)/console-tools.compile: $(console-tools_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(CONSOLE_TOOLS_DIR) && $(CONSOLE_TOOLS_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

console-tools_install: $(STATEDIR)/console-tools.install

$(STATEDIR)/console-tools.install: $(console-tools_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

console-tools_targetinstall: $(STATEDIR)/console-tools.targetinstall

$(STATEDIR)/console-tools.targetinstall: $(console-tools_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, console-tools)
	@$(call install_fixup, console-tools,PACKAGE,console-tools)
	@$(call install_fixup, console-tools,PRIORITY,optional)
	@$(call install_fixup, console-tools,VERSION,$(CONSOLE_TOOLS_VERSION))
	@$(call install_fixup, console-tools,SECTION,base)
	@$(call install_fixup, console-tools,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, console-tools,DEPENDS,)
	@$(call install_fixup, console-tools,DESCRIPTION,missing)

	@$(call install_copy, console-tools, 0, 0, 0755, $(CONSOLE_TOOLS_DIR)/lib/cfont/.libs/libcfont.so.0.0.0, /usr/lib/libcfont.so.0.0.0)
	@$(call install_link, console-tools, libcfont.so.0.0.0, /usr/lib/libcfont.so.0)
	@$(call install_link, console-tools, libcfont.so.0.0.0, /usr/lib/libcfont.so)

	@$(call install_copy, console-tools, 0, 0, 0755, $(CONSOLE_TOOLS_DIR)/lib/console/.libs/libconsole.so.0.0.0, /usr/lib/libconsole.so.0.0.0)
	@$(call install_link, console-tools, libconsole.so.0.0.0, /usr/lib/libconsole.so.0)
	@$(call install_link, console-tools, libconsole.so.0.0.0, /usr/lib/libconsole.so)

	@$(call install_copy, console-tools, 0, 0, 0755, $(CONSOLE_TOOLS_DIR)/lib/ctutils/.libs/libctutils.so.0.0.0, /usr/lib/libctutils.so.0.0.0)
	@$(call install_link, console-tools, libctutils.so.0.0.0, /usr/lib/libctutils.so.0)
	@$(call install_link, console-tools, libctutils.so.0.0.0, /usr/lib/libctutils.so)

	@$(call install_copy, console-tools, 0, 0, 0755, $(CONSOLE_TOOLS_DIR)/lib/generic/.libs/libctgeneric.so.0.0.0, /usr/lib/libctgeneric.so.0.0.0)
	@$(call install_link, console-tools, libctgeneric.so.0.0.0, /usr/lib/libctgeneric.so.0)
	@$(call install_link, console-tools, libctgeneric.so.0.0.0, /usr/lib/libctgeneric.so)

ifdef PTXCONF_CONSOLE_TOOLS_DUMPKEYS
	@$(call install_copy, console-tools, 0, 0, 0755, $(CONSOLE_TOOLS_DIR)/kbdtools/.libs/dumpkeys, /usr/bin/dumpkeys)
endif
ifdef PTXCONF_CONSOLE_TOOLS_LOADKEYS
	@$(call install_copy, console-tools, 0, 0, 0755, $(CONSOLE_TOOLS_DIR)/kbdtools/.libs/loadkeys, /usr/bin/loadkeys)
endif
ifdef PTXCONF_CONSOLE_TOOLS_LOADKEYS_INIT
	@$(call install_copy, console-tools, 0, 0, 0755, $(PTXDIST_WORKSPACE)/projectroot/etc/init.d/keymap, \
	    /etc/init.d/keymap)
	@$(call install_link, console-tools, ../init.d/keymap, /etc/rc.d/S10_keymap)
endif

	@$(call install_finish, console-tools)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

console-tools_clean:
	rm -rf $(STATEDIR)/console-tools.*
	rm -rf $(IMAGEDIR)/console-tools_*
	rm -rf $(CONSOLE_TOOLS_DIR)

# vim: syntax=make
