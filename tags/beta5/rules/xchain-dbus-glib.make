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
ifdef PTXCONF_XCHAIN_DBUS-GLIB
PACKAGES += xchain-dbus-glib
endif

#
# Paths and names
#
XCHAIN_DBUS-GLIB		= $(DBUS-GLIB)
XCHAIN_DBUS-GLIB_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_DBUS-GLIB)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-dbus-glib_get: $(STATEDIR)/xchain-dbus-glib.get

xchain-dbus-glib_get_deps = $(XCHAIN_DBUS-GLIB_SOURCE)

$(STATEDIR)/xchain-dbus-glib.get: $(xchain-dbus-glib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_DBUS-GLIB))
	touch $@

$(XCHAIN_DBUS-GLIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_DBUS-GLIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-dbus-glib_extract: $(STATEDIR)/xchain-dbus-glib.extract

xchain-dbus-glib_extract_deps = $(STATEDIR)/dbus-glib.get

$(STATEDIR)/xchain-dbus-glib.extract: $(xchain-dbus-glib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_DBUS-GLIB_DIR))
	@$(call extract, $(DBUS-GLIB_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_DBUS-GLIB), $(XCHAIN_DBUS-GLIB_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-dbus-glib_prepare: $(STATEDIR)/xchain-dbus-glib.prepare

#
# dependencies
#
xchain-dbus-glib_prepare_deps = \
	$(STATEDIR)/xchain-dbus-glib.extract \
	$(STATEDIR)/xchain-dbus.install

XCHAIN_DBUS-GLIB_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_DBUS-GLIB_ENV 	=  $(HOSTCC_ENV)
XCHAIN_DBUS-GLIB_ENV	+= PKG_CONFIG_PATH=$(PTXCONF_PREFIX)/lib/pkgconfig:$(PKG_CONFIG_PATH)

#
# autoconf
#
XCHAIN_DBUS-GLIB_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-dbus-glib.prepare: $(xchain-dbus-glib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_DBUS-GLIB_DIR)/config.cache)
	cd $(XCHAIN_DBUS-GLIB_DIR) && \
		$(XCHAIN_DBUS-GLIB_PATH) $(XCHAIN_DBUS-GLIB_ENV) \
		./configure $(XCHAIN_DBUS-GLIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-dbus-glib_compile: $(STATEDIR)/xchain-dbus-glib.compile

xchain-dbus-glib_compile_deps = $(STATEDIR)/xchain-dbus-glib.prepare

$(STATEDIR)/xchain-dbus-glib.compile: $(xchain-dbus-glib_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_DBUS-GLIB_PATH) $(MAKE) -C $(XCHAIN_DBUS-GLIB_DIR) HOST_DBUS-BINDING-TOOL=$(XCHAIN_DBUS-GLIB_DIR)/dbus
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-dbus-glib_install: $(STATEDIR)/xchain-dbus-glib.install

$(STATEDIR)/xchain-dbus-glib.install: $(STATEDIR)/xchain-dbus-glib.compile
	@$(call targetinfo, $@)
	$(XCHAIN_DBUS-GLIB_PATH) $(MAKE) -C $(XCHAIN_DBUS-GLIB_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-dbus-glib_targetinstall: $(STATEDIR)/xchain-dbus-glib.targetinstall

xchain-dbus-glib_targetinstall_deps = $(STATEDIR)/xchain-dbus-glib.compile

$(STATEDIR)/xchain-dbus-glib.targetinstall: $(xchain-dbus-glib_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-dbus-glib_clean:
	rm -rf $(STATEDIR)/xchain-dbus-glib.*
	rm -rf $(XCHAIN_DBUS-GLIB_DIR)

# vim: syntax=make
