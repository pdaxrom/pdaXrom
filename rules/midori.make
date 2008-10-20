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
PACKAGES-$(PTXCONF_MIDORI) += midori

#
# Paths and names
#
MIDORI_VERSION	:= 0.0.18
MIDORI		:= midori-$(MIDORI_VERSION)
MIDORI_SUFFIX	:= tar.gz
MIDORI_URL	:= http://software.twotoasts.de/media/midori/$(MIDORI).$(MIDORI_SUFFIX)
MIDORI_SOURCE	:= $(SRCDIR)/$(MIDORI).$(MIDORI_SUFFIX)
MIDORI_DIR	:= $(BUILDDIR)/$(MIDORI)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

midori_get: $(STATEDIR)/midori.get

$(STATEDIR)/midori.get: $(midori_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MIDORI_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MIDORI)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

midori_extract: $(STATEDIR)/midori.extract

$(STATEDIR)/midori.extract: $(midori_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MIDORI_DIR))
	@$(call extract, MIDORI)
	@$(call patchin, MIDORI)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

midori_prepare: $(STATEDIR)/midori.prepare

MIDORI_PATH	:= PATH=$(CROSS_PATH)
MIDORI_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MIDORI_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/midori.prepare: $(midori_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MIDORI_DIR)/config.cache)
	cd $(MIDORI_DIR) && \
		$(MIDORI_PATH) $(MIDORI_ENV) \
		./configure $(MIDORI_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

midori_compile: $(STATEDIR)/midori.compile

$(STATEDIR)/midori.compile: $(midori_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MIDORI_DIR) && $(MIDORI_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

midori_install: $(STATEDIR)/midori.install

$(STATEDIR)/midori.install: $(midori_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, MIDORI)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

midori_targetinstall: $(STATEDIR)/midori.targetinstall

$(STATEDIR)/midori.targetinstall: $(midori_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, midori)
	@$(call install_fixup, midori,PACKAGE,midori)
	@$(call install_fixup, midori,PRIORITY,optional)
	@$(call install_fixup, midori,VERSION,$(MIDORI_VERSION))
	@$(call install_fixup, midori,SECTION,base)
	@$(call install_fixup, midori,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, midori,DEPENDS, "webkit libsexy gtk")
	@$(call install_fixup, midori,DESCRIPTION,missing)

	@$(call install_copy, midori, 0, 0, 0755, $(MIDORI_DIR)/src/midori, /usr/bin/midori)
	@$(call install_copy, midori, 0, 0, 0644, $(MIDORI_DIR)/midori.desktop, /usr/share/applications/midori.desktop)
	@$(call install_copy, midori, 0, 0, 0644, $(PDAXROMDIR)/pixmaps/web-browser.png, /usr/share/pixmaps/web-browser.png)

	@$(call install_finish, midori)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

midori_clean:
	rm -rf $(STATEDIR)/midori.*
	rm -rf $(IMAGEDIR)/midori_*
	rm -rf $(MIDORI_DIR)

# vim: syntax=make
