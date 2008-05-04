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
PACKAGES-$(PTXCONF_LIBFAKEKEY) += libfakekey

#
# Paths and names
#
LIBFAKEKEY_VERSION	:= 0.1
LIBFAKEKEY		:= libfakekey-$(LIBFAKEKEY_VERSION)
LIBFAKEKEY_SUFFIX	:= tar.bz2
LIBFAKEKEY_URL		:= http://matchbox-project.org/sources/libfakekey/0.1/$(LIBFAKEKEY).$(LIBFAKEKEY_SUFFIX)
LIBFAKEKEY_SOURCE	:= $(SRCDIR)/$(LIBFAKEKEY).$(LIBFAKEKEY_SUFFIX)
LIBFAKEKEY_DIR		:= $(BUILDDIR)/$(LIBFAKEKEY)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libfakekey_get: $(STATEDIR)/libfakekey.get

$(STATEDIR)/libfakekey.get: $(libfakekey_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(LIBFAKEKEY_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, LIBFAKEKEY)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libfakekey_extract: $(STATEDIR)/libfakekey.extract

$(STATEDIR)/libfakekey.extract: $(libfakekey_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBFAKEKEY_DIR))
	@$(call extract, LIBFAKEKEY)
	@$(call patchin, LIBFAKEKEY)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libfakekey_prepare: $(STATEDIR)/libfakekey.prepare

LIBFAKEKEY_PATH	:= PATH=$(CROSS_PATH)
LIBFAKEKEY_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
LIBFAKEKEY_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/libfakekey.prepare: $(libfakekey_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBFAKEKEY_DIR)/config.cache)
	cd $(LIBFAKEKEY_DIR) && \
		$(LIBFAKEKEY_PATH) $(LIBFAKEKEY_ENV) \
		./configure $(LIBFAKEKEY_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libfakekey_compile: $(STATEDIR)/libfakekey.compile

$(STATEDIR)/libfakekey.compile: $(libfakekey_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(LIBFAKEKEY_DIR) && $(LIBFAKEKEY_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libfakekey_install: $(STATEDIR)/libfakekey.install

$(STATEDIR)/libfakekey.install: $(libfakekey_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, LIBFAKEKEY)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libfakekey_targetinstall: $(STATEDIR)/libfakekey.targetinstall

$(STATEDIR)/libfakekey.targetinstall: $(libfakekey_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, libfakekey)
	@$(call install_fixup, libfakekey,PACKAGE,libfakekey)
	@$(call install_fixup, libfakekey,PRIORITY,optional)
	@$(call install_fixup, libfakekey,VERSION,$(LIBFAKEKEY_VERSION))
	@$(call install_fixup, libfakekey,SECTION,base)
	@$(call install_fixup, libfakekey,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, libfakekey,DEPENDS, "xorg-lib-x11 xorg-lib-xtst")
	@$(call install_fixup, libfakekey,DESCRIPTION,missing)

	@$(call install_copy, libfakekey, 0, 0, 0755, $(LIBFAKEKEY_DIR)/src/.libs/libfakekey.so.0.0.1, /usr/lib/libfakekey.so.0.0.1)
	@$(call install_link, libfakekey, libfakekey.so.0.0.1, /usr/lib/libfakekey.so.0)
	@$(call install_link, libfakekey, libfakekey.so.0.0.1, /usr/lib/libfakekey.so)

	@$(call install_finish, libfakekey)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libfakekey_clean:
	rm -rf $(STATEDIR)/libfakekey.*
	rm -rf $(IMAGEDIR)/libfakekey_*
	rm -rf $(LIBFAKEKEY_DIR)

# vim: syntax=make
