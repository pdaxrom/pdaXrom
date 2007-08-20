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
ifdef PTXCONF_KDEBASE
PACKAGES += kdebase
endif

#
# Paths and names
#
KDEBASE_VENDOR_VERSION	= 1
KDEBASE_VERSION		= 3.5.0
KDEBASE			= kdebase-$(KDEBASE_VERSION)
KDEBASE_SUFFIX		= tar.bz2
KDEBASE_URL		= http://ftp.chg.ru/pub/kde/stable/3.5/src/$(KDEBASE).$(KDEBASE_SUFFIX)
KDEBASE_SOURCE		= $(SRCDIR)/$(KDEBASE).$(KDEBASE_SUFFIX)
KDEBASE_DIR		= $(BUILDDIR)/$(KDEBASE)
KDEBASE_IPKG_TMP	= $(KDEBASE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

kdebase_get: $(STATEDIR)/kdebase.get

kdebase_get_deps = $(KDEBASE_SOURCE)

$(STATEDIR)/kdebase.get: $(kdebase_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KDEBASE))
	touch $@

$(KDEBASE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KDEBASE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

kdebase_extract: $(STATEDIR)/kdebase.extract

kdebase_extract_deps = $(STATEDIR)/kdebase.get

$(STATEDIR)/kdebase.extract: $(kdebase_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDEBASE_DIR))
	@$(call extract, $(KDEBASE_SOURCE))
	@$(call patchin, $(KDEBASE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

kdebase_prepare: $(STATEDIR)/kdebase.prepare

#
# dependencies
#
kdebase_prepare_deps = \
	$(STATEDIR)/kdebase.extract \
	$(STATEDIR)/xchain-kdelibs.install \
	$(STATEDIR)/kdelibs.install \
	$(STATEDIR)/libusb.install \
	$(STATEDIR)/virtual-xchain.install

KDEBASE_PATH	=  PATH=$(CROSS_PATH)
KDEBASE_ENV 	=  $(CROSS_ENV)
KDEBASE_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
KDEBASE_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
KDEBASE_ENV	+= KDEDIR=$(CROSS_LIB_DIR)
KDEBASE_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
KDEBASE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#KDEBASE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
KDEBASE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr/lib/kde \
	--with-extra-includes=$(CROSS_LIB_DIR)/include \
	--with-extra-libs=$(CROSS_LIB_DIR)/lib \
	--with-qt-dir=$(QT-X11-FREE_DIR) \
	--disable-static \
	--enable-shared \
	--disable-openpty \
	--with-ssl-dir=$(CROSS_LIB_DIR) \
	--enable-final \
	--without-gl

ifndef PTXCONF_KDELIBS-WITH-ARTS
KDEBASE_AUTOCONF += --without-arts
endif

ifdef PTXCONF_XFREE430
KDEBASE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
KDEBASE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/kdebase.prepare: $(kdebase_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDEBASE_DIR)/config.cache)
	### fix fix fix
	ln -sf $(XCHAIN_KDELIBS_DIR)/kdecore/kde-config $(PTXCONF_PREFIX)/bin/kde-config
	rm -f $(CROSS_LIB_DIR)/kde/lib/kde3/plugins/designer/*
	cp -a $(XCHAIN_KDELIBS_DIR)/kde-fake-root/lib/kde3/plugins/designer/* $(CROSS_LIB_DIR)/kde/lib/kde3/plugins/designer/
	###
	cd $(KDEBASE_DIR) && \
		$(KDEBASE_PATH) $(KDEBASE_ENV) \
		ac_cv_ssl_version="ssl_version=0090601" \
		./configure $(KDEBASE_AUTOCONF)
	cd $(KDEBASE_DIR) && patch -p1 < $(TOPDIR)/config/pics/libtool-kde.diff
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

kdebase_compile: $(STATEDIR)/kdebase.compile

kdebase_compile_deps = $(STATEDIR)/kdebase.prepare

$(STATEDIR)/kdebase.compile: $(kdebase_compile_deps)
	@$(call targetinfo, $@)
	$(KDEBASE_PATH) $(MAKE) -C $(KDEBASE_DIR)/kwin/clients/keramik embedtool CC=gcc CXX=g++ LIB_QT="-L$(XCHAIN_QT-X11-FREE_DIR)/lib -lqt-mt" all_libraries="" KDE_RPATH=""
	$(KDEBASE_PATH) $(MAKE) -C $(KDEBASE_DIR)/kdm config.ci
	$(KDEBASE_PATH) $(MAKE) -C $(KDEBASE_DIR)/kdm/kfrontend genkdmconf CC=gcc CXX=g++ LIB_X11=-lX11 X_LDFLAGS="" X_RPATH=""
	$(KDEBASE_PATH) $(MAKE) -C $(KDEBASE_DIR) includedir=$(CROSS_LIB_DIR)/kde/include
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

kdebase_install: $(STATEDIR)/kdebase.install

$(STATEDIR)/kdebase.install: $(STATEDIR)/kdebase.compile
	@$(call targetinfo, $@)
	rm -rf $(KDEBASE_IPKG_TMP)
	$(KDEBASE_PATH) $(MAKE) -C $(KDEBASE_DIR) DESTDIR=$(KDEBASE_IPKG_TMP) install
	
	asdasd
	rm -rf $(KDEBASE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

kdebase_targetinstall: $(STATEDIR)/kdebase.targetinstall

kdebase_targetinstall_deps = $(STATEDIR)/kdebase.compile \
	$(STATEDIR)/kdelibs.targetinstall

$(STATEDIR)/kdebase.targetinstall: $(kdebase_targetinstall_deps)
	@$(call targetinfo, $@)

	rm -rf $(KDEBASE_IPKG_TMP)

	$(KDEBASE_PATH) $(MAKE) -C $(KDEBASE_DIR) DESTDIR=$(KDEBASE_IPKG_TMP) install includedir=$(CROSS_LIB_DIR)/kde/include

	rm -rf $(KDEBASE_IPKG_TMP)/usr/lib/kde/include
	rm -rf $(KDEBASE_IPKG_TMP)/opt

	for FILE in `find $(KDEBASE_IPKG_TMP)/usr/lib/kde/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;		\
	    if [  "$$ZZZ" != "" ]; then				\
		$(CROSSSTRIP) $$FILE;				\
	    fi;							\
	done

	#for FILE in `find $(KDEBASE_IPKG_TMP)/$(CROSS_LIB_DIR)/kde/ -name *.la`; do	\
	#    perl -i -p -e "s,$(CROSS_LIB_DIR)/kde,/usr/lib/kde,g" $$FILE ; 	\
	#done

	#mkdir -p $(KDEBASE_IPKG_TMP)/usr/lib
	#mv -f $(KDEBASE_IPKG_TMP)/$(CROSS_LIB_DIR)/kde $(KDEBASE_IPKG_TMP)/usr/lib
	#rm -rf $(KDEBASE_IPKG_TMP)/opt

	mkdir -p $(KDEBASE_IPKG_TMP)/CONTROL
	echo "Package: kdebase" 										 >$(KDEBASE_IPKG_TMP)/CONTROL/control
	echo "Source: $(KDEBASE_URL)"										>>$(KDEBASE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(KDEBASE_IPKG_TMP)/CONTROL/control
	echo "Section: KDE"				 							>>$(KDEBASE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(KDEBASE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(KDEBASE_IPKG_TMP)/CONTROL/control
	echo "Version: $(KDEBASE_VERSION)-$(KDEBASE_VENDOR_VERSION)" 						>>$(KDEBASE_IPKG_TMP)/CONTROL/control
	echo "Depends: kdelibs" 										>>$(KDEBASE_IPKG_TMP)/CONTROL/control
	echo "Description: KDE core applications and files"							>>$(KDEBASE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(KDEBASE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_KDEBASE_INSTALL
ROMPACKAGES += $(STATEDIR)/kdebase.imageinstall
endif

kdebase_imageinstall_deps = $(STATEDIR)/kdebase.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/kdebase.imageinstall: $(kdebase_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install kdebase
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

kdebase_clean:
	rm -rf $(STATEDIR)/kdebase.*
	rm -rf $(KDEBASE_DIR)

# vim: syntax=make
