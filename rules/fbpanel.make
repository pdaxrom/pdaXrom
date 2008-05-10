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
PACKAGES-$(PTXCONF_FBPANEL) += fbpanel

#
# Paths and names
#
FBPANEL_VERSION	:= 4.12
FBPANEL		:= fbpanel-$(FBPANEL_VERSION)
FBPANEL_SUFFIX	:= tgz
FBPANEL_URL	:= http://downloads.sourceforge.net/fbpanel/$(FBPANEL).$(FBPANEL_SUFFIX)
FBPANEL_SOURCE	:= $(SRCDIR)/$(FBPANEL).$(FBPANEL_SUFFIX)
FBPANEL_DIR	:= $(BUILDDIR)/$(FBPANEL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fbpanel_get: $(STATEDIR)/fbpanel.get

$(STATEDIR)/fbpanel.get: $(fbpanel_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(FBPANEL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, FBPANEL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fbpanel_extract: $(STATEDIR)/fbpanel.extract

$(STATEDIR)/fbpanel.extract: $(fbpanel_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(FBPANEL_DIR))
	@$(call extract, FBPANEL)
	@$(call patchin, FBPANEL)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fbpanel_prepare: $(STATEDIR)/fbpanel.prepare

FBPANEL_PATH	:= PATH=$(CROSS_PATH)
FBPANEL_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
FBPANEL_AUTOCONF := --prefix=/usr --cpu=on

$(STATEDIR)/fbpanel.prepare: $(fbpanel_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(FBPANEL_DIR)/config.cache)
	cd $(FBPANEL_DIR) && \
		$(FBPANEL_PATH) $(FBPANEL_ENV) \
		./configure $(FBPANEL_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fbpanel_compile: $(STATEDIR)/fbpanel.compile

$(STATEDIR)/fbpanel.compile: $(fbpanel_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(FBPANEL_DIR) && $(FBPANEL_PATH) $(FBPANEL_ENV) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fbpanel_install: $(STATEDIR)/fbpanel.install

$(STATEDIR)/fbpanel.install: $(fbpanel_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fbpanel_targetinstall: $(STATEDIR)/fbpanel.targetinstall

$(STATEDIR)/fbpanel.targetinstall: $(fbpanel_targetinstall_deps_default)
	@$(call targetinfo, $@)

	cd $(FBPANEL_DIR) && $(FBPANEL_PATH) $(FBPANEL_ENV) $(MAKE) $(PARALLELMFLAGS) PREFIX=$(FBPANEL_DIR)/fakeroot/usr install

	@$(call install_init, fbpanel)
	@$(call install_fixup, fbpanel,PACKAGE,fbpanel)
	@$(call install_fixup, fbpanel,PRIORITY,optional)
	@$(call install_fixup, fbpanel,VERSION,$(FBPANEL_VERSION))
	@$(call install_fixup, fbpanel,SECTION,base)
	@$(call install_fixup, fbpanel,AUTHOR,"Robert Schwebel <r.schwebel\@pengutronix.de>")
	@$(call install_fixup, fbpanel,DEPENDS, "gtk")
	@$(call install_fixup, fbpanel,DESCRIPTION,missing)

	@$(call install_target, fbpanel, $(FBPANEL_DIR)/fakeroot/usr, /usr)

	@$(call install_finish, fbpanel)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fbpanel_clean:
	rm -rf $(STATEDIR)/fbpanel.*
	rm -rf $(IMAGEDIR)/fbpanel_*
	rm -rf $(FBPANEL_DIR)

# vim: syntax=make
