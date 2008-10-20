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
PACKAGES-$(PTXCONF_STARTUP_NOTIFICATION) += startup-notification

#
# Paths and names
#
STARTUP_NOTIFICATION_VERSION	:= 0.9
STARTUP_NOTIFICATION		:= startup-notification-$(STARTUP_NOTIFICATION_VERSION)
STARTUP_NOTIFICATION_SUFFIX	:= tar.bz2
STARTUP_NOTIFICATION_URL	:= http://www.freedesktop.org/software/startup-notification/releases/$(STARTUP_NOTIFICATION).$(STARTUP_NOTIFICATION_SUFFIX)
STARTUP_NOTIFICATION_SOURCE	:= $(SRCDIR)/$(STARTUP_NOTIFICATION).$(STARTUP_NOTIFICATION_SUFFIX)
STARTUP_NOTIFICATION_DIR	:= $(BUILDDIR)/$(STARTUP_NOTIFICATION)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

startup-notification_get: $(STATEDIR)/startup-notification.get

$(STATEDIR)/startup-notification.get: $(startup-notification_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(STARTUP_NOTIFICATION_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, STARTUP_NOTIFICATION)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

startup-notification_extract: $(STATEDIR)/startup-notification.extract

$(STATEDIR)/startup-notification.extract: $(startup-notification_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(STARTUP_NOTIFICATION_DIR))
	@$(call extract, STARTUP_NOTIFICATION)
	@$(call patchin, STARTUP_NOTIFICATION)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

startup-notification_prepare: $(STATEDIR)/startup-notification.prepare

STARTUP_NOTIFICATION_PATH	:= PATH=$(CROSS_PATH)
STARTUP_NOTIFICATION_ENV 	:= $(CROSS_ENV) \
    ac_cv_func_malloc_0_nonnull=yes \
    lf_cv_sane_realloc=yes

#
# autoconf
#
STARTUP_NOTIFICATION_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/startup-notification.prepare: $(startup-notification_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(STARTUP_NOTIFICATION_DIR)/config.cache)
	cd $(STARTUP_NOTIFICATION_DIR) && \
		$(STARTUP_NOTIFICATION_PATH) $(STARTUP_NOTIFICATION_ENV) \
		./configure $(STARTUP_NOTIFICATION_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

startup-notification_compile: $(STATEDIR)/startup-notification.compile

$(STATEDIR)/startup-notification.compile: $(startup-notification_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(STARTUP_NOTIFICATION_DIR) && $(STARTUP_NOTIFICATION_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

startup-notification_install: $(STATEDIR)/startup-notification.install

$(STATEDIR)/startup-notification.install: $(startup-notification_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, STARTUP_NOTIFICATION)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

startup-notification_targetinstall: $(STATEDIR)/startup-notification.targetinstall

$(STATEDIR)/startup-notification.targetinstall: $(startup-notification_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, startup-notification)
	@$(call install_fixup, startup-notification,PACKAGE,startup-notification)
	@$(call install_fixup, startup-notification,PRIORITY,optional)
	@$(call install_fixup, startup-notification,VERSION,$(STARTUP_NOTIFICATION_VERSION))
	@$(call install_fixup, startup-notification,SECTION,base)
	@$(call install_fixup, startup-notification,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, startup-notification,DEPENDS,)
	@$(call install_fixup, startup-notification,DESCRIPTION,missing)

	@$(call install_copy, startup-notification, 0, 0, 0755, $(STARTUP_NOTIFICATION_DIR)/libsn/.libs/libstartup-notification-1.so.0.0.0,\
		    /usr/lib/libstartup-notification-1.so.0.0.0)
	@$(call install_link, startup-notification, libstartup-notification-1.so.0.0.0, /usr/lib/libstartup-notification-1.so.0)
	@$(call install_link, startup-notification, libstartup-notification-1.so.0.0.0, /usr/lib/libstartup-notification-1.so)

	@$(call install_finish, startup-notification)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

startup-notification_clean:
	rm -rf $(STATEDIR)/startup-notification.*
	rm -rf $(IMAGEDIR)/startup-notification_*
	rm -rf $(STARTUP_NOTIFICATION_DIR)

# vim: syntax=make
