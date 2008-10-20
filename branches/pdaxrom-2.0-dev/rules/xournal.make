# -*-makefile-*-
# $Id: template-make 7626 2007-11-26 10:27:03Z mkl $
#
# Copyright (C) 2008 by Adrian Crutchfield <insearchof@pdaxrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_XOURNAL) += xournal

#
# Paths and names
#
XOURNAL_VERSION	:= 0.4.2.1
XOURNAL		:= xournal-$(XOURNAL_VERSION)
XOURNAL_SUFFIX		:= tar.gz
XOURNAL_URL		:= http://downloads.sourceforge.net/xournal/$(XOURNAL).$(XOURNAL_SUFFIX)
XOURNAL_SOURCE		:= $(SRCDIR)/$(XOURNAL).$(XOURNAL_SUFFIX)
XOURNAL_DIR		:= $(BUILDDIR)/$(XOURNAL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xournal_get: $(STATEDIR)/xournal.get

$(STATEDIR)/xournal.get: $(xournal_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(XOURNAL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, XOURNAL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xournal_extract: $(STATEDIR)/xournal.extract

$(STATEDIR)/xournal.extract: $(xournal_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(XOURNAL_DIR))
	@$(call extract, XOURNAL)
	@$(call patchin, XOURNAL)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xournal_prepare: $(STATEDIR)/xournal.prepare

XOURNAL_PATH	:= PATH=$(CROSS_PATH)
XOURNAL_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
XOURNAL_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/xournal.prepare: $(xournal_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(XOURNAL_DIR)/config.cache)
	cd $(XOURNAL_DIR) && \
		$(XOURNAL_PATH) $(XOURNAL_ENV) \
		./configure $(XOURNAL_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xournal_compile: $(STATEDIR)/xournal.compile

$(STATEDIR)/xournal.compile: $(xournal_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(XOURNAL_DIR) && $(XOURNAL_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xournal_install: $(STATEDIR)/xournal.install

$(STATEDIR)/xournal.install: $(xournal_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, XOURNAL)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xournal_targetinstall: $(STATEDIR)/xournal.targetinstall

$(STATEDIR)/xournal.targetinstall: $(xournal_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, xournal)
	@$(call install_fixup, xournal,PACKAGE,xournal)
	@$(call install_fixup, xournal,PRIORITY,optional)
	@$(call install_fixup, xournal,VERSION,$(XOURNAL_VERSION))
	@$(call install_fixup, xournal,SECTION,base)
	@$(call install_fixup, xournal,AUTHOR,"Adrian Crutchfield <insearchof@pdaXrom.org>")dr
	@$(call install_fixup, xournal,DEPENDS,)
	@$(call install_fixup, xournal,DESCRIPTION,missing)

	@$(call install_copy, xournal, 0, 0, 0755, $(XOURNAL_DIR)/foobar, /dev/null)

	@$(call install_finish, xournal)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xournal_clean:
	rm -rf $(STATEDIR)/xournal.*
	rm -rf $(IMAGEDIR)/xournal_*
	rm -rf $(XOURNAL_DIR)

# vim: syntax=make
