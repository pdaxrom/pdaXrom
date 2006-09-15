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
ifdef PTXCONF_KDE-PIM
PACKAGES += kde-pim
endif

#
# Paths and names
#
KDE-PIM_VENDOR_VERSION	= 1
KDE-PIM_VERSION		= 3.5.0
KDE-PIM			= kdepim-$(KDE-PIM_VERSION)
KDE-PIM_SUFFIX		= tar.bz2
KDE-PIM_URL		= http://ftp.chg.ru/pub/kde/stable/3.5/src/$(KDE-PIM).$(KDE-PIM_SUFFIX)
KDE-PIM_SOURCE		= $(SRCDIR)/$(KDE-PIM).$(KDE-PIM_SUFFIX)
KDE-PIM_DIR		= $(BUILDDIR)/$(KDE-PIM)
KDE-PIM_IPKG_TMP	= $(KDE-PIM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

kde-pim_get: $(STATEDIR)/kde-pim.get

kde-pim_get_deps = $(KDE-PIM_SOURCE)

$(STATEDIR)/kde-pim.get: $(kde-pim_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KDE-PIM))
	touch $@

$(KDE-PIM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KDE-PIM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

kde-pim_extract: $(STATEDIR)/kde-pim.extract

kde-pim_extract_deps = $(STATEDIR)/kde-pim.get

$(STATEDIR)/kde-pim.extract: $(kde-pim_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDE-PIM_DIR))
	@$(call extract, $(KDE-PIM_SOURCE))
	@$(call patchin, $(KDE-PIM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

kde-pim_prepare: $(STATEDIR)/kde-pim.prepare

#
# dependencies
#
kde-pim_prepare_deps = \
	$(STATEDIR)/kde-pim.extract \
	$(STATEDIR)/kdelibs.install \
	$(STATEDIR)/flex.install \
	$(STATEDIR)/xchain-kde-pim.compile \
	$(STATEDIR)/kdebase.prepare \
	$(STATEDIR)/virtual-xchain.install

KDE-PIM_PATH	=  PATH=$(CROSS_PATH)
KDE-PIM_ENV 	=  $(CROSS_ENV)
KDE-PIM_ENV	+= KDEDIR=$(CROSS_LIB_DIR)
KDE-PIM_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
KDE-PIM_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
KDE-PIM_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
KDE-PIM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#KDE-PIM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
KDE-PIM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr/lib/kde \
	--with-extra-includes=$(CROSS_LIB_DIR)/include \
	--with-extra-libs=$(CROSS_LIB_DIR)/lib \
	--with-qt-dir=$(QT-X11-FREE_DIR) \
	--disable-static \
	--enable-shared \
	--enable-final \
	--with-ssl-dir=$(CROSS_LIB_DIR) \
	--without-gpg \
	--without-gpgsm


ifndef PTXCONF_KDELIBS-WITH-ARTS
KDE-PIM_AUTOCONF += --without-arts
endif

ifdef PTXCONF_XFREE430
KDE-PIM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
KDE-PIM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/kde-pim.prepare: $(kde-pim_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDE-PIM_DIR)/config.cache)
	cd $(KDE-PIM_DIR) && \
		ac_cv_ssl_version="ssl_version=0090601" \
		$(KDE-PIM_PATH) $(KDE-PIM_ENV) \
		./configure $(KDE-PIM_AUTOCONF)
	cd $(KDE-PIM_DIR) && patch -p1 < $(TOPDIR)/config/pics/libtool-kde.diff
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

kde-pim_compile: $(STATEDIR)/kde-pim.compile

kde-pim_compile_deps = $(STATEDIR)/kde-pim.prepare

$(STATEDIR)/kde-pim.compile: $(kde-pim_compile_deps)
	@$(call targetinfo, $@)
	$(KDE-PIM_PATH) $(MAKE) -C $(QT-X11-FREE_DIR)/tools/designer/uilib
	$(KDE-PIM_PATH) $(MAKE) -C $(KDE-PIM_DIR) HOST_CC=gcc HOST_KXML_COMPILER=$(XCHAIN_KDE-PIM_DIR)/kode/kxml_compiler/kxml_compiler
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

kde-pim_install: $(STATEDIR)/kde-pim.install

$(STATEDIR)/kde-pim.install: $(STATEDIR)/kde-pim.compile
	@$(call targetinfo, $@)
	###$(KDE-PIM_PATH) $(MAKE) -C $(KDE-PIM_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

kde-pim_targetinstall: $(STATEDIR)/kde-pim.targetinstall

kde-pim_targetinstall_deps = $(STATEDIR)/kde-pim.compile \
	$(STATEDIR)/kdelibs.targetinstall

$(STATEDIR)/kde-pim.targetinstall: $(kde-pim_targetinstall_deps)
	@$(call targetinfo, $@)

	rm -rf $(KDE-PIM_IPKG_TMP)

	$(KDE-PIM_PATH) $(MAKE) -C $(KDE-PIM_DIR) DESTDIR=$(KDE-PIM_IPKG_TMP) install
	mv $(KDE-PIM_IPKG_TMP)/$(CROSS_LIB_DIR)/kde/lib/kde3/plugins $(KDE-PIM_IPKG_TMP)/usr/lib/kde/lib/kde3
	rm -rf $(KDE-PIM_IPKG_TMP)/opt
	rm -rf $(KDE-PIM_IPKG_TMP)/usr/lib/kde/include

	for FILE in `find $(KDE-PIM_IPKG_TMP)/usr/lib/kde/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done


	mkdir -p $(KDE-PIM_IPKG_TMP)/CONTROL
	echo "Package: kdepim" 								 >$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Source: $(KDE-PIM_URL)"							>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Section: KDE" 								>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Version: $(KDE-PIM_VERSION)-$(KDE-PIM_VENDOR_VERSION)" 			>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Depends: kdebase, libqui" 						>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Description: KDE PIM applications"					>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(KDE-PIM_IPKG_TMP)

	rm -rf $(KDE-PIM_IPKG_TMP)

	mkdir -p $(KDE-PIM_IPKG_TMP)/usr/lib/qt/lib
	cp -a $(QT-X11-FREE_DIR)/lib/libqui.so* $(KDE-PIM_IPKG_TMP)/usr/lib/qt/lib
	$(CROSSSTRIP) $(KDE-PIM_IPKG_TMP)/usr/lib/qt/lib/libqui.so*
	mkdir -p $(KDE-PIM_IPKG_TMP)/CONTROL
	echo "Package: libqui" 								 >$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Source: $(QT-X11-FREE_URL)"						>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Section: KDE" 								>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Version: $(QT-X11-FREE_VERSION)"				 		>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt" 								>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	echo "Description: UI QT library"						>>$(KDE-PIM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(KDE-PIM_IPKG_TMP)


	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_KDE-PIM_INSTALL
ROMPACKAGES += $(STATEDIR)/kde-pim.imageinstall
endif

kde-pim_imageinstall_deps = $(STATEDIR)/kde-pim.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/kde-pim.imageinstall: $(kde-pim_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install kdepim
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

kde-pim_clean:
	rm -rf $(STATEDIR)/kde-pim.*
	rm -rf $(KDE-PIM_DIR)

# vim: syntax=make
