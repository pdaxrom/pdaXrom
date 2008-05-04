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
PACKAGES-$(PTXCONF_MB_DESKTOP_IMAGE_BROWSER) += mb-desktop-image-browser

#
# Paths and names
#
MB_DESKTOP_IMAGE_BROWSER_VERSION	:= 0.2
MB_DESKTOP_IMAGE_BROWSER		:= mb-desktop-image-browser-$(MB_DESKTOP_IMAGE_BROWSER_VERSION)
MB_DESKTOP_IMAGE_BROWSER_SUFFIX		:= tar.bz2
MB_DESKTOP_IMAGE_BROWSER_URL		:= http://matchbox-project.org/sources/mb-desktop-image-browser/0.2/$(MB_DESKTOP_IMAGE_BROWSER).$(MB_DESKTOP_IMAGE_BROWSER_SUFFIX)
MB_DESKTOP_IMAGE_BROWSER_SOURCE		:= $(SRCDIR)/$(MB_DESKTOP_IMAGE_BROWSER).$(MB_DESKTOP_IMAGE_BROWSER_SUFFIX)
MB_DESKTOP_IMAGE_BROWSER_DIR		:= $(BUILDDIR)/$(MB_DESKTOP_IMAGE_BROWSER)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-desktop-image-browser_get: $(STATEDIR)/mb-desktop-image-browser.get

$(STATEDIR)/mb-desktop-image-browser.get: $(mb-desktop-image-browser_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MB_DESKTOP_IMAGE_BROWSER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MB_DESKTOP_IMAGE_BROWSER)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-desktop-image-browser_extract: $(STATEDIR)/mb-desktop-image-browser.extract

$(STATEDIR)/mb-desktop-image-browser.extract: $(mb-desktop-image-browser_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MB_DESKTOP_IMAGE_BROWSER_DIR))
	@$(call extract, MB_DESKTOP_IMAGE_BROWSER)
	@$(call patchin, MB_DESKTOP_IMAGE_BROWSER)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-desktop-image-browser_prepare: $(STATEDIR)/mb-desktop-image-browser.prepare

MB_DESKTOP_IMAGE_BROWSER_PATH	:= PATH=$(CROSS_PATH)
MB_DESKTOP_IMAGE_BROWSER_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MB_DESKTOP_IMAGE_BROWSER_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/mb-desktop-image-browser.prepare: $(mb-desktop-image-browser_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MB_DESKTOP_IMAGE_BROWSER_DIR)/config.cache)
	cd $(MB_DESKTOP_IMAGE_BROWSER_DIR) && \
		$(MB_DESKTOP_IMAGE_BROWSER_PATH) $(MB_DESKTOP_IMAGE_BROWSER_ENV) \
		./configure $(MB_DESKTOP_IMAGE_BROWSER_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-desktop-image-browser_compile: $(STATEDIR)/mb-desktop-image-browser.compile

$(STATEDIR)/mb-desktop-image-browser.compile: $(mb-desktop-image-browser_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MB_DESKTOP_IMAGE_BROWSER_DIR) && $(MB_DESKTOP_IMAGE_BROWSER_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-desktop-image-browser_install: $(STATEDIR)/mb-desktop-image-browser.install

$(STATEDIR)/mb-desktop-image-browser.install: $(mb-desktop-image-browser_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, MB_DESKTOP_IMAGE_BROWSER)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-desktop-image-browser_targetinstall: $(STATEDIR)/mb-desktop-image-browser.targetinstall

$(STATEDIR)/mb-desktop-image-browser.targetinstall: $(mb-desktop-image-browser_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, mb-desktop-image-browser)
	@$(call install_fixup, mb-desktop-image-browser,PACKAGE,mb-desktop-image-browser)
	@$(call install_fixup, mb-desktop-image-browser,PRIORITY,optional)
	@$(call install_fixup, mb-desktop-image-browser,VERSION,$(MB_DESKTOP_IMAGE_BROWSER_VERSION))
	@$(call install_fixup, mb-desktop-image-browser,SECTION,base)
	@$(call install_fixup, mb-desktop-image-browser,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, mb-desktop-image-browser,DEPENDS,)
	@$(call install_fixup, mb-desktop-image-browser,DESCRIPTION,missing)

	@$(call install_copy, mb-desktop-image-browser, 0, 0, 0755, $(MB_DESKTOP_IMAGE_BROWSER_DIR)/foobar, /dev/null)

	@$(call install_finish, mb-desktop-image-browser)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-desktop-image-browser_clean:
	rm -rf $(STATEDIR)/mb-desktop-image-browser.*
	rm -rf $(IMAGEDIR)/mb-desktop-image-browser_*
	rm -rf $(MB_DESKTOP_IMAGE_BROWSER_DIR)

# vim: syntax=make
