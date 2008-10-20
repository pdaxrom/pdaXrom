# -*-makefile-*-
# $Id: template-make 7626 2007-11-26 10:27:03Z mkl $
#
# Copyright (C) 2008 by Adrian Crutchfield <insearchof@pdaxrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_XCHAT) += xchat

#
# Paths and names
#
XCHAT_VERSION	:= 2.8.6
XCHAT		:= xchat-$(XCHAT_VERSION)
XCHAT_SUFFIX		:= tar.bz2
XCHAT_URL		:= http://www.xchat.org/files/source/2.8/$(XCHAT).$(XCHAT_SUFFIX)
XCHAT_SOURCE		:= $(SRCDIR)/$(XCHAT).$(XCHAT_SUFFIX)
XCHAT_DIR		:= $(BUILDDIR)/$(XCHAT)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchat_get: $(STATEDIR)/xchat.get

$(STATEDIR)/xchat.get: $(xchat_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(XCHAT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, XCHAT)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchat_extract: $(STATEDIR)/xchat.extract

$(STATEDIR)/xchat.extract: $(xchat_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAT_DIR))
	@$(call extract, XCHAT)
	@$(call patchin, XCHAT)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchat_prepare: $(STATEDIR)/xchat.prepare

XCHAT_PATH	:= PATH=$(CROSS_PATH)
XCHAT_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
XCHAT_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/xchat.prepare: $(xchat_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAT_DIR)/config.cache)
	cd $(XCHAT_DIR) && \
		$(XCHAT_PATH) $(XCHAT_ENV) \
		./configure $(XCHAT_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchat_compile: $(STATEDIR)/xchat.compile

$(STATEDIR)/xchat.compile: $(xchat_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(XCHAT_DIR) && $(XCHAT_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchat_install: $(STATEDIR)/xchat.install

$(STATEDIR)/xchat.install: $(xchat_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, XCHAT)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchat_targetinstall: $(STATEDIR)/xchat.targetinstall

$(STATEDIR)/xchat.targetinstall: $(xchat_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, xchat)
	@$(call install_fixup, xchat,PACKAGE,xchat)
	@$(call install_fixup, xchat,PRIORITY,optional)
	@$(call install_fixup, xchat,VERSION,$(XCHAT_VERSION))
	@$(call install_fixup, xchat,SECTION,base)
	@$(call install_fixup, xchat,AUTHOR,"Robert Schwebel <r.schwebel\@pengutronix.de>")
	@$(call install_fixup, xchat,DEPENDS,)
	@$(call install_fixup, xchat,DESCRIPTION,missing)

	@$(call install_copy, xchat, 0, 0, 0755, $(XCHAT_DIR)/foobar, /dev/null)

	@$(call install_finish, xchat)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchat_clean:
	rm -rf $(STATEDIR)/xchat.*
	rm -rf $(IMAGEDIR)/xchat_*
	rm -rf $(XCHAT_DIR)

# vim: syntax=make
