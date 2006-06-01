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
ifdef PTXCONF_XCHAIN_ARTS
PACKAGES += xchain-arts
endif

#
# Paths and names
#
XCHAIN_ARTS		= arts-$(ARTS_VERSION)
XCHAIN_ARTS_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_ARTS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-arts_get: $(STATEDIR)/xchain-arts.get

xchain-arts_get_deps = $(XCHAIN_ARTS_SOURCE)

$(STATEDIR)/xchain-arts.get: $(xchain-arts_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_ARTS))
	touch $@

$(XCHAIN_ARTS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ARTS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-arts_extract: $(STATEDIR)/xchain-arts.extract

xchain-arts_extract_deps = $(STATEDIR)/arts.get

$(STATEDIR)/xchain-arts.extract: $(xchain-arts_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_ARTS_DIR))
	@$(call extract, $(ARTS_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_ARTS), $(XCHAIN_ARTS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-arts_prepare: $(STATEDIR)/xchain-arts.prepare

#
# dependencies
#
xchain-arts_prepare_deps = \
	$(STATEDIR)/xchain-arts.extract

XCHAIN_ARTS_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_ARTS_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_ARTS_ENV	+=
XCHAIN_ARTS_ENV		+= CFLAGS="-O2 -fomit-frame-pointer"
XCHAIN_ARTS_ENV		+= CXXFLAGS="-O2 -fomit-frame-pointer"
XCHAIN_ARTS_ENV		+= PKG_CONFIG_PATH=$(PTXCONF_PREFIX)/lib/pkgconfig:$(PKG_CONFIG_PATH)

#
# autoconf
#
XCHAIN_ARTS_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
	--with-extra-includes=$(NATIVE_SDK_FILES_PREFIX)/include
#	--with-extra-libs=$(CROSS_LIB_DIR)/lib \
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-arts.prepare: $(xchain-arts_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_ARTS_DIR)/config.cache)
	cd $(XCHAIN_ARTS_DIR) && \
		$(XCHAIN_ARTS_PATH) $(XCHAIN_ARTS_ENV) \
		./configure $(XCHAIN_ARTS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-arts_compile: $(STATEDIR)/xchain-arts.compile

xchain-arts_compile_deps = $(STATEDIR)/xchain-arts.prepare

$(STATEDIR)/xchain-arts.compile: $(xchain-arts_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_ARTS_PATH) $(MAKE) -C $(XCHAIN_ARTS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-arts_install: $(STATEDIR)/xchain-arts.install

$(STATEDIR)/xchain-arts.install: $(STATEDIR)/xchain-arts.compile
	@$(call targetinfo, $@)
	asdasd
	$(XCHAIN_ARTS_PATH) $(MAKE) -C $(XCHAIN_ARTS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-arts_targetinstall: $(STATEDIR)/xchain-arts.targetinstall

xchain-arts_targetinstall_deps = $(STATEDIR)/xchain-arts.compile

$(STATEDIR)/xchain-arts.targetinstall: $(xchain-arts_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-arts_clean:
	rm -rf $(STATEDIR)/xchain-arts.*
	rm -rf $(XCHAIN_ARTS_DIR)

# vim: syntax=make
