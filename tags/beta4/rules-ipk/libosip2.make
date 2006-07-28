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
ifdef PTXCONF_LIBOSIP2
PACKAGES += libosip2
endif

#
# Paths and names
#
LIBOSIP2_VENDOR_VERSION	= 1
LIBOSIP2_VERSION	= 2.2.2
LIBOSIP2		= libosip2-$(LIBOSIP2_VERSION)
LIBOSIP2_SUFFIX		= tar.gz
LIBOSIP2_URL		= http://www.antisip.com/download/$(LIBOSIP2).$(LIBOSIP2_SUFFIX)
LIBOSIP2_SOURCE		= $(SRCDIR)/$(LIBOSIP2).$(LIBOSIP2_SUFFIX)
LIBOSIP2_DIR		= $(BUILDDIR)/$(LIBOSIP2)
LIBOSIP2_IPKG_TMP	= $(LIBOSIP2_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libosip2_get: $(STATEDIR)/libosip2.get

libosip2_get_deps = $(LIBOSIP2_SOURCE)

$(STATEDIR)/libosip2.get: $(libosip2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBOSIP2))
	touch $@

$(LIBOSIP2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBOSIP2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libosip2_extract: $(STATEDIR)/libosip2.extract

libosip2_extract_deps = $(STATEDIR)/libosip2.get

$(STATEDIR)/libosip2.extract: $(libosip2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBOSIP2_DIR))
	@$(call extract, $(LIBOSIP2_SOURCE))
	@$(call patchin, $(LIBOSIP2))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libosip2_prepare: $(STATEDIR)/libosip2.prepare

#
# dependencies
#
libosip2_prepare_deps = \
	$(STATEDIR)/libosip2.extract \
	$(STATEDIR)/virtual-xchain.install

LIBOSIP2_PATH	=  PATH=$(CROSS_PATH)
LIBOSIP2_ENV 	=  $(CROSS_ENV)
#LIBOSIP2_ENV	+=
LIBOSIP2_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBOSIP2_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBOSIP2_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
LIBOSIP2_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBOSIP2_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libosip2.prepare: $(libosip2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBOSIP2_DIR)/config.cache)
	cd $(LIBOSIP2_DIR) && \
		$(LIBOSIP2_PATH) $(LIBOSIP2_ENV) \
		./configure $(LIBOSIP2_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libosip2_compile: $(STATEDIR)/libosip2.compile

libosip2_compile_deps = $(STATEDIR)/libosip2.prepare

$(STATEDIR)/libosip2.compile: $(libosip2_compile_deps)
	@$(call targetinfo, $@)
	$(LIBOSIP2_PATH) $(MAKE) -C $(LIBOSIP2_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libosip2_install: $(STATEDIR)/libosip2.install

$(STATEDIR)/libosip2.install: $(STATEDIR)/libosip2.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBOSIP2_IPKG_TMP)
	$(LIBOSIP2_PATH) $(MAKE) -C $(LIBOSIP2_DIR) DESTDIR=$(LIBOSIP2_IPKG_TMP) install
	cp -a $(LIBOSIP2_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(LIBOSIP2_IPKG_TMP)/usr/lib/*		$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libosip2.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libosipparser2.la
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g"         $(CROSS_LIB_DIR)/lib/pkgconfig/libosip2.pc	
	rm -rf $(LIBOSIP2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libosip2_targetinstall: $(STATEDIR)/libosip2.targetinstall

libosip2_targetinstall_deps = $(STATEDIR)/libosip2.compile

$(STATEDIR)/libosip2.targetinstall: $(libosip2_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBOSIP2_PATH) $(MAKE) -C $(LIBOSIP2_DIR) DESTDIR=$(LIBOSIP2_IPKG_TMP) install
	rm -rf $(LIBOSIP2_IPKG_TMP)/usr/{include,lib/pkgconfig,lib/*.*a}
	rm -rf $(LIBOSIP2_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(LIBOSIP2_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(LIBOSIP2_IPKG_TMP)/CONTROL
	echo "Package: libosip2" 							 >$(LIBOSIP2_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBOSIP2_URL)"							>>$(LIBOSIP2_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBOSIP2_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LIBOSIP2_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBOSIP2_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBOSIP2_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBOSIP2_VERSION)-$(LIBOSIP2_VENDOR_VERSION)" 			>>$(LIBOSIP2_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LIBOSIP2_IPKG_TMP)/CONTROL/control
	echo "Description: oSIP is an implementation of SIP."				>>$(LIBOSIP2_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBOSIP2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBOSIP2_INSTALL
ROMPACKAGES += $(STATEDIR)/libosip2.imageinstall
endif

libosip2_imageinstall_deps = $(STATEDIR)/libosip2.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libosip2.imageinstall: $(libosip2_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libosip2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libosip2_clean:
	rm -rf $(STATEDIR)/libosip2.*
	rm -rf $(LIBOSIP2_DIR)

# vim: syntax=make
