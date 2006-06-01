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
ifdef PTXCONF_DIA
PACKAGES += dia
endif

#
# Paths and names
#
DIA_VENDOR_VERSION	= 1
DIA_VERSION		= 0.95-pre3
DIA			= dia-$(DIA_VERSION)
DIA_SUFFIX		= tar.bz2
DIA_URL			= ftp://ftp.gnome.org/pub/gnome/sources/dia/0.95/$(DIA).$(DIA_SUFFIX)
DIA_SOURCE		= $(SRCDIR)/$(DIA).$(DIA_SUFFIX)
DIA_DIR			= $(BUILDDIR)/$(DIA)
DIA_IPKG_TMP		= $(DIA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dia_get: $(STATEDIR)/dia.get

dia_get_deps = $(DIA_SOURCE)

$(STATEDIR)/dia.get: $(dia_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DIA))
	touch $@

$(DIA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DIA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dia_extract: $(STATEDIR)/dia.extract

dia_extract_deps = $(STATEDIR)/dia.get

$(STATEDIR)/dia.extract: $(dia_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DIA_DIR))
	@$(call extract, $(DIA_SOURCE))
	@$(call patchin, $(DIA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dia_prepare: $(STATEDIR)/dia.prepare

#
# dependencies
#
dia_prepare_deps = \
	$(STATEDIR)/dia.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/libxslt.install \
	$(STATEDIR)/virtual-xchain.install

DIA_PATH	=  PATH=$(CROSS_PATH)
DIA_ENV 	=  $(CROSS_ENV)
#DIA_ENV	+=
DIA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DIA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
DIA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--enable-db2html

ifdef PTXCONF_XFREE430
DIA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DIA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dia.prepare: $(dia_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DIA_DIR)/config.cache)
	cd $(DIA_DIR) && \
		$(DIA_PATH) $(DIA_ENV) \
		./configure $(DIA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dia_compile: $(STATEDIR)/dia.compile

dia_compile_deps = $(STATEDIR)/dia.prepare

$(STATEDIR)/dia.compile: $(dia_compile_deps)
	@$(call targetinfo, $@)
	$(DIA_PATH) $(MAKE) -C $(DIA_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dia_install: $(STATEDIR)/dia.install

$(STATEDIR)/dia.install: $(STATEDIR)/dia.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dia_targetinstall: $(STATEDIR)/dia.targetinstall

dia_targetinstall_deps = $(STATEDIR)/dia.compile

$(STATEDIR)/dia.targetinstall: $(dia_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DIA_PATH) $(MAKE) -C $(DIA_DIR) DESTDIR=$(DIA_IPKG_TMP) install
	rm -rf $(DIA_IPKG_TMP)/usr/lib/dia/*.la
	$(CROSSSTRIP) $(DIA_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(DIA_IPKG_TMP)/usr/lib/dia/*.so*
	mkdir -p $(DIA_IPKG_TMP)/CONTROL
	echo "Package: dia" 								 >$(DIA_IPKG_TMP)/CONTROL/control
	echo "Source: $(DIA_URL)"							>>$(DIA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DIA_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 								>>$(DIA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DIA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DIA_IPKG_TMP)/CONTROL/control
	echo "Version: $(DIA_VERSION)-$(DIA_VENDOR_VERSION)" 				>>$(DIA_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libxml2, expat" 						>>$(DIA_IPKG_TMP)/CONTROL/control
	echo "Description: Dia is designed to be much like the commercial Windows program 'Visio'">>$(DIA_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DIA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DIA_INSTALL
ROMPACKAGES += $(STATEDIR)/dia.imageinstall
endif

dia_imageinstall_deps = $(STATEDIR)/dia.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dia.imageinstall: $(dia_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dia
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dia_clean:
	rm -rf $(STATEDIR)/dia.*
	rm -rf $(DIA_DIR)

# vim: syntax=make
