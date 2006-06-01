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
ifdef PTXCONF_VPND
PACKAGES += vpnd
endif

#
# Paths and names
#
VPND_VENDOR_VERSION	= 1
VPND_VERSION		= 1.1.0
VPND			= vpnd-$(VPND_VERSION)
VPND_SUFFIX		= tar.gz
VPND_URL		= http://sunsite.dk/vpnd/archive/$(VPND).$(VPND_SUFFIX)
VPND_SOURCE		= $(SRCDIR)/$(VPND).$(VPND_SUFFIX)
VPND_DIR		= $(BUILDDIR)/vpnd
VPND_IPKG_TMP		= $(VPND_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

vpnd_get: $(STATEDIR)/vpnd.get

vpnd_get_deps = $(VPND_SOURCE)

$(STATEDIR)/vpnd.get: $(vpnd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(VPND))
	touch $@

$(VPND_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(VPND_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

vpnd_extract: $(STATEDIR)/vpnd.extract

vpnd_extract_deps = $(STATEDIR)/vpnd.get

$(STATEDIR)/vpnd.extract: $(vpnd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(VPND_DIR))
	@$(call extract, $(VPND_SOURCE))
	@$(call patchin, $(VPND), $(VPND_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

vpnd_prepare: $(STATEDIR)/vpnd.prepare

#
# dependencies
#
vpnd_prepare_deps = \
	$(STATEDIR)/vpnd.extract \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/virtual-xchain.install

VPND_PATH	=  PATH=$(CROSS_PATH)
VPND_ENV 	=  $(CROSS_ENV)
#VPND_ENV	+=
VPND_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#VPND_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
VPND_AUTOCONF = \
	--target=Linux \
	--includes=$(CROSS_LIB_DIR)/include \
	--libraries=$(CROSS_LIB_DIR)/lib \
	--arch=$(PTXCONF_ARCH)

#ifdef PTXCONF_XFREE430
#VPND_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
#VPND_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
#endif

$(STATEDIR)/vpnd.prepare: $(vpnd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VPND_DIR)/config.cache)
	cd $(VPND_DIR) && \
		$(VPND_PATH) $(VPND_ENV) \
		./configure $(VPND_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

vpnd_compile: $(STATEDIR)/vpnd.compile

vpnd_compile_deps = $(STATEDIR)/vpnd.prepare

$(STATEDIR)/vpnd.compile: $(vpnd_compile_deps)
	@$(call targetinfo, $@)
	$(VPND_PATH) $(VPND_ENV) $(MAKE) -C $(VPND_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

vpnd_install: $(STATEDIR)/vpnd.install

$(STATEDIR)/vpnd.install: $(STATEDIR)/vpnd.compile
	@$(call targetinfo, $@)
	#$(VPND_PATH) $(MAKE) -C $(VPND_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

vpnd_targetinstall: $(STATEDIR)/vpnd.targetinstall

vpnd_targetinstall_deps = $(STATEDIR)/vpnd.compile \
	$(STATEDIR)/zlib.targetinstall

$(STATEDIR)/vpnd.targetinstall: $(vpnd_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(VPND_PATH) $(MAKE) -C $(VPND_DIR) DESTDIR=$(VPND_IPKG_TMP) install
	$(INSTALL) -D -m 755 $(VPND_DIR)/vpnd $(VPND_IPKG_TMP)/usr/sbin/vpnd
	$(CROSSSTRIP) $(VPND_IPKG_TMP)/usr/sbin/vpnd
	mkdir -p $(VPND_IPKG_TMP)/CONTROL
	echo "Package: vpnd" 								 >$(VPND_IPKG_TMP)/CONTROL/control
	echo "Source: $(VPND_URL)"						>>$(VPND_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(VPND_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(VPND_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(VPND_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(VPND_IPKG_TMP)/CONTROL/control
	echo "Version: $(VPND_VERSION)-$(VPND_VENDOR_VERSION)" 				>>$(VPND_IPKG_TMP)/CONTROL/control
	echo "Depends: libz" 								>>$(VPND_IPKG_TMP)/CONTROL/control
	echo "Description: The virtual private network daemon vpnd is a daemon which connects two networks on network level either via TCP/IP or a (virtual) leased line attached to a serial interface. All data transfered between the two networks are encrypted using the unpatented free Blowfish encryption algorithm." >>$(VPND_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(VPND_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_VPND_INSTALL
ROMPACKAGES += $(STATEDIR)/vpnd.imageinstall
endif

vpnd_imageinstall_deps = $(STATEDIR)/vpnd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/vpnd.imageinstall: $(vpnd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install vpnd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

vpnd_clean:
	rm -rf $(STATEDIR)/vpnd.*
	rm -rf $(VPND_DIR)

# vim: syntax=make
