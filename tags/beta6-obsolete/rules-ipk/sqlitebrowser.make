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
ifdef PTXCONF_SQLITEBROWSER
PACKAGES += sqlitebrowser
endif

#
# Paths and names
#
SQLITEBROWSER_VENDOR_VERSION	= 1
SQLITEBROWSER_VERSION		= 1.2.1
SQLITEBROWSER			= sqlitebrowser-$(SQLITEBROWSER_VERSION)-src
SQLITEBROWSER_SUFFIX		= tar.gz
SQLITEBROWSER_URL		= http://belnet.dl.sourceforge.net/sourceforge/sqlitebrowser/$(SQLITEBROWSER).$(SQLITEBROWSER_SUFFIX)
SQLITEBROWSER_SOURCE		= $(SRCDIR)/$(SQLITEBROWSER).$(SQLITEBROWSER_SUFFIX)
SQLITEBROWSER_DIR		= $(BUILDDIR)/sqlitebrowser
SQLITEBROWSER_IPKG_TMP		= $(SQLITEBROWSER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sqlitebrowser_get: $(STATEDIR)/sqlitebrowser.get

sqlitebrowser_get_deps = $(SQLITEBROWSER_SOURCE)

$(STATEDIR)/sqlitebrowser.get: $(sqlitebrowser_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SQLITEBROWSER))
	touch $@

$(SQLITEBROWSER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SQLITEBROWSER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sqlitebrowser_extract: $(STATEDIR)/sqlitebrowser.extract

sqlitebrowser_extract_deps = $(STATEDIR)/sqlitebrowser.get

$(STATEDIR)/sqlitebrowser.extract: $(sqlitebrowser_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(SQLITEBROWSER_DIR))
	@$(call extract, $(SQLITEBROWSER_SOURCE))
	@$(call patchin, $(SQLITEBROWSER), $(SQLITEBROWSER_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sqlitebrowser_prepare: $(STATEDIR)/sqlitebrowser.prepare

#
# dependencies
#
sqlitebrowser_prepare_deps = \
	$(STATEDIR)/sqlitebrowser.extract \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/sqlite.install \
	$(STATEDIR)/virtual-xchain.install

SQLITEBROWSER_PATH	=  PATH=$(QT-X11-FREE_DIR)/bin:$(CROSS_PATH)
SQLITEBROWSER_ENV 	=  $(CROSS_ENV)
SQLITEBROWSER_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
SQLITEBROWSER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SQLITEBROWSER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SQLITEBROWSER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
SQLITEBROWSER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SQLITEBROWSER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/sqlitebrowser.prepare: $(sqlitebrowser_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SQLITEBROWSER_DIR)/config.cache)
	cd $(SQLITEBROWSER_DIR) && \
		$(SQLITEBROWSER_PATH) $(SQLITEBROWSER_ENV) \
		qmake sqlitedbbrowser.pro
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sqlitebrowser_compile: $(STATEDIR)/sqlitebrowser.compile

sqlitebrowser_compile_deps = $(STATEDIR)/sqlitebrowser.prepare

$(STATEDIR)/sqlitebrowser.compile: $(sqlitebrowser_compile_deps)
	@$(call targetinfo, $@)
	$(SQLITEBROWSER_PATH) $(SQLITEBROWSER_ENV) $(MAKE) -C $(SQLITEBROWSER_DIR) UIC=uic
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sqlitebrowser_install: $(STATEDIR)/sqlitebrowser.install

$(STATEDIR)/sqlitebrowser.install: $(STATEDIR)/sqlitebrowser.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sqlitebrowser_targetinstall: $(STATEDIR)/sqlitebrowser.targetinstall

sqlitebrowser_targetinstall_deps = $(STATEDIR)/sqlitebrowser.compile

$(STATEDIR)/sqlitebrowser.targetinstall: $(sqlitebrowser_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(SQLITEBROWSER_PATH) $(MAKE) -C $(SQLITEBROWSER_DIR) DESTDIR=$(SQLITEBROWSER_IPKG_TMP) install
	mkdir -p $(SQLITEBROWSER_IPKG_TMP)/usr/lib/qt/bin
	cp -a $(SQLITEBROWSER_DIR)/sqlitebrowser/sqlitebrowser $(SQLITEBROWSER_IPKG_TMP)/usr/lib/qt/bin/
	$(CROSSSTRIP) $(SQLITEBROWSER_IPKG_TMP)/usr/lib/qt/bin/*
	mkdir -p $(SQLITEBROWSER_IPKG_TMP)/usr/share/{applications,pixmaps}
	cp -a $(TOPDIR)/config/pics/sqlitebrowser.desktop $(SQLITEBROWSER_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/database.png          $(SQLITEBROWSER_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(SQLITEBROWSER_IPKG_TMP)/CONTROL
	echo "Package: sqlitebrowser" 							 >$(SQLITEBROWSER_IPKG_TMP)/CONTROL/control
	echo "Source: $(SQLITEBROWSER_URL)"						>>$(SQLITEBROWSER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SQLITEBROWSER_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 								>>$(SQLITEBROWSER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SQLITEBROWSER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SQLITEBROWSER_IPKG_TMP)/CONTROL/control
	echo "Version: $(SQLITEBROWSER_VERSION)-$(SQLITEBROWSER_VENDOR_VERSION)" 	>>$(SQLITEBROWSER_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt"								>>$(SQLITEBROWSER_IPKG_TMP)/CONTROL/control
	echo "Description: SQLite Database Browser is a freeware, public domain, open source visual tool used to create, design and edit database files compatible with SQLite.">>$(SQLITEBROWSER_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(SQLITEBROWSER_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SQLITEBROWSER_INSTALL
ROMPACKAGES += $(STATEDIR)/sqlitebrowser.imageinstall
endif

sqlitebrowser_imageinstall_deps = $(STATEDIR)/sqlitebrowser.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/sqlitebrowser.imageinstall: $(sqlitebrowser_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sqlitebrowser
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sqlitebrowser_clean:
	rm -rf $(STATEDIR)/sqlitebrowser.*
	rm -rf $(SQLITEBROWSER_DIR)

# vim: syntax=make
