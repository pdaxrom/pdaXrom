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
ifdef PTXCONF_ARTS
PACKAGES += arts
endif

#
# Paths and names
#
ARTS_VENDOR_VERSION	= 1
ARTS_VERSION		= 1.5.0
ARTS			= arts-$(ARTS_VERSION)
ARTS_SUFFIX		= tar.bz2
ARTS_URL		= http://ftp.chg.ru/pub/kde/stable/3.4/src/$(ARTS).$(ARTS_SUFFIX)
ARTS_SOURCE		= $(SRCDIR)/$(ARTS).$(ARTS_SUFFIX)
ARTS_DIR		= $(BUILDDIR)/$(ARTS)
ARTS_IPKG_TMP		= $(ARTS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

arts_get: $(STATEDIR)/arts.get

arts_get_deps = $(ARTS_SOURCE)

$(STATEDIR)/arts.get: $(arts_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ARTS))
	touch $@

$(ARTS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ARTS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

arts_extract: $(STATEDIR)/arts.extract

arts_extract_deps = $(STATEDIR)/arts.get

$(STATEDIR)/arts.extract: $(arts_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ARTS_DIR))
	@$(call extract, $(ARTS_SOURCE))
	@$(call patchin, $(ARTS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

arts_prepare: $(STATEDIR)/arts.prepare

#
# dependencies
#
arts_prepare_deps = \
	$(STATEDIR)/arts.extract \
	$(STATEDIR)/libxslt.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/libart_lgpl.install \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/xchain-arts.compile \
	$(STATEDIR)/virtual-xchain.install

ARTS_PATH	=  PATH=$(CROSS_PATH)
ARTS_ENV 	=  $(CROSS_ENV)
ARTS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
ARTS_ENV	+= CXXFLAGS="-O2 -fomit-frame-pointer"
ARTS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ARTS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ARTS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)/kde \
	--with-extra-includes=$(CROSS_LIB_DIR)/include \
	--with-extra-libs=$(CROSS_LIB_DIR)/lib \
	--with-qt-dir=$(QT-X11-FREE_DIR) \
	--disable-static \
	--enable-shared \
	--enable-final

ifdef PTXCONF_XFREE430
ARTS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ARTS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/arts.prepare: $(arts_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ARTS_DIR)/config.cache)
	### jpeg fix
	ln -sf libjpeg.so.62.0.0 $(CROSS_LIB_DIR)/lib/libjpeg6b.so
	###
	cd $(ARTS_DIR) && \
		$(ARTS_PATH) $(ARTS_ENV) \
		./configure $(ARTS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

arts_compile: $(STATEDIR)/arts.compile

arts_compile_deps = $(STATEDIR)/arts.prepare

$(STATEDIR)/arts.compile: $(arts_compile_deps)
	@$(call targetinfo, $@)
	$(ARTS_PATH) $(MAKE) -C $(ARTS_DIR) MCOPIDL=$(XCHAIN_ARTS_DIR)/mcopidl/mcopidl
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

arts_install: $(STATEDIR)/arts.install

$(STATEDIR)/arts.install: $(STATEDIR)/arts.compile
	@$(call targetinfo, $@)

	$(ARTS_PATH) $(MAKE) -C $(ARTS_DIR) install
	rm -f $(CROSS_LIB_DIR)/kde/bin/mcopidl
	ln -sf $(XCHAIN_ARTS_DIR)/mcopidl/mcopidl $(CROSS_LIB_DIR)/kde/bin/mcopidl

ifdef XXX_KDE
	rm -rf $(ARTS_IPKG_TMP)
	$(ARTS_PATH) $(MAKE) -C $(ARTS_DIR) DESTDIR=$(ARTS_IPKG_TMP) install
	cp -a $(ARTS_IPKG_TMP)/usr/lib/kde/include/* 			$(CROSS_LIB_DIR)/include
	cp -a $(ARTS_IPKG_TMP)/usr/lib/kde/lib/*     			$(CROSS_LIB_DIR)/lib
	cp -a $(ARTS_IPKG_TMP)/usr/lib/kde/bin/artsc-config 		$(PTXCONF_PREFIX)/bin
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(PTXCONF_PREFIX)/bin/artsc-config
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libartsc.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libartscbackend.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libartsdsp.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libartsdsp_st.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libartsflow.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libartsflow_idl.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libartsgslplayobject.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libartswavplayobject.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libgmcop.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libkmedia2.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libkmedia2_idl.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libmcop.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libmcop_mt.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libqtmcop.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libsoundserver_idl.la
	perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/libx11globalcomm.la
	
	ln -sf $(XCHAIN_ARTS_DIR)/mcopidl/mcopidl $(PTXCONF_PREFIX)/bin/mcopidl
	rm -rf $(ARTS_IPKG_TMP)
endif
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

arts_targetinstall: $(STATEDIR)/arts.targetinstall

arts_targetinstall_deps = $(STATEDIR)/arts.compile

$(STATEDIR)/arts.targetinstall: $(arts_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ARTS_PATH) $(MAKE) -C $(ARTS_DIR) DESTDIR=$(ARTS_IPKG_TMP) install
	mkdir -p $(ARTS_IPKG_TMP)/CONTROL
	echo "Package: arts" 							 >$(ARTS_IPKG_TMP)/CONTROL/control
	echo "Source: $(ARTS_URL)"						>>$(ARTS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ARTS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(ARTS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(ARTS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ARTS_IPKG_TMP)/CONTROL/control
	echo "Version: $(ARTS_VERSION)-$(ARTS_VENDOR_VERSION)" 			>>$(ARTS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(ARTS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(ARTS_IPKG_TMP)/CONTROL/control
	asdasd
	@$(call makeipkg, $(ARTS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ARTS_INSTALL
ROMPACKAGES += $(STATEDIR)/arts.imageinstall
endif

arts_imageinstall_deps = $(STATEDIR)/arts.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/arts.imageinstall: $(arts_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install arts
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

arts_clean:
	rm -rf $(STATEDIR)/arts.*
	rm -rf $(ARTS_DIR)

# vim: syntax=make
