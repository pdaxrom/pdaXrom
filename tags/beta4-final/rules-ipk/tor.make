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
ifdef PTXCONF_TOR
PACKAGES += tor
endif

#
# Paths and names
#
TOR_VENDOR_VERSION	= 1
TOR_VERSION		= 0.1.1.8-alpha
TOR			= tor-$(TOR_VERSION)
TOR_SUFFIX		= tar.gz
TOR_URL			= http://tor.eff.org/dist/$(TOR).$(TOR_SUFFIX)
TOR_SOURCE		= $(SRCDIR)/$(TOR).$(TOR_SUFFIX)
TOR_DIR			= $(BUILDDIR)/$(TOR)
TOR_IPKG_TMP		= $(TOR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tor_get: $(STATEDIR)/tor.get

tor_get_deps = $(TOR_SOURCE)

$(STATEDIR)/tor.get: $(tor_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TOR))
	touch $@

$(TOR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TOR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tor_extract: $(STATEDIR)/tor.extract

tor_extract_deps = $(STATEDIR)/tor.get

$(STATEDIR)/tor.extract: $(tor_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TOR_DIR))
	@$(call extract, $(TOR_SOURCE))
	@$(call patchin, $(TOR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tor_prepare: $(STATEDIR)/tor.prepare

#
# dependencies
#
tor_prepare_deps = \
	$(STATEDIR)/tor.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/libevent.install \
	$(STATEDIR)/virtual-xchain.install

TOR_PATH	=  PATH=$(CROSS_PATH)
TOR_ENV 	=  $(CROSS_ENV)
#TOR_ENV	+=
TOR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TOR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
TOR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--sysconfdir=/etc \
	--prefix=/usr \
	--with-ssl-dir=$(CROSS_LIB_DIR)/lib

ifdef PTXCONF_XFREE430
TOR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TOR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/tor.prepare: $(tor_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TOR_DIR)/config.cache)
	cd $(TOR_DIR) && \
		$(TOR_PATH) $(TOR_ENV) \
		ac_cv_openssldir=$(CROSS_LIB_DIR) \
		./configure $(TOR_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tor_compile: $(STATEDIR)/tor.compile

tor_compile_deps = $(STATEDIR)/tor.prepare

$(STATEDIR)/tor.compile: $(tor_compile_deps)
	@$(call targetinfo, $@)
	$(TOR_PATH) $(MAKE) -C $(TOR_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tor_install: $(STATEDIR)/tor.install

$(STATEDIR)/tor.install: $(STATEDIR)/tor.compile
	@$(call targetinfo, $@)
	asdads
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tor_targetinstall: $(STATEDIR)/tor.targetinstall

tor_targetinstall_deps = $(STATEDIR)/tor.compile \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/tsocks.targetinstall \
	$(STATEDIR)/libevent.targetinstall

$(STATEDIR)/tor.targetinstall: $(tor_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TOR_PATH) $(MAKE) -C $(TOR_DIR) DESTDIR=$(TOR_IPKG_TMP) install
	$(CROSSSTRIP) $(TOR_IPKG_TMP)/usr/bin/{tor,tor-resolve}
	rm -rf $(TOR_IPKG_TMP)/usr/man
	mkdir -p $(TOR_IPKG_TMP)/CONTROL
	echo "Package: tor" 								 >$(TOR_IPKG_TMP)/CONTROL/control
	echo "Source: $(TOR_URL)"							>>$(TOR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(TOR_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(TOR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(TOR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(TOR_IPKG_TMP)/CONTROL/control
	echo "Version: $(TOR_VERSION)-$(TOR_VENDOR_VERSION)" 				>>$(TOR_IPKG_TMP)/CONTROL/control
	echo "Depends: libevent, openssl, tsocks" 					>>$(TOR_IPKG_TMP)/CONTROL/control
	echo "Description: Tor is a toolset for a wide range of organizations and people that want to improve their safety and security on the Internet." >>$(TOR_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TOR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TOR_INSTALL
ROMPACKAGES += $(STATEDIR)/tor.imageinstall
endif

tor_imageinstall_deps = $(STATEDIR)/tor.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tor.imageinstall: $(tor_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tor
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tor_clean:
	rm -rf $(STATEDIR)/tor.*
	rm -rf $(TOR_DIR)

# vim: syntax=make
