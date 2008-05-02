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
PACKAGES-$(PTXCONF_LINKS) += links

#
# Paths and names
#
LINKS_VERSION	:= 2.1pre33
LINKS		:= links-$(LINKS_VERSION)
LINKS_SUFFIX	:= tar.bz2
LINKS_URL	:= http://links.twibright.com/download/$(LINKS).$(LINKS_SUFFIX)
LINKS_SOURCE	:= $(SRCDIR)/$(LINKS).$(LINKS_SUFFIX)
LINKS_DIR	:= $(BUILDDIR)/$(LINKS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

links_get: $(STATEDIR)/links.get

$(STATEDIR)/links.get: $(links_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(LINKS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, LINKS)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

links_extract: $(STATEDIR)/links.extract

$(STATEDIR)/links.extract: $(links_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LINKS_DIR))
	@$(call extract, LINKS)
	@$(call patchin, LINKS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

links_prepare: $(STATEDIR)/links.prepare

LINKS_PATH	:= PATH=$(CROSS_PATH)
LINKS_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
LINKS_AUTOCONF := $(CROSS_AUTOCONF_USR)

ifdef PTXCONF_LINKS_X11
LINKS_AUTOCONF += --enable-graphics --with-x --without-fb --without-directfb --without-pmshell
endif

$(STATEDIR)/links.prepare: $(links_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LINKS_DIR)/config.cache)
	cd $(LINKS_DIR) && \
		$(LINKS_PATH) $(LINKS_ENV) \
		./configure $(LINKS_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

links_compile: $(STATEDIR)/links.compile

$(STATEDIR)/links.compile: $(links_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(LINKS_DIR) && $(LINKS_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

links_install: $(STATEDIR)/links.install

$(STATEDIR)/links.install: $(links_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, LINKS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

links_targetinstall: $(STATEDIR)/links.targetinstall

$(STATEDIR)/links.targetinstall: $(links_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, links)
	@$(call install_fixup, links,PACKAGE,links)
	@$(call install_fixup, links,PRIORITY,optional)
	@$(call install_fixup, links,VERSION,$(LINKS_VERSION))
	@$(call install_fixup, links,SECTION,base)
	@$(call install_fixup, links,AUTHOR,"Robert Schwebel <r.schwebel\@pengutronix.de>")
	@$(call install_fixup, links,DEPENDS,)
	@$(call install_fixup, links,DESCRIPTION,missing)

	@$(call install_copy, links, 0, 0, 0755, $(LINKS_DIR)/links, /usr/bin/links)

	@$(call install_finish, links)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

links_clean:
	rm -rf $(STATEDIR)/links.*
	rm -rf $(IMAGEDIR)/links_*
	rm -rf $(LINKS_DIR)

# vim: syntax=make
