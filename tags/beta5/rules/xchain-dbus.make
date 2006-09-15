# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_XCHAIN_DBUS
PACKAGES += xchain-dbus
endif

#
# Paths and names
#
XCHAIN_DBUS		= $(DBUS)
XCHAIN_DBUS_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_DBUS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-dbus_get: $(STATEDIR)/xchain-dbus.get

xchain-dbus_get_deps = $(XCHAIN_DBUS_SOURCE)

$(STATEDIR)/xchain-dbus.get: $(xchain-dbus_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_DBUS))
	touch $@

$(XCHAIN_DBUS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_DBUS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-dbus_extract: $(STATEDIR)/xchain-dbus.extract

xchain-dbus_extract_deps = $(STATEDIR)/dbus.get

$(STATEDIR)/xchain-dbus.extract: $(xchain-dbus_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_DBUS_DIR))
	@$(call extract, $(DBUS_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_DBUS), $(XCHAIN_DBUS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-dbus_prepare: $(STATEDIR)/xchain-dbus.prepare

#
# dependencies
#
xchain-dbus_prepare_deps = \
	$(STATEDIR)/xchain-dbus.extract

XCHAIN_DBUS_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_DBUS_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_DBUS_ENV	+=

#
# autoconf
#
XCHAIN_DBUS_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-dbus.prepare: $(xchain-dbus_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_DBUS_DIR)/config.cache)
	cd $(XCHAIN_DBUS_DIR) && \
		$(XCHAIN_DBUS_PATH) $(XCHAIN_DBUS_ENV) \
		./configure $(XCHAIN_DBUS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-dbus_compile: $(STATEDIR)/xchain-dbus.compile

xchain-dbus_compile_deps = $(STATEDIR)/xchain-dbus.prepare

$(STATEDIR)/xchain-dbus.compile: $(xchain-dbus_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_DBUS_PATH) $(MAKE) -C $(XCHAIN_DBUS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-dbus_install: $(STATEDIR)/xchain-dbus.install

$(STATEDIR)/xchain-dbus.install: $(STATEDIR)/xchain-dbus.compile
	@$(call targetinfo, $@)
	$(XCHAIN_DBUS_PATH) $(MAKE) -C $(XCHAIN_DBUS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-dbus_targetinstall: $(STATEDIR)/xchain-dbus.targetinstall

xchain-dbus_targetinstall_deps = $(STATEDIR)/xchain-dbus.compile

$(STATEDIR)/xchain-dbus.targetinstall: $(xchain-dbus_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-dbus_clean:
	rm -rf $(STATEDIR)/xchain-dbus.*
	rm -rf $(XCHAIN_DBUS_DIR)

# vim: syntax=make
