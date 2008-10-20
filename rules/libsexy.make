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
PACKAGES-$(PTXCONF_LIBSEXY) += libsexy

#
# Paths and names
#
LIBSEXY_VERSION	:= 0.1.11
LIBSEXY		:= libsexy-$(LIBSEXY_VERSION)
LIBSEXY_SUFFIX	:= tar.gz
LIBSEXY_URL	:= http://releases.chipx86.com/libsexy/libsexy/$(LIBSEXY).$(LIBSEXY_SUFFIX)
LIBSEXY_SOURCE	:= $(SRCDIR)/$(LIBSEXY).$(LIBSEXY_SUFFIX)
LIBSEXY_DIR	:= $(BUILDDIR)/$(LIBSEXY)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libsexy_get: $(STATEDIR)/libsexy.get

$(STATEDIR)/libsexy.get: $(libsexy_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(LIBSEXY_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, LIBSEXY)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libsexy_extract: $(STATEDIR)/libsexy.extract

$(STATEDIR)/libsexy.extract: $(libsexy_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBSEXY_DIR))
	@$(call extract, LIBSEXY)
	@$(call patchin, LIBSEXY)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libsexy_prepare: $(STATEDIR)/libsexy.prepare

LIBSEXY_PATH	:= PATH=$(CROSS_PATH)
LIBSEXY_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
LIBSEXY_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/libsexy.prepare: $(libsexy_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBSEXY_DIR)/config.cache)
	cd $(LIBSEXY_DIR) && \
		$(LIBSEXY_PATH) $(LIBSEXY_ENV) \
		./configure $(LIBSEXY_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libsexy_compile: $(STATEDIR)/libsexy.compile

$(STATEDIR)/libsexy.compile: $(libsexy_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(LIBSEXY_DIR) && $(LIBSEXY_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libsexy_install: $(STATEDIR)/libsexy.install

$(STATEDIR)/libsexy.install: $(libsexy_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, LIBSEXY)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libsexy_targetinstall: $(STATEDIR)/libsexy.targetinstall

$(STATEDIR)/libsexy.targetinstall: $(libsexy_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, libsexy)
	@$(call install_fixup, libsexy,PACKAGE,libsexy)
	@$(call install_fixup, libsexy,PRIORITY,optional)
	@$(call install_fixup, libsexy,VERSION,$(LIBSEXY_VERSION))
	@$(call install_fixup, libsexy,SECTION,base)
	@$(call install_fixup, libsexy,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, libsexy,DEPENDS, "gtk")
	@$(call install_fixup, libsexy,DESCRIPTION,missing)

	@$(call install_copy, libsexy, 0, 0, 0755, $(LIBSEXY_DIR)/libsexy/.libs/libsexy.so.2.0.4, /usr/lib/libsexy.so.2.0.4)
	@$(call install_link, libsexy, libsexy.so.2.0.4, /usr/lib/libsexy.so.2)
	@$(call install_link, libsexy, libsexy.so.2.0.4, /usr/lib/libsexy.so)

	@$(call install_finish, libsexy)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libsexy_clean:
	rm -rf $(STATEDIR)/libsexy.*
	rm -rf $(IMAGEDIR)/libsexy_*
	rm -rf $(LIBSEXY_DIR)

# vim: syntax=make
