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
PACKAGES-$(PTXCONF_DILLO) += dillo

#
# Paths and names
#
DILLO_VERSION	:= 2.0
DILLO		:= dillo-$(DILLO_VERSION)
DILLO_SUFFIX		:= tar.bz2
DILLO_URL		:= http://www.dillo.org/download/$(DILLO).$(DILLO_SUFFIX)
DILLO_SOURCE		:= $(SRCDIR)/$(DILLO).$(DILLO_SUFFIX)
DILLO_DIR		:= $(BUILDDIR)/$(DILLO)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dillo_get: $(STATEDIR)/dillo.get

$(STATEDIR)/dillo.get: $(dillo_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(DILLO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, DILLO)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dillo_extract: $(STATEDIR)/dillo.extract

$(STATEDIR)/dillo.extract: $(dillo_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(DILLO_DIR))
	@$(call extract, DILLO)
	@$(call patchin, DILLO)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dillo_prepare: $(STATEDIR)/dillo.prepare

DILLO_PATH	:= PATH=$(CROSS_PATH)
DILLO_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
DILLO_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/dillo.prepare: $(dillo_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(DILLO_DIR)/config.cache)
	cd $(DILLO_DIR) && \
		$(DILLO_PATH) $(DILLO_ENV) \
		./configure $(DILLO_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dillo_compile: $(STATEDIR)/dillo.compile

$(STATEDIR)/dillo.compile: $(dillo_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(DILLO_DIR) && $(DILLO_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dillo_install: $(STATEDIR)/dillo.install

$(STATEDIR)/dillo.install: $(dillo_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, DILLO)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dillo_targetinstall: $(STATEDIR)/dillo.targetinstall

$(STATEDIR)/dillo.targetinstall: $(dillo_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, dillo)
	@$(call install_fixup, dillo,PACKAGE,dillo)
	@$(call install_fixup, dillo,PRIORITY,optional)
	@$(call install_fixup, dillo,VERSION,$(DILLO_VERSION))
	@$(call install_fixup, dillo,SECTION,base)
	@$(call install_fixup, dillo,AUTHOR,"Robert Schwebel <r.schwebel\@pengutronix.de>")
	@$(call install_fixup, dillo,DEPENDS,)
	@$(call install_fixup, dillo,DESCRIPTION,missing)

	@$(call install_copy, dillo, 0, 0, 0755, $(DILLO_DIR)/foobar, /dev/null)

	@$(call install_finish, dillo)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dillo_clean:
	rm -rf $(STATEDIR)/dillo.*
	rm -rf $(IMAGEDIR)/dillo_*
	rm -rf $(DILLO_DIR)

# vim: syntax=make
