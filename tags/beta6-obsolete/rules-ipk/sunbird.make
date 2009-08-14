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
ifdef PTXCONF_SUNBIRD
PACKAGES += sunbird
endif

#
# Paths and names
#
SUNBIRD_VERSION		= 0.2
SUNBIRD			= sunbird-$(SUNBIRD_VERSION)-source
SUNBIRD_SUFFIX		= tar.bz2
SUNBIRD_URL		= ftp://ftp.mozilla.org/pub/mozilla.org/sunbird/releases/$(SUNBIRD_VERSION)/$(SUNBIRD).$(SUNBIRD_SUFFIX)
SUNBIRD_SOURCE		= $(SRCDIR)/$(SUNBIRD).$(SUNBIRD_SUFFIX)
SUNBIRD_DIR		= $(BUILDDIR)/mozilla
SUNBIRD_IPKG_TMP	= $(SUNBIRD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sunbird_get: $(STATEDIR)/sunbird.get

sunbird_get_deps = $(SUNBIRD_SOURCE)

$(STATEDIR)/sunbird.get: $(sunbird_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SUNBIRD))
	touch $@

$(SUNBIRD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SUNBIRD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sunbird_extract: $(STATEDIR)/sunbird.extract

sunbird_extract_deps = $(STATEDIR)/sunbird.get

$(STATEDIR)/sunbird.extract: $(sunbird_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SUNBIRD_DIR))
	@$(call extract, $(SUNBIRD_SOURCE))
	@$(call patchin, $(SUNBIRD), $(SUNBIRD_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sunbird_prepare: $(STATEDIR)/sunbird.prepare

#
# dependencies
#
sunbird_prepare_deps = \
	$(STATEDIR)/sunbird.extract \
	$(STATEDIR)/gtk22.install     \
	$(STATEDIR)/libIDL082.install \
	$(STATEDIR)/virtual-xchain.install

SUNBIRD_PATH	=  PATH=$(CROSS_PATH)
SUNBIRD_ENV 	=  $(CROSS_ENV)
#SUNBIRD_ENV	+=
SUNBIRD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SUNBIRD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

SUNBIRD_ENV	+= HOST_CC=gcc

#
# autoconf
#
SUNBIRD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--target=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
SUNBIRD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SUNBIRD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/sunbird.prepare: $(sunbird_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SUNBIRD_DIR)/config.cache)
ifdef PTXCONF_ARCH_X86
	cp $(TOPDIR)/config/pdaXrom-x86/mozconfig $(SUNBIRD_DIR)/.mozconfig
else
 ifdef PTXCONF_ARCH_ARM
	cp $(TOPDIR)/config/pdaXrom/sunbird/.mozconfig $(SUNBIRD_DIR)/.mozconfig
 endif
endif
	cd $(SUNBIRD_DIR) && \
		$(SUNBIRD_PATH) $(SUNBIRD_ENV) \
		./configure $(SUNBIRD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sunbird_compile: $(STATEDIR)/sunbird.compile

sunbird_compile_deps = $(STATEDIR)/sunbird.prepare

$(STATEDIR)/sunbird.compile: $(sunbird_compile_deps)
	@$(call targetinfo, $@)
	$(SUNBIRD_PATH) CROSS_COMPILE=1 \
	    $(MAKE) -C $(SUNBIRD_DIR) $(XHOST_LIBIDL2_CFLAGS) $(XHOST_LIBIDL2_LIBS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sunbird_install: $(STATEDIR)/sunbird.install

$(STATEDIR)/sunbird.install: $(STATEDIR)/sunbird.compile
	@$(call targetinfo, $@)
	##$(SUNBIRD_PATH) $(MAKE) -C $(SUNBIRD_DIR) install
	aasda
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sunbird_targetinstall: $(STATEDIR)/sunbird.targetinstall

sunbird_targetinstall_deps = \
	$(STATEDIR)/sunbird.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libIDL082.targetinstall

$(STATEDIR)/sunbird.targetinstall: $(sunbird_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SUNBIRD_PATH) $(MAKE) -C $(SUNBIRD_DIR) DESTDIR=$(SUNBIRD_IPKG_TMP) install
	rm  -f $(SUNBIRD_IPKG_TMP)/usr/bin/sunbird-config
	rm -rf $(SUNBIRD_IPKG_TMP)/usr/include
	rm -rf $(SUNBIRD_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(SUNBIRD_IPKG_TMP)/usr/share/*
	mkdir -p $(SUNBIRD_IPKG_TMP)/usr/share/applications
	mkdir -p $(SUNBIRD_IPKG_TMP)/usr/share/pixmaps
	rm  -f $(SUNBIRD_IPKG_TMP)/usr/lib/sunbird-$(SUNBIRD_VERSION)/TestGtkEmbed
###ifdef PTXCONF_ARCH_ARM
	cp -a $(TOPDIR)/config/pdaXrom/sunbird/sunbird.desktop $(SUNBIRD_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pdaXrom/sunbird/sunbird.png     $(SUNBIRD_IPKG_TMP)/usr/share/pixmaps
###endif
	for FILE in `find $(SUNBIRD_IPKG_TMP)/usr/lib -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(SUNBIRD_IPKG_TMP)/CONTROL
	echo "Package: sunbird" 							>$(SUNBIRD_IPKG_TMP)/CONTROL/control
	echo "Source: $(SUNBIRD_URL)"						>>$(SUNBIRD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SUNBIRD_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(SUNBIRD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SUNBIRD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SUNBIRD_IPKG_TMP)/CONTROL/control
	echo "Version: $(SUNBIRD_VERSION)" 						>>$(SUNBIRD_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2"	 							>>$(SUNBIRD_IPKG_TMP)/CONTROL/control
	echo "Description: The Sunbird Project is a redesign of the Calendar component - a cross platform standalone calendar application based on Mozilla's XUL user interface language.">>$(SUNBIRD_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(SUNBIRD_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SUNBIRD_INSTALL
ROMPACKAGES += $(STATEDIR)/sunbird.imageinstall
endif

sunbird_imageinstall_deps = $(STATEDIR)/sunbird.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/sunbird.imageinstall: $(sunbird_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sunbird
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sunbird_clean:
	rm -rf $(STATEDIR)/sunbird.*
	rm -rf $(SUNBIRD_DIR)

# vim: syntax=make
