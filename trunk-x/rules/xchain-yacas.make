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
ifdef PTXCONF_XCHAIN_YACAS
PACKAGES += xchain-yacas
endif

#
# Paths and names
#
XCHAIN_YACAS			= yacas-$(YACAS_VERSION)
XCHAIN_YACAS_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_YACAS)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-yacas_extract: $(STATEDIR)/xchain-yacas.extract

xchain-yacas_extract_deps = $(STATEDIR)/yacas.get

$(STATEDIR)/xchain-yacas.extract: $(xchain-yacas_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_YACAS_DIR))
	@$(call extract, $(YACAS_SOURCE), $(XCHAIN_BUILDDIR))
	#@$(call patchin, $(XCHAIN_YACAS), $(XCHAIN_YACAS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-yacas_prepare: $(STATEDIR)/xchain-yacas.prepare

#
# dependencies
#
xchain-yacas_prepare_deps = \
	$(STATEDIR)/xchain-yacas.extract

XCHAIN_YACAS_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_YACAS_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_YACAS_ENV	+=

#
# autoconf
#
XCHAIN_YACAS_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST) \
	--enable-static \
	--disable-shared
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-yacas.prepare: $(xchain-yacas_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_YACAS_DIR)/config.cache)
	cd $(XCHAIN_YACAS_DIR) && \
		$(XCHAIN_YACAS_PATH) $(XCHAIN_YACAS_ENV) \
		./configure $(XCHAIN_YACAS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-yacas_compile: $(STATEDIR)/xchain-yacas.compile

xchain-yacas_compile_deps = $(STATEDIR)/xchain-yacas.prepare

$(STATEDIR)/xchain-yacas.compile: $(xchain-yacas_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_YACAS_PATH) $(MAKE) -C $(XCHAIN_YACAS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-yacas_install: $(STATEDIR)/xchain-yacas.install

$(STATEDIR)/xchain-yacas.install: $(STATEDIR)/xchain-yacas.compile
	@$(call targetinfo, $@)
	$(XCHAIN_YACAS_PATH) $(MAKE) -C $(XCHAIN_YACAS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-yacas_targetinstall: $(STATEDIR)/xchain-yacas.targetinstall

xchain-yacas_targetinstall_deps = $(STATEDIR)/xchain-yacas.compile

$(STATEDIR)/xchain-yacas.targetinstall: $(xchain-yacas_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-yacas_clean:
	rm -rf $(STATEDIR)/xchain-yacas.*
	rm -rf $(XCHAIN_YACAS_DIR)

# vim: syntax=make
