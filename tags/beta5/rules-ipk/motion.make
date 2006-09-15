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
ifdef PTXCONF_MOTION
PACKAGES += motion
endif

#
# Paths and names
#
MOTION_VENDOR_VERSION	= 1
MOTION_VERSION		= 3.2.1
MOTION			= motion-$(MOTION_VERSION)
MOTION_SUFFIX		= tar.gz
MOTION_URL		= http://citkit.dl.sourceforge.net/sourceforge/motion/$(MOTION).$(MOTION_SUFFIX)
MOTION_SOURCE		= $(SRCDIR)/$(MOTION).$(MOTION_SUFFIX)
MOTION_DIR		= $(BUILDDIR)/$(MOTION)
MOTION_IPKG_TMP		= $(MOTION_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

motion_get: $(STATEDIR)/motion.get

motion_get_deps = $(MOTION_SOURCE)

$(STATEDIR)/motion.get: $(motion_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MOTION))
	touch $@

$(MOTION_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MOTION_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

motion_extract: $(STATEDIR)/motion.extract

motion_extract_deps = $(STATEDIR)/motion.get

$(STATEDIR)/motion.extract: $(motion_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MOTION_DIR))
	@$(call extract, $(MOTION_SOURCE))
	@$(call patchin, $(MOTION))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

motion_prepare: $(STATEDIR)/motion.prepare

#
# dependencies
#
motion_prepare_deps = \
	$(STATEDIR)/motion.extract \
	$(STATEDIR)/ffmpeg.install \
	$(STATEDIR)/virtual-xchain.install

MOTION_PATH	=  PATH=$(CROSS_PATH)
MOTION_ENV 	=  $(CROSS_ENV)
MOTION_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
MOTION_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
MOTION_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MOTION_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MOTION_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-ffmpeg=$(CROSS_LIB_DIR) \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
MOTION_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MOTION_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/motion.prepare: $(motion_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MOTION_DIR)/config.cache)
	cd $(MOTION_DIR) && \
		$(MOTION_PATH) $(MOTION_ENV) \
		./configure $(MOTION_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

motion_compile: $(STATEDIR)/motion.compile

motion_compile_deps = $(STATEDIR)/motion.prepare

$(STATEDIR)/motion.compile: $(motion_compile_deps)
	@$(call targetinfo, $@)
	$(MOTION_PATH) $(MAKE) -C $(MOTION_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

motion_install: $(STATEDIR)/motion.install

$(STATEDIR)/motion.install: $(STATEDIR)/motion.compile
	@$(call targetinfo, $@)
	#$(MOTION_PATH) $(MAKE) -C $(MOTION_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

motion_targetinstall: $(STATEDIR)/motion.targetinstall

motion_targetinstall_deps = $(STATEDIR)/motion.compile \
	$(STATEDIR)/ffmpeg.targetinstall

$(STATEDIR)/motion.targetinstall: $(motion_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MOTION_PATH) $(MAKE) -C $(MOTION_DIR) DESTDIR=$(MOTION_IPKG_TMP) install
	$(CROSSSTRIP) $(MOTION_IPKG_TMP)/usr/bin/motion
	rm -rf $(MOTION_IPKG_TMP)/usr/man
	rm -rf $(MOTION_IPKG_TMP)/usr/share/doc
	mkdir -p $(MOTION_IPKG_TMP)/CONTROL
	echo "Package: motion" 								 >$(MOTION_IPKG_TMP)/CONTROL/control
	echo "Source: $(MOTION_URL)"						>>$(MOTION_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MOTION_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(MOTION_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(MOTION_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MOTION_IPKG_TMP)/CONTROL/control
	echo "Version: $(MOTION_VERSION)-$(MOTION_VENDOR_VERSION)" 			>>$(MOTION_IPKG_TMP)/CONTROL/control
	echo "Depends: libffmpeg" 							>>$(MOTION_IPKG_TMP)/CONTROL/control
	echo "Description: Motion is a software motion detector."			>>$(MOTION_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MOTION_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MOTION_INSTALL
ROMPACKAGES += $(STATEDIR)/motion.imageinstall
endif

motion_imageinstall_deps = $(STATEDIR)/motion.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/motion.imageinstall: $(motion_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install motion
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

motion_clean:
	rm -rf $(STATEDIR)/motion.*
	rm -rf $(MOTION_DIR)

# vim: syntax=make
