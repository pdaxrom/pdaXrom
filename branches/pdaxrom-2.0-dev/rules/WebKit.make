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
PACKAGES-$(PTXCONF_WEBKIT) += webkit

#
# Paths and names
#
WEBKIT_VERSION	:= r33029
WEBKIT		:= WebKit-$(WEBKIT_VERSION)
WEBKIT_SUFFIX	:= tar.bz2
WEBKIT_URL	:= http://nightly.webkit.org/files/trunk/src/$(WEBKIT).$(WEBKIT_SUFFIX)
WEBKIT_SOURCE	:= $(SRCDIR)/$(WEBKIT).$(WEBKIT_SUFFIX)
WEBKIT_DIR	:= $(BUILDDIR)/$(WEBKIT)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

webkit_get: $(STATEDIR)/webkit.get

$(STATEDIR)/webkit.get: $(webkit_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(WEBKIT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, WEBKIT)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

webkit_extract: $(STATEDIR)/webkit.extract

$(STATEDIR)/webkit.extract: $(webkit_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(WEBKIT_DIR))
	@$(call extract, WEBKIT)
	@$(call patchin, WEBKIT)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

webkit_prepare: $(STATEDIR)/webkit.prepare

WEBKIT_PATH	:= PATH=$(CROSS_PATH)
WEBKIT_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
WEBKIT_AUTOCONF := $(CROSS_AUTOCONF_USR) \
    --enable-svg-animation

$(STATEDIR)/webkit.prepare: $(webkit_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(WEBKIT_DIR)/config.cache)
	cd $(WEBKIT_DIR) && $(WEBKIT_PATH) $(WEBKIT_ENV) \
		autoreconf -i
	cd $(WEBKIT_DIR) && \
		$(WEBKIT_PATH) $(WEBKIT_ENV) \
		SQLITE3_CFLAGS="-I$(SYSROOT)/usr/include" \
		SQLITE3_LIBS="-L$(SYSROOT)/usr/lib -lsqlite3" \
		./configure $(WEBKIT_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

webkit_compile: $(STATEDIR)/webkit.compile

$(STATEDIR)/webkit.compile: $(webkit_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(WEBKIT_DIR) && $(WEBKIT_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

webkit_install: $(STATEDIR)/webkit.install

$(STATEDIR)/webkit.install: $(webkit_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, WEBKIT)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

webkit_targetinstall: $(STATEDIR)/webkit.targetinstall

$(STATEDIR)/webkit.targetinstall: $(webkit_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, webkit)
	@$(call install_fixup, webkit,PACKAGE,webkit)
	@$(call install_fixup, webkit,PRIORITY,optional)
	@$(call install_fixup, webkit,VERSION,$(WEBKIT_VERSION))
	@$(call install_fixup, webkit,SECTION,base)
	@$(call install_fixup, webkit,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, webkit,DEPENDS, "libicui18n libicuuc libicudata")
	@$(call install_fixup, webkit,DESCRIPTION,missing)

	@$(call install_copy, webkit, 0, 0, 0755, $(WEBKIT_DIR)/.libs/libwebkit-1.0.so.1.0.0, /usr/lib/libwebkit-1.0.so.1.0.0)
	@$(call install_link, webkit, libwebkit-1.0.so.1.0.0, /usr/lib/libwebkit-1.0.so.1)
	@$(call install_link, webkit, libwebkit-1.0.so.1.0.0, /usr/lib/libwebkit-1.0.so)

	@$(call install_finish, webkit)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

webkit_clean:
	rm -rf $(STATEDIR)/webkit.*
	rm -rf $(IMAGEDIR)/webkit_*
	rm -rf $(WEBKIT_DIR)

# vim: syntax=make
