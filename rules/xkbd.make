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
PACKAGES-$(PTXCONF_XKBD) += xkbd

#
# Paths and names
#
XKBD_VERSION		:= 0.8.15
XKBD			:= xkbd-$(XKBD_VERSION)
XKBD_SUFFIX		:= tar.gz
XKBD_URL		:= http://mail.pdaXrom.org/src/$(XKBD).$(XKBD_SUFFIX)
XKBD_SOURCE		:= $(SRCDIR)/$(XKBD).$(XKBD_SUFFIX)
XKBD_DIR		:= $(BUILDDIR)/$(XKBD)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xkbd_get: $(STATEDIR)/xkbd.get

$(STATEDIR)/xkbd.get: $(xkbd_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(XKBD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, XKBD)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xkbd_extract: $(STATEDIR)/xkbd.extract

$(STATEDIR)/xkbd.extract: $(xkbd_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(XKBD_DIR))
	@$(call extract, XKBD)
	@$(call patchin, XKBD)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xkbd_prepare: $(STATEDIR)/xkbd.prepare

XKBD_PATH	:= PATH=$(CROSS_PATH)
XKBD_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
XKBD_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/xkbd.prepare: $(xkbd_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(XKBD_DIR)/config.cache)
	cd $(XKBD_DIR) && \
		$(XKBD_PATH) $(XKBD_ENV) \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure $(XKBD_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xkbd_compile: $(STATEDIR)/xkbd.compile

$(STATEDIR)/xkbd.compile: $(xkbd_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(XKBD_DIR) && $(XKBD_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xkbd_install: $(STATEDIR)/xkbd.install

$(STATEDIR)/xkbd.install: $(xkbd_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, XKBD)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xkbd_targetinstall: $(STATEDIR)/xkbd.targetinstall

$(STATEDIR)/xkbd.targetinstall: $(xkbd_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, xkbd)
	@$(call install_fixup, xkbd,PACKAGE,xkbd)
	@$(call install_fixup, xkbd,PRIORITY,optional)
	@$(call install_fixup, xkbd,VERSION,$(XKBD_VERSION))
	@$(call install_fixup, xkbd,SECTION,base)
	@$(call install_fixup, xkbd,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, xkbd,DEPENDS,)
	@$(call install_fixup, xkbd,DESCRIPTION,missing)

	@$(call install_copy, xkbd, 0, 0, 0755, $(XKBD_DIR)/src/xkbd, 			/usr/bin/xkbd)
	@$(call install_copy, xkbd, 0, 0, 0644, $(XKBD_DIR)/data/en_US.qwerty.xkbd, 	/usr/share/xkbd/en_US.qwerty.xkbd)
	@$(call install_copy, xkbd, 0, 0, 0644, $(XKBD_DIR)/data/img/backspace.xpm, 	/usr/share/xkbd/img/backspace.xpm)
	@$(call install_copy, xkbd, 0, 0, 0644, $(XKBD_DIR)/data/img/kbd.xpm, 		/usr/share/xkbd/img/kbd.xpm)
	@$(call install_copy, xkbd, 0, 0, 0644, $(XKBD_DIR)/data/img/return.xpm, 	/usr/share/xkbd/img/return.xpm)
	@$(call install_copy, xkbd, 0, 0, 0644, $(XKBD_DIR)/data/img/shift.xpm, 	/usr/share/xkbd/img/shift.xpm)
	@$(call install_copy, xkbd, 0, 0, 0644, $(XKBD_DIR)/data/img/tab.xpm, 		/usr/share/xkbd/img/tab.xpm)
	@$(call install_copy, xkbd, 0, 0, 0644, $(XKBD_DIR)/xkbd.png,	 		/usr/share/pixmaps/xkbd.png)
	@$(call install_copy, xkbd, 0, 0, 0644, $(XKBD_DIR)/xkbd.desktop,	 	/usr/share/applications/xkbd.desktop)
	
	@$(call install_finish, xkbd)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xkbd_clean:
	rm -rf $(STATEDIR)/xkbd.*
	rm -rf $(IMAGEDIR)/xkbd_*
	rm -rf $(XKBD_DIR)

# vim: syntax=make
