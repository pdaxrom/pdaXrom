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
PACKAGES-$(PTXCONF_GPAINT) += gpaint

#
# Paths and names
#
GPAINT_VERSION	:= 0.3.3
GPAINT		:= gpaint-2-$(GPAINT_VERSION)
GPAINT_SUFFIX	:= tar.gz
GPAINT_URL	:= ftp://alpha.gnu.org/gnu/gpaint/$(GPAINT).$(GPAINT_SUFFIX)
GPAINT_SOURCE	:= $(SRCDIR)/$(GPAINT).$(GPAINT_SUFFIX)
GPAINT_DIR	:= $(BUILDDIR)/$(GPAINT)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gpaint_get: $(STATEDIR)/gpaint.get

$(STATEDIR)/gpaint.get: $(gpaint_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(GPAINT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, GPAINT)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gpaint_extract: $(STATEDIR)/gpaint.extract

$(STATEDIR)/gpaint.extract: $(gpaint_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(GPAINT_DIR))
	@$(call extract, GPAINT)
	@$(call patchin, GPAINT)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gpaint_prepare: $(STATEDIR)/gpaint.prepare

GPAINT_PATH	:= PATH=$(CROSS_PATH)
GPAINT_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
GPAINT_AUTOCONF := $(CROSS_AUTOCONF_USR) \
    --without-gnome

$(STATEDIR)/gpaint.prepare: $(gpaint_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(GPAINT_DIR)/config.cache)
	cd $(GPAINT_DIR) && \
		$(GPAINT_PATH) $(GPAINT_ENV) \
		./configure $(GPAINT_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gpaint_compile: $(STATEDIR)/gpaint.compile

$(STATEDIR)/gpaint.compile: $(gpaint_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(GPAINT_DIR) && $(GPAINT_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gpaint_install: $(STATEDIR)/gpaint.install

$(STATEDIR)/gpaint.install: $(gpaint_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gpaint_targetinstall: $(STATEDIR)/gpaint.targetinstall

$(STATEDIR)/gpaint.targetinstall: $(gpaint_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, gpaint)
	@$(call install_fixup, gpaint,PACKAGE,gpaint)
	@$(call install_fixup, gpaint,PRIORITY,optional)
	@$(call install_fixup, gpaint,VERSION,$(GPAINT_VERSION))
	@$(call install_fixup, gpaint,SECTION,base)
	@$(call install_fixup, gpaint,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, gpaint,DEPENDS,)
	@$(call install_fixup, gpaint,DESCRIPTION,missing)

	@$(call install_copy, gpaint, 0, 0, 0755, $(GPAINT_DIR)/src/gpaint-2, /usr/bin/gpaint-2)
	@$(call install_copy, gpaint, 0, 0, 0644, $(GPAINT_DIR)/gpaint.glade, /usr/share/gpaint/glade/gpaint.glade)
	@$(call install_copy, gpaint, 0, 0, 0644, $(PDAXROMDIR)/apps/gpaint.desktop, /usr/share/applications/gpaint.desktop)

	@$(call install_finish, gpaint)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gpaint_clean:
	rm -rf $(STATEDIR)/gpaint.*
	rm -rf $(IMAGEDIR)/gpaint_*
	rm -rf $(GPAINT_DIR)

# vim: syntax=make
