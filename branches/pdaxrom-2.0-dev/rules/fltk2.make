# -*-makefile-*-
# $Id: template 6655 2007-01-02 12:55:21Z rsc $
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
PACKAGES-$(PTXCONF_FLTK2) += fltk2

#
# Paths and names
#
FLTK2_VERSION	:= 2.0.x-r6403
FLTK2		:= fltk-$(FLTK2_VERSION)
FLTK2_SUFFIX		:= tar.bz2
FLTK2_URL		:= http://ftp2.easysw.com/pub/fltk/snapshots/$(FLTK2).$(FLTK2_SUFFIX)
FLTK2_SOURCE		:= $(SRCDIR)/$(FLTK2).$(FLTK2_SUFFIX)
FLTK2_DIR		:= $(BUILDDIR)/$(FLTK2)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fltk2_get: $(STATEDIR)/fltk2.get

$(STATEDIR)/fltk2.get: $(fltk2_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(FLTK2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, FLTK2)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fltk2_extract: $(STATEDIR)/fltk2.extract

$(STATEDIR)/fltk2.extract: $(fltk2_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(FLTK2_DIR))
	@$(call extract, FLTK2)
	@$(call patchin, FLTK2)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fltk2_prepare: $(STATEDIR)/fltk2.prepare

FLTK2_PATH	:= PATH=$(CROSS_PATH)
FLTK2_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
FLTK2_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/fltk2.prepare: $(fltk2_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(FLTK2_DIR)/config.cache)
	cd $(FLTK2_DIR) && \
		$(FLTK2_PATH) $(FLTK2_ENV) \
		./configure $(FLTK2_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fltk2_compile: $(STATEDIR)/fltk2.compile

$(STATEDIR)/fltk2.compile: $(fltk2_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(FLTK2_DIR) && $(FLTK2_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fltk2_install: $(STATEDIR)/fltk2.install

$(STATEDIR)/fltk2.install: $(fltk2_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, FLTK2)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fltk2_targetinstall: $(STATEDIR)/fltk2.targetinstall

$(STATEDIR)/fltk2.targetinstall: $(fltk2_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, fltk2)
	@$(call install_fixup, fltk2,PACKAGE,fltk2)
	@$(call install_fixup, fltk2,PRIORITY,optional)
	@$(call install_fixup, fltk2,VERSION,$(FLTK2_VERSION))
	@$(call install_fixup, fltk2,SECTION,base)
	@$(call install_fixup, fltk2,AUTHOR,"Robert Schwebel <r.schwebel\@pengutronix.de>")
	@$(call install_fixup, fltk2,DEPENDS,)
	@$(call install_fixup, fltk2,DESCRIPTION,missing)

	@$(call install_copy, fltk2, 0, 0, 0755, $(FLTK2_DIR)/foobar, /dev/null)

	@$(call install_finish, fltk2)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fltk2_clean:
	rm -rf $(STATEDIR)/fltk2.*
	rm -rf $(IMAGEDIR)/fltk2_*
	rm -rf $(FLTK2_DIR)

# vim: syntax=make
