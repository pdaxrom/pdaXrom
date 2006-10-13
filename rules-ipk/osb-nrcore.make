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
ifdef PTXCONF_OSB-NRCORE
PACKAGES += osb-nrcore
endif

#
# Paths and names
#
OSB-NRCORE_VENDOR_VERSION	= 1
OSB-NRCORE_VERSION		= cvs-27122005
OSB-NRCORE			= osb-nrcore-$(OSB-NRCORE_VERSION)
OSB-NRCORE_SUFFIX		= tar.bz2
OSB-NRCORE_URL			= http://citkit.dl.sourceforge.net/sourceforge/gtk-webcore/$(OSB-NRCORE).$(OSB-NRCORE_SUFFIX)
OSB-NRCORE_SOURCE		= $(SRCDIR)/$(OSB-NRCORE).$(OSB-NRCORE_SUFFIX)
OSB-NRCORE_DIR			= $(BUILDDIR)/NRCore
OSB-NRCORE_IPKG_TMP		= $(OSB-NRCORE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

osb-nrcore_get: $(STATEDIR)/osb-nrcore.get

osb-nrcore_get_deps = $(OSB-NRCORE_SOURCE)

$(STATEDIR)/osb-nrcore.get: $(osb-nrcore_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OSB-NRCORE))
	touch $@

$(OSB-NRCORE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OSB-NRCORE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

osb-nrcore_extract: $(STATEDIR)/osb-nrcore.extract

osb-nrcore_extract_deps = $(STATEDIR)/osb-nrcore.get

$(STATEDIR)/osb-nrcore.extract: $(osb-nrcore_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OSB-NRCORE_DIR))
	@$(call extract, $(OSB-NRCORE_SOURCE))
	@$(call patchin, $(OSB-NRCORE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

osb-nrcore_prepare: $(STATEDIR)/osb-nrcore.prepare

#
# dependencies
#
osb-nrcore_prepare_deps = \
	$(STATEDIR)/osb-nrcore.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/curl.install \
	$(STATEDIR)/osb-jscore.install \
	$(STATEDIR)/virtual-xchain.install

OSB-NRCORE_PATH	=  PATH=$(CROSS_PATH)
OSB-NRCORE_ENV 	=  $(CROSS_ENV)
#OSB-NRCORE_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
#OSB-NRCORE_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
OSB-NRCORE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OSB-NRCORE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
OSB-NRCORE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
OSB-NRCORE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OSB-NRCORE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/osb-nrcore.prepare: $(osb-nrcore_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OSB-NRCORE_DIR)/config.cache)
	cd $(OSB-NRCORE_DIR) && \
		$(OSB-NRCORE_PATH) $(OSB-NRCORE_ENV) \
		./autogen.sh
	cd $(OSB-NRCORE_DIR) && \
		$(OSB-NRCORE_PATH) $(OSB-NRCORE_ENV) \
		./configure $(OSB-NRCORE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

osb-nrcore_compile: $(STATEDIR)/osb-nrcore.compile

osb-nrcore_compile_deps = $(STATEDIR)/osb-nrcore.prepare

$(STATEDIR)/osb-nrcore.compile: $(osb-nrcore_compile_deps)
	@$(call targetinfo, $@)
	$(OSB-NRCORE_PATH) $(MAKE) -C $(OSB-NRCORE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

osb-nrcore_install: $(STATEDIR)/osb-nrcore.install

$(STATEDIR)/osb-nrcore.install: $(STATEDIR)/osb-nrcore.compile
	@$(call targetinfo, $@)
	rm -rf $(OSB-NRCORE_IPKG_TMP)
	$(OSB-NRCORE_PATH) $(MAKE) -C $(OSB-NRCORE_DIR) DESTDIR=$(OSB-NRCORE_IPKG_TMP) install install_sh=install
	cp -a $(OSB-NRCORE_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(OSB-NRCORE_IPKG_TMP)/usr/lib/*		$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libnrcore.la
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" 	$(CROSS_LIB_DIR)/lib/pkgconfig/osb-nrcore.pc
	rm -rf $(OSB-NRCORE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

osb-nrcore_targetinstall: $(STATEDIR)/osb-nrcore.targetinstall

osb-nrcore_targetinstall_deps = $(STATEDIR)/osb-nrcore.compile \
	$(STATEDIR)/osb-jscore.targetinstall

$(STATEDIR)/osb-nrcore.targetinstall: $(osb-nrcore_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OSB-NRCORE_PATH) $(MAKE) -C $(OSB-NRCORE_DIR) DESTDIR=$(OSB-NRCORE_IPKG_TMP) install install_sh=install
	rm -rf $(OSB-NRCORE_IPKG_TMP)/usr/include
	rm -rf $(OSB-NRCORE_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(OSB-NRCORE_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(OSB-NRCORE_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(OSB-NRCORE_IPKG_TMP)/CONTROL
	echo "Package: osb-nrcore" 								 >$(OSB-NRCORE_IPKG_TMP)/CONTROL/control
	echo "Source: $(OSB-NRCORE_URL)"							>>$(OSB-NRCORE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(OSB-NRCORE_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 								>>$(OSB-NRCORE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(OSB-NRCORE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(OSB-NRCORE_IPKG_TMP)/CONTROL/control
	echo "Version: $(OSB-NRCORE_VERSION)-$(OSB-NRCORE_VENDOR_VERSION)" 			>>$(OSB-NRCORE_IPKG_TMP)/CONTROL/control
	echo "Depends: osb-jscore" 								>>$(OSB-NRCORE_IPKG_TMP)/CONTROL/control
	echo "Description: OSB HTML Rendering engine"						>>$(OSB-NRCORE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(OSB-NRCORE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OSB-NRCORE_INSTALL
ROMPACKAGES += $(STATEDIR)/osb-nrcore.imageinstall
endif

osb-nrcore_imageinstall_deps = $(STATEDIR)/osb-nrcore.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/osb-nrcore.imageinstall: $(osb-nrcore_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install osb-nrcore
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

osb-nrcore_clean:
	rm -rf $(STATEDIR)/osb-nrcore.*
	rm -rf $(OSB-NRCORE_DIR)

# vim: syntax=make
