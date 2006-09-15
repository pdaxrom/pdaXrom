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
ifdef PTXCONF_POSE
PACKAGES += POSE
endif

#
# Paths and names
#
POSE_VENDOR_VERSION	= 1
POSE_VERSION		= 3.5
POSE			= emulator_src_$(POSE_VERSION)
POSE_SUFFIX		= tar.gz
POSE_URL		= http://www.pdaXrom.org/src/$(POSE).$(POSE_SUFFIX)
POSE_SOURCE		= $(SRCDIR)/$(POSE).$(POSE_SUFFIX)
POSE_DIR		= $(BUILDDIR)/Emulator_Src_$(POSE_VERSION)
POSE_IPKG_TMP		= $(POSE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

POSE_get: $(STATEDIR)/POSE.get

POSE_get_deps = $(POSE_SOURCE)

$(STATEDIR)/POSE.get: $(POSE_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(POSE))
	touch $@

$(POSE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(POSE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

POSE_extract: $(STATEDIR)/POSE.extract

POSE_extract_deps = $(STATEDIR)/POSE.get

$(STATEDIR)/POSE.extract: $(POSE_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(POSE_DIR))
	@$(call extract, $(POSE_SOURCE))
	@$(call patchin, $(POSE), $(POSE_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

POSE_prepare: $(STATEDIR)/POSE.prepare

#
# dependencies
#
POSE_prepare_deps = \
	$(STATEDIR)/POSE.extract \
	$(STATEDIR)/fltk-utf8.install \
	$(STATEDIR)/xchain-fltk-utf8.install \
	$(STATEDIR)/virtual-xchain.install

POSE_PATH	=  PATH=$(CROSS_PATH)
POSE_ENV 	=  $(CROSS_ENV)
#POSE_ENV	+=
POSE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#POSE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
POSE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
POSE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
POSE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/POSE.prepare: $(POSE_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(POSE_DIR)/config.cache)
	cd $(POSE_DIR)/BuildUnix && \
		$(POSE_PATH) $(POSE_ENV) \
		./configure $(POSE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

POSE_compile: $(STATEDIR)/POSE.compile

POSE_compile_deps = $(STATEDIR)/POSE.prepare

$(STATEDIR)/POSE.compile: $(POSE_compile_deps)
	@$(call targetinfo, $@)
	$(POSE_PATH) $(MAKE) -C $(POSE_DIR)/BuildUnix
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

POSE_install: $(STATEDIR)/POSE.install

$(STATEDIR)/POSE.install: $(STATEDIR)/POSE.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

POSE_targetinstall: $(STATEDIR)/POSE.targetinstall

POSE_targetinstall_deps = $(STATEDIR)/POSE.compile

$(STATEDIR)/POSE.targetinstall: $(POSE_targetinstall_deps)
	@$(call targetinfo, $@)
	$(POSE_PATH) $(MAKE) -C $(POSE_DIR)/BuildUnix DESTDIR=$(POSE_IPKG_TMP) install
	mkdir -p $(POSE_IPKG_TMP)/CONTROL
	echo "Package: pose" 								 >$(POSE_IPKG_TMP)/CONTROL/control
	echo "Source: $(POSE_URL)"							>>$(POSE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(POSE_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(POSE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(POSE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(POSE_IPKG_TMP)/CONTROL/control
	echo "Version: $(POSE_VERSION)-$(POSE_VENDOR_VERSION)" 				>>$(POSE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(POSE_IPKG_TMP)/CONTROL/control
	echo "Description: Palm OS emulator"						>>$(POSE_IPKG_TMP)/CONTROL/control
	asasd
	cd $(FEEDDIR) && $(XMKIPKG) $(POSE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_POSE_INSTALL
ROMPACKAGES += $(STATEDIR)/POSE.imageinstall
endif

POSE_imageinstall_deps = $(STATEDIR)/POSE.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/POSE.imageinstall: $(POSE_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pose
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

POSE_clean:
	rm -rf $(STATEDIR)/POSE.*
	rm -rf $(POSE_DIR)

# vim: syntax=make
