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
PACKAGES-$(PTXCONF_LXPANEL) += lxpanel

#
# Paths and names
#
LXPANEL_VERSION	:= 0.3.8.1
LXPANEL		:= lxpanel-$(LXPANEL_VERSION)
LXPANEL_SUFFIX		:= tar.gz
LXPANEL_URL		:= http://voxel.dl.sourceforge.net/sourceforge/lxde/$(LXPANEL).$(LXPANEL_SUFFIX)
LXPANEL_SOURCE		:= $(SRCDIR)/$(LXPANEL).$(LXPANEL_SUFFIX)
LXPANEL_DIR		:= $(BUILDDIR)/$(LXPANEL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lxpanel_get: $(STATEDIR)/lxpanel.get

$(STATEDIR)/lxpanel.get: $(lxpanel_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(LXPANEL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, LXPANEL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lxpanel_extract: $(STATEDIR)/lxpanel.extract

$(STATEDIR)/lxpanel.extract: $(lxpanel_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LXPANEL_DIR))
	@$(call extract, LXPANEL)
	@$(call patchin, LXPANEL)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lxpanel_prepare: $(STATEDIR)/lxpanel.prepare

LXPANEL_PATH	:= PATH=$(CROSS_PATH)
LXPANEL_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
LXPANEL_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/lxpanel.prepare: $(lxpanel_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LXPANEL_DIR)/config.cache)
	cd $(LXPANEL_DIR) && \
		$(LXPANEL_PATH) $(LXPANEL_ENV) \
	       ac_cv_func_malloc_0_nonnull=yes ./configure $(LXPANEL_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lxpanel_compile: $(STATEDIR)/lxpanel.compile

$(STATEDIR)/lxpanel.compile: $(lxpanel_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(LXPANEL_DIR) && $(LXPANEL_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lxpanel_install: $(STATEDIR)/lxpanel.install

$(STATEDIR)/lxpanel.install: $(lxpanel_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lxpanel_targetinstall: $(STATEDIR)/lxpanel.targetinstall

$(STATEDIR)/lxpanel.targetinstall: $(lxpanel_targetinstall_deps_default)
	@$(call targetinfo, $@)
	
	cd $(LXPANEL_DIR) && $(LXPANEL_PATH) $(LXPANEL_ENV) $(MAKE) $(PARALLELMFLAGS) DESTDIR=$(LXPANEL_DIR)/fakeroot install	

	@$(call install_init, lxpanel)
	@$(call install_fixup, lxpanel,PACKAGE,lxpanel)
	@$(call install_fixup, lxpanel,PRIORITY,optional)
	@$(call install_fixup, lxpanel,VERSION,$(LXPANEL_VERSION))
	@$(call install_fixup, lxpanel,SECTION,base)
	@$(call install_fixup, lxpanel,AUTHOR,"Adrian Crutchfield <insearchof@pdaXrom.org>")
	@$(call install_fixup, lxpanel,DEPENDS,)
	@$(call install_fixup, lxpanel,DESCRIPTION,missing)

	@$(call install_target, lxpanel, $(LXPANEL_DIR)/fakeroot/usr, /usr)

	@$(call install_finish, lxpanel)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lxpanel_clean:
	rm -rf $(STATEDIR)/lxpanel.*
	rm -rf $(IMAGEDIR)/lxpanel_*
	rm -rf $(LXPANEL_DIR)

# vim: syntax=make
