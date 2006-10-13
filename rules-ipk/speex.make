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
ifdef PTXCONF_SPEEX
PACKAGES += speex
endif

#
# Paths and names
#
SPEEX_VENDOR_VERSION	= 1
SPEEX_VERSION		= 1.1.12
SPEEX			= speex-$(SPEEX_VERSION)
SPEEX_SUFFIX		= tar.gz
SPEEX_URL		= http://downloads.us.xiph.org/releases/speex/$(SPEEX).$(SPEEX_SUFFIX)
SPEEX_SOURCE		= $(SRCDIR)/$(SPEEX).$(SPEEX_SUFFIX)
SPEEX_DIR		= $(BUILDDIR)/$(SPEEX)
SPEEX_IPKG_TMP		= $(SPEEX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

speex_get: $(STATEDIR)/speex.get

speex_get_deps = $(SPEEX_SOURCE)

$(STATEDIR)/speex.get: $(speex_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SPEEX))
	touch $@

$(SPEEX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SPEEX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

speex_extract: $(STATEDIR)/speex.extract

speex_extract_deps = $(STATEDIR)/speex.get

$(STATEDIR)/speex.extract: $(speex_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SPEEX_DIR))
	@$(call extract, $(SPEEX_SOURCE))
	@$(call patchin, $(SPEEX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

speex_prepare: $(STATEDIR)/speex.prepare

#
# dependencies
#
speex_prepare_deps = \
	$(STATEDIR)/speex.extract \
	$(STATEDIR)/virtual-xchain.install

SPEEX_PATH	=  PATH=$(CROSS_PATH)
SPEEX_ENV 	=  $(CROSS_ENV)
#SPEEX_ENV	+=
SPEEX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SPEEX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SPEEX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--disable-ogg \
	--disable-debug

ifdef PTXCONF_ARCH_ARM
SPEEX_AUTOCONF += --enable-fixed-point
endif

ifdef PTXCONF_ARM_ARCH_PXA
SPEEX_AUTOCONF += --enable-arm5e-asm
endif

ifdef PTXCONF_ARM_ARCH_SA1100
SPEEX_AUTOCONF += --enable-arm4-asm
endif

ifdef PTXCONF_XFREE430
SPEEX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SPEEX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/speex.prepare: $(speex_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SPEEX_DIR)/config.cache)
	cd $(SPEEX_DIR) && \
		$(SPEEX_PATH) $(SPEEX_ENV) \
		./configure $(SPEEX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

speex_compile: $(STATEDIR)/speex.compile

speex_compile_deps = $(STATEDIR)/speex.prepare

$(STATEDIR)/speex.compile: $(speex_compile_deps)
	@$(call targetinfo, $@)
	$(SPEEX_PATH) $(MAKE) -C $(SPEEX_DIR)/libspeex
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

speex_install: $(STATEDIR)/speex.install

$(STATEDIR)/speex.install: $(STATEDIR)/speex.compile
	@$(call targetinfo, $@)
	rm -rf $(SPEEX_IPKG_TMP)
	$(SPEEX_PATH) $(MAKE) -C $(SPEEX_DIR)/libspeex DESTDIR=$(SPEEX_IPKG_TMP) install
	$(SPEEX_PATH) $(MAKE) -C $(SPEEX_DIR)/include  DESTDIR=$(SPEEX_IPKG_TMP) install
	#rm -rf $(SPEEX_IPKG_TMP)/usr/share/doc
	cp -a $(SPEEX_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(SPEEX_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib/
	#cp -a $(SPEEX_IPKG_TMP)/usr/share/*	$(PTXCONF_PREFIX)/share/
	cp -a $(SPEEX_DIR)/speex.pc             $(CROSS_LIB_DIR)/lib/pkgconfig/
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libspeex.la
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/speex.pc
	rm -rf $(SPEEX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

speex_targetinstall: $(STATEDIR)/speex.targetinstall

speex_targetinstall_deps = $(STATEDIR)/speex.compile

$(STATEDIR)/speex.targetinstall: $(speex_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SPEEX_PATH) $(MAKE) -C $(SPEEX_DIR)/libspeex DESTDIR=$(SPEEX_IPKG_TMP) install
	#rm -rf $(SPEEX_IPKG_TMP)/usr/share
	#rm -rf $(SPEEX_IPKG_TMP)/usr/{bin,include}
	rm -rf $(SPEEX_IPKG_TMP)/usr/lib/pkgconfig
	rm  -f $(SPEEX_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(SPEEX_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(SPEEX_IPKG_TMP)/CONTROL
	echo "Package: libspeex" 							 >$(SPEEX_IPKG_TMP)/CONTROL/control
	echo "Source: $(SPEEX_URL)"							>>$(SPEEX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SPEEX_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(SPEEX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SPEEX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SPEEX_IPKG_TMP)/CONTROL/control
	echo "Version: $(SPEEX_VERSION)-$(SPEEX_VENDOR_VERSION)" 			>>$(SPEEX_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(SPEEX_IPKG_TMP)/CONTROL/control
	echo "Description: Speex is an Open Source/Free Software patent-free audio compression format designed for speech." >>$(SPEEX_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(SPEEX_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SPEEX_INSTALL
ROMPACKAGES += $(STATEDIR)/speex.imageinstall
endif

speex_imageinstall_deps = $(STATEDIR)/speex.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/speex.imageinstall: $(speex_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libspeex
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

speex_clean:
	rm -rf $(STATEDIR)/speex.*
	rm -rf $(SPEEX_DIR)

# vim: syntax=make
