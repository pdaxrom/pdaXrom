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
ifdef PTXCONF_OSB-NRCIT
PACKAGES += osb-nrcit
endif

#
# Paths and names
#
OSB-NRCIT_VENDOR_VERSION	= 1
OSB-NRCIT_VERSION		= cvs-27122005
OSB-NRCIT			= osb-nrcit-$(OSB-NRCIT_VERSION)
OSB-NRCIT_SUFFIX		= tar.bz2
OSB-NRCIT_URL			= http://citkit.dl.sourceforge.net/sourceforge/gtk-webcore/$(OSB-NRCIT).$(OSB-NRCIT_SUFFIX)
OSB-NRCIT_SOURCE		= $(SRCDIR)/$(OSB-NRCIT).$(OSB-NRCIT_SUFFIX)
OSB-NRCIT_DIR			= $(BUILDDIR)/NRCit
OSB-NRCIT_IPKG_TMP		= $(OSB-NRCIT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

osb-nrcit_get: $(STATEDIR)/osb-nrcit.get

osb-nrcit_get_deps = $(OSB-NRCIT_SOURCE)

$(STATEDIR)/osb-nrcit.get: $(osb-nrcit_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OSB-NRCIT))
	touch $@

$(OSB-NRCIT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OSB-NRCIT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

osb-nrcit_extract: $(STATEDIR)/osb-nrcit.extract

osb-nrcit_extract_deps = $(STATEDIR)/osb-nrcit.get

$(STATEDIR)/osb-nrcit.extract: $(osb-nrcit_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OSB-NRCIT_DIR))
	@$(call extract, $(OSB-NRCIT_SOURCE))
	@$(call patchin, $(OSB-NRCIT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

osb-nrcit_prepare: $(STATEDIR)/osb-nrcit.prepare

#
# dependencies
#
osb-nrcit_prepare_deps = \
	$(STATEDIR)/osb-nrcit.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/curl.install \
	$(STATEDIR)/osb-nrcore.install \
	$(STATEDIR)/virtual-xchain.install

OSB-NRCIT_PATH	=  PATH=$(CROSS_PATH)
OSB-NRCIT_ENV 	=  $(CROSS_ENV)
#OSB-NRCIT_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
#OSB-NRCIT_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
OSB-NRCIT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OSB-NRCIT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
OSB-NRCIT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
OSB-NRCIT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OSB-NRCIT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/osb-nrcit.prepare: $(osb-nrcit_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OSB-NRCIT_DIR)/config.cache)
	cd $(OSB-NRCIT_DIR) && \
		$(OSB-NRCIT_PATH) $(OSB-NRCIT_ENV) \
		./autogen.sh
	cd $(OSB-NRCIT_DIR) && \
		$(OSB-NRCIT_PATH) $(OSB-NRCIT_ENV) \
		./configure $(OSB-NRCIT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

osb-nrcit_compile: $(STATEDIR)/osb-nrcit.compile

osb-nrcit_compile_deps = $(STATEDIR)/osb-nrcit.prepare

$(STATEDIR)/osb-nrcit.compile: $(osb-nrcit_compile_deps)
	@$(call targetinfo, $@)
	$(OSB-NRCIT_PATH) $(MAKE) -C $(OSB-NRCIT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

osb-nrcit_install: $(STATEDIR)/osb-nrcit.install

$(STATEDIR)/osb-nrcit.install: $(STATEDIR)/osb-nrcit.compile
	@$(call targetinfo, $@)
	rm -rf $(OSB-NRCIT_IPKG_TMP)
	$(OSB-NRCIT_PATH) $(MAKE) -C $(OSB-NRCIT_DIR) DESTDIR=$(OSB-NRCIT_IPKG_TMP) install install_sh=install
	cp -a $(OSB-NRCIT_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(OSB-NRCIT_IPKG_TMP)/usr/lib/*		$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libnrcit.la
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" 	$(CROSS_LIB_DIR)/lib/pkgconfig/osb-nrcit.pc
	rm -rf $(OSB-NRCIT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

osb-nrcit_targetinstall: $(STATEDIR)/osb-nrcit.targetinstall

osb-nrcit_targetinstall_deps = $(STATEDIR)/osb-nrcit.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/curl.targetinstall \
	$(STATEDIR)/osb-nrcore.targetinstall

$(STATEDIR)/osb-nrcit.targetinstall: $(osb-nrcit_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OSB-NRCIT_PATH) $(MAKE) -C $(OSB-NRCIT_DIR) DESTDIR=$(OSB-NRCIT_IPKG_TMP) install install_sh=install
	rm -rf $(OSB-NRCIT_IPKG_TMP)/usr/include
	rm -rf $(OSB-NRCIT_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(OSB-NRCIT_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(OSB-NRCIT_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(OSB-NRCIT_IPKG_TMP)/CONTROL
	echo "Package: osb-nrcit" 								 >$(OSB-NRCIT_IPKG_TMP)/CONTROL/control
	echo "Source: $(OSB-NRCIT_URL)"								>>$(OSB-NRCIT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(OSB-NRCIT_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 								>>$(OSB-NRCIT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(OSB-NRCIT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(OSB-NRCIT_IPKG_TMP)/CONTROL/control
	echo "Version: $(OSB-NRCIT_VERSION)-$(OSB-NRCIT_VENDOR_VERSION)" 			>>$(OSB-NRCIT_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, librsvg, gnome-vfs, openssl, libcurl, osb-nrcore" 			>>$(OSB-NRCIT_IPKG_TMP)/CONTROL/control
	echo "Description: OSB HTML Rendering engine browser interface"				>>$(OSB-NRCIT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OSB-NRCIT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OSB-NRCIT_INSTALL
ROMPACKAGES += $(STATEDIR)/osb-nrcit.imageinstall
endif

osb-nrcit_imageinstall_deps = $(STATEDIR)/osb-nrcit.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/osb-nrcit.imageinstall: $(osb-nrcit_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install osb-nrcit
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

osb-nrcit_clean:
	rm -rf $(STATEDIR)/osb-nrcit.*
	rm -rf $(OSB-NRCIT_DIR)

# vim: syntax=make
