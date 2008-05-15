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
PACKAGES-$(PTXCONF_PDAXROM_THEME) += pdaxrom-theme

#
# Paths and names
#
PDAXROM_THEME_VERSION	:= 2.0
PDAXROM_THEME		:= pdaXrom-theme-$(PDAXROM_THEME_VERSION)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pdaxrom-theme_get: $(STATEDIR)/pdaxrom-theme.get

$(STATEDIR)/pdaxrom-theme.get: $(pdaxrom-theme_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pdaxrom-theme_extract: $(STATEDIR)/pdaxrom-theme.extract

$(STATEDIR)/pdaxrom-theme.extract: $(pdaxrom-theme_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pdaxrom-theme_prepare: $(STATEDIR)/pdaxrom-theme.prepare

PDAXROM_THEME_PATH	:= PATH=$(CROSS_PATH)
PDAXROM_THEME_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
PDAXROM_THEME_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/pdaxrom-theme.prepare: $(pdaxrom-theme_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(PDAXROM_THEME_DIR)/config.cache)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pdaxrom-theme_compile: $(STATEDIR)/pdaxrom-theme.compile

$(STATEDIR)/pdaxrom-theme.compile: $(pdaxrom-theme_compile_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pdaxrom-theme_install: $(STATEDIR)/pdaxrom-theme.install

$(STATEDIR)/pdaxrom-theme.install: $(pdaxrom-theme_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pdaxrom-theme_targetinstall: $(STATEDIR)/pdaxrom-theme.targetinstall

$(STATEDIR)/pdaxrom-theme.targetinstall: $(pdaxrom-theme_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, pdaxrom-theme)
	@$(call install_fixup, pdaxrom-theme,PACKAGE,pdaxrom-theme)
	@$(call install_fixup, pdaxrom-theme,PRIORITY,optional)
	@$(call install_fixup, pdaxrom-theme,VERSION,$(PDAXROM_THEME_VERSION))
	@$(call install_fixup, pdaxrom-theme,SECTION,base)
	@$(call install_fixup, pdaxrom-theme,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, pdaxrom-theme,DEPENDS,)
	@$(call install_fixup, pdaxrom-theme,DESCRIPTION,missing)

ifdef PTXCONF_PDAXROM_THEME_DESKTOP
	@$(call install_copy, pdaxrom-theme, 0, 0, 0755, $(PDAXROMDIR)/configs/openbox/autostart.sh, /etc/xdg/openbox/autostart.sh)
	@cd $(PDAXROMDIR)/pixmaps/fbpanel; \
	for i in *.png; do \
		$(call install_copy, pdaxrom-theme, 0, 0, 0644, $$i, \
			/usr/share/pixmaps/$$i,n); \
	done;
endif
	@$(call install_finish, pdaxrom-theme)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pdaxrom-theme_clean:
	rm -rf $(STATEDIR)/pdaxrom-theme.*
	rm -rf $(IMAGEDIR)/pdaxrom-theme_*
	rm -rf $(PDAXROM_THEME_DIR)

# vim: syntax=make
