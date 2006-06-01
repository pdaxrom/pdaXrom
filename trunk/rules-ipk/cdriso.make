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
ifdef PTXCONF_CDRISO
PACKAGES += cdriso
endif

#
# Paths and names
#
CDRISO_VENDOR_VERSION	= 1
CDRISO_VERSION		= 1.4
CDRISO			= cdriso-$(CDRISO_VERSION)
CDRISO_SUFFIX		= tgz
CDRISO_URL		= http://www.pdaXrom.org/src/$(CDRISO).$(CDRISO_SUFFIX)
CDRISO_SOURCE		= $(SRCDIR)/$(CDRISO).$(CDRISO_SUFFIX)
CDRISO_DIR		= $(BUILDDIR)/cdriso
CDRISO_IPKG_TMP		= $(CDRISO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

cdriso_get: $(STATEDIR)/cdriso.get

cdriso_get_deps = $(CDRISO_SOURCE)

$(STATEDIR)/cdriso.get: $(cdriso_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CDRISO))
	touch $@

$(CDRISO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CDRISO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

cdriso_extract: $(STATEDIR)/cdriso.extract

cdriso_extract_deps = $(STATEDIR)/cdriso.get

$(STATEDIR)/cdriso.extract: $(cdriso_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(CDRISO_DIR))
	@$(call extract, $(CDRISO_SOURCE))
	@$(call patchin, $(CDRISO), $(CDRISO_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

cdriso_prepare: $(STATEDIR)/cdriso.prepare

#
# dependencies
#
cdriso_prepare_deps = \
	$(STATEDIR)/cdriso.extract \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/ubzip2.install \
	$(STATEDIR)/gtk1210.install \
	$(STATEDIR)/virtual-xchain.install

CDRISO_PATH	=  PATH=$(CROSS_PATH)
CDRISO_ENV 	=  $(CROSS_ENV)
#CDRISO_ENV	+=
CDRISO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CDRISO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
CDRISO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
CDRISO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CDRISO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/cdriso.prepare: $(cdriso_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CDRISO_DIR)/config.cache)
	#cd $(CDRISO_DIR) && \
	#	$(CDRISO_PATH) $(CDRISO_ENV) \
	#	./configure $(CDRISO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

cdriso_compile: $(STATEDIR)/cdriso.compile

cdriso_compile_deps = $(STATEDIR)/cdriso.prepare

$(STATEDIR)/cdriso.compile: $(cdriso_compile_deps)
	@$(call targetinfo, $@)
	$(CDRISO_PATH) $(MAKE) -C $(CDRISO_DIR)/src/Linux $(CROSS_ENV_CC) $(CROSS_ENV_STRIP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

cdriso_install: $(STATEDIR)/cdriso.install

$(STATEDIR)/cdriso.install: $(STATEDIR)/cdriso.compile
	@$(call targetinfo, $@)
	###$(CDRISO_PATH) $(MAKE) -C $(CDRISO_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

cdriso_targetinstall: $(STATEDIR)/cdriso.targetinstall

cdriso_targetinstall_deps = $(STATEDIR)/cdriso.compile \
	$(STATEDIR)/zlib.targetinstall \
	$(STATEDIR)/ubzip2.targetinstall \
	$(STATEDIR)/gtk1210.targetinstall

$(STATEDIR)/cdriso.targetinstall: $(cdriso_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(CDRISO_PATH) $(MAKE) -C $(CDRISO_DIR) DESTDIR=$(CDRISO_IPKG_TMP) install
	mkdir -p $(CDRISO_IPKG_TMP)/usr/share/pcsx/Plugin
	cp -a $(CDRISO_DIR)/src/Linux/libcdriso-1.4.so	$(CDRISO_IPKG_TMP)/usr/share/pcsx/Plugin
	cp -a $(CDRISO_DIR)/src/Linux/cfgCdrIso		$(CDRISO_IPKG_TMP)/usr/share/pcsx
	$(CROSSSTRIP) $(CDRISO_IPKG_TMP)/usr/share/pcsx/Plugin/*
	$(CROSSSTRIP) $(CDRISO_IPKG_TMP)/usr/share/pcsx/cfgCdrIso
	mkdir -p $(CDRISO_IPKG_TMP)/CONTROL
	echo "Package: cdriso" 								 >$(CDRISO_IPKG_TMP)/CONTROL/control
	echo "Source: $(CDRISO_URL)"							>>$(CDRISO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(CDRISO_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(CDRISO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(CDRISO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(CDRISO_IPKG_TMP)/CONTROL/control
	echo "Version: $(CDRISO_VERSION)-$(CDRISO_VENDOR_VERSION)" 			>>$(CDRISO_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk, libz, bzip2" 						>>$(CDRISO_IPKG_TMP)/CONTROL/control
	echo "Description: cdriso plugin"						>>$(CDRISO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(CDRISO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CDRISO_INSTALL
ROMPACKAGES += $(STATEDIR)/cdriso.imageinstall
endif

cdriso_imageinstall_deps = $(STATEDIR)/cdriso.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/cdriso.imageinstall: $(cdriso_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install cdriso
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

cdriso_clean:
	rm -rf $(STATEDIR)/cdriso.*
	rm -rf $(CDRISO_DIR)

# vim: syntax=make
