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
ifdef PTXCONF_GOFFICE
PACKAGES += goffice
endif

#
# Paths and names
#
GOFFICE_VENDOR_VERSION	= 1
#GOFFICE_VERSION		= 0.2.1
GOFFICE_VERSION		= 0.3.0
GOFFICE			= goffice-$(GOFFICE_VERSION)
GOFFICE_SUFFIX		= tar.bz2
GOFFICE_URL		= http://ftp.acc.umu.se/pub/GNOME/sources/goffice/0.3/$(GOFFICE).$(GOFFICE_SUFFIX)
GOFFICE_SOURCE		= $(SRCDIR)/$(GOFFICE).$(GOFFICE_SUFFIX)
GOFFICE_DIR		= $(BUILDDIR)/$(GOFFICE)
GOFFICE_IPKG_TMP	= $(GOFFICE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

goffice_get: $(STATEDIR)/goffice.get

goffice_get_deps = $(GOFFICE_SOURCE)

$(STATEDIR)/goffice.get: $(goffice_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GOFFICE))
	touch $@

$(GOFFICE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GOFFICE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

goffice_extract: $(STATEDIR)/goffice.extract

goffice_extract_deps = $(STATEDIR)/goffice.get

$(STATEDIR)/goffice.extract: $(goffice_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GOFFICE_DIR))
	@$(call extract, $(GOFFICE_SOURCE))
	@$(call patchin, $(GOFFICE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

goffice_prepare: $(STATEDIR)/goffice.prepare

#
# dependencies
#
goffice_prepare_deps = \
	$(STATEDIR)/goffice.extract \
	$(STATEDIR)/virtual-xchain.install

GOFFICE_PATH	=  PATH=$(CROSS_PATH)
GOFFICE_ENV 	=  $(CROSS_ENV)
#GOFFICE_ENV	+=
GOFFICE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GOFFICE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GOFFICE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GOFFICE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GOFFICE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/goffice.prepare: $(goffice_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GOFFICE_DIR)/config.cache)
	cd $(GOFFICE_DIR) && \
		$(GOFFICE_PATH) $(GOFFICE_ENV) \
		./configure $(GOFFICE_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(GOFFICE_DIR)/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

goffice_compile: $(STATEDIR)/goffice.compile

goffice_compile_deps = $(STATEDIR)/goffice.prepare

$(STATEDIR)/goffice.compile: $(goffice_compile_deps)
	@$(call targetinfo, $@)
	$(GOFFICE_PATH) $(MAKE) -C $(GOFFICE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

goffice_install: $(STATEDIR)/goffice.install

$(STATEDIR)/goffice.install: $(STATEDIR)/goffice.compile
	@$(call targetinfo, $@)
	rm -rf $(GOFFICE_IPKG_TMP)
	$(GOFFICE_PATH) $(MAKE) -C $(GOFFICE_DIR) DESTDIR=$(GOFFICE_IPKG_TMP) install

	rm -rf $(GOFFICE_IPKG_TMP)/usr/lib/goffice

	cp -a $(GOFFICE_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(GOFFICE_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib/

	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" 	$(CROSS_LIB_DIR)/lib/libgoffice-0.la
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/libgoffice-0.3.pc

	rm -rf $(GOFFICE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

goffice_targetinstall: $(STATEDIR)/goffice.targetinstall

goffice_targetinstall_deps = $(STATEDIR)/goffice.compile

$(STATEDIR)/goffice.targetinstall: $(goffice_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GOFFICE_PATH) $(MAKE) -C $(GOFFICE_DIR) DESTDIR=$(GOFFICE_IPKG_TMP) install
	rm -rf $(GOFFICE_IPKG_TMP)/usr/include
	rm -rf $(GOFFICE_IPKG_TMP)/usr/share/locale
	rm -rf $(GOFFICE_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(GOFFICE_IPKG_TMP)/usr/lib/pkgconfig
	for FILE in `find $(GOFFICE_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done	
	mkdir -p $(GOFFICE_IPKG_TMP)/CONTROL
	echo "Package: goffice" 							 >$(GOFFICE_IPKG_TMP)/CONTROL/control
	echo "Source: $(GOFFICE_URL)"						>>$(GOFFICE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GOFFICE_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(GOFFICE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GOFFICE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GOFFICE_IPKG_TMP)/CONTROL/control
	echo "Version: $(GOFFICE_VERSION)-$(GOFFICE_VENDOR_VERSION)" 			>>$(GOFFICE_IPKG_TMP)/CONTROL/control
	echo "Depends: glib2, libgsf, gtk2, libglade, libgnomeprint, libart-lgpl, libxml2" 	>>$(GOFFICE_IPKG_TMP)/CONTROL/control
	echo "Description: GNOME Office library"					>>$(GOFFICE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(GOFFICE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GOFFICE_INSTALL
ROMPACKAGES += $(STATEDIR)/goffice.imageinstall
endif

goffice_imageinstall_deps = $(STATEDIR)/goffice.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/goffice.imageinstall: $(goffice_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install goffice
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

goffice_clean:
	rm -rf $(STATEDIR)/goffice.*
	rm -rf $(GOFFICE_DIR)

# vim: syntax=make
