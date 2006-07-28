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
ifdef PTXCONF_PADXWIN
PACKAGES += padXwin
endif

#
# Paths and names
#
PADXWIN_VENDOR_VERSION	= 1
PADXWIN_VERSION		= 1.6
PADXWIN			= padXwin-$(PADXWIN_VERSION)
PADXWIN_SUFFIX		= tgz
PADXWIN_URL		= http://www.pdaXrom.org/src/$(PADXWIN).$(PADXWIN_SUFFIX)
PADXWIN_SOURCE		= $(SRCDIR)/$(PADXWIN).$(PADXWIN_SUFFIX)
PADXWIN_DIR		= $(BUILDDIR)/$(PADXWIN)
PADXWIN_IPKG_TMP	= $(PADXWIN_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

padXwin_get: $(STATEDIR)/padXwin.get

padXwin_get_deps = $(PADXWIN_SOURCE)

$(STATEDIR)/padXwin.get: $(padXwin_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PADXWIN))
	touch $@

$(PADXWIN_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PADXWIN_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

padXwin_extract: $(STATEDIR)/padXwin.extract

padXwin_extract_deps = $(STATEDIR)/padXwin.get

$(STATEDIR)/padXwin.extract: $(padXwin_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(PADXWIN_DIR))
	@$(call extract, $(PADXWIN_SOURCE), $(PADXWIN_DIR))
	@$(call patchin, $(PADXWIN), $(PADXWIN_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

padXwin_prepare: $(STATEDIR)/padXwin.prepare

#
# dependencies
#
padXwin_prepare_deps = \
	$(STATEDIR)/padXwin.extract \
	$(STATEDIR)/virtual-xchain.install

PADXWIN_PATH	=  PATH=$(CROSS_PATH)
PADXWIN_ENV 	=  $(CROSS_ENV)
#PADXWIN_ENV	+=
PADXWIN_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PADXWIN_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PADXWIN_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PADXWIN_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PADXWIN_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/padXwin.prepare: $(padXwin_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PADXWIN_DIR)/config.cache)
	#cd $(PADXWIN_DIR) && \
	#	$(PADXWIN_PATH) $(PADXWIN_ENV) \
	#	./configure $(PADXWIN_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

padXwin_compile: $(STATEDIR)/padXwin.compile

padXwin_compile_deps = $(STATEDIR)/padXwin.prepare

$(STATEDIR)/padXwin.compile: $(padXwin_compile_deps)
	@$(call targetinfo, $@)
	$(PADXWIN_PATH) $(PADXWIN_ENV) $(MAKE) -C $(PADXWIN_DIR)/src $(CROSS_ENV_CC) $(CROSS_ENV_STRIP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

padXwin_install: $(STATEDIR)/padXwin.install

$(STATEDIR)/padXwin.install: $(STATEDIR)/padXwin.compile
	@$(call targetinfo, $@)
	###$(PADXWIN_PATH) $(MAKE) -C $(PADXWIN_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

padXwin_targetinstall: $(STATEDIR)/padXwin.targetinstall

padXwin_targetinstall_deps = $(STATEDIR)/padXwin.compile

$(STATEDIR)/padXwin.targetinstall: $(padXwin_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(PADXWIN_PATH) $(MAKE) -C $(PADXWIN_DIR) DESTDIR=$(PADXWIN_IPKG_TMP) install
	mkdir -p $(PADXWIN_IPKG_TMP)/usr/share/pcsx/Plugin
	cp -a $(PADXWIN_DIR)/src/libpadXwin-1.6.so 	$(PADXWIN_IPKG_TMP)/usr/share/pcsx/Plugin/
	cp -a $(PADXWIN_DIR)/src/cfgPadXwin		$(PADXWIN_IPKG_TMP)/usr/share/pcsx/
	$(CROSSSTRIP) $(PADXWIN_IPKG_TMP)/usr/share/pcsx/Plugin/*
	$(CROSSSTRIP) $(PADXWIN_IPKG_TMP)/usr/share/pcsx/cfgPadXwin
	mkdir -p $(PADXWIN_IPKG_TMP)/CONTROL
	echo "Package: padxwin" 							 >$(PADXWIN_IPKG_TMP)/CONTROL/control
	echo "Source: $(PADXWIN_URL)"							>>$(PADXWIN_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PADXWIN_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(PADXWIN_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PADXWIN_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PADXWIN_IPKG_TMP)/CONTROL/control
	echo "Version: $(PADXWIN_VERSION)-$(PADXWIN_VENDOR_VERSION)" 			>>$(PADXWIN_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk" 								>>$(PADXWIN_IPKG_TMP)/CONTROL/control
	echo "Description: keypad plugin"						>>$(PADXWIN_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PADXWIN_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PADXWIN_INSTALL
ROMPACKAGES += $(STATEDIR)/padXwin.imageinstall
endif

padXwin_imageinstall_deps = $(STATEDIR)/padXwin.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/padXwin.imageinstall: $(padXwin_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install padxwin
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

padXwin_clean:
	rm -rf $(STATEDIR)/padXwin.*
	rm -rf $(PADXWIN_DIR)

# vim: syntax=make
