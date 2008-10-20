# -*-makefile-*-
# $Id: template 6655 2007-01-02 12:55:21Z rsc $
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
PACKAGES-$(PTXCONF_PCMCIAUTILS) += pcmciautils

#
# Paths and names
#
PCMCIAUTILS_VERSION	:= 014
PCMCIAUTILS		:= pcmciautils-$(PCMCIAUTILS_VERSION)
PCMCIAUTILS_SUFFIX	:= tar.bz2
PCMCIAUTILS_URL		:= http://www.kernel.org/pub/linux/utils/kernel/pcmcia/$(PCMCIAUTILS).$(PCMCIAUTILS_SUFFIX)
PCMCIAUTILS_SOURCE	:= $(SRCDIR)/$(PCMCIAUTILS).$(PCMCIAUTILS_SUFFIX)
PCMCIAUTILS_DIR		:= $(BUILDDIR)/$(PCMCIAUTILS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pcmciautils_get: $(STATEDIR)/pcmciautils.get

$(STATEDIR)/pcmciautils.get: $(pcmciautils_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(PCMCIAUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, PCMCIAUTILS)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pcmciautils_extract: $(STATEDIR)/pcmciautils.extract

$(STATEDIR)/pcmciautils.extract: $(pcmciautils_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(PCMCIAUTILS_DIR))
	@$(call extract, PCMCIAUTILS)
	@$(call patchin, PCMCIAUTILS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pcmciautils_prepare: $(STATEDIR)/pcmciautils.prepare

PCMCIAUTILS_PATH	:= PATH=$(CROSS_PATH)
PCMCIAUTILS_ENV 	:= $(CROSS_ENV)

PCMCIAUTILS_MAKEVARS :=  ARCH=$(PTXCONF_ARCH) \
	prefix=$(SYSROOT) \
	CROSS=$(COMPILER_PREFIX) \
	GCCINCDIR=$(SYSROOT)/usr/include

#
# autoconf
#
PCMCIAUTILS_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/pcmciautils.prepare: $(pcmciautils_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(PCMCIAUTILS_DIR)/config.cache)
ifndef PTXCONF_PCMCIAUTILS_STARTUP
	@perl -p -i -e 's/STARTUP = true/STARTUP = false/' $(PCMCIAUTILS_DIR)/Makefile
endif
#	cd $(PCMCIAUTILS_DIR) && \
#		$(PCMCIAUTILS_PATH) $(PCMCIAUTILS_ENV) \
#		./configure $(PCMCIAUTILS_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pcmciautils_compile: $(STATEDIR)/pcmciautils.compile

$(STATEDIR)/pcmciautils.compile: $(pcmciautils_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(PCMCIAUTILS_DIR) && $(PCMCIAUTILS_ENV) $(PCMCIAUTILS_PATH) make $(PCMCIAUTILS_MAKEVARS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pcmciautils_install: $(STATEDIR)/pcmciautils.install

$(STATEDIR)/pcmciautils.install: $(pcmciautils_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, PCMCIAUTILS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pcmciautils_targetinstall: $(STATEDIR)/pcmciautils.targetinstall

$(STATEDIR)/pcmciautils.targetinstall: $(pcmciautils_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, pcmciautils)
	@$(call install_fixup, pcmciautils,PACKAGE,pcmciautils)
	@$(call install_fixup, pcmciautils,PRIORITY,optional)
	@$(call install_fixup, pcmciautils,VERSION,$(PCMCIAUTILS_VERSION))
	@$(call install_fixup, pcmciautils,SECTION,base)
	@$(call install_fixup, pcmciautils,AUTHOR,"Robert Schwebel <r.schwebel\@pengutronix.de>")
	@$(call install_fixup, pcmciautils,DEPENDS,)
	@$(call install_fixup, pcmciautils,DESCRIPTION,missing)

	@$(call install_copy, pcmciautils, 0, 0, 0755, /sbin)
	@$(call install_copy, pcmciautils, 0, 0, 0755, $(PCMCIAUTILS_DIR)/pccardctl, /sbin/pccardctl)
	@$(call install_copy, pcmciautils, 0, 0, 0755, $(PCMCIAUTILS_DIR)/pcmcia-check-broken-cis, /sbin/pcmcia-check-broken-cis)
	@$(call install_link, pcmciautils, pccardctl, /sbin/lspcmcia)

	@$(call install_copy, pcmciautils, 0, 0, 0755, /etc/udev/rules.d)
	@$(call install_copy, pcmciautils, 0, 0, 0644, $(PCMCIAUTILS_DIR)/udev/60-pcmcia.rules, /etc/udev/rules.d/60-pcmcia.rules)

	@$(call install_finish, pcmciautils)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pcmciautils_clean:
	rm -rf $(STATEDIR)/pcmciautils.*
	rm -rf $(IMAGEDIR)/pcmciautils_*
	rm -rf $(PCMCIAUTILS_DIR)

# vim: syntax=make
