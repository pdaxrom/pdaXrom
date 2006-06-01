# -*-makefile-*-
# $Id: pango12.make,v 1.3 2003/10/23 15:01:19 mkl Exp $
#
# Copyright (C) 2003 by Robert Schwebel <r.schwebel@pengutronix.de>
#                       Pengutronix <info@pengutronix.de>, Germany
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_PANGO12
PACKAGES += pango
endif

#
# Paths and names
#
#PANGO12_VERSION_MAJOR	= 1
#PANGO12_VERSION_MINOR	= 8
#PANGO12_VERSION_MICRO	= 0

PANGO12_VERSION_MAJOR	= 1
PANGO12_VERSION_MINOR	= 10
PANGO12_VERSION_MICRO	= 0

PANGO12_VERSION		= $(PANGO12_VERSION_MAJOR).$(PANGO12_VERSION_MINOR).$(PANGO12_VERSION_MICRO)
PANGO12			= pango-$(PANGO12_VERSION)
PANGO12_SUFFIX		= tar.bz2
PANGO12_URL		= ftp://ftp.gtk.org/pub/gtk/v2.8/$(PANGO12).$(PANGO12_SUFFIX)
PANGO12_SOURCE		= $(SRCDIR)/$(PANGO12).$(PANGO12_SUFFIX)
PANGO12_DIR		= $(BUILDDIR)/$(PANGO12)
PANGO12_PATCH		= $(PANGO12)-ptx1.diff
PANGO12_PATCH_SOURCE	= $(SRCDIR)/$(PANGO12_PATCH)
PANGO12_PATCH_URL	= http://www.pengutronix.de/software/ptxdist/temporary-src/$(PANGO12_PATCH)
PANGO12_IPKG_TMP	= $(PANGO12_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pango12_get: $(STATEDIR)/pango12.get

pango12_get_deps	=  $(PANGO12_SOURCE)
#pango12_get_deps	+= $(PANGO12_PATCH_SOURCE)

$(STATEDIR)/pango12.get: $(pango12_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PANGO12))
	touch $@

$(PANGO12_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PANGO12_URL))

$(PANGO12_PATCH_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PANGO12_PATCH_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pango12_extract: $(STATEDIR)/pango12.extract

pango12_extract_deps	=  $(STATEDIR)/pango12.get

$(STATEDIR)/pango12.extract: $(pango12_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PANGO12_DIR))
	@$(call extract, $(PANGO12_SOURCE))
	@$(call patchin, $(PANGO12))
	#cd $(PANGO12_DIR) && patch -p1 < $(PANGO12_PATCH_SOURCE)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pango12_prepare: $(STATEDIR)/pango12.prepare

#
# dependencies
#
pango12_prepare_deps =  \
	$(STATEDIR)/pango12.extract \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/cairo.install \
	$(STATEDIR)/virtual-xchain.install

PANGO12_PATH	=  PATH=$(PTXCONF_PREFIX)/bin:$(CROSS_PATH)
PANGO12_ENV 	=  $(CROSS_ENV)
###PANGO12_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
PANGO12_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig

# FIXME: pango does not use pkg-config yet...
#PANGO12_ENV	+= ac_cv_path_FREETYPE_CONFIG=$(PTXCONF_PREFIX)/bin/freetype-config
#PANGO12_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib

PANGO12_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"

#
# autoconf
#
PANGO12_AUTOCONF	=  --prefix=/usr
PANGO12_AUTOCONF	+= --build=$(GNU_HOST)
PANGO12_AUTOCONF	+= --host=$(PTXCONF_GNU_TARGET)
PANGO12_AUTOCONF	+= --x-includes=$(CROSS_LIB_DIR)/include
PANGO12_AUTOCONF	+= --x-libraries=$(CROSS_LIB_DIR)/lib
PANGO12_AUTOCONF	+= --disable-debug --enable-shared --disable-static --sysconfdir=/etc

$(STATEDIR)/pango12.prepare: $(pango12_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PANGO12_BUILDDIR))
	cd $(PANGO12_DIR) && \
		$(PANGO12_PATH) $(PANGO12_ENV) \
		./configure $(PANGO12_AUTOCONF) --disable-glibtest 
	#--enable-explicit-deps=no
	#cp -f $(PTXCONF_PREFIX)/bin/libtool $(PANGO12_DIR)/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pango12_compile: $(STATEDIR)/pango12.compile

pango12_compile_deps =  $(STATEDIR)/pango12.prepare

$(STATEDIR)/pango12.compile: $(pango12_compile_deps)
	@$(call targetinfo, $@)

	$(PANGO12_PATH) $(PANGO12_ENV) $(MAKE) -C $(PANGO12_DIR)

	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pango12_install: $(STATEDIR)/pango12.install

$(STATEDIR)/pango12.install: $(STATEDIR)/pango12.compile
	@$(call targetinfo, $@)

	rm -rf $(PANGO12_IPKG_TMP)

	$(PANGO12_PATH) $(PANGO12_ENV) $(MAKE) -C $(PANGO12_DIR) install DESTDIR=$(PANGO12_IPKG_TMP)

	cp -a $(PANGO12_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(PANGO12_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib/
	
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libpango-1.0.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libpangocairo-1.0.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libpangoft2-1.0.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libpangox-1.0.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libpangoxft-1.0.la
	
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/pango.pc
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/pangocairo.pc
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/pangoft2.pc
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/pangox.pc
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/pangoxft.pc
	
	rm -rf $(CROSS_LIB_DIR)/lib/pango

	rm -rf $(PANGO12_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pango12_targetinstall: $(STATEDIR)/pango12.targetinstall

pango12_targetinstall_deps	=  \
	$(STATEDIR)/pango12.compile \
	$(STATEDIR)/glib22.targetinstall \
	$(STATEDIR)/libpng125.targetinstall \
	$(STATEDIR)/zlib.targetinstall \
	$(STATEDIR)/jpeg.targetinstall \
	$(STATEDIR)/cairo.targetinstall \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/pango12.targetinstall: $(pango12_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PANGO12_PATH) $(PANGO12_ENV) $(MAKE) -C $(PANGO12_DIR) install DESTDIR=$(PANGO12_IPKG_TMP)
	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(PANGO12_VERSION) 					\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh pango $(PANGO12_IPKG_TMP)
	$(CROSSSTRIP) $(PANGO12_IPKG_TMP)/usr/bin/pango-querymodules
	mkdir -p $(PANGO12_IPKG_TMP)/etc/pango
	$(INSTALL) -m 644 $(PANGO12_DIR)/examples/pangox.aliases $(PANGO12_IPKG_TMP)/etc/pango/
	rm -rf $(PANGO12_IPKG_TMP)/usr/include
	rm -rf $(PANGO12_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(PANGO12_IPKG_TMP)/usr/lib/*.a $(PANGO12_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(PANGO12_IPKG_TMP)/usr/lib/*.so*
	rm -rf $(PANGO12_IPKG_TMP)/usr/lib/pango/1.4.0/modules/*.a
	rm -rf $(PANGO12_IPKG_TMP)/usr/lib/pango/1.4.0/modules/*.la
	$(CROSSSTRIP) $(PANGO12_IPKG_TMP)/usr/lib/pango/1.4.0/modules/*.so
	rm -rf $(PANGO12_IPKG_TMP)/usr/man
	rm -rf $(PANGO12_IPKG_TMP)/usr/share/gtk-doc
	mkdir -p $(PANGO12_IPKG_TMP)/CONTROL
	echo "Package: pango" 				 >$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Source: $(PANGO12_URL)"						>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 			>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Version: $(PANGO12_VERSION)" 		>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Depends: glib2, xfree, cairo" 		>>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "Description: Pango is a library for layout and rendering of text, with an emphasis on internationalization.">>$(PANGO12_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh"						 >$(PANGO12_IPKG_TMP)/CONTROL/postinst
	echo "/usr/bin/pango-querymodules > /etc/pango/pango.modules" 	>>$(PANGO12_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(PANGO12_IPKG_TMP)/CONTROL/postinst
	cd $(FEEDDIR) && $(XMKIPKG) $(PANGO12_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pango12_clean:
	rm -rf $(STATEDIR)/pango12.*
	rm -rf $(PANGO12_DIR)
	rm -f $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/share/pkg-config/pango*

# vim: syntax=make
