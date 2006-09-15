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
ifdef PTXCONF_YUDIT
PACKAGES += yudit
endif

#
# Paths and names
#
YUDIT_VENDOR_VERSION	= 1
YUDIT_VERSION		= 2.7.8
YUDIT			= yudit-$(YUDIT_VERSION)
YUDIT_SUFFIX		= tar.bz2
YUDIT_URL		= http://yudit.org/download/$(YUDIT).$(YUDIT_SUFFIX)
YUDIT_SOURCE		= $(SRCDIR)/$(YUDIT).$(YUDIT_SUFFIX)
YUDIT_DIR		= $(BUILDDIR)/$(YUDIT)
YUDIT_IPKG_TMP		= $(YUDIT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

yudit_get: $(STATEDIR)/yudit.get

yudit_get_deps = $(YUDIT_SOURCE)

$(STATEDIR)/yudit.get: $(yudit_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(YUDIT))
	touch $@

$(YUDIT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(YUDIT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

yudit_extract: $(STATEDIR)/yudit.extract

yudit_extract_deps = $(STATEDIR)/yudit.get

$(STATEDIR)/yudit.extract: $(yudit_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(YUDIT_DIR))
	@$(call extract, $(YUDIT_SOURCE))
	@$(call patchin, $(YUDIT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

yudit_prepare: $(STATEDIR)/yudit.prepare

#
# dependencies
#
yudit_prepare_deps = \
	$(STATEDIR)/yudit.extract \
	$(STATEDIR)/xchain-yudit.install \
	$(STATEDIR)/virtual-xchain.install

YUDIT_PATH	=  PATH=$(CROSS_PATH)
YUDIT_ENV 	=  $(CROSS_ENV)
#YUDIT_ENV	+=
YUDIT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#YUDIT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
YUDIT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
YUDIT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
YUDIT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/yudit.prepare: $(yudit_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(YUDIT_DIR)/config.cache)
	cd $(YUDIT_DIR) && \
		$(YUDIT_PATH) $(YUDIT_ENV) \
		./configure $(YUDIT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

yudit_compile: $(STATEDIR)/yudit.compile

yudit_compile_deps = $(STATEDIR)/yudit.prepare

$(STATEDIR)/yudit.compile: $(yudit_compile_deps)
	@$(call targetinfo, $@)
	$(YUDIT_PATH) $(MAKE) -C $(YUDIT_DIR) MYTOOL=$(XCHAIN_YUDIT_DIR)/mytool/mytool
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

yudit_install: $(STATEDIR)/yudit.install

$(STATEDIR)/yudit.install: $(STATEDIR)/yudit.compile
	@$(call targetinfo, $@)
	#$(YUDIT_PATH) $(MAKE) -C $(YUDIT_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

yudit_targetinstall: $(STATEDIR)/yudit.targetinstall

yudit_targetinstall_deps = $(STATEDIR)/yudit.compile

$(STATEDIR)/yudit.targetinstall: $(yudit_targetinstall_deps)
	@$(call targetinfo, $@)
	$(YUDIT_PATH) $(MAKE) -C $(YUDIT_DIR) DESTDIR=$(YUDIT_IPKG_TMP) install
	$(CROSSSTRIP) $(YUDIT_IPKG_TMP)/usr/bin/*
	rm -rf $(YUDIT_IPKG_TMP)/usr/man
	rm -rf $(YUDIT_IPKG_TMP)/usr/share/yudir/locale
	rm -rf $(YUDIT_IPKG_TMP)/usr/share/yudit/doc
	mkdir -p $(YUDIT_IPKG_TMP)/usr/share/{applications,pixmaps}
	cp -a $(YUDIT_DIR)/gnome-yudit.png        $(YUDIT_IPKG_TMP)/usr/share/pixmaps/
	cp -a $(TOPDIR)/config/pics/yudit.desktop $(YUDIT_IPKG_TMP)/usr/share/applications/
	mkdir -p $(YUDIT_IPKG_TMP)/CONTROL
	echo "Package: yudit" 								 >$(YUDIT_IPKG_TMP)/CONTROL/control
	echo "Source: $(YUDIT_URL)"						>>$(YUDIT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(YUDIT_IPKG_TMP)/CONTROL/control
	echo "Section: Office"	 							>>$(YUDIT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(YUDIT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(YUDIT_IPKG_TMP)/CONTROL/control
	echo "Version: $(YUDIT_VERSION)-$(YUDIT_VENDOR_VERSION)" 			>>$(YUDIT_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree" 							>>$(YUDIT_IPKG_TMP)/CONTROL/control
	echo "Description: Yudit is a free (Y)unicode text editor for all unices."	>>$(YUDIT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(YUDIT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_YUDIT_INSTALL
ROMPACKAGES += $(STATEDIR)/yudit.imageinstall
endif

yudit_imageinstall_deps = $(STATEDIR)/yudit.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/yudit.imageinstall: $(yudit_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install yudit
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

yudit_clean:
	rm -rf $(STATEDIR)/yudit.*
	rm -rf $(YUDIT_DIR)

# vim: syntax=make
