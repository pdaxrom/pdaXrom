# -*-makefile-*-
# $Id: template-make 7626 2007-11-26 10:27:03Z mkl $
#
# Copyright (C) 2008 by 
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_XRANDR) += xrandr

#
# Paths and names
#
XRANDR_VERSION	:= 1.2.2
XRANDR		:= xrandr-$(XRANDR_VERSION)
XRANDR_SUFFIX		:= tar.bz2
XRANDR_URL		:= http://xorg.freedesktop.org/releases/X11R7.3/src/everything/$(XRANDR).$(XRANDR_SUFFIX)
XRANDR_SOURCE		:= $(SRCDIR)/$(XRANDR).$(XRANDR_SUFFIX)
XRANDR_DIR		:= $(BUILDDIR)/$(XRANDR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xrandr_get: $(STATEDIR)/xrandr.get

$(STATEDIR)/xrandr.get: $(xrandr_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(XRANDR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, XRANDR)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xrandr_extract: $(STATEDIR)/xrandr.extract

$(STATEDIR)/xrandr.extract: $(xrandr_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(XRANDR_DIR))
	@$(call extract, XRANDR)
	@$(call patchin, XRANDR)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xrandr_prepare: $(STATEDIR)/xrandr.prepare

XRANDR_PATH	:= PATH=$(CROSS_PATH)
XRANDR_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
XRANDR_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/xrandr.prepare: $(xrandr_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(XRANDR_DIR)/config.cache)
	cd $(XRANDR_DIR) && \
		$(XRANDR_PATH) $(XRANDR_ENV) \
		./configure $(XRANDR_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xrandr_compile: $(STATEDIR)/xrandr.compile

$(STATEDIR)/xrandr.compile: $(xrandr_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(XRANDR_DIR) && $(XRANDR_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xrandr_install: $(STATEDIR)/xrandr.install

$(STATEDIR)/xrandr.install: $(xrandr_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, XRANDR)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xrandr_targetinstall: $(STATEDIR)/xrandr.targetinstall

$(STATEDIR)/xrandr.targetinstall: $(xrandr_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, xrandr)
	@$(call install_fixup, xrandr,PACKAGE,xrandr)
	@$(call install_fixup, xrandr,PRIORITY,optional)
	@$(call install_fixup, xrandr,VERSION,$(XRANDR_VERSION))
	@$(call install_fixup, xrandr,SECTION,base)
	@$(call install_fixup, xrandr,AUTHOR,"Adrian Crutchfield <insearchof@pdaXrom.org>")
	@$(call install_fixup, xrandr,DEPENDS,)
	@$(call install_fixup, xrandr,DESCRIPTION,missing)

	@$(call install_copy, xrandr, 0, 0, 0755, $(XRANDR_DIR)/xrandr, /usr/bin)

	@$(call install_finish, xrandr)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xrandr_clean:
	rm -rf $(STATEDIR)/xrandr.*
	rm -rf $(IMAGEDIR)/xrandr_*
	rm -rf $(XRANDR_DIR)

# vim: syntax=make
