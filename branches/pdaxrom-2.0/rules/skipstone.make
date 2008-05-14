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
PACKAGES-$(PTXCONF_SKIPSTONE) += skipstone

#
# Paths and names
#
SKIPSTONE_VERSION	:= 1.0.1
SKIPSTONE		:= skipstone-$(SKIPSTONE_VERSION)
SKIPSTONE_SUFFIX	:= tar.gz
SKIPSTONE_URL		:= http://www.muhri.net/skipstone/$(SKIPSTONE).$(SKIPSTONE_SUFFIX)
SKIPSTONE_SOURCE	:= $(SRCDIR)/$(SKIPSTONE).$(SKIPSTONE_SUFFIX)
SKIPSTONE_DIR		:= $(BUILDDIR)/$(SKIPSTONE)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

skipstone_get: $(STATEDIR)/skipstone.get

$(STATEDIR)/skipstone.get: $(skipstone_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(SKIPSTONE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, SKIPSTONE)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

skipstone_extract: $(STATEDIR)/skipstone.extract

$(STATEDIR)/skipstone.extract: $(skipstone_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(SKIPSTONE_DIR))
	@$(call extract, SKIPSTONE)
	@$(call patchin, SKIPSTONE)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

skipstone_prepare: $(STATEDIR)/skipstone.prepare

SKIPSTONE_PATH	:= PATH=$(CROSS_PATH)
SKIPSTONE_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
SKIPSTONE_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/skipstone.prepare: $(skipstone_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(SKIPSTONE_DIR)/config.cache)
	#cd $(SKIPSTONE_DIR) && \
	#	$(SKIPSTONE_PATH) $(SKIPSTONE_ENV) \
	#	./configure $(SKIPSTONE_AUTOCONF)
	cp -f $(SKIPSTONE_DIR)/src/Makefile.webkit $(SKIPSTONE_DIR)/src/Makefile
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

skipstone_compile: $(STATEDIR)/skipstone.compile

$(STATEDIR)/skipstone.compile: $(skipstone_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(SKIPSTONE_DIR) && $(SKIPSTONE_PATH) $(SKIPSTONE_ENV) $(MAKE) $(PARALLELMFLAGS) \
	    LDFLAGS="-Wl,-rpath-link,$(SYSROOT)/usr/lib -Wl,-rpath-link,$(SYSROOT)/lib"
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

skipstone_install: $(STATEDIR)/skipstone.install

$(STATEDIR)/skipstone.install: $(skipstone_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

skipstone_targetinstall: $(STATEDIR)/skipstone.targetinstall

$(STATEDIR)/skipstone.targetinstall: $(skipstone_targetinstall_deps_default)
	@$(call targetinfo, $@)

	cd $(SKIPSTONE_DIR) && $(SKIPSTONE_PATH) $(SKIPSTONE_ENV) $(MAKE) $(PARALLELMFLAGS) \
	    LDFLAGS="-Wl,-rpath-link,$(SYSROOT)/usr/lib -Wl,-rpath-link,$(SYSROOT)/lib" \
	    PREFIX=$(SKIPSTONE_DIR)/fakeroot/usr install

	@$(call install_init, skipstone)
	@$(call install_fixup, skipstone,PACKAGE,skipstone)
	@$(call install_fixup, skipstone,PRIORITY,optional)
	@$(call install_fixup, skipstone,VERSION,$(SKIPSTONE_VERSION))
	@$(call install_fixup, skipstone,SECTION,base)
	@$(call install_fixup, skipstone,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, skipstone,DEPENDS,)
	@$(call install_fixup, skipstone,DESCRIPTION,missing)

	@$(call install_target, skipstone, $(SKIPSTONE_DIR)/fakeroot/usr, /usr)

	@$(call install_copy, skipstone, 0, 0, 0644, $(PDAXROMDIR)/apps/skipstone.desktop, /usr/share/applications/skipstone.desktop)

	@$(call install_finish, skipstone)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

skipstone_clean:
	rm -rf $(STATEDIR)/skipstone.*
	rm -rf $(IMAGEDIR)/skipstone_*
	rm -rf $(SKIPSTONE_DIR)

# vim: syntax=make
