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
ifdef PTXCONF_KDEEDU
PACKAGES += kdeedu
endif

#
# Paths and names
#
KDEEDU_VENDOR_VERSION	= 1
KDEEDU_VERSION		= 3.5.0
KDEEDU			= kdeedu-$(KDEEDU_VERSION)
KDEEDU_SUFFIX		= tar.bz2
KDEEDU_URL		= http://ftp.chg.ru/pub/kde/stable/3.5/src/$(KDEEDU).$(KDEEDU_SUFFIX)
KDEEDU_SOURCE		= $(SRCDIR)/$(KDEEDU).$(KDEEDU_SUFFIX)
KDEEDU_DIR		= $(BUILDDIR)/$(KDEEDU)
KDEEDU_IPKG_TMP		= $(KDEEDU_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

kdeedu_get: $(STATEDIR)/kdeedu.get

kdeedu_get_deps = $(KDEEDU_SOURCE)

$(STATEDIR)/kdeedu.get: $(kdeedu_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KDEEDU))
	touch $@

$(KDEEDU_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KDEEDU_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

kdeedu_extract: $(STATEDIR)/kdeedu.extract

kdeedu_extract_deps = $(STATEDIR)/kdeedu.get

$(STATEDIR)/kdeedu.extract: $(kdeedu_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDEEDU_DIR))
	@$(call extract, $(KDEEDU_SOURCE))
	@$(call patchin, $(KDEEDU))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

kdeedu_prepare: $(STATEDIR)/kdeedu.prepare

#
# dependencies
#
kdeedu_prepare_deps = \
	$(STATEDIR)/kdeedu.extract \
	$(STATEDIR)/kdelibs.install \
	$(STATEDIR)/flex.install \
	$(STATEDIR)/kdebase.prepare \
	$(STATEDIR)/virtual-xchain.install

KDEEDU_PATH	=  PATH=$(CROSS_PATH)
KDEEDU_ENV 	=  $(CROSS_ENV)
KDEEDU_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
KDEEDU_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
KDEEDU_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#KDEEDU_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
KDEEDU_AUTOCONF = \
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
	--disable-v4l2

ifndef PTXCONF_KDELIBS-WITH-ARTS
KDEEDU_AUTOCONF += --without-arts
endif

ifdef PTXCONF_XFREE430
KDEEDU_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
KDEEDU_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/kdeedu.prepare: $(kdeedu_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDEEDU_DIR)/config.cache)
	cd $(KDEEDU_DIR) && \
		$(KDEEDU_PATH) $(KDEEDU_ENV) \
		ac_cv_ssl_version="ssl_version=0090601" \
		./configure $(KDEEDU_AUTOCONF)
	cd $(KDEEDU_DIR) && patch -p1 < $(TOPDIR)/config/pics/libtool-kde.diff
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

kdeedu_compile: $(STATEDIR)/kdeedu.compile

kdeedu_compile_deps = $(STATEDIR)/kdeedu.prepare

$(STATEDIR)/kdeedu.compile: $(kdeedu_compile_deps)
	@$(call targetinfo, $@)
	$(KDEEDU_PATH) $(MAKE) -C $(KDEEDU_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

kdeedu_install: $(STATEDIR)/kdeedu.install

$(STATEDIR)/kdeedu.install: $(STATEDIR)/kdeedu.compile
	@$(call targetinfo, $@)
	###$(KDEEDU_PATH) $(MAKE) -C $(KDEEDU_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

kdeedu_targetinstall: $(STATEDIR)/kdeedu.targetinstall

kdeedu_targetinstall_deps = $(STATEDIR)/kdeedu.compile \
	$(STATEDIR)/kdelibs.targetinstall

$(STATEDIR)/kdeedu.targetinstall: $(kdeedu_targetinstall_deps)
	@$(call targetinfo, $@)
	$(KDEEDU_PATH) $(MAKE) -C $(KDEEDU_DIR) DESTDIR=$(KDEEDU_IPKG_TMP) install

	rm -rf $(KDEEDU_IPKG_TMP)/usr/lib/kde/include
	rm -rf $(KDEEDU_IPKG_TMP)/opt

	for FILE in `find $(KDEEDU_IPKG_TMP)/usr/lib/kde/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;		\
	    if [  "$$ZZZ" != "" ]; then				\
		$(CROSSSTRIP) $$FILE;				\
	    fi;							\
	done

	mkdir -p $(KDEEDU_IPKG_TMP)/CONTROL
	echo "Package: kdeedu" 								 >$(KDEEDU_IPKG_TMP)/CONTROL/control
	echo "Source: $(KDEEDU_URL)"							>>$(KDEEDU_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(KDEEDU_IPKG_TMP)/CONTROL/control
	echo "Section: KDE" 								>>$(KDEEDU_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(KDEEDU_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(KDEEDU_IPKG_TMP)/CONTROL/control
	echo "Version: $(KDEEDU_VERSION)-$(KDEEDU_VENDOR_VERSION)" 			>>$(KDEEDU_IPKG_TMP)/CONTROL/control
	echo "Depends: kdelibs" 							>>$(KDEEDU_IPKG_TMP)/CONTROL/control
	echo "Description: KDE education"						>>$(KDEEDU_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(KDEEDU_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_KDEEDU_INSTALL
ROMPACKAGES += $(STATEDIR)/kdeedu.imageinstall
endif

kdeedu_imageinstall_deps = $(STATEDIR)/kdeedu.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/kdeedu.imageinstall: $(kdeedu_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install kdeedu
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

kdeedu_clean:
	rm -rf $(STATEDIR)/kdeedu.*
	rm -rf $(KDEEDU_DIR)

# vim: syntax=make
