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
ifdef PTXCONF_KDELIBS
PACKAGES += kdelibs
endif

#
# Paths and names
#
KDELIBS_VENDOR_VERSION	= 1
KDELIBS_VERSION		= 3.5.0
KDELIBS			= kdelibs-$(KDELIBS_VERSION)
KDELIBS_SUFFIX		= tar.bz2
KDELIBS_URL		= http://ftp.chg.ru/pub/kde/stable/3.5/src/$(KDELIBS).$(KDELIBS_SUFFIX)
KDELIBS_SOURCE		= $(SRCDIR)/$(KDELIBS).$(KDELIBS_SUFFIX)
KDELIBS_DIR		= $(BUILDDIR)/$(KDELIBS)
KDELIBS_IPKG_TMP	= $(KDELIBS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

kdelibs_get: $(STATEDIR)/kdelibs.get

kdelibs_get_deps = $(KDELIBS_SOURCE)

$(STATEDIR)/kdelibs.get: $(kdelibs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KDELIBS))
	touch $@

$(KDELIBS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KDELIBS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

kdelibs_extract: $(STATEDIR)/kdelibs.extract

kdelibs_extract_deps = $(STATEDIR)/kdelibs.get

$(STATEDIR)/kdelibs.extract: $(kdelibs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDELIBS_DIR))
	@$(call extract, $(KDELIBS_SOURCE))
	@$(call patchin, $(KDELIBS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

kdelibs_prepare: $(STATEDIR)/kdelibs.prepare

#
# dependencies
#
kdelibs_prepare_deps = \
	$(STATEDIR)/kdelibs.extract \
	$(STATEDIR)/libxslt.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/pcre.install \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/libart_lgpl.install \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/xchain-arts.compile \
	$(STATEDIR)/xchain-kdelibs.compile \
	$(STATEDIR)/virtual-xchain.install

ifdef KDELIBS-WITH-ARTS
kdelibs_prepare_deps += $(STATEDIR)/arts.install
endif

KDELIBS_PATH	=  PATH=$(CROSS_LIB_DIR)/kde/bin:$(CROSS_PATH)
KDELIBS_ENV 	=  $(CROSS_ENV)
###KDELIBS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
###KDELIBS_ENV	+= CXXFLAGS="-O2 -fomit-frame-pointer"
KDELIBS_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
KDELIBS_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
KDELIBS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#KDELIBS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
KDELIBS_AUTOCONF = \
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
	--enable-final

ifndef PTXCONF_KDELIBS-WITH-ARTS
KDELIBS_AUTOCONF += --without-arts
endif

ifdef PTXCONF_XFREE430
KDELIBS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
KDELIBS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/kdelibs.prepare: $(kdelibs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDELIBS_DIR)/config.cache)
	###
	mkdir -p $(CROSS_LIB_DIR)/kde/bin/
	rm -f $(CROSS_LIB_DIR)/kde/bin/mcopidl
	ln -sf $(XCHAIN_ARTS_DIR)/mcopidl/mcopidl $(CROSS_LIB_DIR)/kde/bin/mcopidl
	###
	cd $(KDELIBS_DIR) && \
		$(KDELIBS_PATH) $(KDELIBS_ENV) \
		ac_cv_ssl_version="ssl_version=0090601" ./configure $(KDELIBS_AUTOCONF)
	cd $(KDELIBS_DIR) && patch -p1 < $(TOPDIR)/config/pics/libtool-kde.diff
	###perl -i -p -e "s,$(CROSS_LIB_DIR)/kde,/usr/lib/kde,g" $(KDELIBS_DIR)/kdecore/kde-config.cpp
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

kdelibs_compile: $(STATEDIR)/kdelibs.compile

kdelibs_compile_deps = $(STATEDIR)/kdelibs.prepare

$(STATEDIR)/kdelibs.compile: $(kdelibs_compile_deps)
	@$(call targetinfo, $@)
	$(KDELIBS_PATH) $(MAKE) -C $(KDELIBS_DIR) \
	    DCOPIDL=$(XCHAIN_KDELIBS_DIR)/dcop/dcopidl/dcopidl \
	    DCOPIDL2CPP=$(XCHAIN_KDELIBS_DIR)/dcop/dcopidl2cpp/dcopidl2cpp \
	    DCOPIDLNG=$(XCHAIN_KDELIBS_DIR)/dcop/dcopidlng/dcopidlng \
	    KCONFIG_COMPILER=$(XCHAIN_KDELIBS_DIR)/kdecore/kconfig_compiler/kconfig_compiler \
	    GENEMBED=$(XCHAIN_KDELIBS_DIR)/kstyles/keramik/genembed \
	    KSVGTOPNG=$(XCHAIN_KDELIBS_DIR)/pics/ksvgtopng \
	    KIMAGE_CONCAT=$(XCHAIN_KDELIBS_DIR)/pics/kimage_concat \
	    MAKEKDEWIDGETS=$(XCHAIN_KDELIBS_DIR)/kdewidgets/makekdewidgets

	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

kdelibs_install: $(STATEDIR)/kdelibs.install \
	$(STATEDIR)/xchain-kdelibs.install

$(STATEDIR)/kdelibs.install: $(STATEDIR)/kdelibs.compile
	@$(call targetinfo, $@)

	$(KDELIBS_PATH) $(MAKE) -C $(KDELIBS_DIR) install DESTDIR=$(CROSS_LIB_DIR)
	cp -a $(CROSS_LIB_DIR)/usr/lib/kde/* $(CROSS_LIB_DIR)/kde/
	rm -rf $(CROSS_LIB_DIR)/usr/lib/kde

	for FILE in `find $(CROSS_LIB_DIR)/kde/ -name *.la`; do	\
	    perl -i -p -e "s,/usr/lib/kde,$(CROSS_LIB_DIR)/kde,g" $$FILE ; 	\
	done

	rm -f $(CROSS_LIB_DIR)/kde/bin/{dcopidl,dcopidl2cpp,dcopidlng,kconfig_compiler,genembed,ksvgtopng,kimage_concat,makekdewidgets,kde-config}

	ln -sf $(XCHAIN_KDELIBS_DIR)/dcop/dcopidl/dcopidl		$(CROSS_LIB_DIR)/kde/bin/dcopidl
	ln -sf $(XCHAIN_KDELIBS_DIR)/dcop/dcopidl2cpp/dcopidl2cpp	$(CROSS_LIB_DIR)/kde/bin/dcopidl2cpp
	ln -sf $(XCHAIN_KDELIBS_DIR)/dcop/dcopidlng/dcopidlng		$(CROSS_LIB_DIR)/kde/bin/dcopidlng
	ln -sf $(XCHAIN_KDELIBS_DIR)/kdecore/kconfig_compiler/kconfig_compiler	$(CROSS_LIB_DIR)/kde/bin/kconfig_compiler
	ln -sf $(XCHAIN_KDELIBS_DIR)/kstyles/keramik/genembed		$(CROSS_LIB_DIR)/kde/bin/genembed
	ln -sf $(XCHAIN_KDELIBS_DIR)/pics/ksvgtopng			$(CROSS_LIB_DIR)/kde/bin/ksvgtopng
	ln -sf $(XCHAIN_KDELIBS_DIR)/pics/kimage_concat			$(CROSS_LIB_DIR)/kde/bin/kimage_concat
	ln -sf $(XCHAIN_KDELIBS_DIR)/kdewidgets/makekdewidgets		$(CROSS_LIB_DIR)/kde/bin/makekdewidgets
	ln -sf $(XCHAIN_KDELIBS_DIR)/kdecore/kde-config 		$(CROSS_LIB_DIR)/kde/bin/kde-config

	ln -sf $(XCHAIN_KDELIBS_DIR)/kde-fake-root/bin/meinproc		$(CROSS_LIB_DIR)/kde/bin/meinproc

	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

kdelibs_targetinstall: $(STATEDIR)/kdelibs.targetinstall

kdelibs_targetinstall_deps = $(STATEDIR)/kdelibs.compile \
	$(STATEDIR)/libxslt.targetinstall \
	$(STATEDIR)/libxml2.targetinstall \
	$(STATEDIR)/pcre.targetinstall \
	$(STATEDIR)/qt-x11-free.targetinstall \
	$(STATEDIR)/libart_lgpl.targetinstall \
	$(STATEDIR)/esound.targetinstall

ifdef KDELIBS-WITH-ARTS
kdelibs_targetinstall_deps += $(STATEDIR)/arts.targetinstall
endif

$(STATEDIR)/kdelibs.targetinstall: $(kdelibs_targetinstall_deps)
	@$(call targetinfo, $@)

	rm -rf $(KDELIBS_IPKG_TMP)

	$(KDELIBS_PATH) $(MAKE) -C $(KDELIBS_DIR) DESTDIR=$(KDELIBS_IPKG_TMP) install
	rm -rf $(KDELIBS_IPKG_TMP)/usr/lib/kde/include

	for FILE in `find $(KDELIBS_IPKG_TMP)/usr/lib/kde/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;		\
	    if [  "$$ZZZ" != "" ]; then				\
		$(CROSSSTRIP) $$FILE;				\
	    fi;							\
	done

	#for FILE in `find $(KDELIBS_IPKG_TMP)/$(CROSS_LIB_DIR)/kde/ -name *.la`; do	\
	#    perl -i -p -e "s,$(CROSS_LIB_DIR)/kde,/usr/lib/kde,g" $$FILE ; 	\
	#done
	
	#mkdir -p $(KDELIBS_IPKG_TMP)/usr/lib
	#mv -f $(KDELIBS_IPKG_TMP)/$(CROSS_LIB_DIR)/kde $(KDELIBS_IPKG_TMP)/usr/lib
	#rm -rf $(KDELIBS_IPKG_TMP)/opt
	
	mkdir -p $(KDELIBS_IPKG_TMP)/CONTROL
	echo "Package: kdelibs" 							 >$(KDELIBS_IPKG_TMP)/CONTROL/control
	echo "Source: $(KDELIBS_URL)"							>>$(KDELIBS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(KDELIBS_IPKG_TMP)/CONTROL/control
	echo "Section: KDE"	 							>>$(KDELIBS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(KDELIBS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(KDELIBS_IPKG_TMP)/CONTROL/control
	echo "Version: $(KDELIBS_VERSION)-$(KDELIBS_VENDOR_VERSION)" 			>>$(KDELIBS_IPKG_TMP)/CONTROL/control
	echo "Depends: libxml2, libxslt, qt-mt, pcre, libart-lgpl" 			>>$(KDELIBS_IPKG_TMP)/CONTROL/control
	echo "Description: KDE core libraries"						>>$(KDELIBS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(KDELIBS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_KDELIBS_INSTALL
ROMPACKAGES += $(STATEDIR)/kdelibs.imageinstall
endif

kdelibs_imageinstall_deps = $(STATEDIR)/kdelibs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/kdelibs.imageinstall: $(kdelibs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install kdelibs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

kdelibs_clean:
	rm -rf $(STATEDIR)/kdelibs.*
	rm -rf $(KDELIBS_DIR)

# vim: syntax=make
