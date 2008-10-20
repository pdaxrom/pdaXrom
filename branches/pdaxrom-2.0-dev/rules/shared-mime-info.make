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
PACKAGES-$(PTXCONF_SHARED_MIME_INFO) += shared-mime-info

#
# Paths and names
#
SHARED_MIME_INFO_VERSION	:= 0.23
SHARED_MIME_INFO		:= shared-mime-info-$(SHARED_MIME_INFO_VERSION)
SHARED_MIME_INFO_SUFFIX		:= tar.bz2
SHARED_MIME_INFO_URL		:= http://freedesktop.org/~hadess/$(SHARED_MIME_INFO).$(SHARED_MIME_INFO_SUFFIX)
SHARED_MIME_INFO_SOURCE		:= $(SRCDIR)/$(SHARED_MIME_INFO).$(SHARED_MIME_INFO_SUFFIX)
SHARED_MIME_INFO_DIR		:= $(BUILDDIR)/$(SHARED_MIME_INFO)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

shared-mime-info_get: $(STATEDIR)/shared-mime-info.get

$(STATEDIR)/shared-mime-info.get: $(shared-mime-info_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(SHARED_MIME_INFO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, SHARED_MIME_INFO)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

shared-mime-info_extract: $(STATEDIR)/shared-mime-info.extract

$(STATEDIR)/shared-mime-info.extract: $(shared-mime-info_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(SHARED_MIME_INFO_DIR))
	@$(call extract, SHARED_MIME_INFO)
	@$(call patchin, SHARED_MIME_INFO)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

shared-mime-info_prepare: $(STATEDIR)/shared-mime-info.prepare

SHARED_MIME_INFO_PATH	:= PATH=$(CROSS_PATH)
SHARED_MIME_INFO_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
SHARED_MIME_INFO_AUTOCONF := $(CROSS_AUTOCONF_USR) \
    --disable-update-mimedb

$(STATEDIR)/shared-mime-info.prepare: $(shared-mime-info_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(SHARED_MIME_INFO_DIR)/config.cache)
	cd $(SHARED_MIME_INFO_DIR) && \
		$(SHARED_MIME_INFO_PATH) $(SHARED_MIME_INFO_ENV) \
		./configure $(SHARED_MIME_INFO_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

shared-mime-info_compile: $(STATEDIR)/shared-mime-info.compile

$(STATEDIR)/shared-mime-info.compile: $(shared-mime-info_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(SHARED_MIME_INFO_DIR) && $(SHARED_MIME_INFO_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

shared-mime-info_install: $(STATEDIR)/shared-mime-info.install

$(STATEDIR)/shared-mime-info.install: $(shared-mime-info_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, SHARED_MIME_INFO)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

shared-mime-info_targetinstall: $(STATEDIR)/shared-mime-info.targetinstall

$(STATEDIR)/shared-mime-info.targetinstall: $(shared-mime-info_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, shared-mime-info)
	@$(call install_fixup, shared-mime-info,PACKAGE,shared-mime-info)
	@$(call install_fixup, shared-mime-info,PRIORITY,optional)
	@$(call install_fixup, shared-mime-info,VERSION,$(SHARED_MIME_INFO_VERSION))
	@$(call install_fixup, shared-mime-info,SECTION,base)
	@$(call install_fixup, shared-mime-info,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, shared-mime-info,DEPENDS,)
	@$(call install_fixup, shared-mime-info,DESCRIPTION,missing)

	@$(call install_copy, shared-mime-info, 0, 0, 0644, $(SHARED_MIME_INFO_DIR)/freedesktop.org.xml, \
	    /usr/share/mime/packages/freedesktop.org.xml)

	@$(call install_finish, shared-mime-info)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

shared-mime-info_clean:
	rm -rf $(STATEDIR)/shared-mime-info.*
	rm -rf $(IMAGEDIR)/shared-mime-info_*
	rm -rf $(SHARED_MIME_INFO_DIR)

# vim: syntax=make
