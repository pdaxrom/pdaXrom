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
ifdef PTXCONF_DROPBEAR
PACKAGES += dropbear
endif

#
# Paths and names
#
DROPBEAR_VENDOR_VERSION	= 1
DROPBEAR_VERSION	= 0.47
DROPBEAR		= dropbear-$(DROPBEAR_VERSION)
DROPBEAR_SUFFIX		= tar.bz2
DROPBEAR_URL		= http://matt.ucc.asn.au/dropbear/releases/$(DROPBEAR).$(DROPBEAR_SUFFIX)
DROPBEAR_SOURCE		= $(SRCDIR)/$(DROPBEAR).$(DROPBEAR_SUFFIX)
DROPBEAR_DIR		= $(BUILDDIR)/$(DROPBEAR)
DROPBEAR_IPKG_TMP	= $(DROPBEAR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dropbear_get: $(STATEDIR)/dropbear.get

dropbear_get_deps = $(DROPBEAR_SOURCE)

$(STATEDIR)/dropbear.get: $(dropbear_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DROPBEAR))
	touch $@

$(DROPBEAR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DROPBEAR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dropbear_extract: $(STATEDIR)/dropbear.extract

dropbear_extract_deps = $(STATEDIR)/dropbear.get

$(STATEDIR)/dropbear.extract: $(dropbear_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DROPBEAR_DIR))
	@$(call extract, $(DROPBEAR_SOURCE))
	@$(call patchin, $(DROPBEAR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dropbear_prepare: $(STATEDIR)/dropbear.prepare

#
# dependencies
#
dropbear_prepare_deps = \
	$(STATEDIR)/dropbear.extract \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/virtual-xchain.install

DROPBEAR_PATH	=  PATH=$(CROSS_PATH)
DROPBEAR_ENV 	=  $(CROSS_ENV)
#DROPBEAR_ENV	+=
DROPBEAR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DROPBEAR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
DROPBEAR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-openpty \
	--enable-shadow \
	--enable-zlib \
	--disable-pam

ifdef PTXCONF_XFREE430
DROPBEAR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DROPBEAR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dropbear.prepare: $(dropbear_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DROPBEAR_DIR)/config.cache)
	cd $(DROPBEAR_DIR) && \
		$(DROPBEAR_PATH) $(DROPBEAR_ENV) \
		dropbear_cv_func_have_openpty=yes \
		ac_cv_file___dev_ptmx=no \
		ac_cv_file___dev_ptc=no  \
		./configure $(DROPBEAR_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dropbear_compile: $(STATEDIR)/dropbear.compile

dropbear_compile_deps = $(STATEDIR)/dropbear.prepare

$(STATEDIR)/dropbear.compile: $(dropbear_compile_deps)
	@$(call targetinfo, $@)
	$(DROPBEAR_PATH) $(MAKE) -C $(DROPBEAR_DIR) LD=$(PTXCONF_GNU_TARGET)-gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dropbear_install: $(STATEDIR)/dropbear.install

$(STATEDIR)/dropbear.install: $(STATEDIR)/dropbear.compile
	@$(call targetinfo, $@)
	$(DROPBEAR_PATH) $(MAKE) -C $(DROPBEAR_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dropbear_targetinstall: $(STATEDIR)/dropbear.targetinstall

dropbear_targetinstall_deps = $(STATEDIR)/dropbear.compile \
	$(STATEDIR)/zlib.targetinstall

$(STATEDIR)/dropbear.targetinstall: $(dropbear_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DROPBEAR_PATH) $(MAKE) -C $(DROPBEAR_DIR) DESTDIR=$(DROPBEAR_IPKG_TMP) install
	$(CROSSSTRIP) $(DROPBEAR_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(DROPBEAR_IPKG_TMP)/usr/sbin/*
	mkdir -p $(DROPBEAR_IPKG_TMP)/etc/dropbear
	mkdir -p $(DROPBEAR_IPKG_TMP)/etc/rc.d/{init.d,rc5.d}
	cp -a $(TOPDIR)/config/pics/dropbear.init $(DROPBEAR_IPKG_TMP)/etc/rc.d/init.d/dropbear
	ln -sf ../init.d/dropbear $(DROPBEAR_IPKG_TMP)/etc/rc.d/rc5.d/S17dropbear
	mkdir -p $(DROPBEAR_IPKG_TMP)/CONTROL
	echo "Package: dropbear" 							 >$(DROPBEAR_IPKG_TMP)/CONTROL/control
	echo "Source: $(DROPBEAR_URL)"							>>$(DROPBEAR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DROPBEAR_IPKG_TMP)/CONTROL/control
	echo "Section: Security" 							>>$(DROPBEAR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DROPBEAR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DROPBEAR_IPKG_TMP)/CONTROL/control
	echo "Version: $(DROPBEAR_VERSION)-$(DROPBEAR_VENDOR_VERSION)" 			>>$(DROPBEAR_IPKG_TMP)/CONTROL/control
	echo "Depends: libz" 								>>$(DROPBEAR_IPKG_TMP)/CONTROL/control
	echo "Description: Dropbear is an SSH 2 server and client that is designed to be small enough to be used in low-memory embedded environments, while still being functional and secure enough for general use." >>$(DROPBEAR_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh"				 >$(DROPBEAR_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/dropbear start" 		>>$(DROPBEAR_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(DROPBEAR_IPKG_TMP)/CONTROL/postinst	
	cd $(FEEDDIR) && $(XMKIPKG) $(DROPBEAR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DROPBEAR_INSTALL
ROMPACKAGES += $(STATEDIR)/dropbear.imageinstall
endif

dropbear_imageinstall_deps = $(STATEDIR)/dropbear.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dropbear.imageinstall: $(dropbear_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dropbear
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dropbear_clean:
	rm -rf $(STATEDIR)/dropbear.*
	rm -rf $(DROPBEAR_DIR)

# vim: syntax=make
