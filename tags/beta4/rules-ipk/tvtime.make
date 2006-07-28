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
ifdef PTXCONF_TVTIME
PACKAGES += tvtime
endif

#
# Paths and names
#
TVTIME_VENDOR_VERSION	= 1
TVTIME_VERSION		= 0.99
TVTIME			= tvtime-$(TVTIME_VERSION)
TVTIME_SUFFIX		= tar.gz
TVTIME_URL		= http://citkit.dl.sourceforge.net/sourceforge/tvtime/$(TVTIME).$(TVTIME_SUFFIX)
TVTIME_SOURCE		= $(SRCDIR)/$(TVTIME).$(TVTIME_SUFFIX)
TVTIME_DIR		= $(BUILDDIR)/$(TVTIME)
TVTIME_IPKG_TMP		= $(TVTIME_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tvtime_get: $(STATEDIR)/tvtime.get

tvtime_get_deps = $(TVTIME_SOURCE)

$(STATEDIR)/tvtime.get: $(tvtime_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TVTIME))
	touch $@

$(TVTIME_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TVTIME_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tvtime_extract: $(STATEDIR)/tvtime.extract

tvtime_extract_deps = $(STATEDIR)/tvtime.get

$(STATEDIR)/tvtime.extract: $(tvtime_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TVTIME_DIR))
	@$(call extract, $(TVTIME_SOURCE))
	@$(call patchin, $(TVTIME))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tvtime_prepare: $(STATEDIR)/tvtime.prepare

#
# dependencies
#
tvtime_prepare_deps = \
	$(STATEDIR)/tvtime.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

TVTIME_PATH	=  PATH=$(CROSS_PATH)
TVTIME_ENV 	=  $(CROSS_ENV)
#TVTIME_ENV	+=
TVTIME_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TVTIME_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
TVTIME_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
TVTIME_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TVTIME_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/tvtime.prepare: $(tvtime_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TVTIME_DIR)/config.cache)
	cd $(TVTIME_DIR) && \
		$(TVTIME_PATH) $(TVTIME_ENV) \
		./configure $(TVTIME_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tvtime_compile: $(STATEDIR)/tvtime.compile

tvtime_compile_deps = $(STATEDIR)/tvtime.prepare

$(STATEDIR)/tvtime.compile: $(tvtime_compile_deps)
	@$(call targetinfo, $@)
	$(TVTIME_PATH) $(MAKE) -C $(TVTIME_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tvtime_install: $(STATEDIR)/tvtime.install

$(STATEDIR)/tvtime.install: $(STATEDIR)/tvtime.compile
	@$(call targetinfo, $@)
	###$(TVTIME_PATH) $(MAKE) -C $(TVTIME_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tvtime_targetinstall: $(STATEDIR)/tvtime.targetinstall

tvtime_targetinstall_deps = $(STATEDIR)/tvtime.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/tvtime.targetinstall: $(tvtime_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TVTIME_PATH) $(MAKE) -C $(TVTIME_DIR) DESTDIR=$(TVTIME_IPKG_TMP) install
	$(CROSSSTRIP) $(TVTIME_IPKG_TMP)/usr/bin/*
	mkdir -p $(TVTIME_IPKG_TMP)/CONTROL
	echo "Package: tvtime" 									 >$(TVTIME_IPKG_TMP)/CONTROL/control
	echo "Source: $(TVTIME_URL)"						>>$(TVTIME_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(TVTIME_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 								>>$(TVTIME_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(TVTIME_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(TVTIME_IPKG_TMP)/CONTROL/control
	echo "Version: $(TVTIME_VERSION)-$(TVTIME_VENDOR_VERSION)" 				>>$(TVTIME_IPKG_TMP)/CONTROL/control
	echo "Depends: " 									>>$(TVTIME_IPKG_TMP)/CONTROL/control
	echo "Description: high quality television application for use with video capture cards on Linux systems." >>$(TVTIME_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TVTIME_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TVTIME_INSTALL
ROMPACKAGES += $(STATEDIR)/tvtime.imageinstall
endif

tvtime_imageinstall_deps = $(STATEDIR)/tvtime.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tvtime.imageinstall: $(tvtime_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tvtime
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tvtime_clean:
	rm -rf $(STATEDIR)/tvtime.*
	rm -rf $(TVTIME_DIR)

# vim: syntax=make
