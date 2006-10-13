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
ifdef PTXCONF_SYSFSUTILS
PACKAGES += sysfsutils
endif

#
# Paths and names
#
SYSFSUTILS_VENDOR_VERSION	= 1
SYSFSUTILS_VERSION		= 1.3.0
SYSFSUTILS			= sysfsutils-$(SYSFSUTILS_VERSION)
SYSFSUTILS_SUFFIX		= tar.gz
SYSFSUTILS_URL			= http://citkit.dl.sourceforge.net/sourceforge/linux-diag/$(SYSFSUTILS).$(SYSFSUTILS_SUFFIX)
SYSFSUTILS_SOURCE		= $(SRCDIR)/$(SYSFSUTILS).$(SYSFSUTILS_SUFFIX)
SYSFSUTILS_DIR			= $(BUILDDIR)/$(SYSFSUTILS)
SYSFSUTILS_IPKG_TMP		= $(SYSFSUTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sysfsutils_get: $(STATEDIR)/sysfsutils.get

sysfsutils_get_deps = $(SYSFSUTILS_SOURCE)

$(STATEDIR)/sysfsutils.get: $(sysfsutils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SYSFSUTILS))
	touch $@

$(SYSFSUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SYSFSUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sysfsutils_extract: $(STATEDIR)/sysfsutils.extract

sysfsutils_extract_deps = $(STATEDIR)/sysfsutils.get

$(STATEDIR)/sysfsutils.extract: $(sysfsutils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SYSFSUTILS_DIR))
	@$(call extract, $(SYSFSUTILS_SOURCE))
	@$(call patchin, $(SYSFSUTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sysfsutils_prepare: $(STATEDIR)/sysfsutils.prepare

#
# dependencies
#
sysfsutils_prepare_deps = \
	$(STATEDIR)/sysfsutils.extract \
	$(STATEDIR)/virtual-xchain.install

SYSFSUTILS_PATH	=  PATH=$(CROSS_PATH)
SYSFSUTILS_ENV 	=  $(CROSS_ENV)
#SYSFSUTILS_ENV	+=
SYSFSUTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SYSFSUTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SYSFSUTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
SYSFSUTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SYSFSUTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/sysfsutils.prepare: $(sysfsutils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SYSFSUTILS_DIR)/config.cache)
	cd $(SYSFSUTILS_DIR) && \
		$(SYSFSUTILS_PATH) $(SYSFSUTILS_ENV) \
		./configure $(SYSFSUTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sysfsutils_compile: $(STATEDIR)/sysfsutils.compile

sysfsutils_compile_deps = $(STATEDIR)/sysfsutils.prepare

$(STATEDIR)/sysfsutils.compile: $(sysfsutils_compile_deps)
	@$(call targetinfo, $@)
	$(SYSFSUTILS_PATH) $(MAKE) -C $(SYSFSUTILS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sysfsutils_install: $(STATEDIR)/sysfsutils.install

$(STATEDIR)/sysfsutils.install: $(STATEDIR)/sysfsutils.compile
	@$(call targetinfo, $@)
	rm -rf $(SYSFSUTILS_IPKG_TMP)
	$(SYSFSUTILS_PATH) $(MAKE) -C $(SYSFSUTILS_DIR) DESTDIR=$(SYSFSUTILS_IPKG_TMP) install
	cp -a $(SYSFSUTILS_IPKG_TMP)/usr/include/* 		$(CROSS_LIB_DIR)/include/
	cp -a $(SYSFSUTILS_IPKG_TMP)/usr/lib/*			$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" 	$(CROSS_LIB_DIR)/lib/libsysfs.la
	rm -rf $(SYSFSUTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sysfsutils_targetinstall: $(STATEDIR)/sysfsutils.targetinstall

sysfsutils_targetinstall_deps = $(STATEDIR)/sysfsutils.compile

$(STATEDIR)/sysfsutils.targetinstall: $(sysfsutils_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SYSFSUTILS_PATH) $(MAKE) -C $(SYSFSUTILS_DIR) DESTDIR=$(SYSFSUTILS_IPKG_TMP) install
	rm -rf $(SYSFSUTILS_IPKG_TMP)/usr/include
	rm -rf $(SYSFSUTILS_IPKG_TMP)/usr/man
	rm -f  $(SYSFSUTILS_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(SYSFSUTILS_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(SYSFSUTILS_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(SYSFSUTILS_IPKG_TMP)/CONTROL
	echo "Package: sysfsutils" 							 >$(SYSFSUTILS_IPKG_TMP)/CONTROL/control
	echo "Source: $(SYSFSUTILS_URL)"						>>$(SYSFSUTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SYSFSUTILS_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(SYSFSUTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SYSFSUTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SYSFSUTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(SYSFSUTILS_VERSION)-$(SYSFSUTILS_VENDOR_VERSION)" 		>>$(SYSFSUTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(SYSFSUTILS_IPKG_TMP)/CONTROL/control
	echo "Description: System Utilities Based on Sysfs"				>>$(SYSFSUTILS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(SYSFSUTILS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SYSFSUTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/sysfsutils.imageinstall
endif

sysfsutils_imageinstall_deps = $(STATEDIR)/sysfsutils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/sysfsutils.imageinstall: $(sysfsutils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sysfsutils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sysfsutils_clean:
	rm -rf $(STATEDIR)/sysfsutils.*
	rm -rf $(SYSFSUTILS_DIR)

# vim: syntax=make
