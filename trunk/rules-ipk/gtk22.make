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
ifdef PTXCONF_GTK22
PACKAGES += gtk22
endif

#
# Paths and names
#
GTK22_VENDOR_VERSION	= 1
GTK22_VERSION		= 2.10.1
GTK22			= gtk+-$(GTK22_VERSION)
GTK22_SUFFIX		= tar.bz2
GTK22_URL		= http://ftp.gnome.org/pub/gnome/sources/gtk+/2.10/$(GTK22).$(GTK22_SUFFIX)
GTK22_SOURCE		= $(SRCDIR)/$(GTK22).$(GTK22_SUFFIX)
GTK22_DIR		= $(BUILDDIR)/$(GTK22)
GTK22_IPKG_TMP		= $(GTK22_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gtk22_get: $(STATEDIR)/gtk22.get

gtk22_get_deps = $(GTK22_SOURCE)

$(STATEDIR)/gtk22.get: $(gtk22_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GTK22))
	touch $@

$(GTK22_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GTK22_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gtk22_extract: $(STATEDIR)/gtk22.extract

gtk22_extract_deps = $(STATEDIR)/gtk22.get

$(STATEDIR)/gtk22.extract: $(gtk22_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTK22_DIR))
	@$(call extract, $(GTK22_SOURCE))
	@$(call patchin, $(GTK22))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gtk22_prepare: $(STATEDIR)/gtk22.prepare

#
# dependencies
#
gtk22_prepare_deps = \
	$(STATEDIR)/gtk22.extract \
	$(STATEDIR)/atk124.install \
	$(STATEDIR)/hicolor-icon-theme.install \
	$(STATEDIR)/virtual-xchain.install

GTK22_PATH	=  PATH=$(CROSS_PATH)
GTK22_ENV 	=  $(CROSS_ENV)
GTK22_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GTK22_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GTK22_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GTK22_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

GTK22_AUTOCONF	+= --without-libtiff
GTK22_AUTOCONF	+= --with-libjpeg
GTK22_AUTOCONF	+= --with-libpng
GTK22_AUTOCONF	+= --enable-debug=no

ifdef PTXCONF_XFREE430
GTK22_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GTK22_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

ifndef PTXCONF_CUPS
GTK22_ENV += ac_cv_path_CUPS_CONFIG=no
endif

$(STATEDIR)/gtk22.prepare: $(gtk22_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTK22_DIR)/config.cache)
	cd $(GTK22_DIR) && \
		$(GTK22_PATH) $(GTK22_ENV) \
		./configure $(GTK22_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gtk22_compile: $(STATEDIR)/gtk22.compile

gtk22_compile_deps = $(STATEDIR)/gtk22.prepare

$(STATEDIR)/gtk22.compile: $(gtk22_compile_deps)
	@$(call targetinfo, $@)
	#cc $(GTK22_DIR)/gtk/updateiconcache.c -o $(GTK22_DIR)/gtk/host-gtk-update-icon-cache \
	#    `pkg-config gtk+-2.0 --cflags` -I ../ `pkg-config gtk+-2.0 --libs` \
	#    -I$(GTK22_DIR)
	$(GTK22_PATH) $(MAKE) -C $(GTK22_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gtk22_install: $(STATEDIR)/gtk22.install

$(STATEDIR)/gtk22.install: $(STATEDIR)/gtk22.compile
	@$(call targetinfo, $@)
	rm -rf $(GTK22_IPKG_TMP)
	$(GTK22_PATH) $(MAKE) -C $(GTK22_DIR) DESTDIR=$(GTK22_IPKG_TMP) install
	@$(call copyincludes, $(GTK22_IPKG_TMP))
	@$(call copylibraries,$(GTK22_IPKG_TMP))
	@$(call copymiscfiles,$(GTK22_IPKG_TMP))
	rm -rf $(GTK22_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gtk22_targetinstall: $(STATEDIR)/gtk22.targetinstall

gtk22_targetinstall_deps = $(STATEDIR)/gtk22.compile \
	$(STATEDIR)/atk124.targetinstall \
	$(STATEDIR)/hicolor-icon-theme.targetinstall \
	$(STATEDIR)/xfree430.targetinstall


$(STATEDIR)/gtk22.targetinstall: $(gtk22_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GTK22_PATH) $(MAKE) -C $(GTK22_DIR) DESTDIR=$(GTK22_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(GTK22_VERSION)-$(GTK22_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh gtk2 $(GTK22_IPKG_TMP)

	mkdir -p $(GTK22_IPKG_TMP)/etc/gtk-2.0

	@$(call removedevfiles, $(GTK22_IPKG_TMP))
	@$(call stripfiles, $(GTK22_IPKG_TMP))
	mkdir -p $(GTK22_IPKG_TMP)/CONTROL
	echo "Package: gtk2" 								 >$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Source: $(GTK22_URL)"							>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Version: $(GTK22_VERSION)-$(GTK22_VENDOR_VERSION)" 			>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Depends: glib2, atk, pango, xfree, libjpeg, libpng, hicolor-icon-theme"	>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Description: GTK+ is a multi-platform toolkit for creating graphical user interfaces.">>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh"								 >$(GTK22_IPKG_TMP)/CONTROL/postinst
	echo "/usr/bin/gtk-query-immodules-2.0 > /etc/gtk-2.0/gtk.immodules" 		>>$(GTK22_IPKG_TMP)/CONTROL/postinst
	echo "/usr/bin/gdk-pixbuf-query-loaders > /etc/gtk-2.0/gdk-pixbuf.loaders"	>>$(GTK22_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(GTK22_IPKG_TMP)/CONTROL/postinst
	@$(call makeipkg, $(GTK22_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GTK22_INSTALL
ROMPACKAGES += $(STATEDIR)/gtk22.imageinstall
endif

gtk22_imageinstall_deps = $(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gtk22.imageinstall: $(gtk22_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gtk2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gtk22_clean:
	rm -rf $(STATEDIR)/gtk22.*
	rm -rf $(GTK22_DIR)

# vim: syntax=make
