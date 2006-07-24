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
ifdef PTXCONF_MOTO4LIN
PACKAGES += moto4lin
endif

#
# Paths and names
#
MOTO4LIN_VENDOR_VERSION	= 1
MOTO4LIN_VERSION	= 0.3
MOTO4LIN		= moto4lin-$(MOTO4LIN_VERSION)
MOTO4LIN_SUFFIX		= tar.bz2
MOTO4LIN_URL		= http://citkit.dl.sourceforge.net/sourceforge/moto4lin/$(MOTO4LIN).$(MOTO4LIN_SUFFIX)
MOTO4LIN_SOURCE		= $(SRCDIR)/$(MOTO4LIN).$(MOTO4LIN_SUFFIX)
MOTO4LIN_DIR		= $(BUILDDIR)/$(MOTO4LIN)
MOTO4LIN_IPKG_TMP	= $(MOTO4LIN_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

moto4lin_get: $(STATEDIR)/moto4lin.get

moto4lin_get_deps = $(MOTO4LIN_SOURCE)

$(STATEDIR)/moto4lin.get: $(moto4lin_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MOTO4LIN))
	touch $@

$(MOTO4LIN_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MOTO4LIN_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

moto4lin_extract: $(STATEDIR)/moto4lin.extract

moto4lin_extract_deps = $(STATEDIR)/moto4lin.get

$(STATEDIR)/moto4lin.extract: $(moto4lin_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MOTO4LIN_DIR))
	@$(call extract, $(MOTO4LIN_SOURCE))
	@$(call patchin, $(MOTO4LIN))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

moto4lin_prepare: $(STATEDIR)/moto4lin.prepare

#
# dependencies
#
moto4lin_prepare_deps = \
	$(STATEDIR)/moto4lin.extract \
	$(STATEDIR)/libusb.install \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/virtual-xchain.install

MOTO4LIN_PATH	=  PATH=$(QT-X11-FREE_DIR)/bin:$(CROSS_PATH)
MOTO4LIN_ENV 	=  $(CROSS_ENV)
MOTO4LIN_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
MOTO4LIN_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MOTO4LIN_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MOTO4LIN_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MOTO4LIN_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MOTO4LIN_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/moto4lin.prepare: $(moto4lin_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MOTO4LIN_DIR)/config.cache)
	cd $(MOTO4LIN_DIR) && \
		$(MOTO4LIN_PATH) $(MOTO4LIN_ENV) \
		qmake
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

moto4lin_compile: $(STATEDIR)/moto4lin.compile

moto4lin_compile_deps = $(STATEDIR)/moto4lin.prepare

$(STATEDIR)/moto4lin.compile: $(moto4lin_compile_deps)
	@$(call targetinfo, $@)
	$(MOTO4LIN_PATH) $(MOTO4LIN_ENV) $(MAKE) -C $(MOTO4LIN_DIR) UIC=uic
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

moto4lin_install: $(STATEDIR)/moto4lin.install

$(STATEDIR)/moto4lin.install: $(STATEDIR)/moto4lin.compile
	@$(call targetinfo, $@)
	asad
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

moto4lin_targetinstall: $(STATEDIR)/moto4lin.targetinstall

moto4lin_targetinstall_deps = $(STATEDIR)/moto4lin.compile \
	$(STATEDIR)/qt-x11-free.targetinstall \
	$(STATEDIR)/libusb.targetinstall


$(STATEDIR)/moto4lin.targetinstall: $(moto4lin_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(MOTO4LIN_PATH) $(MAKE) -C $(MOTO4LIN_DIR) DESTDIR=$(MOTO4LIN_IPKG_TMP) install
	$(INSTALL) -D $(MOTO4LIN_DIR)/moto_ui/moto4lin		$(MOTO4LIN_IPKG_TMP)/usr/bin/moto4lin
	$(INSTALL) -m 644 -D $(TOPDIR)/config/pics/moto4lin.desktop	$(MOTO4LIN_IPKG_TMP)/usr/share/applications/moto4lin.desktop
	$(INSTALL) -m 644 -D $(TOPDIR)/config/pics/motorola.png		$(MOTO4LIN_IPKG_TMP)/usr/share/pixmaps/motorola.png
	$(CROSSSTRIP) $(MOTO4LIN_IPKG_TMP)/usr/bin/moto4lin
	mkdir -p $(MOTO4LIN_IPKG_TMP)/CONTROL
	echo "Package: moto4lin" 							 >$(MOTO4LIN_IPKG_TMP)/CONTROL/control
	echo "Source: $(MOTO4LIN_URL)"						>>$(MOTO4LIN_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MOTO4LIN_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(MOTO4LIN_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(MOTO4LIN_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MOTO4LIN_IPKG_TMP)/CONTROL/control
	echo "Version: $(MOTO4LIN_VERSION)-$(MOTO4LIN_VENDOR_VERSION)" 			>>$(MOTO4LIN_IPKG_TMP)/CONTROL/control
	echo "Depends: libusb, qt-mt" 							>>$(MOTO4LIN_IPKG_TMP)/CONTROL/control
	echo "Description: Moto4lin is file manager and seem editor for Motorola P2K phones, such as C380.">>$(MOTO4LIN_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MOTO4LIN_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MOTO4LIN_INSTALL
ROMPACKAGES += $(STATEDIR)/moto4lin.imageinstall
endif

moto4lin_imageinstall_deps = $(STATEDIR)/moto4lin.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/moto4lin.imageinstall: $(moto4lin_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install moto4lin
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

moto4lin_clean:
	rm -rf $(STATEDIR)/moto4lin.*
	rm -rf $(MOTO4LIN_DIR)

# vim: syntax=make
