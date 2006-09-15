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
ifdef PTXCONF_M17N-LIB
PACKAGES += m17n-lib
endif

#
# Paths and names
#
M17N-LIB_VENDOR_VERSION	= 1
M17N-LIB_VERSION	= 1.2.0
M17N-LIB		= m17n-lib-$(M17N-LIB_VERSION)
M17N-LIB_SUFFIX		= tar.gz
M17N-LIB_URL		= http://www.m17n.org/m17n-lib/download/$(M17N-LIB).$(M17N-LIB_SUFFIX)
M17N-LIB_SOURCE		= $(SRCDIR)/$(M17N-LIB).$(M17N-LIB_SUFFIX)
M17N-LIB_DIR		= $(BUILDDIR)/$(M17N-LIB)
M17N-LIB_IPKG_TMP	= $(M17N-LIB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

m17n-lib_get: $(STATEDIR)/m17n-lib.get

m17n-lib_get_deps = $(M17N-LIB_SOURCE)

$(STATEDIR)/m17n-lib.get: $(m17n-lib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(M17N-LIB))
	touch $@

$(M17N-LIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(M17N-LIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

m17n-lib_extract: $(STATEDIR)/m17n-lib.extract

m17n-lib_extract_deps = $(STATEDIR)/m17n-lib.get

$(STATEDIR)/m17n-lib.extract: $(m17n-lib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(M17N-LIB_DIR))
	@$(call extract, $(M17N-LIB_SOURCE))
	@$(call patchin, $(M17N-LIB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

m17n-lib_prepare: $(STATEDIR)/m17n-lib.prepare

#
# dependencies
#
m17n-lib_prepare_deps = \
	$(STATEDIR)/m17n-lib.extract \
	$(STATEDIR)/virtual-xchain.install

M17N-LIB_PATH	=  PATH=$(CROSS_PATH)
M17N-LIB_ENV 	=  $(CROSS_ENV)
#M17N-LIB_ENV	+=
M17N-LIB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#M17N-LIB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
M17N-LIB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
M17N-LIB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
M17N-LIB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/m17n-lib.prepare: $(m17n-lib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(M17N-LIB_DIR)/config.cache)
	cd $(M17N-LIB_DIR) && \
		$(M17N-LIB_PATH) $(M17N-LIB_ENV) \
		./configure $(M17N-LIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

m17n-lib_compile: $(STATEDIR)/m17n-lib.compile

m17n-lib_compile_deps = $(STATEDIR)/m17n-lib.prepare

$(STATEDIR)/m17n-lib.compile: $(m17n-lib_compile_deps)
	@$(call targetinfo, $@)
	$(M17N-LIB_PATH) $(MAKE) -C $(M17N-LIB_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

m17n-lib_install: $(STATEDIR)/m17n-lib.install

$(STATEDIR)/m17n-lib.install: $(STATEDIR)/m17n-lib.compile
	@$(call targetinfo, $@)
	rm -rf $(M17N-LIB_IPKG_TMP)
	$(M17N-LIB_PATH) $(MAKE) -C $(M17N-LIB_DIR) DESTDIR=$(M17N-LIB_IPKG_TMP) install

	cp -a $(M17N-LIB_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(M17N-LIB_IPKG_TMP)/usr/lib/*		$(CROSS_LIB_DIR)/lib/
	
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libm17n-X.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libm17n-core.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libm17n-gd.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libm17n-gui.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libm17n.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libmimx-anthy.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libmimx-ispell.la

	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/m17n-core.pc
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/m17n-gui.pc
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/m17n-shell.pc

	rm -rf $(M17N-LIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

m17n-lib_targetinstall: $(STATEDIR)/m17n-lib.targetinstall

m17n-lib_targetinstall_deps = $(STATEDIR)/m17n-lib.compile

###	$(STATEDIR)/m17n-db.targetinstall

$(STATEDIR)/m17n-lib.targetinstall: $(m17n-lib_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(M17N-LIB_IPKG_TMP)
	$(M17N-LIB_PATH) $(MAKE) -C $(M17N-LIB_DIR) DESTDIR=$(M17N-LIB_IPKG_TMP) install
	rm -f $(M17N-LIB_IPKG_TMP)/usr/bin/m17n-config
	rm -rf $(M17N-LIB_IPKG_TMP)/usr/include
	rm -rf $(M17N-LIB_IPKG_TMP)/usr/lib/*.la
	rm -rf $(M17N-LIB_IPKG_TMP)/usr/lib/pkgconfig
	$(CROSSSTRIP) $(M17N-LIB_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(M17N-LIB_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(M17N-LIB_IPKG_TMP)/CONTROL
	echo "Package: m17n-lib" 							 >$(M17N-LIB_IPKG_TMP)/CONTROL/control
	echo "Source: $(M17N-LIB_URL)"						>>$(M17N-LIB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(M17N-LIB_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(M17N-LIB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(M17N-LIB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(M17N-LIB_IPKG_TMP)/CONTROL/control
	echo "Version: $(M17N-LIB_VERSION)-$(M17N-LIB_VENDOR_VERSION)" 			>>$(M17N-LIB_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree, libxml2"		 					>>$(M17N-LIB_IPKG_TMP)/CONTROL/control
	echo "Description: m17n is the abbreviation of multilingualization  which is coined from multi-lingual." >>$(M17N-LIB_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(M17N-LIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_M17N-LIB_INSTALL
ROMPACKAGES += $(STATEDIR)/m17n-lib.imageinstall
endif

m17n-lib_imageinstall_deps = $(STATEDIR)/m17n-lib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/m17n-lib.imageinstall: $(m17n-lib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install m17n-lib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

m17n-lib_clean:
	rm -rf $(STATEDIR)/m17n-lib.*
	rm -rf $(M17N-LIB_DIR)

# vim: syntax=make
