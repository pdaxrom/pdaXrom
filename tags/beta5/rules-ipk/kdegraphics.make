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
ifdef PTXCONF_KDEGRAPHICS
PACKAGES += kdegraphics
endif

#
# Paths and names
#
KDEGRAPHICS_VENDOR_VERSION	= 1
KDEGRAPHICS_VERSION		= 3.5.0
KDEGRAPHICS			= kdegraphics-$(KDEGRAPHICS_VERSION)
KDEGRAPHICS_SUFFIX		= tar.bz2
KDEGRAPHICS_URL			= http://ftp.chg.ru/pub/kde/stable/3.5/src/$(KDEGRAPHICS).$(KDEGRAPHICS_SUFFIX)
KDEGRAPHICS_SOURCE		= $(SRCDIR)/$(KDEGRAPHICS).$(KDEGRAPHICS_SUFFIX)
KDEGRAPHICS_DIR			= $(BUILDDIR)/$(KDEGRAPHICS)
KDEGRAPHICS_IPKG_TMP		= $(KDEGRAPHICS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

kdegraphics_get: $(STATEDIR)/kdegraphics.get

kdegraphics_get_deps = $(KDEGRAPHICS_SOURCE)

$(STATEDIR)/kdegraphics.get: $(kdegraphics_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KDEGRAPHICS))
	touch $@

$(KDEGRAPHICS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KDEGRAPHICS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

kdegraphics_extract: $(STATEDIR)/kdegraphics.extract

kdegraphics_extract_deps = $(STATEDIR)/kdegraphics.get

$(STATEDIR)/kdegraphics.extract: $(kdegraphics_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDEGRAPHICS_DIR))
	@$(call extract, $(KDEGRAPHICS_SOURCE))
	@$(call patchin, $(KDEGRAPHICS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

kdegraphics_prepare: $(STATEDIR)/kdegraphics.prepare

#
# dependencies
#
kdegraphics_prepare_deps = \
	$(STATEDIR)/kdegraphics.extract \
	$(STATEDIR)/kdelibs.install \
	$(STATEDIR)/flex.install \
	$(STATEDIR)/kdebase.prepare \
	$(STATEDIR)/virtual-xchain.install

KDEGRAPHICS_PATH	=  PATH=$(CROSS_PATH)
KDEGRAPHICS_ENV 	=  $(CROSS_ENV)
KDEGRAPHICS_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
KDEGRAPHICS_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
KDEGRAPHICS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#KDEGRAPHICS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
KDEGRAPHICS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr/lib/kde \
	--with-extra-includes=$(CROSS_LIB_DIR)/include \
	--with-extra-libs=$(CROSS_LIB_DIR)/lib \
	--with-qt-dir=$(QT-X11-FREE_DIR) \
	--disable-static \
	--enable-shared \
	--enable-final \
	--with-ssl-dir=$(CROSS_LIB_DIR)

ifndef PTXCONF_KDELIBS-WITH-ARTS
KDEGRAPHICS_AUTOCONF += --without-arts
endif

ifdef PTXCONF_XFREE430
KDEGRAPHICS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
KDEGRAPHICS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/kdegraphics.prepare: $(kdegraphics_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDEGRAPHICS_DIR)/config.cache)
	cd $(KDEGRAPHICS_DIR) && \
		$(KDEGRAPHICS_PATH) $(KDEGRAPHICS_ENV) \
		./configure $(KDEGRAPHICS_AUTOCONF)
	cd $(KDEGRAPHICS_DIR) && patch -p1 < $(TOPDIR)/config/pics/libtool-kde.diff
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

kdegraphics_compile: $(STATEDIR)/kdegraphics.compile

kdegraphics_compile_deps = $(STATEDIR)/kdegraphics.prepare

$(STATEDIR)/kdegraphics.compile: $(kdegraphics_compile_deps)
	@$(call targetinfo, $@)
	$(KDEGRAPHICS_PATH) $(MAKE) -C $(KDEGRAPHICS_DIR) HOST_CC=gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

kdegraphics_install: $(STATEDIR)/kdegraphics.install

$(STATEDIR)/kdegraphics.install: $(STATEDIR)/kdegraphics.compile
	@$(call targetinfo, $@)
	###$(KDEGRAPHICS_PATH) $(MAKE) -C $(KDEGRAPHICS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

kdegraphics_targetinstall: $(STATEDIR)/kdegraphics.targetinstall

kdegraphics_targetinstall_deps = $(STATEDIR)/kdegraphics.compile \
	$(STATEDIR)/kdelibs.targetinstall

$(STATEDIR)/kdegraphics.targetinstall: $(kdegraphics_targetinstall_deps)
	@$(call targetinfo, $@)
	$(KDEGRAPHICS_PATH) $(MAKE) -C $(KDEGRAPHICS_DIR) DESTDIR=$(KDEGRAPHICS_IPKG_TMP) install

	rm -rf $(KDEGRAPHICS_IPKG_TMP)/usr/lib/kde/include
	rm -rf $(KDEGRAPHICS_IPKG_TMP)/opt

	for FILE in `find $(KDEGRAPHICS_IPKG_TMP)/usr/lib/kde/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;		\
	    if [  "$$ZZZ" != "" ]; then				\
		$(CROSSSTRIP) $$FILE;				\
	    fi;							\
	done

	mkdir -p $(KDEGRAPHICS_IPKG_TMP)/CONTROL
	echo "Package: kdegraphics" 								 >$(KDEGRAPHICS_IPKG_TMP)/CONTROL/control
	echo "Source: $(KDEGRAPHICS_URL)"							>>$(KDEGRAPHICS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(KDEGRAPHICS_IPKG_TMP)/CONTROL/control
	echo "Section: KDE" 									>>$(KDEGRAPHICS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(KDEGRAPHICS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(KDEGRAPHICS_IPKG_TMP)/CONTROL/control
	echo "Version: $(KDEGRAPHICS_VERSION)-$(KDEGRAPHICS_VENDOR_VERSION)" 			>>$(KDEGRAPHICS_IPKG_TMP)/CONTROL/control
	echo "Depends: kdelibs" 								>>$(KDEGRAPHICS_IPKG_TMP)/CONTROL/control
	echo "Description: KDE graphics"							>>$(KDEGRAPHICS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(KDEGRAPHICS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_KDEGRAPHICS_INSTALL
ROMPACKAGES += $(STATEDIR)/kdegraphics.imageinstall
endif

kdegraphics_imageinstall_deps = $(STATEDIR)/kdegraphics.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/kdegraphics.imageinstall: $(kdegraphics_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install kdegraphics
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

kdegraphics_clean:
	rm -rf $(STATEDIR)/kdegraphics.*
	rm -rf $(KDEGRAPHICS_DIR)

# vim: syntax=make
