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
ifdef PTXCONF_PILOT-LINK
PACKAGES += pilot-link
endif

#
# Paths and names
#
PILOT-LINK_VENDOR_VERSION	= 1
PILOT-LINK_VERSION		= 0.12.0-pre4
PILOT-LINK			= pilot-link-$(PILOT-LINK_VERSION)
PILOT-LINK_SUFFIX		= tar.bz2
PILOT-LINK_URL			= http://www.pilot-link.org/filestore2/download/168/$(PILOT-LINK).$(PILOT-LINK_SUFFIX)
PILOT-LINK_SOURCE		= $(SRCDIR)/$(PILOT-LINK).$(PILOT-LINK_SUFFIX)
PILOT-LINK_DIR			= $(BUILDDIR)/$(PILOT-LINK)
PILOT-LINK_IPKG_TMP		= $(PILOT-LINK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pilot-link_get: $(STATEDIR)/pilot-link.get

pilot-link_get_deps = $(PILOT-LINK_SOURCE)

$(STATEDIR)/pilot-link.get: $(pilot-link_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PILOT-LINK))
	touch $@

$(PILOT-LINK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PILOT-LINK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pilot-link_extract: $(STATEDIR)/pilot-link.extract

pilot-link_extract_deps = $(STATEDIR)/pilot-link.get

$(STATEDIR)/pilot-link.extract: $(pilot-link_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PILOT-LINK_DIR))
	@$(call extract, $(PILOT-LINK_SOURCE))
	@$(call patchin, $(PILOT-LINK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pilot-link_prepare: $(STATEDIR)/pilot-link.prepare

#
# dependencies
#
pilot-link_prepare_deps = \
	$(STATEDIR)/pilot-link.extract \
	$(STATEDIR)/virtual-xchain.install

PILOT-LINK_PATH	=  PATH=$(CROSS_PATH)
PILOT-LINK_ENV 	=  $(CROSS_ENV)
PILOT-LINK_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
PILOT-LINK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PILOT-LINK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PILOT-LINK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--with-libpng=$(CROSS_LIB_DIR)

ifdef PTXCONF_XFREE430
PILOT-LINK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PILOT-LINK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pilot-link.prepare: $(pilot-link_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PILOT-LINK_DIR)/config.cache)
	cd $(PILOT-LINK_DIR) && \
		$(PILOT-LINK_PATH) $(PILOT-LINK_ENV) \
		./configure $(PILOT-LINK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pilot-link_compile: $(STATEDIR)/pilot-link.compile

pilot-link_compile_deps = $(STATEDIR)/pilot-link.prepare

$(STATEDIR)/pilot-link.compile: $(pilot-link_compile_deps)
	@$(call targetinfo, $@)
	$(PILOT-LINK_PATH) $(MAKE) -C $(PILOT-LINK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pilot-link_install: $(STATEDIR)/pilot-link.install

$(STATEDIR)/pilot-link.install: $(STATEDIR)/pilot-link.compile
	@$(call targetinfo, $@)
	rm -rf $(PILOT-LINK_IPKG_TMP)
	$(PILOT-LINK_PATH) $(MAKE) -C $(PILOT-LINK_DIR) DESTDIR=$(PILOT-LINK_IPKG_TMP) install
	cp -a $(PILOT-LINK_IPKG_TMP)/usr/include/*		$(CROSS_LIB_DIR)/include/
	cp -a $(PILOT-LINK_IPKG_TMP)/usr/lib/*			$(CROSS_LIB_DIR)/lib/
	cp -a $(PILOT-LINK_IPKG_TMP)/usr/share/aclocal/*	$(PTXCONF_PREFIX)/share/aclocal/
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" 	$(CROSS_LIB_DIR)/lib/libpisock.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" 	$(CROSS_LIB_DIR)/lib/libpisync.la
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/pilot-link.pc
	rm -rf $(PILOT-LINK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pilot-link_targetinstall: $(STATEDIR)/pilot-link.targetinstall

pilot-link_targetinstall_deps = $(STATEDIR)/pilot-link.compile

$(STATEDIR)/pilot-link.targetinstall: $(pilot-link_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(PILOT-LINK_IPKG_TMP)-libpisock
	rm -rf $(PILOT-LINK_IPKG_TMP)-libpisync
	$(PILOT-LINK_PATH) $(MAKE) -C $(PILOT-LINK_DIR) DESTDIR=$(PILOT-LINK_IPKG_TMP) install
	rm -rf $(PILOT-LINK_IPKG_TMP)/usr/include
	rm -rf $(PILOT-LINK_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(PILOT-LINK_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(PILOT-LINK_IPKG_TMP)/usr/man
	rm -rf $(PILOT-LINK_IPKG_TMP)/usr/share/aclocal
	$(CROSSSTRIP) $(PILOT-LINK_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(PILOT-LINK_IPKG_TMP)/usr/lib/*.so*
	
	mkdir -p $(PILOT-LINK_IPKG_TMP)-libpisock/CONTROL
	mkdir -p $(PILOT-LINK_IPKG_TMP)-libpisock/usr/lib
	mv $(PILOT-LINK_IPKG_TMP)/usr/lib/libpisock* $(PILOT-LINK_IPKG_TMP)-libpisock/usr/lib
	echo "Package: libpisock" 							 >$(PILOT-LINK_IPKG_TMP)-libpisock/CONTROL/control
	echo "Source: $(PILOT-LINK_URL)"						>>$(PILOT-LINK_IPKG_TMP)-libpisock/CONTROL/control
	echo "Priority: optional" 							>>$(PILOT-LINK_IPKG_TMP)-libpisock/CONTROL/control
	echo "Section: Libraries" 							>>$(PILOT-LINK_IPKG_TMP)-libpisock/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PILOT-LINK_IPKG_TMP)-libpisock/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PILOT-LINK_IPKG_TMP)-libpisock/CONTROL/control
	echo "Version: $(PILOT-LINK_VERSION)-$(PILOT-LINK_VENDOR_VERSION)" 		>>$(PILOT-LINK_IPKG_TMP)-libpisock/CONTROL/control
	echo "Depends: libpisync" 							>>$(PILOT-LINK_IPKG_TMP)-libpisock/CONTROL/control
	echo "Description: pilot-link is a suite of tools used to connect your Palm or PalmOS compatible handheld with Unix, Linux, and any other POSIX-compatible machine." >>$(PILOT-LINK_IPKG_TMP)-libpisock/CONTROL/control
	@$(call makeipkg, $(PILOT-LINK_IPKG_TMP))

	mkdir -p $(PILOT-LINK_IPKG_TMP)-libpisync/CONTROL
	mkdir -p $(PILOT-LINK_IPKG_TMP)-libpisync/usr/lib
	mv $(PILOT-LINK_IPKG_TMP)/usr/lib/libpisync* $(PILOT-LINK_IPKG_TMP)-libpisync/usr/lib
	echo "Package: libpisync" 							 >$(PILOT-LINK_IPKG_TMP)-libpisync/CONTROL/control
	echo "Source: $(PILOT-LINK_URL)"						>>$(PILOT-LINK_IPKG_TMP)-libpisync/CONTROL/control
	echo "Priority: optional" 							>>$(PILOT-LINK_IPKG_TMP)-libpisync/CONTROL/control
	echo "Section: Libraries" 							>>$(PILOT-LINK_IPKG_TMP)-libpisync/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PILOT-LINK_IPKG_TMP)-libpisync/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PILOT-LINK_IPKG_TMP)-libpisync/CONTROL/control
	echo "Version: $(PILOT-LINK_VERSION)-$(PILOT-LINK_VENDOR_VERSION)" 		>>$(PILOT-LINK_IPKG_TMP)-libpisync/CONTROL/control
	echo "Depends: libpisock"	 						>>$(PILOT-LINK_IPKG_TMP)-libpisync/CONTROL/control
	echo "Description: pilot-link is a suite of tools used to connect your Palm or PalmOS compatible handheld with Unix, Linux, and any other POSIX-compatible machine." >>$(PILOT-LINK_IPKG_TMP)-libpisync/CONTROL/control
	@$(call makeipkg, $(PILOT-LINK_IPKG_TMP))
	
	mkdir -p $(PILOT-LINK_IPKG_TMP)/CONTROL
	echo "Package: pilot-link" 							 >$(PILOT-LINK_IPKG_TMP)/CONTROL/control
	echo "Source: $(PILOT-LINK_URL)"						>>$(PILOT-LINK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PILOT-LINK_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(PILOT-LINK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PILOT-LINK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PILOT-LINK_IPKG_TMP)/CONTROL/control
	echo "Version: $(PILOT-LINK_VERSION)-$(PILOT-LINK_VENDOR_VERSION)" 		>>$(PILOT-LINK_IPKG_TMP)/CONTROL/control
	echo "Depends: libpisock, libpisync" 						>>$(PILOT-LINK_IPKG_TMP)/CONTROL/control
	echo "Description: pilot-link is a suite of tools used to connect your Palm or PalmOS compatible handheld with Unix, Linux, and any other POSIX-compatible machine." >>$(PILOT-LINK_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(PILOT-LINK_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PILOT-LINK_INSTALL
ROMPACKAGES += $(STATEDIR)/pilot-link.imageinstall
endif

pilot-link_imageinstall_deps = $(STATEDIR)/pilot-link.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pilot-link.imageinstall: $(pilot-link_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pilot-link
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pilot-link_clean:
	rm -rf $(STATEDIR)/pilot-link.*
	rm -rf $(PILOT-LINK_DIR)

# vim: syntax=make
