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
ifdef PTXCONF_OSB-JSCORE
PACKAGES += osb-jscore
endif

#
# Paths and names
#
OSB-JSCORE_VENDOR_VERSION	= 1
OSB-JSCORE_VERSION		= cvs-27122005
OSB-JSCORE			= osb-jscore-$(OSB-JSCORE_VERSION)
OSB-JSCORE_SUFFIX		= tar.bz2
OSB-JSCORE_URL			= http://citkit.dl.sourceforge.net/sourceforge/gtk-webcore/$(OSB-JSCORE).$(OSB-JSCORE_SUFFIX)
OSB-JSCORE_SOURCE		= $(SRCDIR)/$(OSB-JSCORE).$(OSB-JSCORE_SUFFIX)
OSB-JSCORE_DIR			= $(BUILDDIR)/JavaScriptCore
OSB-JSCORE_IPKG_TMP		= $(OSB-JSCORE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

osb-jscore_get: $(STATEDIR)/osb-jscore.get

osb-jscore_get_deps = $(OSB-JSCORE_SOURCE)

$(STATEDIR)/osb-jscore.get: $(osb-jscore_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OSB-JSCORE))
	touch $@

$(OSB-JSCORE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OSB-JSCORE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

osb-jscore_extract: $(STATEDIR)/osb-jscore.extract

osb-jscore_extract_deps = $(STATEDIR)/osb-jscore.get

$(STATEDIR)/osb-jscore.extract: $(osb-jscore_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OSB-JSCORE_DIR))
	@$(call extract, $(OSB-JSCORE_SOURCE))
	@$(call patchin, $(OSB-JSCORE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

osb-jscore_prepare: $(STATEDIR)/osb-jscore.prepare

#
# dependencies
#
osb-jscore_prepare_deps = \
	$(STATEDIR)/osb-jscore.extract \
	$(STATEDIR)/virtual-xchain.install

OSB-JSCORE_PATH	=  PATH=$(CROSS_PATH)
OSB-JSCORE_ENV 	=  $(CROSS_ENV)
#OSB-JSCORE_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
#OSB-JSCORE_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
OSB-JSCORE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OSB-JSCORE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
OSB-JSCORE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
OSB-JSCORE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OSB-JSCORE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/osb-jscore.prepare: $(osb-jscore_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OSB-JSCORE_DIR)/config.cache)
	cd $(OSB-JSCORE_DIR) && \
		$(OSB-JSCORE_PATH) $(OSB-JSCORE_ENV) \
		./autogen.sh
	cd $(OSB-JSCORE_DIR) && \
		$(OSB-JSCORE_PATH) $(OSB-JSCORE_ENV) \
		./configure $(OSB-JSCORE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

osb-jscore_compile: $(STATEDIR)/osb-jscore.compile

osb-jscore_compile_deps = $(STATEDIR)/osb-jscore.prepare

$(STATEDIR)/osb-jscore.compile: $(osb-jscore_compile_deps)
	@$(call targetinfo, $@)
	$(OSB-JSCORE_PATH) $(MAKE) -C $(OSB-JSCORE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

osb-jscore_install: $(STATEDIR)/osb-jscore.install

$(STATEDIR)/osb-jscore.install: $(STATEDIR)/osb-jscore.compile
	@$(call targetinfo, $@)
	rm -rf $(OSB-JSCORE_IPKG_TMP)
	$(OSB-JSCORE_PATH) $(MAKE) -C $(OSB-JSCORE_DIR) DESTDIR=$(OSB-JSCORE_IPKG_TMP) install install_sh=install
	cp -a $(OSB-JSCORE_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(OSB-JSCORE_IPKG_TMP)/usr/lib/*		$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libjscore.la
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" 	$(CROSS_LIB_DIR)/lib/pkgconfig/osb-jscore.pc
	rm -rf $(OSB-JSCORE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

osb-jscore_targetinstall: $(STATEDIR)/osb-jscore.targetinstall

osb-jscore_targetinstall_deps = $(STATEDIR)/osb-jscore.compile

$(STATEDIR)/osb-jscore.targetinstall: $(osb-jscore_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OSB-JSCORE_PATH) $(MAKE) -C $(OSB-JSCORE_DIR) DESTDIR=$(OSB-JSCORE_IPKG_TMP) install install_sh=install
	rm -rf $(OSB-JSCORE_IPKG_TMP)/usr/include
	rm -rf $(OSB-JSCORE_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(OSB-JSCORE_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(OSB-JSCORE_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(OSB-JSCORE_IPKG_TMP)/CONTROL
	echo "Package: osb-jscore" 							 >$(OSB-JSCORE_IPKG_TMP)/CONTROL/control
	echo "Source: $(OSB-JSCORE_URL)"						>>$(OSB-JSCORE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(OSB-JSCORE_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(OSB-JSCORE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(OSB-JSCORE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(OSB-JSCORE_IPKG_TMP)/CONTROL/control
	echo "Version: $(OSB-JSCORE_VERSION)-$(OSB-JSCORE_VENDOR_VERSION)" 		>>$(OSB-JSCORE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(OSB-JSCORE_IPKG_TMP)/CONTROL/control
	echo "Description: OSB EcmaScript engine"					>>$(OSB-JSCORE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OSB-JSCORE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OSB-JSCORE_INSTALL
ROMPACKAGES += $(STATEDIR)/osb-jscore.imageinstall
endif

osb-jscore_imageinstall_deps = $(STATEDIR)/osb-jscore.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/osb-jscore.imageinstall: $(osb-jscore_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install osb-jscore
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

osb-jscore_clean:
	rm -rf $(STATEDIR)/osb-jscore.*
	rm -rf $(OSB-JSCORE_DIR)

# vim: syntax=make
