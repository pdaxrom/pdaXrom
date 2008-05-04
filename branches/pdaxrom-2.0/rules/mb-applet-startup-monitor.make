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
PACKAGES-$(PTXCONF_MB_APPLET_STARTUP_MONITOR) += mb-applet-startup-monitor

#
# Paths and names
#
MB_APPLET_STARTUP_MONITOR_VERSION	:= 0.1
MB_APPLET_STARTUP_MONITOR		:= mb-applet-startup-monitor-$(MB_APPLET_STARTUP_MONITOR_VERSION)
MB_APPLET_STARTUP_MONITOR_SUFFIX	:= tar.bz2
MB_APPLET_STARTUP_MONITOR_URL		:= http://matchbox-project.org/sources/mb-applet-startup-monitor/0.1/$(MB_APPLET_STARTUP_MONITOR).$(MB_APPLET_STARTUP_MONITOR_SUFFIX)
MB_APPLET_STARTUP_MONITOR_SOURCE	:= $(SRCDIR)/$(MB_APPLET_STARTUP_MONITOR).$(MB_APPLET_STARTUP_MONITOR_SUFFIX)
MB_APPLET_STARTUP_MONITOR_DIR		:= $(BUILDDIR)/$(MB_APPLET_STARTUP_MONITOR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-applet-startup-monitor_get: $(STATEDIR)/mb-applet-startup-monitor.get

$(STATEDIR)/mb-applet-startup-monitor.get: $(mb-applet-startup-monitor_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MB_APPLET_STARTUP_MONITOR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MB_APPLET_STARTUP_MONITOR)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-applet-startup-monitor_extract: $(STATEDIR)/mb-applet-startup-monitor.extract

$(STATEDIR)/mb-applet-startup-monitor.extract: $(mb-applet-startup-monitor_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MB_APPLET_STARTUP_MONITOR_DIR))
	@$(call extract, MB_APPLET_STARTUP_MONITOR)
	@$(call patchin, MB_APPLET_STARTUP_MONITOR)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-applet-startup-monitor_prepare: $(STATEDIR)/mb-applet-startup-monitor.prepare

MB_APPLET_STARTUP_MONITOR_PATH	:= PATH=$(CROSS_PATH)
MB_APPLET_STARTUP_MONITOR_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MB_APPLET_STARTUP_MONITOR_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/mb-applet-startup-monitor.prepare: $(mb-applet-startup-monitor_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MB_APPLET_STARTUP_MONITOR_DIR)/config.cache)
	cd $(MB_APPLET_STARTUP_MONITOR_DIR) && \
		$(MB_APPLET_STARTUP_MONITOR_PATH) $(MB_APPLET_STARTUP_MONITOR_ENV) \
		./configure $(MB_APPLET_STARTUP_MONITOR_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-applet-startup-monitor_compile: $(STATEDIR)/mb-applet-startup-monitor.compile

$(STATEDIR)/mb-applet-startup-monitor.compile: $(mb-applet-startup-monitor_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MB_APPLET_STARTUP_MONITOR_DIR) && $(MB_APPLET_STARTUP_MONITOR_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-applet-startup-monitor_install: $(STATEDIR)/mb-applet-startup-monitor.install

$(STATEDIR)/mb-applet-startup-monitor.install: $(mb-applet-startup-monitor_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-applet-startup-monitor_targetinstall: $(STATEDIR)/mb-applet-startup-monitor.targetinstall

$(STATEDIR)/mb-applet-startup-monitor.targetinstall: $(mb-applet-startup-monitor_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, mb-applet-startup-monitor)
	@$(call install_fixup, mb-applet-startup-monitor,PACKAGE,mb-applet-startup-monitor)
	@$(call install_fixup, mb-applet-startup-monitor,PRIORITY,optional)
	@$(call install_fixup, mb-applet-startup-monitor,VERSION,$(MB_APPLET_STARTUP_MONITOR_VERSION))
	@$(call install_fixup, mb-applet-startup-monitor,SECTION,base)
	@$(call install_fixup, mb-applet-startup-monitor,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, mb-applet-startup-monitor,DEPENDS,)
	@$(call install_fixup, mb-applet-startup-monitor,DESCRIPTION,missing)

	@$(call install_copy, mb-applet-startup-monitor, 0, 0, 0755, $(MB_APPLET_STARTUP_MONITOR_DIR)/mb-applet-startup-monitor, /usr/bin/mb-applet-startup-monitor)
	@$(call install_copy, mb-applet-startup-monitor, 0, 0, 0644, $(MB_APPLET_STARTUP_MONITOR_DIR)/data/hourglass-1.png, /usr/share/pixmaps/hourglass-1.png)
	@$(call install_copy, mb-applet-startup-monitor, 0, 0, 0644, $(MB_APPLET_STARTUP_MONITOR_DIR)/data/hourglass-1.png, /usr/share/pixmaps/hourglass-2.png)
	@$(call install_copy, mb-applet-startup-monitor, 0, 0, 0644, $(MB_APPLET_STARTUP_MONITOR_DIR)/data/hourglass-1.png, /usr/share/pixmaps/hourglass-3.png)
	@$(call install_copy, mb-applet-startup-monitor, 0, 0, 0644, $(MB_APPLET_STARTUP_MONITOR_DIR)/data/hourglass-1.png, /usr/share/pixmaps/hourglass-4.png)
	@$(call install_copy, mb-applet-startup-monitor, 0, 0, 0644, $(MB_APPLET_STARTUP_MONITOR_DIR)/data/hourglass-1.png, /usr/share/pixmaps/hourglass-5.png)
	@$(call install_copy, mb-applet-startup-monitor, 0, 0, 0644, $(MB_APPLET_STARTUP_MONITOR_DIR)/data/hourglass-1.png, /usr/share/pixmaps/hourglass-6.png)
	@$(call install_copy, mb-applet-startup-monitor, 0, 0, 0644, $(MB_APPLET_STARTUP_MONITOR_DIR)/data/hourglass-1.png, /usr/share/pixmaps/hourglass-7.png)
	@$(call install_copy, mb-applet-startup-monitor, 0, 0, 0644, $(MB_APPLET_STARTUP_MONITOR_DIR)/data/hourglass-1.png, /usr/share/pixmaps/hourglass-8.png)
	
	@$(call install_finish, mb-applet-startup-monitor)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-applet-startup-monitor_clean:
	rm -rf $(STATEDIR)/mb-applet-startup-monitor.*
	rm -rf $(IMAGEDIR)/mb-applet-startup-monitor_*
	rm -rf $(MB_APPLET_STARTUP_MONITOR_DIR)

# vim: syntax=make
