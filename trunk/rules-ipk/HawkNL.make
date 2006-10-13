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
ifdef PTXCONF_HAWKNL
PACKAGES += HawkNL
endif

#
# Paths and names
#
HAWKNL_VENDOR_VERSION	= 1
HAWKNL_VERSION		= 168
HAWKNL			= HawkNL$(HAWKNL_VERSION)src
HAWKNL_SUFFIX		= tar.gz
HAWKNL_URL		= http://www.hawksoft.com/download/files/$(HAWKNL).$(HAWKNL_SUFFIX)
HAWKNL_SOURCE		= $(SRCDIR)/$(HAWKNL).$(HAWKNL_SUFFIX)
HAWKNL_DIR		= $(BUILDDIR)/hawknl1.68
HAWKNL_IPKG_TMP		= $(HAWKNL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

HawkNL_get: $(STATEDIR)/HawkNL.get

HawkNL_get_deps = $(HAWKNL_SOURCE)

$(STATEDIR)/HawkNL.get: $(HawkNL_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(HAWKNL))
	touch $@

$(HAWKNL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(HAWKNL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

HawkNL_extract: $(STATEDIR)/HawkNL.extract

HawkNL_extract_deps = $(STATEDIR)/HawkNL.get

$(STATEDIR)/HawkNL.extract: $(HawkNL_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HAWKNL_DIR))
	@$(call extract, $(HAWKNL_SOURCE))
	@$(call patchin, $(HAWKNL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

HawkNL_prepare: $(STATEDIR)/HawkNL.prepare

#
# dependencies
#
HawkNL_prepare_deps = \
	$(STATEDIR)/HawkNL.extract \
	$(STATEDIR)/virtual-xchain.install

HAWKNL_PATH	=  PATH=$(CROSS_PATH)
HAWKNL_ENV 	=  $(CROSS_ENV)
#HAWKNL_ENV	+=
HAWKNL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#HAWKNL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
HAWKNL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
HAWKNL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
HAWKNL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/HawkNL.prepare: $(HawkNL_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HAWKNL_DIR)/config.cache)
	#cd $(HAWKNL_DIR) && \
	#	$(HAWKNL_PATH) $(HAWKNL_ENV) \
	#	./configure $(HAWKNL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

HawkNL_compile: $(STATEDIR)/HawkNL.compile

HawkNL_compile_deps = $(STATEDIR)/HawkNL.prepare

$(STATEDIR)/HawkNL.compile: $(HawkNL_compile_deps)
	@$(call targetinfo, $@)
	$(HAWKNL_PATH) $(MAKE) -C $(HAWKNL_DIR) -f makefile.linux $(CROSS_ENV_CC) AR="$(PTXCONF_GNU_TARGET)-ar rcu" $(CROSS_ENV_RANLIB) $(CROSS_ENV_STRIP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

HawkNL_install: $(STATEDIR)/HawkNL.install

$(STATEDIR)/HawkNL.install: $(STATEDIR)/HawkNL.compile
	@$(call targetinfo, $@)
	cp -a $(HAWKNL_DIR)/include/nl.h 	$(CROSS_LIB_DIR)/include/
	cp -a $(HAWKNL_DIR)/src/libNL.so.1.6.8 	$(CROSS_LIB_DIR)/lib/
	ln -sf libNL.so.1.6.8 			$(CROSS_LIB_DIR)/lib/libNL.so
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

HawkNL_targetinstall: $(STATEDIR)/HawkNL.targetinstall

HawkNL_targetinstall_deps = $(STATEDIR)/HawkNL.compile

$(STATEDIR)/HawkNL.targetinstall: $(HawkNL_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(HAWKNL_PATH) $(MAKE) -C $(HAWKNL_DIR) DESTDIR=$(HAWKNL_IPKG_TMP) install
	mkdir -p $(HAWKNL_IPKG_TMP)/usr/lib
	cp -a $(HAWKNL_DIR)/src/libNL.so.1.6.8 $(HAWKNL_IPKG_TMP)/usr/lib/
	ln -sf libNL.so.1.6.8 $(HAWKNL_IPKG_TMP)/usr/lib/libNL.so
	$(CROSSSTRIP) $(HAWKNL_IPKG_TMP)/usr/lib/libNL.so*
	mkdir -p $(HAWKNL_IPKG_TMP)/CONTROL
	echo "Package: hawknl" 								 >$(HAWKNL_IPKG_TMP)/CONTROL/control
	echo "Source: $(HAWKNL_URL)"							>>$(HAWKNL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(HAWKNL_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(HAWKNL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(HAWKNL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(HAWKNL_IPKG_TMP)/CONTROL/control
	echo "Version: $(HAWKNL_VERSION)-$(HAWKNL_VENDOR_VERSION)" 			>>$(HAWKNL_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(HAWKNL_IPKG_TMP)/CONTROL/control
	echo "Description: HawkNL is a free, open source, game oriented network API released under the GNU Library General Public License (LGPL). " >>$(HAWKNL_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(HAWKNL_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_HAWKNL_INSTALL
ROMPACKAGES += $(STATEDIR)/HawkNL.imageinstall
endif

HawkNL_imageinstall_deps = $(STATEDIR)/HawkNL.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/HawkNL.imageinstall: $(HawkNL_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install hawknl
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

HawkNL_clean:
	rm -rf $(STATEDIR)/HawkNL.*
	rm -rf $(HAWKNL_DIR)

# vim: syntax=make
