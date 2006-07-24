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
ifdef PTXCONF_LRZSZ
PACKAGES += lrzsz
endif

#
# Paths and names
#
LRZSZ_VENDOR_VERSION	= 1
LRZSZ_VERSION		= 0.12.20
LRZSZ			= lrzsz-$(LRZSZ_VERSION)
LRZSZ_SUFFIX		= tar.gz
LRZSZ_URL		= http://www.ohse.de/uwe/releases/$(LRZSZ).$(LRZSZ_SUFFIX)
LRZSZ_SOURCE		= $(SRCDIR)/$(LRZSZ).$(LRZSZ_SUFFIX)
LRZSZ_DIR		= $(BUILDDIR)/$(LRZSZ)
LRZSZ_IPKG_TMP		= $(LRZSZ_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lrzsz_get: $(STATEDIR)/lrzsz.get

lrzsz_get_deps = $(LRZSZ_SOURCE)

$(STATEDIR)/lrzsz.get: $(lrzsz_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LRZSZ))
	touch $@

$(LRZSZ_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LRZSZ_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lrzsz_extract: $(STATEDIR)/lrzsz.extract

lrzsz_extract_deps = $(STATEDIR)/lrzsz.get

$(STATEDIR)/lrzsz.extract: $(lrzsz_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LRZSZ_DIR))
	@$(call extract, $(LRZSZ_SOURCE))
	@$(call patchin, $(LRZSZ))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lrzsz_prepare: $(STATEDIR)/lrzsz.prepare

#
# dependencies
#
lrzsz_prepare_deps = \
	$(STATEDIR)/lrzsz.extract \
	$(STATEDIR)/virtual-xchain.install

LRZSZ_PATH	=  PATH=$(CROSS_PATH)
LRZSZ_ENV 	=  $(CROSS_ENV)
#LRZSZ_ENV	+=
LRZSZ_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LRZSZ_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LRZSZ_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--program-transform-name=s/l//

ifdef PTXCONF_XFREE430
LRZSZ_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LRZSZ_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/lrzsz.prepare: $(lrzsz_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LRZSZ_DIR)/config.cache)
	cd $(LRZSZ_DIR) && \
		$(LRZSZ_PATH) $(LRZSZ_ENV) \
		./configure $(LRZSZ_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lrzsz_compile: $(STATEDIR)/lrzsz.compile

lrzsz_compile_deps = $(STATEDIR)/lrzsz.prepare

$(STATEDIR)/lrzsz.compile: $(lrzsz_compile_deps)
	@$(call targetinfo, $@)
	$(LRZSZ_PATH) $(MAKE) -C $(LRZSZ_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lrzsz_install: $(STATEDIR)/lrzsz.install

$(STATEDIR)/lrzsz.install: $(STATEDIR)/lrzsz.compile
	@$(call targetinfo, $@)
	###$(LRZSZ_PATH) $(MAKE) -C $(LRZSZ_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lrzsz_targetinstall: $(STATEDIR)/lrzsz.targetinstall

lrzsz_targetinstall_deps = $(STATEDIR)/lrzsz.compile

$(STATEDIR)/lrzsz.targetinstall: $(lrzsz_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(LRZSZ_IPKG_TMP)
	$(LRZSZ_PATH) $(MAKE) -C $(LRZSZ_DIR) DESTDIR=$(LRZSZ_IPKG_TMP) install
	rm -rf $(LRZSZ_IPKG_TMP)/usr/man
	rm -f $(LRZSZ_IPKG_TMP)/usr/bin/{rx,rz,sx,sz}
	ln -sf rb $(LRZSZ_IPKG_TMP)/usr/bin/rx
	ln -sf rb $(LRZSZ_IPKG_TMP)/usr/bin/rz
	ln -sf sb $(LRZSZ_IPKG_TMP)/usr/bin/sx
	ln -sf sb $(LRZSZ_IPKG_TMP)/usr/bin/sz
	$(CROSSSTRIP) $(LRZSZ_IPKG_TMP)/usr/bin/*
	mkdir -p $(LRZSZ_IPKG_TMP)/CONTROL
	echo "Package: lrzsz" 								 >$(LRZSZ_IPKG_TMP)/CONTROL/control
	echo "Source: $(LRZSZ_URL)"						>>$(LRZSZ_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LRZSZ_IPKG_TMP)/CONTROL/control
	echo "Section: Console" 							>>$(LRZSZ_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LRZSZ_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LRZSZ_IPKG_TMP)/CONTROL/control
	echo "Version: $(LRZSZ_VERSION)-$(LRZSZ_VENDOR_VERSION)" 			>>$(LRZSZ_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LRZSZ_IPKG_TMP)/CONTROL/control
	echo "Description: Unix communication package providing the XMODEM, YMODEM ZMODEM file transfer protocols." >>$(LRZSZ_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LRZSZ_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LRZSZ_INSTALL
ROMPACKAGES += $(STATEDIR)/lrzsz.imageinstall
endif

lrzsz_imageinstall_deps = $(STATEDIR)/lrzsz.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/lrzsz.imageinstall: $(lrzsz_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lrzsz
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lrzsz_clean:
	rm -rf $(STATEDIR)/lrzsz.*
	rm -rf $(LRZSZ_DIR)

# vim: syntax=make
