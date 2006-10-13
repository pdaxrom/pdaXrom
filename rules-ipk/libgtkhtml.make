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
ifdef PTXCONF_LIBGTKHTML
PACKAGES += libgtkhtml
endif

#
# Paths and names
#
LIBGTKHTML_VENDOR_VERSION	= 1
LIBGTKHTML_VERSION		= 2.11.0
LIBGTKHTML			= libgtkhtml-$(LIBGTKHTML_VERSION)
LIBGTKHTML_SUFFIX		= tar.bz2
LIBGTKHTML_URL			= http://ftp.gnome.org/pub/GNOME/sources/libgtkhtml/2.11/$(LIBGTKHTML).$(LIBGTKHTML_SUFFIX)
LIBGTKHTML_SOURCE		= $(SRCDIR)/$(LIBGTKHTML).$(LIBGTKHTML_SUFFIX)
LIBGTKHTML_DIR			= $(BUILDDIR)/$(LIBGTKHTML)
LIBGTKHTML_IPKG_TMP		= $(LIBGTKHTML_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libgtkhtml_get: $(STATEDIR)/libgtkhtml.get

libgtkhtml_get_deps = $(LIBGTKHTML_SOURCE)

$(STATEDIR)/libgtkhtml.get: $(libgtkhtml_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBGTKHTML))
	touch $@

$(LIBGTKHTML_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBGTKHTML_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libgtkhtml_extract: $(STATEDIR)/libgtkhtml.extract

libgtkhtml_extract_deps = $(STATEDIR)/libgtkhtml.get

$(STATEDIR)/libgtkhtml.extract: $(libgtkhtml_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGTKHTML_DIR))
	@$(call extract, $(LIBGTKHTML_SOURCE))
	@$(call patchin, $(LIBGTKHTML))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libgtkhtml_prepare: $(STATEDIR)/libgtkhtml.prepare

#
# dependencies
#
libgtkhtml_prepare_deps = \
	$(STATEDIR)/libgtkhtml.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/gnome-vfs.install \
	$(STATEDIR)/virtual-xchain.install

LIBGTKHTML_PATH	=  PATH=$(CROSS_PATH)
LIBGTKHTML_ENV 	=  $(CROSS_ENV)
#LIBGTKHTML_ENV	+=
LIBGTKHTML_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBGTKHTML_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBGTKHTML_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--disable-accessibility

ifdef PTXCONF_XFREE430
LIBGTKHTML_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBGTKHTML_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libgtkhtml.prepare: $(libgtkhtml_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGTKHTML_DIR)/config.cache)
	cd $(LIBGTKHTML_DIR) && \
		$(LIBGTKHTML_PATH) $(LIBGTKHTML_ENV) \
		./configure $(LIBGTKHTML_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libgtkhtml_compile: $(STATEDIR)/libgtkhtml.compile

libgtkhtml_compile_deps = $(STATEDIR)/libgtkhtml.prepare

$(STATEDIR)/libgtkhtml.compile: $(libgtkhtml_compile_deps)
	@$(call targetinfo, $@)
	$(LIBGTKHTML_PATH) $(MAKE) -C $(LIBGTKHTML_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libgtkhtml_install: $(STATEDIR)/libgtkhtml.install

$(STATEDIR)/libgtkhtml.install: $(STATEDIR)/libgtkhtml.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBGTKHTML_IPKG_TMP)
	$(LIBGTKHTML_PATH) $(MAKE) -C $(LIBGTKHTML_DIR) DESTDIR=$(LIBGTKHTML_IPKG_TMP) install
	cp -a $(LIBGTKHTML_IPKG_TMP)/usr/include/*		$(CROSS_LIB_DIR)/include/
	cp -a $(LIBGTKHTML_IPKG_TMP)/usr/lib/*			$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" 	$(CROSS_LIB_DIR)/lib/libgtkhtml-2.la
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/libgtkhtml-2.0.pc
	rm -rf $(LIBGTKHTML_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libgtkhtml_targetinstall: $(STATEDIR)/libgtkhtml.targetinstall

libgtkhtml_targetinstall_deps = $(STATEDIR)/libgtkhtml.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/gnome-vfs.targetinstall


$(STATEDIR)/libgtkhtml.targetinstall: $(libgtkhtml_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBGTKHTML_PATH) $(MAKE) -C $(LIBGTKHTML_DIR) DESTDIR=$(LIBGTKHTML_IPKG_TMP) install
	rm -rf $(LIBGTKHTML_IPKG_TMP)/usr/include
	rm -rf $(LIBGTKHTML_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBGTKHTML_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(LIBGTKHTML_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(LIBGTKHTML_IPKG_TMP)/CONTROL
	echo "Package: libgtkhtml" 							 >$(LIBGTKHTML_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBGTKHTML_URL)"						>>$(LIBGTKHTML_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBGTKHTML_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LIBGTKHTML_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBGTKHTML_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBGTKHTML_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBGTKHTML_VERSION)-$(LIBGTKHTML_VENDOR_VERSION)" 		>>$(LIBGTKHTML_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 								>>$(LIBGTKHTML_IPKG_TMP)/CONTROL/control
	echo "Description: GTK2 HTML support"						>>$(LIBGTKHTML_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LIBGTKHTML_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBGTKHTML_INSTALL
ROMPACKAGES += $(STATEDIR)/libgtkhtml.imageinstall
endif

libgtkhtml_imageinstall_deps = $(STATEDIR)/libgtkhtml.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libgtkhtml.imageinstall: $(libgtkhtml_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libgtkhtml
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libgtkhtml_clean:
	rm -rf $(STATEDIR)/libgtkhtml.*
	rm -rf $(LIBGTKHTML_DIR)

# vim: syntax=make
