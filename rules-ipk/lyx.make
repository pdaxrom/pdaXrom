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
ifdef PTXCONF_LYX
PACKAGES += lyx
endif

#
# Paths and names
#
LYX_VENDOR_VERSION	= 1
LYX_VERSION		= 1.3.5
LYX			= lyx-$(LYX_VERSION)
LYX_SUFFIX		= tar.bz2
LYX_URL			= ftp://ftp.lyx.org/pub/lyx/stable/$(LYX).$(LYX_SUFFIX)
LYX_SOURCE		= $(SRCDIR)/$(LYX).$(LYX_SUFFIX)
LYX_DIR			= $(BUILDDIR)/$(LYX)
LYX_IPKG_TMP		= $(LYX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lyx_get: $(STATEDIR)/lyx.get

lyx_get_deps = $(LYX_SOURCE)

$(STATEDIR)/lyx.get: $(lyx_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LYX))
	touch $@

$(LYX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LYX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lyx_extract: $(STATEDIR)/lyx.extract

lyx_extract_deps = $(STATEDIR)/lyx.get

$(STATEDIR)/lyx.extract: $(lyx_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LYX_DIR))
	@$(call extract, $(LYX_SOURCE))
	@$(call patchin, $(LYX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lyx_prepare: $(STATEDIR)/lyx.prepare

#
# dependencies
#
lyx_prepare_deps = \
	$(STATEDIR)/lyx.extract \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/virtual-xchain.install

LYX_PATH	=  PATH=$(CROSS_PATH)
LYX_ENV 	=  $(CROSS_ENV)
LYX_ENV		+= QTDIR=$(QT-X11-FREE_DIR)
LYX_ENV		+= CFLAGS="-O2 -fomit-frame-pointer"
LYX_ENV		+= CXXFLAGS="-O2 -fomit-frame-pointer"
LYX_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LYX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LYX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-frontend=qt \
	--with-qt-dir=$(QT-X11-FREE_DIR)

ifdef PTXCONF_XFREE430
LYX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LYX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/lyx.prepare: $(lyx_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LYX_DIR)/config.cache)
	cd $(LYX_DIR) && \
		$(LYX_PATH) $(LYX_ENV) \
		./configure $(LYX_AUTOCONF)
	cd $(LYX_DIR) && patch -p1 < $(TOPDIR)/config/pics/libtool-lyx.diff
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lyx_compile: $(STATEDIR)/lyx.compile

lyx_compile_deps = $(STATEDIR)/lyx.prepare

$(STATEDIR)/lyx.compile: $(lyx_compile_deps)
	@$(call targetinfo, $@)
	$(LYX_PATH) $(MAKE) -C $(LYX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lyx_install: $(STATEDIR)/lyx.install

$(STATEDIR)/lyx.install: $(STATEDIR)/lyx.compile
	@$(call targetinfo, $@)
	###$(LYX_PATH) $(MAKE) -C $(LYX_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lyx_targetinstall: $(STATEDIR)/lyx.targetinstall

lyx_targetinstall_deps = $(STATEDIR)/lyx.compile \
	$(STATEDIR)/qt-x11-free.targetinstall \
	$(STATEDIR)/startup-notification.targetinstall

$(STATEDIR)/lyx.targetinstall: $(lyx_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LYX_PATH) $(MAKE) -C $(LYX_DIR) DESTDIR=$(LYX_IPKG_TMP) install
	$(CROSSSTRIP) $(LYX_IPKG_TMP)/usr/bin/lyx
	rm -rf $(LYX_IPKG_TMP)/usr/man
	rm -rf $(LYX_IPKG_TMP)/usr/share/locale
	rm -rf $(LYX_IPKG_TMP)/usr/share/doc
	$(INSTALL) -D $(TOPDIR)/config/pics/lyx.desktop	$(LYX_IPKG_TMP)/usr/share/applications/lyx.desktop
	$(INSTALL) -D $(LYX_DIR)/lib/images/lyx.xpm 	$(LYX_IPKG_TMP)/usr/share/pixmaps/lyx.xpm
	mkdir -p $(LYX_IPKG_TMP)/CONTROL
	echo "Package: lyx" 								 >$(LYX_IPKG_TMP)/CONTROL/control
	echo "Source: $(LYX_URL)"						>>$(LYX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LYX_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(LYX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LYX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LYX_IPKG_TMP)/CONTROL/control
	echo "Version: $(LYX_VERSION)-$(LYX_VENDOR_VERSION)" 				>>$(LYX_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt" 								>>$(LYX_IPKG_TMP)/CONTROL/control
	echo "Description: The Document Processor"					>>$(LYX_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LYX_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LYX_INSTALL
ROMPACKAGES += $(STATEDIR)/lyx.imageinstall
endif

lyx_imageinstall_deps = $(STATEDIR)/lyx.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/lyx.imageinstall: $(lyx_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lyx
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lyx_clean:
	rm -rf $(STATEDIR)/lyx.*
	rm -rf $(LYX_DIR)

# vim: syntax=make
