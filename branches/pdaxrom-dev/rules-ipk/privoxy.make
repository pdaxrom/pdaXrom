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
ifdef PTXCONF_PRIVOXY
PACKAGES += privoxy
endif

#
# Paths and names
#
PRIVOXY_VENDOR_VERSION	= 1
PRIVOXY_VERSION		= 3.0.3
PRIVOXY			= privoxy-$(PRIVOXY_VERSION)
PRIVOXY_SUFFIX		= tar.gz
PRIVOXY_URL		= http://citkit.dl.sourceforge.net/sourceforge/ijbswa/$(PRIVOXY)-1-stable-src.$(PRIVOXY_SUFFIX)
PRIVOXY_SOURCE		= $(SRCDIR)/$(PRIVOXY)-1-stable-src.$(PRIVOXY_SUFFIX)
PRIVOXY_DIR		= $(BUILDDIR)/$(PRIVOXY)-stable
PRIVOXY_IPKG_TMP	= $(PRIVOXY_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

privoxy_get: $(STATEDIR)/privoxy.get

privoxy_get_deps = $(PRIVOXY_SOURCE)

$(STATEDIR)/privoxy.get: $(privoxy_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PRIVOXY))
	touch $@

$(PRIVOXY_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PRIVOXY_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

privoxy_extract: $(STATEDIR)/privoxy.extract

privoxy_extract_deps = $(STATEDIR)/privoxy.get

$(STATEDIR)/privoxy.extract: $(privoxy_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PRIVOXY_DIR))
	@$(call extract, $(PRIVOXY_SOURCE))
	@$(call patchin, $(PRIVOXY))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

privoxy_prepare: $(STATEDIR)/privoxy.prepare

#
# dependencies
#
privoxy_prepare_deps = \
	$(STATEDIR)/privoxy.extract \
	$(STATEDIR)/virtual-xchain.install

PRIVOXY_PATH	=  PATH=$(CROSS_PATH)
PRIVOXY_ENV 	=  $(CROSS_ENV)
#PRIVOXY_ENV	+=
PRIVOXY_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PRIVOXY_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PRIVOXY_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PRIVOXY_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PRIVOXY_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/privoxy.prepare: $(privoxy_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PRIVOXY_DIR)/config.cache)
	cd $(PRIVOXY_DIR) && $(PRIVOXY_PATH) aclocal
	#cd $(PRIVOXY_DIR) && $(PRIVOXY_PATH) automake --add-missing
	cd $(PRIVOXY_DIR) && $(PRIVOXY_PATH) autoheader
	cd $(PRIVOXY_DIR) && $(PRIVOXY_PATH) autoconf
	cd $(PRIVOXY_DIR) && \
		$(PRIVOXY_PATH) $(PRIVOXY_ENV) \
		./configure $(PRIVOXY_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

privoxy_compile: $(STATEDIR)/privoxy.compile

privoxy_compile_deps = $(STATEDIR)/privoxy.prepare

$(STATEDIR)/privoxy.compile: $(privoxy_compile_deps)
	@$(call targetinfo, $@)
	$(PRIVOXY_PATH) $(MAKE) -C $(PRIVOXY_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

privoxy_install: $(STATEDIR)/privoxy.install

$(STATEDIR)/privoxy.install: $(STATEDIR)/privoxy.compile
	@$(call targetinfo, $@)
	#$(PRIVOXY_PATH) $(MAKE) -C $(PRIVOXY_DIR) install
	aqwsd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

privoxy_targetinstall: $(STATEDIR)/privoxy.targetinstall

privoxy_targetinstall_deps = $(STATEDIR)/privoxy.compile

$(STATEDIR)/privoxy.targetinstall: $(privoxy_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PRIVOXY_PATH) $(MAKE) -C $(PRIVOXY_DIR) DESTDIR=$(PRIVOXY_IPKG_TMP) install
	mkdir -p $(PRIVOXY_IPKG_TMP)/CONTROL
	echo "Package: privoxy" 							 >$(PRIVOXY_IPKG_TMP)/CONTROL/control
	echo "Source: $(PRIVOXY_URL)"							>>$(PRIVOXY_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PRIVOXY_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(PRIVOXY_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PRIVOXY_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PRIVOXY_IPKG_TMP)/CONTROL/control
	echo "Version: $(PRIVOXY_VERSION)-$(PRIVOXY_VENDOR_VERSION)" 			>>$(PRIVOXY_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(PRIVOXY_IPKG_TMP)/CONTROL/control
	echo "Description: Privoxy is a web proxy with advanced filtering capabilities for protecting privacy, modifying web page content, managing cookies, controlling access, and removing ads, banners, pop-ups and other obnoxious Internet junk." >>$(PRIVOXY_IPKG_TMP)/CONTROL/control
	asdas
	@$(call makeipkg, $(PRIVOXY_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PRIVOXY_INSTALL
ROMPACKAGES += $(STATEDIR)/privoxy.imageinstall
endif

privoxy_imageinstall_deps = $(STATEDIR)/privoxy.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/privoxy.imageinstall: $(privoxy_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install privoxy
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

privoxy_clean:
	rm -rf $(STATEDIR)/privoxy.*
	rm -rf $(PRIVOXY_DIR)

# vim: syntax=make
