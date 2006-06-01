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
ifdef PTXCONF_XCHAIN_XUTF8
PACKAGES += xchain-xutf8
endif

#
# Paths and names
#
XCHAIN_XUTF8			= xutf8-$(XUTF8_VERSION)
XCHAIN_XUTF8_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_XUTF8)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-xutf8_extract: $(STATEDIR)/xchain-xutf8.extract

xchain-xutf8_extract_deps = $(STATEDIR)/xutf8.get

$(STATEDIR)/xchain-xutf8.extract: $(xchain-xutf8_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_XUTF8_DIR))
	@$(call extract, $(XUTF8_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_XUTF8), $(XCHAIN_XUTF8_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-xutf8_prepare: $(STATEDIR)/xchain-xutf8.prepare

#
# dependencies
#
xchain-xutf8_prepare_deps = \
	$(STATEDIR)/xchain-xutf8.extract

XCHAIN_XUTF8_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_XUTF8_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_XUTF8_ENV	+= LDFLAGS="-liconv"

#
# autoconf
#
XCHAIN_XUTF8_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST) \
	--disable-shared \
	--enable-static
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-xutf8.prepare: $(xchain-xutf8_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_XUTF8_DIR)/config.cache)
	cd $(XCHAIN_XUTF8_DIR) && \
		$(XCHAIN_XUTF8_PATH) $(XCHAIN_XUTF8_ENV) \
		./configure $(XCHAIN_XUTF8_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-xutf8_compile: $(STATEDIR)/xchain-xutf8.compile

xchain-xutf8_compile_deps = $(STATEDIR)/xchain-xutf8.prepare

$(STATEDIR)/xchain-xutf8.compile: $(xchain-xutf8_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_XUTF8_PATH) $(MAKE) -C $(XCHAIN_XUTF8_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-xutf8_install: $(STATEDIR)/xchain-xutf8.install

$(STATEDIR)/xchain-xutf8.install: $(STATEDIR)/xchain-xutf8.compile
	@$(call targetinfo, $@)
	$(XCHAIN_XUTF8_PATH) $(MAKE) -C $(XCHAIN_XUTF8_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-xutf8_targetinstall: $(STATEDIR)/xchain-xutf8.targetinstall

xchain-xutf8_targetinstall_deps = $(STATEDIR)/xchain-xutf8.compile

$(STATEDIR)/xchain-xutf8.targetinstall: $(xchain-xutf8_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-xutf8_clean:
	rm -rf $(STATEDIR)/xchain-xutf8.*
	rm -rf $(XCHAIN_XUTF8_DIR)

# vim: syntax=make
