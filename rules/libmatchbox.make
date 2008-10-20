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
PACKAGES-$(PTXCONF_LIBMATCHBOX) += libmatchbox

#
# Paths and names
#
LIBMATCHBOX_VERSION	:= 1.9
LIBMATCHBOX		:= libmatchbox-$(LIBMATCHBOX_VERSION)
LIBMATCHBOX_SUFFIX	:= tar.bz2
LIBMATCHBOX_URL		:= http://matchbox-project.org/sources/libmatchbox/1.9/$(LIBMATCHBOX).$(LIBMATCHBOX_SUFFIX)
LIBMATCHBOX_SOURCE	:= $(SRCDIR)/$(LIBMATCHBOX).$(LIBMATCHBOX_SUFFIX)
LIBMATCHBOX_DIR		:= $(BUILDDIR)/$(LIBMATCHBOX)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libmatchbox_get: $(STATEDIR)/libmatchbox.get

$(STATEDIR)/libmatchbox.get: $(libmatchbox_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(LIBMATCHBOX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, LIBMATCHBOX)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libmatchbox_extract: $(STATEDIR)/libmatchbox.extract

$(STATEDIR)/libmatchbox.extract: $(libmatchbox_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBMATCHBOX_DIR))
	@$(call extract, LIBMATCHBOX)
	@$(call patchin, LIBMATCHBOX)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libmatchbox_prepare: $(STATEDIR)/libmatchbox.prepare

LIBMATCHBOX_PATH	:= PATH=$(CROSS_PATH)
LIBMATCHBOX_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
LIBMATCHBOX_AUTOCONF := $(CROSS_AUTOCONF_USR) --enable-jpeg

$(STATEDIR)/libmatchbox.prepare: $(libmatchbox_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBMATCHBOX_DIR)/config.cache)
	cd $(LIBMATCHBOX_DIR) && \
		$(LIBMATCHBOX_PATH) $(LIBMATCHBOX_ENV) \
		./configure $(LIBMATCHBOX_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libmatchbox_compile: $(STATEDIR)/libmatchbox.compile

$(STATEDIR)/libmatchbox.compile: $(libmatchbox_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(LIBMATCHBOX_DIR) && $(LIBMATCHBOX_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libmatchbox_install: $(STATEDIR)/libmatchbox.install

$(STATEDIR)/libmatchbox.install: $(libmatchbox_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, LIBMATCHBOX)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libmatchbox_targetinstall: $(STATEDIR)/libmatchbox.targetinstall

$(STATEDIR)/libmatchbox.targetinstall: $(libmatchbox_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, libmatchbox)
	@$(call install_fixup, libmatchbox,PACKAGE,libmatchbox)
	@$(call install_fixup, libmatchbox,PRIORITY,optional)
	@$(call install_fixup, libmatchbox,VERSION,$(LIBMATCHBOX_VERSION))
	@$(call install_fixup, libmatchbox,SECTION,base)
	@$(call install_fixup, libmatchbox,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, libmatchbox,DEPENDS, "startup-notification libpng libjpeg")
	@$(call install_fixup, libmatchbox,DESCRIPTION,missing)

	@$(call install_copy, libmatchbox, 0, 0, 0755, $(LIBMATCHBOX_DIR)/libmb/.libs/libmb.so.1.0.9, /usr/lib/libmb.so.1.0.9)
	@$(call install_link, libmatchbox, libmb.so.1.0.9, /usr/lib/libmb.so.1)
	@$(call install_link, libmatchbox, libmb.so.1.0.9, /usr/lib/libmb.so)

	@$(call install_finish, libmatchbox)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libmatchbox_clean:
	rm -rf $(STATEDIR)/libmatchbox.*
	rm -rf $(IMAGEDIR)/libmatchbox_*
	rm -rf $(LIBMATCHBOX_DIR)

# vim: syntax=make
