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
ifdef PTXCONF_GQCAM
PACKAGES += gqcam
endif

#
# Paths and names
#
GQCAM_VENDOR_VERSION	= 1
GQCAM_VERSION		= 0.9
GQCAM			= gqcam-$(GQCAM_VERSION)
GQCAM_SUFFIX		= tar.gz
GQCAM_URL		= http://cse.unl.edu/~cluening/gqcam/download/$(GQCAM).$(GQCAM_SUFFIX)
GQCAM_SOURCE		= $(SRCDIR)/$(GQCAM).$(GQCAM_SUFFIX)
GQCAM_DIR		= $(BUILDDIR)/$(GQCAM)
GQCAM_IPKG_TMP		= $(GQCAM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gqcam_get: $(STATEDIR)/gqcam.get

gqcam_get_deps = $(GQCAM_SOURCE)

$(STATEDIR)/gqcam.get: $(gqcam_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GQCAM))
	touch $@

$(GQCAM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GQCAM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gqcam_extract: $(STATEDIR)/gqcam.extract

gqcam_extract_deps = $(STATEDIR)/gqcam.get

$(STATEDIR)/gqcam.extract: $(gqcam_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GQCAM_DIR))
	@$(call extract, $(GQCAM_SOURCE))
	@$(call patchin, $(GQCAM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gqcam_prepare: $(STATEDIR)/gqcam.prepare

#
# dependencies
#
gqcam_prepare_deps = \
	$(STATEDIR)/gqcam.extract \
	$(STATEDIR)/virtual-xchain.install

GQCAM_PATH	=  PATH=$(CROSS_PATH)
GQCAM_ENV 	=  $(CROSS_ENV)
#GQCAM_ENV	+=
GQCAM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GQCAM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GQCAM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GQCAM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GQCAM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gqcam.prepare: $(gqcam_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GQCAM_DIR)/config.cache)
	#cd $(GQCAM_DIR) && \
	#	$(GQCAM_PATH) $(GQCAM_ENV) \
	#	./configure $(GQCAM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gqcam_compile: $(STATEDIR)/gqcam.compile

gqcam_compile_deps = $(STATEDIR)/gqcam.prepare

$(STATEDIR)/gqcam.compile: $(gqcam_compile_deps)
	@$(call targetinfo, $@)
	$(GQCAM_PATH) $(MAKE) -C $(GQCAM_DIR) $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gqcam_install: $(STATEDIR)/gqcam.install

$(STATEDIR)/gqcam.install: $(STATEDIR)/gqcam.compile
	@$(call targetinfo, $@)
	###$(GQCAM_PATH) $(MAKE) -C $(GQCAM_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gqcam_targetinstall: $(STATEDIR)/gqcam.targetinstall

gqcam_targetinstall_deps = $(STATEDIR)/gqcam.compile

$(STATEDIR)/gqcam.targetinstall: $(gqcam_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(GQCAM_PATH) $(MAKE) -C $(GQCAM_DIR) DESTDIR=$(GQCAM_IPKG_TMP) install
	$(INSTALL) -D $(GQCAM_DIR)/gqcam $(GQCAM_IPKG_TMP)/usr/bin/gqcam
	$(CROSSSTRIP) $(GQCAM_IPKG_TMP)/usr/bin/gqcam
	mkdir -p $(GQCAM_IPKG_TMP)/CONTROL
	echo "Package: gqcam" 								 >$(GQCAM_IPKG_TMP)/CONTROL/control
	echo "Source: $(GQCAM_URL)"						>>$(GQCAM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GQCAM_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(GQCAM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GQCAM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GQCAM_IPKG_TMP)/CONTROL/control
	echo "Version: $(GQCAM_VERSION)-$(GQCAM_VENDOR_VERSION)" 			>>$(GQCAM_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk" 								>>$(GQCAM_IPKG_TMP)/CONTROL/control
	echo "Description: GTK webcam frontend"						>>$(GQCAM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GQCAM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GQCAM_INSTALL
ROMPACKAGES += $(STATEDIR)/gqcam.imageinstall
endif

gqcam_imageinstall_deps = $(STATEDIR)/gqcam.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gqcam.imageinstall: $(gqcam_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gqcam
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gqcam_clean:
	rm -rf $(STATEDIR)/gqcam.*
	rm -rf $(GQCAM_DIR)

# vim: syntax=make
