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
ifdef PTXCONF_T1LIB
PACKAGES += t1lib
endif

#
# Paths and names
#
T1LIB_VENDOR_VERSION	= 1
T1LIB_VERSION		= 5.0.2
T1LIB			= t1lib-$(T1LIB_VERSION)
T1LIB_SUFFIX		= tar.gz
T1LIB_URL		= ftp://sunsite.unc.edu/pub/linux/libs/graphics//$(T1LIB).$(T1LIB_SUFFIX)
T1LIB_SOURCE		= $(SRCDIR)/$(T1LIB).$(T1LIB_SUFFIX)
T1LIB_DIR		= $(BUILDDIR)/$(T1LIB)
T1LIB_IPKG_TMP		= $(T1LIB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

t1lib_get: $(STATEDIR)/t1lib.get

t1lib_get_deps = $(T1LIB_SOURCE)

$(STATEDIR)/t1lib.get: $(t1lib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(T1LIB))
	touch $@

$(T1LIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(T1LIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

t1lib_extract: $(STATEDIR)/t1lib.extract

t1lib_extract_deps = $(STATEDIR)/t1lib.get

$(STATEDIR)/t1lib.extract: $(t1lib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(T1LIB_DIR))
	@$(call extract, $(T1LIB_SOURCE))
	@$(call patchin, $(T1LIB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

t1lib_prepare: $(STATEDIR)/t1lib.prepare

#
# dependencies
#
t1lib_prepare_deps = \
	$(STATEDIR)/t1lib.extract \
	$(STATEDIR)/virtual-xchain.install

T1LIB_PATH	=  PATH=$(CROSS_PATH)
T1LIB_ENV 	=  $(CROSS_ENV)
T1LIB_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
T1LIB_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
T1LIB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#T1LIB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
T1LIB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
T1LIB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
T1LIB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/t1lib.prepare: $(t1lib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(T1LIB_DIR)/config.cache)
	cd $(T1LIB_DIR) && \
		$(T1LIB_PATH) $(T1LIB_ENV) \
		./configure $(T1LIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

t1lib_compile: $(STATEDIR)/t1lib.compile

t1lib_compile_deps = $(STATEDIR)/t1lib.prepare

$(STATEDIR)/t1lib.compile: $(t1lib_compile_deps)
	@$(call targetinfo, $@)
	$(T1LIB_PATH) $(MAKE) -C $(T1LIB_DIR) without_doc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

t1lib_install: $(STATEDIR)/t1lib.install

$(STATEDIR)/t1lib.install: $(STATEDIR)/t1lib.compile
	@$(call targetinfo, $@)
	rm -rf $(T1LIB_IPKG_TMP)
	$(T1LIB_PATH) $(MAKE) -C $(T1LIB_DIR) prefix=$(T1LIB_IPKG_TMP)/usr install
	cp -a $(T1LIB_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(T1LIB_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libt1.la
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libt1x.la
	rm -rf $(T1LIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

t1lib_targetinstall: $(STATEDIR)/t1lib.targetinstall

t1lib_targetinstall_deps = $(STATEDIR)/t1lib.compile

$(STATEDIR)/t1lib.targetinstall: $(t1lib_targetinstall_deps)
	@$(call targetinfo, $@)
	$(T1LIB_PATH) $(MAKE) -C $(T1LIB_DIR) prefix=$(T1LIB_IPKG_TMP)/usr install
	rm -rf $(T1LIB_IPKG_TMP)/usr/bin
	rm -rf $(T1LIB_IPKG_TMP)/usr/include
	rm -rf $(T1LIB_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(T1LIB_IPKG_TMP)/usr/share/t1lib/doc
	$(CROSSSTRIP) $(T1LIB_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(T1LIB_IPKG_TMP)/CONTROL
	echo "Package: t1lib" 											 >$(T1LIB_IPKG_TMP)/CONTROL/control
	echo "Source: $(T1LIB_URL)"						>>$(T1LIB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(T1LIB_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 											>>$(T1LIB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(T1LIB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(T1LIB_IPKG_TMP)/CONTROL/control
	echo "Version: $(T1LIB_VERSION)-$(T1LIB_VENDOR_VERSION)" 						>>$(T1LIB_IPKG_TMP)/CONTROL/control
	echo "Depends: " 											>>$(T1LIB_IPKG_TMP)/CONTROL/control
	echo "Description: Adobe Type 1 Font Rasterizing Library"						>>$(T1LIB_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(T1LIB_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_T1LIB_INSTALL
ROMPACKAGES += $(STATEDIR)/t1lib.imageinstall
endif

t1lib_imageinstall_deps = $(STATEDIR)/t1lib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/t1lib.imageinstall: $(t1lib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install t1lib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

t1lib_clean:
	rm -rf $(STATEDIR)/t1lib.*
	rm -rf $(T1LIB_DIR)

# vim: syntax=make
