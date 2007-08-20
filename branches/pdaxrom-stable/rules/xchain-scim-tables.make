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
ifdef PTXCONF_XCHAIN_SCIM-TABLES
PACKAGES += xchain-scim-tables
endif

#
# Paths and names
#
XCHAIN_SCIM-TABLES		= scim-tables-$(SCIM-TABLES_VERSION)
XCHAIN_SCIM-TABLES_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_SCIM-TABLES)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-scim-tables_extract: $(STATEDIR)/xchain-scim-tables.extract

xchain-scim-tables_extract_deps = $(STATEDIR)/scim-tables.get

$(STATEDIR)/xchain-scim-tables.extract: $(xchain-scim-tables_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_SCIM-TABLES_DIR))
	@$(call extract, $(SCIM-TABLES_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_SCIM-TABLES), $(XCHAIN_SCIM-TABLES_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-scim-tables_prepare: $(STATEDIR)/xchain-scim-tables.prepare

#
# dependencies
#
xchain-scim-tables_prepare_deps = \
	$(STATEDIR)/xchain-scim.install \
	$(STATEDIR)/xchain-scim-tables.extract

XCHAIN_SCIM-TABLES_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_SCIM-TABLES_ENV 	=  $(HOSTCC_ENV)
XCHAIN_SCIM-TABLES_ENV	+= PKG_CONFIG_PATH=$(PTXCONF_PREFIX)/lib/pkgconfig:$(PKG_CONFIG_PATH)

#
# autoconf
#
XCHAIN_SCIM-TABLES_AUTOCONF = \
	--build=$(GNU_HOST) \
	--disable-debug \
	--disable-shared \
	--enable-static \
	--prefix=/usr

# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-scim-tables.prepare: $(xchain-scim-tables_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_SCIM-TABLES_DIR)/config.cache)
	cd $(XCHAIN_SCIM-TABLES_DIR) && \
		$(XCHAIN_SCIM-TABLES_PATH) $(XCHAIN_SCIM-TABLES_ENV) \
		./configure $(XCHAIN_SCIM-TABLES_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-scim-tables_compile: $(STATEDIR)/xchain-scim-tables.compile

xchain-scim-tables_compile_deps = $(STATEDIR)/xchain-scim-tables.prepare

$(STATEDIR)/xchain-scim-tables.compile: $(xchain-scim-tables_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_SCIM-TABLES_PATH) $(MAKE) -C $(XCHAIN_SCIM-TABLES_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-scim-tables_install: $(STATEDIR)/xchain-scim-tables.install

$(STATEDIR)/xchain-scim-tables.install: $(STATEDIR)/xchain-scim-tables.compile
	@$(call targetinfo, $@)
	$(XCHAIN_SCIM-TABLES_PATH) $(MAKE) -C $(XCHAIN_SCIM-TABLES_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-scim-tables_targetinstall: $(STATEDIR)/xchain-scim-tables.targetinstall

xchain-scim-tables_targetinstall_deps = $(STATEDIR)/xchain-scim-tables.compile

$(STATEDIR)/xchain-scim-tables.targetinstall: $(xchain-scim-tables_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-scim-tables_clean:
	rm -rf $(STATEDIR)/xchain-scim-tables.*
	rm -rf $(XCHAIN_SCIM-TABLES_DIR)

# vim: syntax=make
