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
PACKAGES-$(PTXCONF_FIREFOX) += firefox

#
# Paths and names
#
FIREFOX_VERSION	:= 2.0.0.14
FIREFOX		:= firefox-$(FIREFOX_VERSION)-source
FIREFOX_SUFFIX	:= tar.bz2
FIREFOX_URL	:= ftp://ftp.mozilla.org/pub/mozilla.org/firefox/releases/2.0.0.14/source/$(FIREFOX).$(FIREFOX_SUFFIX)
FIREFOX_SOURCE	:= $(SRCDIR)/$(FIREFOX).$(FIREFOX_SUFFIX)
FIREFOX_DIR	:= $(BUILDDIR)/mozilla

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

firefox_get: $(STATEDIR)/firefox.get

$(STATEDIR)/firefox.get: $(firefox_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(FIREFOX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, FIREFOX)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

firefox_extract: $(STATEDIR)/firefox.extract

$(STATEDIR)/firefox.extract: $(firefox_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(FIREFOX_DIR))
	@$(call extract, FIREFOX)
	@$(call patchin, FIREFOX, $(FIREFOX_DIR))
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

firefox_prepare: $(STATEDIR)/firefox.prepare

FIREFOX_PATH	:= PATH=$(CROSS_PATH)
FIREFOX_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
FIREFOX_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/firefox.prepare: $(firefox_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(FIREFOX_DIR)/config.cache)
	cp -f $(PDAXROMDIR)/configs/mozconfigs/firefox-$(FIREFOX_VERSION)-arm $(FIREFOX_DIR)/.mozconfig
	cd $(FIREFOX_DIR) && \
		$(FIREFOX_PATH) $(FIREFOX_ENV) \
		./configure --prefix=/usr --sysconfdir=/etc --build=i686-host-linux-gnu --target=arm-926ejs-linux-gnueabi
		#$(FIREFOX_AUTOCONF)
	cp -f $(PDAXROMDIR)/configs/mozconfigs/jsautocfg.h-arm $(FIREFOX_DIR)/js/src/jsautocfg.h
	sed -i "s|CPU_ARCH =|CPU_ARCH = $(PTXCONF_ARCH)|" $(FIREFOX_DIR)/security/coreconf/Linux.mk
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

firefox_compile: $(STATEDIR)/firefox.compile

$(STATEDIR)/firefox.compile: $(firefox_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(FIREFOX_DIR) && $(FIREFOX_PATH) $(MAKE) $(PARALLELMFLAGS) \
	    CROSS_COMPILE=1 \
	    HOST_CXXFLAGS="$(HOST_CPPFLAGS)" \
	    HOST_LIBIDL_CFLAGS="`PATH=$(HOST_PATH) libIDL-config-2 --cflags`" \
	    HOST_LIBIDL_LIBS="$(HOST_LDFLAGS) `PATH=$(HOST_PATH) libIDL-config-2 --libs`"
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

firefox_install: $(STATEDIR)/firefox.install

$(STATEDIR)/firefox.install: $(firefox_install_deps_default)
	@$(call targetinfo, $@)
	#@$(call install, FIREFOX)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

firefox_targetinstall: $(STATEDIR)/firefox.targetinstall

$(STATEDIR)/firefox.targetinstall: $(firefox_targetinstall_deps_default)
	@$(call targetinfo, $@)

	cd $(FIREFOX_DIR) && $(FIREFOX_PATH) $(MAKE) $(PARALLELMFLAGS) \
	    CROSS_COMPILE=1 \
	    HOST_CXXFLAGS="$(HOST_CPPFLAGS)" \
	    HOST_LIBIDL_CFLAGS="`PATH=$(HOST_PATH) libIDL-config-2 --cflags`" \
	    HOST_LIBIDL_LIBS="$(HOST_LDFLAGS) `PATH=$(HOST_PATH) libIDL-config-2 --libs`" \
	    DESTDIR=$(FIREFOX_DIR)/fakeroot install

	rm -rf $(FIREFOX_DIR)/fakeroot/usr/bin/firefox-config
	rm -rf $(FIREFOX_DIR)/fakeroot/usr/include
	rm -rf $(FIREFOX_DIR)/fakeroot/usr/lib/pkgconfig
	rm -rf $(FIREFOX_DIR)/fakeroot/usr/share/aclocal
	rm -rf $(FIREFOX_DIR)/fakeroot/usr/share/idl

	@$(call install_init, firefox)
	@$(call install_fixup, firefox,PACKAGE,firefox)
	@$(call install_fixup, firefox,PRIORITY,optional)
	@$(call install_fixup, firefox,VERSION,$(FIREFOX_VERSION))
	@$(call install_fixup, firefox,SECTION,base)
	@$(call install_fixup, firefox,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, firefox,DEPENDS, "gtk")
	@$(call install_fixup, firefox,DESCRIPTION,missing)

	@$(call install_target, firefox, $(FIREFOX_DIR)/fakeroot/usr, /usr)

	@$(call install_copy, firefox, 0, 0, 0644, $(PDAXROMDIR)/apps/mozilla-firefox.desktop, /usr/share/applications/mozilla-firefox.desktop)
	@$(call install_copy, firefox, 0, 0, 0644, $(PDAXROMDIR)/pixmaps/mozilla-firefox.png, /usr/share/pixmaps/mozilla-firefox.png)

	@$(call install_finish, firefox)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

firefox_clean:
	rm -rf $(STATEDIR)/firefox.*
	rm -rf $(IMAGEDIR)/firefox_*
	rm -rf $(FIREFOX_DIR)

# vim: syntax=make
