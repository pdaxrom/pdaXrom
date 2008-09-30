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
PACKAGES-$(PTXCONF_QUASAR) += quasar

#
# Paths and names
#
QUASAR_VERSION	:= 0.9_beta3_sources
QUASAR		:= quasar_$(QUASAR_VERSION)
QUASAR_SUFFIX		:= tar.bz2
QUASAR_URL		:= http://katastrophos.net/zaurus/sources/quasar/$(QUASAR).$(QUASAR_SUFFIX)
QUASAR_SOURCE		:= $(SRCDIR)/$(QUASAR).$(QUASAR_SUFFIX)
QUASAR_DIR		:= $(BUILDDIR)/v0.9_beta3

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

quasar_get: $(STATEDIR)/quasar.get

$(STATEDIR)/quasar.get: $(quasar_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(QUASAR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, QUASAR)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

quasar_extract: $(STATEDIR)/quasar.extract

$(STATEDIR)/quasar.extract: $(quasar_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(QUASAR_DIR))
	@$(call extract, QUASAR)
	@$(call patchin, QUASAR)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

quasar_prepare: $(STATEDIR)/quasar.prepare

QUASAR_PATH	:= PATH=$(CROSS_PATH)
QUASAR_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
QUASAR_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/quasar.prepare: $(quasar_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(QUASAR_DIR)/config.cache)
	cd $(QUASAR_DIR) && \
		$(QUASAR_PATH) $(QUASAR_ENV) \
		./configure $(QUASAR_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

quasar_compile: $(STATEDIR)/quasar.compile

$(STATEDIR)/quasar.compile: $(quasar_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(QUASAR_DIR) && $(QUASAR_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

quasar_install: $(STATEDIR)/quasar.install

$(STATEDIR)/quasar.install: $(quasar_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, QUASAR)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

quasar_targetinstall: $(STATEDIR)/quasar.targetinstall

$(STATEDIR)/quasar.targetinstall: $(quasar_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, quasar)
	@$(call install_fixup, quasar,PACKAGE,quasar)
	@$(call install_fixup, quasar,PRIORITY,optional)
	@$(call install_fixup, quasar,VERSION,$(QUASAR_VERSION))
	@$(call install_fixup, quasar,SECTION,base)
	@$(call install_fixup, quasar,AUTHOR,"Adrian Crutchfield <insearchof@pdaXrom.org>")dr
	@$(call install_fixup, quasar,DEPENDS,)
	@$(call install_fixup, quasar,DESCRIPTION,missing)

	@$(call install_copy, quasar, 0, 0, 0755, $(QUASAR_DIR)/foobar, /dev/null)

	@$(call install_finish, quasar)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

quasar_clean:
	rm -rf $(STATEDIR)/quasar.*
	rm -rf $(IMAGEDIR)/quasar_*
	rm -rf $(QUASAR_DIR)

# vim: syntax=make
