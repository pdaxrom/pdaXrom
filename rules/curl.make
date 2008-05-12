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
PACKAGES-$(PTXCONF_CURL) += curl

#
# Paths and names
#
CURL_VERSION	:= 7.18.1
CURL		:= curl-$(CURL_VERSION)
CURL_SUFFIX	:= tar.bz2
CURL_URL	:= http://curl.haxx.se/download/$(CURL).$(CURL_SUFFIX)
CURL_SOURCE	:= $(SRCDIR)/$(CURL).$(CURL_SUFFIX)
CURL_DIR	:= $(BUILDDIR)/$(CURL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

curl_get: $(STATEDIR)/curl.get

$(STATEDIR)/curl.get: $(curl_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(CURL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, CURL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

curl_extract: $(STATEDIR)/curl.extract

$(STATEDIR)/curl.extract: $(curl_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(CURL_DIR))
	@$(call extract, CURL)
	@$(call patchin, CURL)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

curl_prepare: $(STATEDIR)/curl.prepare

CURL_PATH	:= PATH=$(CROSS_PATH)
CURL_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
CURL_AUTOCONF := $(CROSS_AUTOCONF_USR) \
    --with-random=/dev/urandom \
    --without-gnutls \
    --without-nss \
    --without-libidn \
    --without-libssh2 \
    --enable-crypto-auth \
    --with-ssl=$(SYSROOT)

$(STATEDIR)/curl.prepare: $(curl_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(CURL_DIR)/config.cache)
	cd $(CURL_DIR) && \
		$(CURL_PATH) $(CURL_ENV) \
		./configure $(CURL_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

curl_compile: $(STATEDIR)/curl.compile

$(STATEDIR)/curl.compile: $(curl_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(CURL_DIR) && $(CURL_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

curl_install: $(STATEDIR)/curl.install

$(STATEDIR)/curl.install: $(curl_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, CURL)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

curl_targetinstall: $(STATEDIR)/curl.targetinstall

$(STATEDIR)/curl.targetinstall: $(curl_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init,  libcurl)
	@$(call install_fixup, libcurl,PACKAGE,libcurl)
	@$(call install_fixup, libcurl,PRIORITY,optional)
	@$(call install_fixup, libcurl,VERSION,$(CURL_VERSION))
	@$(call install_fixup, libcurl,SECTION,base)
	@$(call install_fixup, libcurl,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, libcurl,DEPENDS, "openssl zlib")
	@$(call install_fixup, libcurl,DESCRIPTION,missing)
	@$(call install_copy,  libcurl, 0, 0, 0755, $(CURL_DIR)/lib/.libs/libcurl.so.4.0.1, /usr/lib/libcurl.so.4.0.1)
	@$(call install_link,  libcurl, libcurl.so.4.0.1, /usr/lib/libcurl.so.4)
	@$(call install_link,  libcurl, libcurl.so.4.0.1, /usr/lib/libcurl.so)
	@$(call install_finish, libcurl)

	@$(call install_init,  curl)
	@$(call install_fixup, curl,PACKAGE,curl)
	@$(call install_fixup, curl,PRIORITY,optional)
	@$(call install_fixup, curl,VERSION,$(CURL_VERSION))
	@$(call install_fixup, curl,SECTION,base)
	@$(call install_fixup, curl,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, curl,DEPENDS, "libcurl")
	@$(call install_fixup, curl,DESCRIPTION,missing)
	@$(call install_copy, curl, 0, 0, 0755, $(CURL_DIR)/src/.libs/curl, /usr/bin/curl)
	@$(call install_finish, curl)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

curl_clean:
	rm -rf $(STATEDIR)/curl.*
	rm -rf $(IMAGEDIR)/curl_*
	rm -rf $(CURL_DIR)

# vim: syntax=make
