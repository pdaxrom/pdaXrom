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
ifdef PTXCONF_OPENVPN
PACKAGES += openvpn
endif

#
# Paths and names
#
OPENVPN_VENDOR_VERSION	= 1
OPENVPN_VERSION		= 2.0.7
OPENVPN			= openvpn-$(OPENVPN_VERSION)
OPENVPN_SUFFIX		= tar.gz
OPENVPN_URL		= http://openvpn.net/release/$(OPENVPN).$(OPENVPN_SUFFIX)
OPENVPN_SOURCE		= $(SRCDIR)/$(OPENVPN).$(OPENVPN_SUFFIX)
OPENVPN_DIR		= $(BUILDDIR)/$(OPENVPN)
OPENVPN_IPKG_TMP	= $(OPENVPN_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

openvpn_get: $(STATEDIR)/openvpn.get

openvpn_get_deps = $(OPENVPN_SOURCE)

$(STATEDIR)/openvpn.get: $(openvpn_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OPENVPN))
	touch $@

$(OPENVPN_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OPENVPN_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

openvpn_extract: $(STATEDIR)/openvpn.extract

openvpn_extract_deps = $(STATEDIR)/openvpn.get

$(STATEDIR)/openvpn.extract: $(openvpn_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENVPN_DIR))
	@$(call extract, $(OPENVPN_SOURCE))
	@$(call patchin, $(OPENVPN))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

openvpn_prepare: $(STATEDIR)/openvpn.prepare

#
# dependencies
#
openvpn_prepare_deps = \
	$(STATEDIR)/openvpn.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/lzo.install \
	$(STATEDIR)/virtual-xchain.install

OPENVPN_PATH	=  PATH=$(CROSS_PATH)
OPENVPN_ENV 	=  $(CROSS_ENV)
#OPENVPN_ENV	+=
OPENVPN_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OPENVPN_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
OPENVPN_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
OPENVPN_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OPENVPN_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/openvpn.prepare: $(openvpn_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENVPN_DIR)/config.cache)
	cd $(OPENVPN_DIR) && \
		$(OPENVPN_PATH) $(OPENVPN_ENV) \
		./configure $(OPENVPN_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

openvpn_compile: $(STATEDIR)/openvpn.compile

openvpn_compile_deps = $(STATEDIR)/openvpn.prepare

$(STATEDIR)/openvpn.compile: $(openvpn_compile_deps)
	@$(call targetinfo, $@)
	$(OPENVPN_PATH) $(MAKE) -C $(OPENVPN_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

openvpn_install: $(STATEDIR)/openvpn.install

$(STATEDIR)/openvpn.install: $(STATEDIR)/openvpn.compile
	@$(call targetinfo, $@)
	rm -rf $(OPENVPN_IPKG_TMP)
	$(OPENVPN_PATH) $(MAKE) -C $(OPENVPN_DIR) DESTDIR=$(OPENVPN_IPKG_TMP) install
	@$(call copyincludes, $(OPENVPN_IPKG_TMP))
	@$(call copylibraries,$(OPENVPN_IPKG_TMP))
	@$(call copymiscfiles,$(OPENVPN_IPKG_TMP))
	rm -rf $(OPENVPN_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

openvpn_targetinstall: $(STATEDIR)/openvpn.targetinstall

openvpn_targetinstall_deps = $(STATEDIR)/openvpn.compile \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/lzo.targetinstall

$(STATEDIR)/openvpn.targetinstall: $(openvpn_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OPENVPN_PATH) $(MAKE) -C $(OPENVPN_DIR) DESTDIR=$(OPENVPN_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(OPENVPN_VERSION)-$(OPENVPN_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh openvpn $(OPENVPN_IPKG_TMP)

	@$(call removedevfiles, $(OPENVPN_IPKG_TMP))
	@$(call stripfiles, $(OPENVPN_IPKG_TMP))

	mkdir -p $(OPENVPN_IPKG_TMP)/etc/openvpn
	mkdir -p $(OPENVPN_IPKG_TMP)/etc/rc.d/{init.d,rc0.d,rc5.d,rc6.d}
	cp -a $(OPENVPN_DIR)/sample-scripts/openvpn.init $(OPENVPN_IPKG_TMP)/etc/rc.d/init.d/openvpn

	mkdir -p $(OPENVPN_IPKG_TMP)/CONTROL
	echo "Package: openvpn" 							 >$(OPENVPN_IPKG_TMP)/CONTROL/control
	echo "Source: $(OPENVPN_URL)"							>>$(OPENVPN_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(OPENVPN_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(OPENVPN_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(OPENVPN_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(OPENVPN_IPKG_TMP)/CONTROL/control
	echo "Version: $(OPENVPN_VERSION)-$(OPENVPN_VENDOR_VERSION)" 			>>$(OPENVPN_IPKG_TMP)/CONTROL/control
	echo "Depends: lzo, openssl" 							>>$(OPENVPN_IPKG_TMP)/CONTROL/control
	echo "Description: OpenVPN is a full-featured SSL VPN solution which can accomodate a wide range of configurations, including remote access, site-to-site VPNs, WiFi security, and enterprise-scale remote access solutions with load balancing, failover, and fine-grained access-controls" >>$(OPENVPN_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OPENVPN_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OPENVPN_INSTALL
ROMPACKAGES += $(STATEDIR)/openvpn.imageinstall
endif

openvpn_imageinstall_deps = $(STATEDIR)/openvpn.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/openvpn.imageinstall: $(openvpn_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install openvpn
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

openvpn_clean:
	rm -rf $(STATEDIR)/openvpn.*
	rm -rf $(OPENVPN_DIR)

# vim: syntax=make
