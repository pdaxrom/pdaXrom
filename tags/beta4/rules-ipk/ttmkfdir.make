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
ifdef PTXCONF_TTMKFDIR
PACKAGES += ttmkfdir
endif

#
# Paths and names
#
TTMKFDIR_VENDOR_VERSION	= 1
TTMKFDIR_VERSION	= 3.0.9
TTMKFDIR		= ttmkfdir_$(TTMKFDIR_VERSION).orig
TTMKFDIR_SUFFIX		= tar.gz
TTMKFDIR_URL		= http://ftp.debian.org/debian/pool/main/t/ttmkfdir/$(TTMKFDIR).$(TTMKFDIR_SUFFIX)
TTMKFDIR_SOURCE		= $(SRCDIR)/$(TTMKFDIR).$(TTMKFDIR_SUFFIX)
TTMKFDIR_DIR		= $(BUILDDIR)/ttmkfdir-$(TTMKFDIR_VERSION)
TTMKFDIR_IPKG_TMP	= $(TTMKFDIR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ttmkfdir_get: $(STATEDIR)/ttmkfdir.get

ttmkfdir_get_deps = $(TTMKFDIR_SOURCE)

$(STATEDIR)/ttmkfdir.get: $(ttmkfdir_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TTMKFDIR))
	touch $@

$(TTMKFDIR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TTMKFDIR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ttmkfdir_extract: $(STATEDIR)/ttmkfdir.extract

ttmkfdir_extract_deps = $(STATEDIR)/ttmkfdir.get

$(STATEDIR)/ttmkfdir.extract: $(ttmkfdir_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(TTMKFDIR_DIR))
	@$(call extract, $(TTMKFDIR_SOURCE))
	@$(call patchin, $(TTMKFDIR), $(TTMKFDIR_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ttmkfdir_prepare: $(STATEDIR)/ttmkfdir.prepare

#
# dependencies
#
ttmkfdir_prepare_deps = \
	$(STATEDIR)/ttmkfdir.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

TTMKFDIR_PATH	=  PATH=$(CROSS_PATH)
TTMKFDIR_ENV 	=  $(CROSS_ENV)
#TTMKFDIR_ENV	+=
TTMKFDIR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TTMKFDIR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
TTMKFDIR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
TTMKFDIR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TTMKFDIR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ttmkfdir.prepare: $(ttmkfdir_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TTMKFDIR_DIR)/config.cache)
	#cd $(TTMKFDIR_DIR) && \
	#	$(TTMKFDIR_PATH) $(TTMKFDIR_ENV) \
	#	./configure $(TTMKFDIR_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ttmkfdir_compile: $(STATEDIR)/ttmkfdir.compile

ttmkfdir_compile_deps = $(STATEDIR)/ttmkfdir.prepare

$(STATEDIR)/ttmkfdir.compile: $(ttmkfdir_compile_deps)
	@$(call targetinfo, $@)
	$(TTMKFDIR_PATH) $(TTMKFDIR_ENV) $(MAKE) -C $(TTMKFDIR_DIR) $(CROSS_CXX_ENV)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ttmkfdir_install: $(STATEDIR)/ttmkfdir.install

$(STATEDIR)/ttmkfdir.install: $(STATEDIR)/ttmkfdir.compile
	@$(call targetinfo, $@)
	##$(TTMKFDIR_PATH) $(MAKE) -C $(TTMKFDIR_DIR) install
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ttmkfdir_targetinstall: $(STATEDIR)/ttmkfdir.targetinstall

ttmkfdir_targetinstall_deps = $(STATEDIR)/ttmkfdir.compile

$(STATEDIR)/ttmkfdir.targetinstall: $(ttmkfdir_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TTMKFDIR_PATH) $(MAKE) -C $(TTMKFDIR_DIR) DESTDIR=$(TTMKFDIR_IPKG_TMP) install
	$(CROSSSTRIP) $(TTMKFDIR_IPKG_TMP)/usr/bin/*
	mkdir -p $(TTMKFDIR_IPKG_TMP)/CONTROL
	echo "Package: ttmkfdir" 							 >$(TTMKFDIR_IPKG_TMP)/CONTROL/control
	echo "Source: $(TTMKFDIR_URL)"							>>$(TTMKFDIR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(TTMKFDIR_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(TTMKFDIR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(TTMKFDIR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(TTMKFDIR_IPKG_TMP)/CONTROL/control
	echo "Version: $(TTMKFDIR_VERSION)-$(TTMKFDIR_VENDOR_VERSION)" 			>>$(TTMKFDIR_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree" 								>>$(TTMKFDIR_IPKG_TMP)/CONTROL/control
	echo "Description: tool to create valid and complete fonts.scale file from TrueType fonts." >>$(TTMKFDIR_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TTMKFDIR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TTMKFDIR_INSTALL
ROMPACKAGES += $(STATEDIR)/ttmkfdir.imageinstall
endif

ttmkfdir_imageinstall_deps = $(STATEDIR)/ttmkfdir.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ttmkfdir.imageinstall: $(ttmkfdir_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ttmkfdir
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ttmkfdir_clean:
	rm -rf $(STATEDIR)/ttmkfdir.*
	rm -rf $(TTMKFDIR_DIR)

# vim: syntax=make
