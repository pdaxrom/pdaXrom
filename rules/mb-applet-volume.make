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
PACKAGES-$(PTXCONF_MB_APPLET_VOLUME) += mb-applet-volume

#
# Paths and names
#
MB_APPLET_VOLUME_VERSION	:= 0.2
MB_APPLET_VOLUME		:= mb-applet-volume-$(MB_APPLET_VOLUME_VERSION)
MB_APPLET_VOLUME_SUFFIX		:= tar.bz2
MB_APPLET_VOLUME_URL		:= http://matchbox-project.org/sources/mb-applet-volume/0.2/$(MB_APPLET_VOLUME).$(MB_APPLET_VOLUME_SUFFIX)
MB_APPLET_VOLUME_SOURCE		:= $(SRCDIR)/$(MB_APPLET_VOLUME).$(MB_APPLET_VOLUME_SUFFIX)
MB_APPLET_VOLUME_DIR		:= $(BUILDDIR)/$(MB_APPLET_VOLUME)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-applet-volume_get: $(STATEDIR)/mb-applet-volume.get

$(STATEDIR)/mb-applet-volume.get: $(mb-applet-volume_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(MB_APPLET_VOLUME_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, MB_APPLET_VOLUME)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-applet-volume_extract: $(STATEDIR)/mb-applet-volume.extract

$(STATEDIR)/mb-applet-volume.extract: $(mb-applet-volume_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MB_APPLET_VOLUME_DIR))
	@$(call extract, MB_APPLET_VOLUME)
	@$(call patchin, MB_APPLET_VOLUME)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-applet-volume_prepare: $(STATEDIR)/mb-applet-volume.prepare

MB_APPLET_VOLUME_PATH	:= PATH=$(CROSS_PATH)
MB_APPLET_VOLUME_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
MB_APPLET_VOLUME_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/mb-applet-volume.prepare: $(mb-applet-volume_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(MB_APPLET_VOLUME_DIR)/config.cache)
	cd $(MB_APPLET_VOLUME_DIR) && \
		$(MB_APPLET_VOLUME_PATH) $(MB_APPLET_VOLUME_ENV) \
		./configure $(MB_APPLET_VOLUME_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-applet-volume_compile: $(STATEDIR)/mb-applet-volume.compile

$(STATEDIR)/mb-applet-volume.compile: $(mb-applet-volume_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(MB_APPLET_VOLUME_DIR) && $(MB_APPLET_VOLUME_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-applet-volume_install: $(STATEDIR)/mb-applet-volume.install

$(STATEDIR)/mb-applet-volume.install: $(mb-applet-volume_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-applet-volume_targetinstall: $(STATEDIR)/mb-applet-volume.targetinstall

$(STATEDIR)/mb-applet-volume.targetinstall: $(mb-applet-volume_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, mb-applet-volume)
	@$(call install_fixup, mb-applet-volume,PACKAGE,mb-applet-volume)
	@$(call install_fixup, mb-applet-volume,PRIORITY,optional)
	@$(call install_fixup, mb-applet-volume,VERSION,$(MB_APPLET_VOLUME_VERSION))
	@$(call install_fixup, mb-applet-volume,SECTION,base)
	@$(call install_fixup, mb-applet-volume,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, mb-applet-volume,DEPENDS,matchbox-panel)
	@$(call install_fixup, mb-applet-volume,DESCRIPTION,missing)

	@$(call install_copy, mb-applet-volume, 0, 0, 0755, $(MB_APPLET_VOLUME_DIR)/mb-applet-volume, 	/usr/bin/mb-applet-volume)
	@$(call install_copy, mb-applet-volume, 0, 0, 0644, $(MB_APPLET_VOLUME_DIR)/mb-applet-volume.desktop, /usr/share/applications/mb-applet-volume.desktop)
	@$(call install_copy, mb-applet-volume, 0, 0, 0644, $(MB_APPLET_VOLUME_DIR)/mbvol-high.png,	/usr/share/pixmaps/mbvol-high.png)
	@$(call install_copy, mb-applet-volume, 0, 0, 0644, $(MB_APPLET_VOLUME_DIR)/mbvol-low.png, 	/usr/share/pixmaps/mbvol-low.png)
	@$(call install_copy, mb-applet-volume, 0, 0, 0644, $(MB_APPLET_VOLUME_DIR)/mbvol-mid.png, 	/usr/share/pixmaps/mbvol-mid.png)
	@$(call install_copy, mb-applet-volume, 0, 0, 0644, $(MB_APPLET_VOLUME_DIR)/mbvol-zero.png, 	/usr/share/pixmaps/mbvol-zero.png)
    
	@$(call install_finish, mb-applet-volume)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-applet-volume_clean:
	rm -rf $(STATEDIR)/mb-applet-volume.*
	rm -rf $(IMAGEDIR)/mb-applet-volume_*
	rm -rf $(MB_APPLET_VOLUME_DIR)

# vim: syntax=make
