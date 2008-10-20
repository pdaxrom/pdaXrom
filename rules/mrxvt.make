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
PACKAGES-$(PTXCONF_MRXVT) += mrxvt

#
# Paths and names
#
MRXVT_VERSION	:= 0.5.4
MRXVT		:= mrxvt-$(MRXVT_VERSION)
MRXVT_SUFFIX		:= tar.gz
MRXVT_URL		:= http://voxel.dl.sourceforge.net/sourceforge/materm/$(MRXVT).$(MRXVT_SUFFIX)
MRXVT_SOURCE		:= $(SRCDIR)/$(MRXVT).$(MRXVT_SUFFIX)
MRXVT_DIR		:= $(BUILDDIR)/$(MRXVT)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mrxvt_get: $(STATEDIR)/mrxvt.get

$(STATEDIR)/mrxvt.get: $(mrxvt_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MRXVT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MRXVT)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mrxvt_extract: $(STATEDIR)/mrxvt.extract

$(STATEDIR)/mrxvt.extract: $(mrxvt_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MRXVT_DIR))
	@$(call extract, MRXVT)
	@$(call patchin, MRXVT)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mrxvt_prepare: $(STATEDIR)/mrxvt.prepare

MRXVT_PATH	:= PATH=$(CROSS_PATH)
MRXVT_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MRXVT_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/mrxvt.prepare: $(mrxvt_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MRXVT_DIR)/config.cache)
	cd $(MRXVT_DIR) && \
		$(MRXVT_PATH) $(MRXVT_ENV) \
		./configure $(MRXVT_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mrxvt_compile: $(STATEDIR)/mrxvt.compile

$(STATEDIR)/mrxvt.compile: $(mrxvt_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MRXVT_DIR) && $(MRXVT_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mrxvt_install: $(STATEDIR)/mrxvt.install

$(STATEDIR)/mrxvt.install: $(mrxvt_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, MRXVT)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mrxvt_targetinstall: $(STATEDIR)/mrxvt.targetinstall

$(STATEDIR)/mrxvt.targetinstall: $(mrxvt_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, mrxvt)
	@$(call install_fixup, mrxvt,PACKAGE,mrxvt)
	@$(call install_fixup, mrxvt,PRIORITY,optional)
	@$(call install_fixup, mrxvt,VERSION,$(MRXVT_VERSION))
	@$(call install_fixup, mrxvt,SECTION,base)
	@$(call install_fixup, mrxvt,AUTHOR,"Adrian Crutchfield <insearchof@pdaXrom.org>")dr
	@$(call install_fixup, mrxvt,DEPENDS,)
	@$(call install_fixup, mrxvt,DESCRIPTION,missing)

	@$(call install_copy, mrxvt, 0, 0, 0755, $(MRXVT_DIR)/foobar, /dev/null)

	@$(call install_finish, mrxvt)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mrxvt_clean:
	rm -rf $(STATEDIR)/mrxvt.*
	rm -rf $(IMAGEDIR)/mrxvt_*
	rm -rf $(MRXVT_DIR)

# vim: syntax=make
