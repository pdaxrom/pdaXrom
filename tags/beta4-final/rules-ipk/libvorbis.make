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
ifdef PTXCONF_LIBVORBIS
PACKAGES += libvorbis
endif

#
# Paths and names
#
LIBVORBIS_VENDOR_VERSION	= 1
LIBVORBIS_VERSION		= 1.1.2
LIBVORBIS			= libvorbis-$(LIBVORBIS_VERSION)
LIBVORBIS_SUFFIX		= tar.gz
LIBVORBIS_URL			= http://downloads.xiph.org/releases/vorbis/$(LIBVORBIS).$(LIBVORBIS_SUFFIX)
LIBVORBIS_SOURCE		= $(SRCDIR)/$(LIBVORBIS).$(LIBVORBIS_SUFFIX)
LIBVORBIS_DIR			= $(BUILDDIR)/$(LIBVORBIS)
LIBVORBIS_IPKG_TMP		= $(LIBVORBIS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libvorbis_get: $(STATEDIR)/libvorbis.get

libvorbis_get_deps = $(LIBVORBIS_SOURCE)

$(STATEDIR)/libvorbis.get: $(libvorbis_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBVORBIS))
	touch $@

$(LIBVORBIS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBVORBIS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libvorbis_extract: $(STATEDIR)/libvorbis.extract

libvorbis_extract_deps = $(STATEDIR)/libvorbis.get

$(STATEDIR)/libvorbis.extract: $(libvorbis_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBVORBIS_DIR))
	@$(call extract, $(LIBVORBIS_SOURCE))
	@$(call patchin, $(LIBVORBIS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libvorbis_prepare: $(STATEDIR)/libvorbis.prepare

#
# dependencies
#
libvorbis_prepare_deps = \
	$(STATEDIR)/libvorbis.extract \
	$(STATEDIR)/libogg.install \
	$(STATEDIR)/virtual-xchain.install

LIBVORBIS_PATH	=  PATH=$(CROSS_PATH)
LIBVORBIS_ENV 	=  $(CROSS_ENV)
#LIBVORBIS_ENV	+=
LIBVORBIS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBVORBIS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBVORBIS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LIBVORBIS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBVORBIS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libvorbis.prepare: $(libvorbis_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBVORBIS_DIR)/config.cache)
	cd $(LIBVORBIS_DIR) && \
		$(LIBVORBIS_PATH) $(LIBVORBIS_ENV) \
		./configure $(LIBVORBIS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libvorbis_compile: $(STATEDIR)/libvorbis.compile

libvorbis_compile_deps = $(STATEDIR)/libvorbis.prepare

$(STATEDIR)/libvorbis.compile: $(libvorbis_compile_deps)
	@$(call targetinfo, $@)
	$(LIBVORBIS_PATH) $(MAKE) -C $(LIBVORBIS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libvorbis_install: $(STATEDIR)/libvorbis.install

$(STATEDIR)/libvorbis.install: $(STATEDIR)/libvorbis.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBVORBIS_IPKG_TMP)
	$(LIBVORBIS_PATH) $(MAKE) -C $(LIBVORBIS_DIR) DESTDIR=$(LIBVORBIS_IPKG_TMP) install
	@$(call copyincludes, $(LIBVORBIS_IPKG_TMP))
	@$(call copylibraries,$(LIBVORBIS_IPKG_TMP))
	@$(call copymiscfiles,$(LIBVORBIS_IPKG_TMP))
	rm -rf $(LIBVORBIS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libvorbis_targetinstall: $(STATEDIR)/libvorbis.targetinstall

libvorbis_targetinstall_deps = $(STATEDIR)/libvorbis.compile \
	$(STATEDIR)/libogg.targetinstall

$(STATEDIR)/libvorbis.targetinstall: $(libvorbis_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBVORBIS_PATH) $(MAKE) -C $(LIBVORBIS_DIR) DESTDIR=$(LIBVORBIS_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LIBVORBIS_VERSION)-$(LIBVORBIS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh libvorbis $(LIBVORBIS_IPKG_TMP)

	@$(call removedevfiles, $(LIBVORBIS_IPKG_TMP))
	@$(call stripfiles, $(LIBVORBIS_IPKG_TMP))
	mkdir -p $(LIBVORBIS_IPKG_TMP)/CONTROL
	echo "Package: libvorbis" 							 >$(LIBVORBIS_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBVORBIS_URL)"							>>$(LIBVORBIS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBVORBIS_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LIBVORBIS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBVORBIS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBVORBIS_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBVORBIS_VERSION)-$(LIBVORBIS_VENDOR_VERSION)" 		>>$(LIBVORBIS_IPKG_TMP)/CONTROL/control
	echo "Depends: libogg" 								>>$(LIBVORBIS_IPKG_TMP)/CONTROL/control
	echo "Description: vorbisfile is a library that provides a convenient high-level API for decoding and basic manipulation of all Vorbis I audio streams">>$(LIBVORBIS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBVORBIS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBVORBIS_INSTALL
ROMPACKAGES += $(STATEDIR)/libvorbis.imageinstall
endif

libvorbis_imageinstall_deps = $(STATEDIR)/libvorbis.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libvorbis.imageinstall: $(libvorbis_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libvorbis
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libvorbis_clean:
	rm -rf $(STATEDIR)/libvorbis.*
	rm -rf $(LIBVORBIS_DIR)

# vim: syntax=make
