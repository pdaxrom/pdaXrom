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
PACKAGES-$(PTXCONF_DHCPCD) += dhcpcd

#
# Paths and names
#
DHCPCD_VERSION		:= 3.2.3
DHCPCD			:= dhcpcd-$(DHCPCD_VERSION)
DHCPCD_SUFFIX		:= tar.bz2
DHCPCD_URL		:= http://roy.marples.name/dhcpcd/$(DHCPCD).$(DHCPCD_SUFFIX)
DHCPCD_SOURCE		:= $(SRCDIR)/$(DHCPCD).$(DHCPCD_SUFFIX)
DHCPCD_DIR		:= $(BUILDDIR)/$(DHCPCD)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dhcpcd_get: $(STATEDIR)/dhcpcd.get

$(STATEDIR)/dhcpcd.get: $(dhcpcd_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(DHCPCD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, DHCPCD)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dhcpcd_extract: $(STATEDIR)/dhcpcd.extract

$(STATEDIR)/dhcpcd.extract: $(dhcpcd_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(DHCPCD_DIR))
	@$(call extract, DHCPCD)
	@$(call patchin, DHCPCD)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dhcpcd_prepare: $(STATEDIR)/dhcpcd.prepare

DHCPCD_PATH	:= PATH=$(CROSS_PATH)
DHCPCD_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
DHCPCD_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/dhcpcd.prepare: $(dhcpcd_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(DHCPCD_DIR)/config.cache)
	#cd $(DHCPCD_DIR) && \
	#	$(DHCPCD_PATH) $(DHCPCD_ENV) \
	#	./configure $(DHCPCD_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dhcpcd_compile: $(STATEDIR)/dhcpcd.compile

$(STATEDIR)/dhcpcd.compile: $(dhcpcd_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(DHCPCD_DIR) && \
	    $(DHCPCD_PATH) $(DHCPCD_ENV) \
	    $(MAKE) $(PARALLELMFLAGS) \
		HAVE_FORK=yes HAVE_INIT=SYSV
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dhcpcd_install: $(STATEDIR)/dhcpcd.install

$(STATEDIR)/dhcpcd.install: $(dhcpcd_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, DHCPCD)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dhcpcd_targetinstall: $(STATEDIR)/dhcpcd.targetinstall

$(STATEDIR)/dhcpcd.targetinstall: $(dhcpcd_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, dhcpcd)
	@$(call install_fixup, dhcpcd,PACKAGE,dhcpcd)
	@$(call install_fixup, dhcpcd,PRIORITY,optional)
	@$(call install_fixup, dhcpcd,VERSION,$(DHCPCD_VERSION))
	@$(call install_fixup, dhcpcd,SECTION,base)
	@$(call install_fixup, dhcpcd,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, dhcpcd,DEPENDS,)
	@$(call install_fixup, dhcpcd,DESCRIPTION,missing)

	@$(call install_copy, dhcpcd, 0, 0, 0755, $(DHCPCD_DIR)/dhcpcd, /sbin/dhcpcd)
	@$(call install_copy, dhcpcd, 0, 0, 0755, /var/lib/dhcpcd)

	@$(call install_finish, dhcpcd)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dhcpcd_clean:
	rm -rf $(STATEDIR)/dhcpcd.*
	rm -rf $(IMAGEDIR)/dhcpcd_*
	rm -rf $(DHCPCD_DIR)

# vim: syntax=make
