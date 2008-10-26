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
PACKAGES-$(PTXCONF_MTPAINT) += mtpaint

#
# Paths and names
#
MTPAINT_VERSION	:= 3.21
MTPAINT		:= mtpaint-$(MTPAINT_VERSION)
MTPAINT_SUFFIX	:= tar.bz2
MTPAINT_URL	:= http://downloads.sourceforge.net/mtpaint/$(MTPAINT).$(MTPAINT_SUFFIX)
MTPAINT_SOURCE	:= $(SRCDIR)/$(MTPAINT).$(MTPAINT_SUFFIX)
MTPAINT_DIR	:= $(BUILDDIR)/$(MTPAINT)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mtpaint_get: $(STATEDIR)/mtpaint.get

$(STATEDIR)/mtpaint.get: $(mtpaint_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MTPAINT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MTPAINT)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mtpaint_extract: $(STATEDIR)/mtpaint.extract

$(STATEDIR)/mtpaint.extract: $(mtpaint_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MTPAINT_DIR))
	@$(call extract, MTPAINT)
	@$(call patchin, MTPAINT)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mtpaint_prepare: $(STATEDIR)/mtpaint.prepare

MTPAINT_PATH	:= PATH=$(CROSS_PATH)
MTPAINT_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MTPAINT_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/mtpaint.prepare: $(mtpaint_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MTPAINT_DIR)/config.cache)
	cd $(MTPAINT_DIR) && \
		$(MTPAINT_PATH) $(MTPAINT_ENV) \
		./configure $(MTPAINT_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mtpaint_compile: $(STATEDIR)/mtpaint.compile

$(STATEDIR)/mtpaint.compile: $(mtpaint_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MTPAINT_DIR) && $(MTPAINT_PATH) $(MTPAINT_ENV) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mtpaint_install: $(STATEDIR)/mtpaint.install

$(STATEDIR)/mtpaint.install: $(mtpaint_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mtpaint_targetinstall: $(STATEDIR)/mtpaint.targetinstall

$(STATEDIR)/mtpaint.targetinstall: $(mtpaint_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, mtpaint)
	@$(call install_fixup, mtpaint,PACKAGE,mtpaint)
	@$(call install_fixup, mtpaint,PRIORITY,optional)
	@$(call install_fixup, mtpaint,VERSION,$(MTPAINT_VERSION))
	@$(call install_fixup, mtpaint,SECTION,base)
	@$(call install_fixup, mtpaint,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, mtpaint,DEPENDS,)
	@$(call install_fixup, mtpaint,DESCRIPTION,missing)

	@$(call install_copy, mtpaint, 0, 0, 0755, $(MTPAINT_DIR)/src/mtpaint, /usr/bin/mtpaint)
	@$(call install_copy, mtpaint, 0, 0, 0644, $(PDAXROMDIR)/apps/mtpaint.desktop, /usr/share/applications/mtpaint.desktop)
	@$(call install_copy, mtpaint, 0, 0, 0644, $(PDAXROMDIR)/pixmaps/mtpaint.png, /usr/share/pixmaps/mtpaint.png)

	@$(call install_finish, mtpaint)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mtpaint_clean:
	rm -rf $(STATEDIR)/mtpaint.*
	rm -rf $(IMAGEDIR)/mtpaint_*
	rm -rf $(MTPAINT_DIR)

# vim: syntax=make
