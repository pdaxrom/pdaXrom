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
PACKAGES-$(PTXCONF_ATERM) += aterm

#
# Paths and names
#
ATERM_VERSION	:= 1.0.1
ATERM		:= aterm-$(ATERM_VERSION)
ATERM_SUFFIX	:= tar.bz2
ATERM_URL	:= http://downloads.sourceforge.net/aterm/$(ATERM).$(ATERM_SUFFIX)
ATERM_SOURCE	:= $(SRCDIR)/$(ATERM).$(ATERM_SUFFIX)
ATERM_DIR	:= $(BUILDDIR)/$(ATERM)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

aterm_get: $(STATEDIR)/aterm.get

$(STATEDIR)/aterm.get: $(aterm_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(ATERM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, ATERM)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

aterm_extract: $(STATEDIR)/aterm.extract

$(STATEDIR)/aterm.extract: $(aterm_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(ATERM_DIR))
	@$(call extract, ATERM)
	@$(call patchin, ATERM)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

aterm_prepare: $(STATEDIR)/aterm.prepare

ATERM_PATH	:= PATH=$(CROSS_PATH)
ATERM_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
ATERM_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/aterm.prepare: $(aterm_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(ATERM_DIR)/config.cache)
	cd $(ATERM_DIR) && \
		$(ATERM_PATH) $(ATERM_ENV) \
		./configure $(ATERM_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

aterm_compile: $(STATEDIR)/aterm.compile

$(STATEDIR)/aterm.compile: $(aterm_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(ATERM_DIR) && $(ATERM_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

aterm_install: $(STATEDIR)/aterm.install

$(STATEDIR)/aterm.install: $(aterm_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

aterm_targetinstall: $(STATEDIR)/aterm.targetinstall

$(STATEDIR)/aterm.targetinstall: $(aterm_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, aterm)
	@$(call install_fixup, aterm,PACKAGE,aterm)
	@$(call install_fixup, aterm,PRIORITY,optional)
	@$(call install_fixup, aterm,VERSION,$(ATERM_VERSION))
	@$(call install_fixup, aterm,SECTION,base)
	@$(call install_fixup, aterm,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, aterm,DEPENDS,)
	@$(call install_fixup, aterm,DESCRIPTION,missing)

	@$(call install_copy, aterm, 0, 0, 0755, $(ATERM_DIR)/src/aterm, /usr/bin/aterm)

	@$(call install_finish, aterm)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

aterm_clean:
	rm -rf $(STATEDIR)/aterm.*
	rm -rf $(IMAGEDIR)/aterm_*
	rm -rf $(ATERM_DIR)

# vim: syntax=make
