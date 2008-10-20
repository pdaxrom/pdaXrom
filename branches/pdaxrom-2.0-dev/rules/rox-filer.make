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
PACKAGES-$(PTXCONF_ROX_FILER) += rox-filer

#
# Paths and names
#
ROX_FILER_VERSION	:= 2.7.1
ROX_FILER		:= rox-filer-$(ROX_FILER_VERSION)
ROX_FILER_SUFFIX	:= tar.bz2
ROX_FILER_URL		:= http://downloads.sourceforge.net/rox/$(ROX_FILER).$(ROX_FILER_SUFFIX)
ROX_FILER_SOURCE	:= $(SRCDIR)/$(ROX_FILER).$(ROX_FILER_SUFFIX)
ROX_FILER_DIR		:= $(BUILDDIR)/$(ROX_FILER)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rox-filer_get: $(STATEDIR)/rox-filer.get

$(STATEDIR)/rox-filer.get: $(rox-filer_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(ROX_FILER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, ROX_FILER)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rox-filer_extract: $(STATEDIR)/rox-filer.extract

$(STATEDIR)/rox-filer.extract: $(rox-filer_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX_FILER_DIR))
	@$(call extract, ROX_FILER)
	@$(call patchin, ROX_FILER)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rox-filer_prepare: $(STATEDIR)/rox-filer.prepare

ROX_FILER_PATH	:= PATH=$(CROSS_PATH)
ROX_FILER_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
ROX_FILER_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/rox-filer.prepare: $(rox-filer_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX_FILER_DIR)/config.cache)
	mkdir -p $(ROX_FILER_DIR)/ROX-Filer/build
	cd $(ROX_FILER_DIR)/ROX-Filer/build && \
		$(ROX_FILER_PATH) $(ROX_FILER_ENV) \
		../src/configure $(ROX_FILER_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rox-filer_compile: $(STATEDIR)/rox-filer.compile

$(STATEDIR)/rox-filer.compile: $(rox-filer_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(ROX_FILER_DIR)/ROX-Filer/build && $(ROX_FILER_PATH) $(ROX_FILER_ENV) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rox-filer_install: $(STATEDIR)/rox-filer.install

$(STATEDIR)/rox-filer.install: $(rox-filer_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rox-filer_targetinstall: $(STATEDIR)/rox-filer.targetinstall

$(STATEDIR)/rox-filer.targetinstall: $(rox-filer_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, rox-filer)
	@$(call install_fixup, rox-filer,PACKAGE,rox-filer)
	@$(call install_fixup, rox-filer,PRIORITY,optional)
	@$(call install_fixup, rox-filer,VERSION,$(ROX_FILER_VERSION))
	@$(call install_fixup, rox-filer,SECTION,base)
	@$(call install_fixup, rox-filer,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, rox-filer,DEPENDS, "shared-mime-info libglade gtk")
	@$(call install_fixup, rox-filer,DESCRIPTION,missing)

	@$(call install_copy, rox-filer, 0, 0, 0755, /usr/Applications/ROX-Filer)
	@$(call install_copy, rox-filer, 0, 0, 0644, $(ROX_FILER_DIR)/ROX-Filer/.DirIcon, /usr/Applications/ROX-Filer/.DirIcon)
	@$(call install_copy, rox-filer, 0, 0, 0644, $(ROX_FILER_DIR)/ROX-Filer/AppInfo.xml, /usr/Applications/ROX-Filer/AppInfo.xml)
	@$(call install_copy, rox-filer, 0, 0, 0644, $(ROX_FILER_DIR)/ROX-Filer/Options.xml, /usr/Applications/ROX-Filer/Options.xml)
	@$(call install_copy, rox-filer, 0, 0, 0644, $(ROX_FILER_DIR)/ROX-Filer/ROX-Filer-src.xml, /usr/Applications/ROX-Filer/ROX-Filer-src.xml)
	@$(call install_copy, rox-filer, 0, 0, 0644, $(ROX_FILER_DIR)/ROX-Filer/Templates.glade, /usr/Applications/ROX-Filer/Templates.glade)
	@$(call install_copy, rox-filer, 0, 0, 0644, $(ROX_FILER_DIR)/ROX-Filer/style.css, /usr/Applications/ROX-Filer/style.css)
	@$(call install_copy, rox-filer, 0, 0, 0644, $(ROX_FILER_DIR)/ROX-Filer/subclasses, /usr/Applications/ROX-Filer/subclasses)
	
	@$(call install_target, rox-filer, $(ROX_FILER_DIR)/ROX-Filer/Help, /usr/Applications/ROX-Filer/Help)
	@$(call install_target, rox-filer, $(ROX_FILER_DIR)/ROX-Filer/ROX, /usr/Applications/ROX-Filer/ROX)
	@$(call install_target, rox-filer, $(ROX_FILER_DIR)/ROX-Filer/images, /usr/Applications/ROX-Filer/images)
	@$(call install_copy, rox-filer, 0, 0, 0755, $(ROX_FILER_DIR)/ROX-Filer/ROX-Filer, /usr/Applications/ROX-Filer/ROX-Filer)
	@$(call install_copy, rox-filer, 0, 0, 0755, $(ROX_FILER_DIR)/ROX-Filer/AppRun, /usr/Applications/ROX-Filer/AppRun)
	@$(call install_copy, rox-filer, 0, 0, 0755, $(PDAXROMDIR)/configs/rox/rox, /usr/bin/rox)

	@$(call install_finish, rox-filer)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rox-filer_clean:
	rm -rf $(STATEDIR)/rox-filer.*
	rm -rf $(IMAGEDIR)/rox-filer_*
	rm -rf $(ROX_FILER_DIR)

# vim: syntax=make
