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
PACKAGES-$(PTXCONF_LZO) += lzo

#
# Paths and names
#
LZO_VERSION	:= 2.03
LZO		:= lzo-$(LZO_VERSION)
LZO_SUFFIX	:= tar.gz
LZO_URL		:= http://www.oberhumer.com/opensource/lzo/download/$(LZO).$(LZO_SUFFIX)
LZO_SOURCE	:= $(SRCDIR)/$(LZO).$(LZO_SUFFIX)
LZO_DIR		:= $(BUILDDIR)/$(LZO)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lzo_get: $(STATEDIR)/lzo.get

$(STATEDIR)/lzo.get: $(lzo_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(LZO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, LZO)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lzo_extract: $(STATEDIR)/lzo.extract

$(STATEDIR)/lzo.extract: $(lzo_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LZO_DIR))
	@$(call extract, LZO)
	@$(call patchin, LZO)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lzo_prepare: $(STATEDIR)/lzo.prepare

LZO_PATH	:= PATH=$(CROSS_PATH)
LZO_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
LZO_AUTOCONF := $(CROSS_AUTOCONF_USR) \
    --enable-shared

$(STATEDIR)/lzo.prepare: $(lzo_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(LZO_DIR)/config.cache)
	cd $(LZO_DIR) && \
		$(LZO_PATH) $(LZO_ENV) \
		./configure $(LZO_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lzo_compile: $(STATEDIR)/lzo.compile

$(STATEDIR)/lzo.compile: $(lzo_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(LZO_DIR) && $(LZO_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lzo_install: $(STATEDIR)/lzo.install

$(STATEDIR)/lzo.install: $(lzo_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, LZO)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lzo_targetinstall: $(STATEDIR)/lzo.targetinstall

$(STATEDIR)/lzo.targetinstall: $(lzo_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, lzo)
	@$(call install_fixup, lzo,PACKAGE,lzo)
	@$(call install_fixup, lzo,PRIORITY,optional)
	@$(call install_fixup, lzo,VERSION,$(LZO_VERSION))
	@$(call install_fixup, lzo,SECTION,base)
	@$(call install_fixup, lzo,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, lzo,DEPENDS,)
	@$(call install_fixup, lzo,DESCRIPTION,missing)

	@$(call install_copy, lzo, 0, 0, 0755, $(LZO_DIR)/src/.libs/liblzo2.so.2.0.0, /usr/lib/liblzo2.so.2.0.0)
	@$(call install_link, lzo, liblzo2.so.2.0.0, /usr/lib/liblzo2.so.2)
	@$(call install_link, lzo, liblzo2.so.2.0.0, /usr/lib/liblzo2.so)

	@$(call install_finish, lzo)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lzo_clean:
	rm -rf $(STATEDIR)/lzo.*
	rm -rf $(IMAGEDIR)/lzo_*
	rm -rf $(LZO_DIR)

# vim: syntax=make
