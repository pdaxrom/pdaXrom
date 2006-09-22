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
ifdef PTXCONF_LIBTHEORA
PACKAGES += libtheora
endif

#
# Paths and names
#
LIBTHEORA_VENDOR_VERSION	= 1
LIBTHEORA_VERSION		= 1.0alpha7
LIBTHEORA			= libtheora-$(LIBTHEORA_VERSION)
LIBTHEORA_SUFFIX		= tar.bz2
LIBTHEORA_URL			= http://downloads.xiph.org/releases/theora/$(LIBTHEORA).$(LIBTHEORA_SUFFIX)
LIBTHEORA_SOURCE		= $(SRCDIR)/$(LIBTHEORA).$(LIBTHEORA_SUFFIX)
LIBTHEORA_DIR			= $(BUILDDIR)/$(LIBTHEORA)
LIBTHEORA_IPKG_TMP		= $(LIBTHEORA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libtheora_get: $(STATEDIR)/libtheora.get

libtheora_get_deps = $(LIBTHEORA_SOURCE)

$(STATEDIR)/libtheora.get: $(libtheora_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBTHEORA))
	touch $@

$(LIBTHEORA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBTHEORA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libtheora_extract: $(STATEDIR)/libtheora.extract

libtheora_extract_deps = $(STATEDIR)/libtheora.get

$(STATEDIR)/libtheora.extract: $(libtheora_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBTHEORA_DIR))
	@$(call extract, $(LIBTHEORA_SOURCE))
	@$(call patchin, $(LIBTHEORA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libtheora_prepare: $(STATEDIR)/libtheora.prepare

#
# dependencies
#
libtheora_prepare_deps = \
	$(STATEDIR)/libtheora.extract \
	$(STATEDIR)/libvorbis.install \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/virtual-xchain.install

LIBTHEORA_PATH	=  PATH=$(CROSS_PATH)
LIBTHEORA_ENV 	=  $(CROSS_ENV)
#LIBTHEORA_ENV	+=
LIBTHEORA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBTHEORA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBTHEORA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_ARCH_ARM
LIBTHEORA_AUTOCONF += --disable-float
endif

ifdef PTXCONF_XFREE430
LIBTHEORA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBTHEORA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libtheora.prepare: $(libtheora_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBTHEORA_DIR)/config.cache)
	cd $(LIBTHEORA_DIR) && \
		$(LIBTHEORA_PATH) $(LIBTHEORA_ENV) \
		./configure $(LIBTHEORA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libtheora_compile: $(STATEDIR)/libtheora.compile

libtheora_compile_deps = $(STATEDIR)/libtheora.prepare

$(STATEDIR)/libtheora.compile: $(libtheora_compile_deps)
	@$(call targetinfo, $@)
	$(LIBTHEORA_PATH) $(MAKE) -C $(LIBTHEORA_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libtheora_install: $(STATEDIR)/libtheora.install

$(STATEDIR)/libtheora.install: $(STATEDIR)/libtheora.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBTHEORA_IPKG_TMP)
	$(LIBTHEORA_PATH) $(MAKE) -C $(LIBTHEORA_DIR) DESTDIR=$(LIBTHEORA_IPKG_TMP) install
	@$(call copyincludes, $(LIBTHEORA_IPKG_TMP))
	@$(call copylibraries,$(LIBTHEORA_IPKG_TMP))
	@$(call copymiscfiles,$(LIBTHEORA_IPKG_TMP))
	rm -rf $(LIBTHEORA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libtheora_targetinstall: $(STATEDIR)/libtheora.targetinstall

libtheora_targetinstall_deps = $(STATEDIR)/libtheora.compile \
	$(STATEDIR)/libvorbis.targetinstall \
	$(STATEDIR)/SDL.targetinstall

LIBTHEORA_DEPLIST = 

$(STATEDIR)/libtheora.targetinstall: $(libtheora_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBTHEORA_PATH) $(MAKE) -C $(LIBTHEORA_DIR) DESTDIR=$(LIBTHEORA_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LIBTHEORA_VERSION)-$(LIBTHEORA_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh libtheora $(LIBTHEORA_IPKG_TMP)

	@$(call removedevfiles, $(LIBTHEORA_IPKG_TMP))
	@$(call stripfiles, $(LIBTHEORA_IPKG_TMP))
	mkdir -p $(LIBTHEORA_IPKG_TMP)/CONTROL
	echo "Package: libtheora" 							 >$(LIBTHEORA_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBTHEORA_URL)"							>>$(LIBTHEORA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBTHEORA_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LIBTHEORA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBTHEORA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBTHEORA_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBTHEORA_VERSION)-$(LIBTHEORA_VENDOR_VERSION)" 		>>$(LIBTHEORA_IPKG_TMP)/CONTROL/control
	echo "Depends: $(LIBTHEORA_DEPLIST)" 						>>$(LIBTHEORA_IPKG_TMP)/CONTROL/control
	echo "Description: Theora is an open video codec being developed by the Xiph.org" >>$(LIBTHEORA_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBTHEORA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBTHEORA_INSTALL
ROMPACKAGES += $(STATEDIR)/libtheora.imageinstall
endif

libtheora_imageinstall_deps = $(STATEDIR)/libtheora.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libtheora.imageinstall: $(libtheora_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libtheora
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libtheora_clean:
	rm -rf $(STATEDIR)/libtheora.*
	rm -rf $(LIBTHEORA_DIR)

# vim: syntax=make
