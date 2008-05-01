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
PACKAGES-$(PTXCONF_RCONTROL) += rcontrol

#
# Paths and names
#
RCONTROL_VERSION	:= 0.1
RCONTROL		:= rcontrol-$(RCONTROL_VERSION)
RCONTROL_SUFFIX		:= tar.bz2
RCONTROL_URL		:= http://www.pdaXrom.org/src/$(RCONTROL).$(RCONTROL_SUFFIX)
RCONTROL_SOURCE		:= $(SRCDIR)/$(RCONTROL).$(RCONTROL_SUFFIX)
RCONTROL_DIR		:= $(BUILDDIR)/$(RCONTROL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rcontrol_get: $(STATEDIR)/rcontrol.get

$(STATEDIR)/rcontrol.get: $(rcontrol_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(RCONTROL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, RCONTROL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rcontrol_extract: $(STATEDIR)/rcontrol.extract

$(STATEDIR)/rcontrol.extract: $(rcontrol_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(RCONTROL_DIR))
	@$(call extract, RCONTROL)
	@$(call patchin, RCONTROL)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rcontrol_prepare: $(STATEDIR)/rcontrol.prepare

RCONTROL_PATH	:= PATH=$(CROSS_PATH)
RCONTROL_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
RCONTROL_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/rcontrol.prepare: $(rcontrol_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(RCONTROL_DIR)/config.cache)
#	cd $(RCONTROL_DIR) && \
#		$(RCONTROL_PATH) $(RCONTROL_ENV) \
#		./configure $(RCONTROL_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rcontrol_compile: $(STATEDIR)/rcontrol.compile

$(STATEDIR)/rcontrol.compile: $(rcontrol_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(RCONTROL_DIR) && $(RCONTROL_PATH) $(RCONTROL_ENV) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rcontrol_install: $(STATEDIR)/rcontrol.install

$(STATEDIR)/rcontrol.install: $(rcontrol_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rcontrol_targetinstall: $(STATEDIR)/rcontrol.targetinstall

$(STATEDIR)/rcontrol.targetinstall: $(rcontrol_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, rcontrol)
	@$(call install_fixup, rcontrol,PACKAGE,rcontrol)
	@$(call install_fixup, rcontrol,PRIORITY,optional)
	@$(call install_fixup, rcontrol,VERSION,$(RCONTROL_VERSION))
	@$(call install_fixup, rcontrol,SECTION,base)
	@$(call install_fixup, rcontrol,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, rcontrol,DEPENDS,)
	@$(call install_fixup, rcontrol,DESCRIPTION,missing)

	@$(call install_copy, rcontrol, 0, 0, 0755, /usr/sbin)
	@$(call install_copy, rcontrol, 0, 0, 0755, $(RCONTROL_DIR)/rcontrol, /usr/sbin/rcontrol)
	@$(call install_copy, rcontrol, 0, 0, 0755, /etc/init.d)
	@$(call install_copy, rcontrol, 0, 0, 0755, $(RCONTROL_DIR)/rcontrol.init, /etc/init.d/rcontrol)
	@$(call install_copy, rcontrol, 0, 0, 0755, /etc/rc.d)
	@$(call install_link, rcontrol, ../init.d/rcontrol, /etc/rc.d/S10_rcontrol)
	@$(call install_copy, rcontrol, 0, 0, 0755, /var/run)

	@$(call install_finish, rcontrol)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rcontrol_clean:
	rm -rf $(STATEDIR)/rcontrol.*
	rm -rf $(IMAGEDIR)/rcontrol_*
	rm -rf $(RCONTROL_DIR)

# vim: syntax=make
