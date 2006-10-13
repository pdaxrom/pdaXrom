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
ifdef PTXCONF_FLITE
PACKAGES += flite
endif

#
# Paths and names
#
FLITE_VENDOR_VERSION	= 1
FLITE_VERSION		= 1.3
FLITE			= flite-$(FLITE_VERSION)-release
FLITE_SUFFIX		= tar.bz2
FLITE_URL		= http://www.speech.cs.cmu.edu/flite/packed/flite-1.3/$(FLITE).$(FLITE_SUFFIX)
FLITE_SOURCE		= $(SRCDIR)/$(FLITE).$(FLITE_SUFFIX)
FLITE_DIR		= $(BUILDDIR)/$(FLITE)
FLITE_IPKG_TMP		= $(FLITE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

flite_get: $(STATEDIR)/flite.get

flite_get_deps = $(FLITE_SOURCE)

$(STATEDIR)/flite.get: $(flite_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FLITE))
	touch $@

$(FLITE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FLITE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

flite_extract: $(STATEDIR)/flite.extract

flite_extract_deps = $(STATEDIR)/flite.get

$(STATEDIR)/flite.extract: $(flite_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FLITE_DIR))
	@$(call extract, $(FLITE_SOURCE))
	@$(call patchin, $(FLITE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

flite_prepare: $(STATEDIR)/flite.prepare

#
# dependencies
#
flite_prepare_deps = \
	$(STATEDIR)/flite.extract \
	$(STATEDIR)/virtual-xchain.install

FLITE_PATH	=  PATH=$(CROSS_PATH)
FLITE_ENV 	=  $(CROSS_ENV)
FLITE_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
FLITE_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
FLITE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FLITE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
FLITE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--with-audio=oss \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
FLITE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FLITE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/flite.prepare: $(flite_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FLITE_DIR)/config.cache)
	cd $(FLITE_DIR) && \
		$(FLITE_PATH) $(FLITE_ENV) \
		./configure $(FLITE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

flite_compile: $(STATEDIR)/flite.compile

flite_compile_deps = $(STATEDIR)/flite.prepare

$(STATEDIR)/flite.compile: $(flite_compile_deps)
	@$(call targetinfo, $@)
	$(FLITE_PATH) ; ( unset BUILDDIR; $(MAKE) -C $(FLITE_DIR) )
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

flite_install: $(STATEDIR)/flite.install

$(STATEDIR)/flite.install: $(STATEDIR)/flite.compile
	@$(call targetinfo, $@)
	###$(FLITE_PATH) $(MAKE) -C $(FLITE_DIR) install
	asasda
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

flite_targetinstall: $(STATEDIR)/flite.targetinstall

flite_targetinstall_deps = $(STATEDIR)/flite.compile

$(STATEDIR)/flite.targetinstall: $(flite_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(FLITE_PATH) ; ( unset BUILDDIR; $(MAKE) -C $(FLITE_DIR) prefix=$(FLITE_IPKG_TMP)/usr install )
	#rm -rf $(FLITE_IPKG_TMP)/usr/include
	#rm -f  $(FLITE_IPKG_TMP)/usr/lib/*.*a
	#rm -f  $(FLITE_IPKG_TMP)/usr/lib/*_kal16.*
	#rm -f  $(FLITE_IPKG_TMP)/usr/bin/*_time
	#rm -f  $(FLITE_IPKG_TMP)/usr/lib/*_time_*
	#$(CROSSSTRIP) $(FLITE_IPKG_TMP)/usr/lib/*.so*
	
	mkdir -p $(FLITE_IPKG_TMP)/usr/bin
	cp -a $(FLITE_DIR)/bin/flite $(FLITE_IPKG_TMP)/usr/bin
	$(CROSSSTRIP) $(FLITE_IPKG_TMP)/usr/bin/*
	mkdir -p $(FLITE_IPKG_TMP)/CONTROL
	echo "Package: flite" 								 >$(FLITE_IPKG_TMP)/CONTROL/control
	echo "Source: $(FLITE_URL)"							>>$(FLITE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(FLITE_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(FLITE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(FLITE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(FLITE_IPKG_TMP)/CONTROL/control
	echo "Version: $(FLITE_VERSION)-$(FLITE_VENDOR_VERSION)" 			>>$(FLITE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(FLITE_IPKG_TMP)/CONTROL/control
	echo "Description: a small run-time speech synthesis engine"			>>$(FLITE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(FLITE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FLITE_INSTALL
ROMPACKAGES += $(STATEDIR)/flite.imageinstall
endif

flite_imageinstall_deps = $(STATEDIR)/flite.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/flite.imageinstall: $(flite_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install flite
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

flite_clean:
	rm -rf $(STATEDIR)/flite.*
	rm -rf $(FLITE_DIR)

# vim: syntax=make
