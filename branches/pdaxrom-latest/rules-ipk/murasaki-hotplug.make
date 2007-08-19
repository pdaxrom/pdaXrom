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
ifdef PTXCONF_MURASAKI-HOTPLUG
PACKAGES += murasaki-hotplug
endif

#
# Paths and names
#
MURASAKI-HOTPLUG_VENDOR_VERSION	= 1
MURASAKI-HOTPLUG_VERSION	= 0.0.0
MURASAKI-HOTPLUG		= murasaki-hotplug
MURASAKI-HOTPLUG_SUFFIX		= tar.bz2
MURASAKI-HOTPLUG_URL		= http://www.pdaXrom.org/src/$(MURASAKI-HOTPLUG).$(MURASAKI-HOTPLUG_SUFFIX)
MURASAKI-HOTPLUG_SOURCE		= $(SRCDIR)/$(MURASAKI-HOTPLUG).$(MURASAKI-HOTPLUG_SUFFIX)
MURASAKI-HOTPLUG_DIR		= $(BUILDDIR)/murasaki
MURASAKI-HOTPLUG_IPKG_TMP	= $(MURASAKI-HOTPLUG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

murasaki-hotplug_get: $(STATEDIR)/murasaki-hotplug.get

murasaki-hotplug_get_deps = $(MURASAKI-HOTPLUG_SOURCE)

$(STATEDIR)/murasaki-hotplug.get: $(murasaki-hotplug_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MURASAKI-HOTPLUG))
	touch $@

$(MURASAKI-HOTPLUG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MURASAKI-HOTPLUG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

murasaki-hotplug_extract: $(STATEDIR)/murasaki-hotplug.extract

murasaki-hotplug_extract_deps = $(STATEDIR)/murasaki-hotplug.get

$(STATEDIR)/murasaki-hotplug.extract: $(murasaki-hotplug_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(MURASAKI-HOTPLUG_DIR))
	@$(call extract, $(MURASAKI-HOTPLUG_SOURCE))
	@$(call patchin, $(MURASAKI-HOTPLUG), $(MURASAKI-HOTPLUG_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

murasaki-hotplug_prepare: $(STATEDIR)/murasaki-hotplug.prepare

#
# dependencies
#
murasaki-hotplug_prepare_deps = \
	$(STATEDIR)/murasaki-hotplug.extract \
	$(STATEDIR)/virtual-xchain.install

MURASAKI-HOTPLUG_PATH	=  PATH=$(CROSS_PATH)
MURASAKI-HOTPLUG_ENV 	=  $(CROSS_ENV)
#MURASAKI-HOTPLUG_ENV	+=
MURASAKI-HOTPLUG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MURASAKI-HOTPLUG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MURASAKI-HOTPLUG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MURASAKI-HOTPLUG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MURASAKI-HOTPLUG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/murasaki-hotplug.prepare: $(murasaki-hotplug_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MURASAKI-HOTPLUG_DIR)/config.cache)
	#cd $(MURASAKI-HOTPLUG_DIR) && \
	#	$(MURASAKI-HOTPLUG_PATH) $(MURASAKI-HOTPLUG_ENV) \
	#	./configure $(MURASAKI-HOTPLUG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

murasaki-hotplug_compile: $(STATEDIR)/murasaki-hotplug.compile

murasaki-hotplug_compile_deps = $(STATEDIR)/murasaki-hotplug.prepare

$(STATEDIR)/murasaki-hotplug.compile: $(murasaki-hotplug_compile_deps)
	@$(call targetinfo, $@)
	$(MURASAKI-HOTPLUG_PATH) $(MURASAKI-HOTPLUG_ENV) $(MAKE) -C $(MURASAKI-HOTPLUG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

murasaki-hotplug_install: $(STATEDIR)/murasaki-hotplug.install

$(STATEDIR)/murasaki-hotplug.install: $(STATEDIR)/murasaki-hotplug.compile
	@$(call targetinfo, $@)
	#$(MURASAKI-HOTPLUG_PATH) $(MAKE) -C $(MURASAKI-HOTPLUG_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

murasaki-hotplug_targetinstall: $(STATEDIR)/murasaki-hotplug.targetinstall

murasaki-hotplug_targetinstall_deps = $(STATEDIR)/murasaki-hotplug.compile

$(STATEDIR)/murasaki-hotplug.targetinstall: $(murasaki-hotplug_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(MURASAKI-HOTPLUG_IPKG_TMP)/etc/rc.d/init.d
	mkdir -p $(MURASAKI-HOTPLUG_IPKG_TMP)/etc/rc.d/{rc0.d,rc1.d,rc2.d,rc3.d,rc4.d,rc5.d,rc6.d}
	$(MURASAKI-HOTPLUG_PATH) $(MAKE) -C $(MURASAKI-HOTPLUG_DIR) DESTDIR=$(MURASAKI-HOTPLUG_IPKG_TMP) install
	mv $(MURASAKI-HOTPLUG_IPKG_TMP)/etc/rc.d/hotplug $(MURASAKI-HOTPLUG_IPKG_TMP)/etc/rc.d/init.d/
	$(CROSSSTRIP) $(MURASAKI-HOTPLUG_IPKG_TMP)/sbin/*
	mkdir -p $(MURASAKI-HOTPLUG_IPKG_TMP)/CONTROL
	echo "Package: murasaki-hotplug" 						 >$(MURASAKI-HOTPLUG_IPKG_TMP)/CONTROL/control
	echo "Source: $(MURASAKI-HOTPLUG_URL)"						>>$(MURASAKI-HOTPLUG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MURASAKI-HOTPLUG_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(MURASAKI-HOTPLUG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(MURASAKI-HOTPLUG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MURASAKI-HOTPLUG_IPKG_TMP)/CONTROL/control
	echo "Version: $(MURASAKI-HOTPLUG_VERSION)-$(MURASAKI-HOTPLUG_VENDOR_VERSION)" 	>>$(MURASAKI-HOTPLUG_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(MURASAKI-HOTPLUG_IPKG_TMP)/CONTROL/control
	echo "Description: Another hotplug stuff"					>>$(MURASAKI-HOTPLUG_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(MURASAKI-HOTPLUG_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MURASAKI-HOTPLUG_INSTALL
ROMPACKAGES += $(STATEDIR)/murasaki-hotplug.imageinstall
endif

murasaki-hotplug_imageinstall_deps = $(STATEDIR)/murasaki-hotplug.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/murasaki-hotplug.imageinstall: $(murasaki-hotplug_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install murasaki-hotplug
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

murasaki-hotplug_clean:
	rm -rf $(STATEDIR)/murasaki-hotplug.*
	rm -rf $(MURASAKI-HOTPLUG_DIR)

# vim: syntax=make
