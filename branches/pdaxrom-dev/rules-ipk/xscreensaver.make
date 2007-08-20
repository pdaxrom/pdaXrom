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
ifdef PTXCONF_XSCREENSAVER
PACKAGES += xscreensaver
endif

#
# Paths and names
#
XSCREENSAVER_VENDOR_VERSION	= 1
XSCREENSAVER_VERSION		= 5.00
XSCREENSAVER			= xscreensaver-$(XSCREENSAVER_VERSION)
XSCREENSAVER_SUFFIX		= tar.gz
XSCREENSAVER_URL		= http://www.jwz.org/xscreensaver/$(XSCREENSAVER).$(XSCREENSAVER_SUFFIX)
XSCREENSAVER_SOURCE		= $(SRCDIR)/$(XSCREENSAVER).$(XSCREENSAVER_SUFFIX)
XSCREENSAVER_DIR		= $(BUILDDIR)/$(XSCREENSAVER)
XSCREENSAVER_IPKG_TMP		= $(XSCREENSAVER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xscreensaver_get: $(STATEDIR)/xscreensaver.get

xscreensaver_get_deps = $(XSCREENSAVER_SOURCE)

$(STATEDIR)/xscreensaver.get: $(xscreensaver_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XSCREENSAVER))
	touch $@

$(XSCREENSAVER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XSCREENSAVER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xscreensaver_extract: $(STATEDIR)/xscreensaver.extract

xscreensaver_extract_deps = $(STATEDIR)/xscreensaver.get

$(STATEDIR)/xscreensaver.extract: $(xscreensaver_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XSCREENSAVER_DIR))
	@$(call extract, $(XSCREENSAVER_SOURCE))
	@$(call patchin, $(XSCREENSAVER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xscreensaver_prepare: $(STATEDIR)/xscreensaver.prepare

#
# dependencies
#
xscreensaver_prepare_deps = \
	$(STATEDIR)/xscreensaver.extract \
	$(STATEDIR)/virtual-xchain.install

XSCREENSAVER_PATH	=  PATH=$(CROSS_PATH)
XSCREENSAVER_ENV 	=  $(CROSS_ENV)
#XSCREENSAVER_ENV	+=
XSCREENSAVER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XSCREENSAVER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XSCREENSAVER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-hackdir=/usr/lib/xscreensaver

ifdef PTXCONF_XFREE430
XSCREENSAVER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XSCREENSAVER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xscreensaver.prepare: $(xscreensaver_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XSCREENSAVER_DIR)/config.cache)
	cd $(XSCREENSAVER_DIR) && \
		$(XSCREENSAVER_PATH) $(XSCREENSAVER_ENV) \
		./configure $(XSCREENSAVER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xscreensaver_compile: $(STATEDIR)/xscreensaver.compile

xscreensaver_compile_deps = $(STATEDIR)/xscreensaver.prepare

$(STATEDIR)/xscreensaver.compile: $(xscreensaver_compile_deps)
	@$(call targetinfo, $@)
	$(XSCREENSAVER_PATH) $(MAKE) -C $(XSCREENSAVER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xscreensaver_install: $(STATEDIR)/xscreensaver.install

$(STATEDIR)/xscreensaver.install: $(STATEDIR)/xscreensaver.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xscreensaver_targetinstall: $(STATEDIR)/xscreensaver.targetinstall

xscreensaver_targetinstall_deps = $(STATEDIR)/xscreensaver.compile

$(STATEDIR)/xscreensaver.targetinstall: $(xscreensaver_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XSCREENSAVER_PATH) $(MAKE) -C $(XSCREENSAVER_DIR) install_prefix=$(XSCREENSAVER_IPKG_TMP) install
	rm -rf $(XSCREENSAVER_IPKG_TMP)/usr/share/man

	for FILE in `find $(XSCREENSAVER_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;				\
	    if [  "$$ZZZ" != "" ]; then						\
		$(CROSSSTRIP) $$FILE;						\
	    fi;									\
	done

	#cp -a $(XSCREENSAVER_IPKG_TMP)/$(CROSS_LIB_DIR)/share $(XSCREENSAVER_IPKG_TMP)/usr
	#rm -rf $(XSCREENSAVER_IPKG_TMP)/opt

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XSCREENSAVER_VERSION) 				\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xscreensaver $(XSCREENSAVER_IPKG_TMP)

	rm -rf $(XSCREENSAVER_IPKG_TMP)/usr/share/locale

	mkdir -p $(XSCREENSAVER_IPKG_TMP)/CONTROL
	echo "Package: xscreensaver" 							 >$(XSCREENSAVER_IPKG_TMP)/CONTROL/control
	echo "Source: $(XSCREENSAVER_URL)"						>>$(XSCREENSAVER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XSCREENSAVER_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(XSCREENSAVER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(XSCREENSAVER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XSCREENSAVER_IPKG_TMP)/CONTROL/control
	echo "Version: $(XSCREENSAVER_VERSION)-$(XSCREENSAVER_VENDOR_VERSION)" 		>>$(XSCREENSAVER_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(XSCREENSAVER_IPKG_TMP)/CONTROL/control
	echo "Description:  The XScreenSaver collection is available below as a DMG containing all 200+ screen savers."	>>$(XSCREENSAVER_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XSCREENSAVER_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XSCREENSAVER_INSTALL
ROMPACKAGES += $(STATEDIR)/xscreensaver.imageinstall
endif

xscreensaver_imageinstall_deps = $(STATEDIR)/xscreensaver.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xscreensaver.imageinstall: $(xscreensaver_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xscreensaver
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xscreensaver_clean:
	rm -rf $(STATEDIR)/xscreensaver.*
	rm -rf $(XSCREENSAVER_DIR)

# vim: syntax=make
