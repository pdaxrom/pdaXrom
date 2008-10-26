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
PACKAGES-$(PTXCONF_GPICVIEW) += gpicview

#
# Paths and names
#
GPICVIEW_VERSION	:= 0.1.10
GPICVIEW		:= gpicview-$(GPICVIEW_VERSION)
GPICVIEW_SUFFIX		:= tar.gz
GPICVIEW_URL		:= http://voxel.dl.sourceforge.net/sourceforge/lxde//$(GPICVIEW).$(GPICVIEW_SUFFIX)
GPICVIEW_SOURCE		:= $(SRCDIR)/$(GPICVIEW).$(GPICVIEW_SUFFIX)
GPICVIEW_DIR		:= $(BUILDDIR)/$(GPICVIEW)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gpicview_get: $(STATEDIR)/gpicview.get

$(STATEDIR)/gpicview.get: $(gpicview_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(GPICVIEW_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, GPICVIEW)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gpicview_extract: $(STATEDIR)/gpicview.extract

$(STATEDIR)/gpicview.extract: $(gpicview_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(GPICVIEW_DIR))
	@$(call extract, GPICVIEW)
	@$(call patchin, GPICVIEW)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gpicview_prepare: $(STATEDIR)/gpicview.prepare

GPICVIEW_PATH	:= PATH=$(CROSS_PATH)
GPICVIEW_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
GPICVIEW_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/gpicview.prepare: $(gpicview_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(GPICVIEW_DIR)/config.cache)
	cd $(GPICVIEW_DIR) && \
		$(GPICVIEW_PATH) $(GPICVIEW_ENV) \
		./configure $(GPICVIEW_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gpicview_compile: $(STATEDIR)/gpicview.compile

$(STATEDIR)/gpicview.compile: $(gpicview_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(GPICVIEW_DIR) && $(GPICVIEW_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gpicview_install: $(STATEDIR)/gpicview.install

$(STATEDIR)/gpicview.install: $(gpicview_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, GPICVIEW)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gpicview_targetinstall: $(STATEDIR)/gpicview.targetinstall

$(STATEDIR)/gpicview.targetinstall: $(gpicview_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, gpicview)
	@$(call install_fixup, gpicview,PACKAGE,gpicview)
	@$(call install_fixup, gpicview,PRIORITY,optional)
	@$(call install_fixup, gpicview,VERSION,$(GPICVIEW_VERSION))
	@$(call install_fixup, gpicview,SECTION,base)
	@$(call install_fixup, gpicview,AUTHOR,"Adrian Crutchfield <insearchof@pdaXrom.org>")
	@$(call install_fixup, gpicview,DEPENDS,)
	@$(call install_fixup, gpicview,DESCRIPTION,missing)

	@$(call install_copy, gpicview, 0, 0, 0755, $(GPICVIEW_DIR)/foobar, /dev/null)

	@$(call install_finish, gpicview)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gpicview_clean:
	rm -rf $(STATEDIR)/gpicview.*
	rm -rf $(IMAGEDIR)/gpicview_*
	rm -rf $(GPICVIEW_DIR)

# vim: syntax=make
