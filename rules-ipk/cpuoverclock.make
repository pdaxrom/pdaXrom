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
ifdef PTXCONF_CPUOVERCLOCK
PACKAGES += cpuoverclock
endif

#
# Paths and names
#
CPUOVERCLOCK_VENDOR_VERSION	= 1
CPUOVERCLOCK_VERSION		= 0.0.2
CPUOVERCLOCK			= cpuoverclock-$(CPUOVERCLOCK_VERSION)
CPUOVERCLOCK_SUFFIX		= tar.bz2
CPUOVERCLOCK_URL		= http://www.pdaXrom.org/src/$(CPUOVERCLOCK).$(CPUOVERCLOCK_SUFFIX)
CPUOVERCLOCK_SOURCE		= $(SRCDIR)/$(CPUOVERCLOCK).$(CPUOVERCLOCK_SUFFIX)
CPUOVERCLOCK_DIR		= $(BUILDDIR)/$(CPUOVERCLOCK)
CPUOVERCLOCK_IPKG_TMP		= $(CPUOVERCLOCK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

cpuoverclock_get: $(STATEDIR)/cpuoverclock.get

cpuoverclock_get_deps = $(CPUOVERCLOCK_SOURCE)

$(STATEDIR)/cpuoverclock.get: $(cpuoverclock_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CPUOVERCLOCK))
	touch $@

$(CPUOVERCLOCK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CPUOVERCLOCK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

cpuoverclock_extract: $(STATEDIR)/cpuoverclock.extract

cpuoverclock_extract_deps = $(STATEDIR)/cpuoverclock.get

$(STATEDIR)/cpuoverclock.extract: $(cpuoverclock_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CPUOVERCLOCK_DIR))
	@$(call extract, $(CPUOVERCLOCK_SOURCE))
	@$(call patchin, $(CPUOVERCLOCK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

cpuoverclock_prepare: $(STATEDIR)/cpuoverclock.prepare

#
# dependencies
#
cpuoverclock_prepare_deps = \
	$(STATEDIR)/cpuoverclock.extract \
	$(STATEDIR)/pygtk.install \
	$(STATEDIR)/virtual-xchain.install

CPUOVERCLOCK_PATH	=  PATH=$(CROSS_PATH)
CPUOVERCLOCK_ENV 	=  $(CROSS_ENV)
#CPUOVERCLOCK_ENV	+=
CPUOVERCLOCK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CPUOVERCLOCK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
CPUOVERCLOCK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
CPUOVERCLOCK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CPUOVERCLOCK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/cpuoverclock.prepare: $(cpuoverclock_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CPUOVERCLOCK_DIR)/config.cache)
	#cd $(CPUOVERCLOCK_DIR) && \
	#	$(CPUOVERCLOCK_PATH) $(CPUOVERCLOCK_ENV) \
	#	./configure $(CPUOVERCLOCK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

cpuoverclock_compile: $(STATEDIR)/cpuoverclock.compile

cpuoverclock_compile_deps = $(STATEDIR)/cpuoverclock.prepare

$(STATEDIR)/cpuoverclock.compile: $(cpuoverclock_compile_deps)
	@$(call targetinfo, $@)
	#$(CPUOVERCLOCK_PATH) $(MAKE) -C $(CPUOVERCLOCK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

cpuoverclock_install: $(STATEDIR)/cpuoverclock.install

$(STATEDIR)/cpuoverclock.install: $(STATEDIR)/cpuoverclock.compile
	@$(call targetinfo, $@)
	#$(CPUOVERCLOCK_PATH) $(MAKE) -C $(CPUOVERCLOCK_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

cpuoverclock_targetinstall: $(STATEDIR)/cpuoverclock.targetinstall

cpuoverclock_targetinstall_deps = $(STATEDIR)/cpuoverclock.compile \
	$(STATEDIR)/pygtk.targetinstall

$(STATEDIR)/cpuoverclock.targetinstall: $(cpuoverclock_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(CPUOVERCLOCK_PATH) $(MAKE) -C $(CPUOVERCLOCK_DIR) DESTDIR=$(CPUOVERCLOCK_IPKG_TMP) install
	mkdir -p $(CPUOVERCLOCK_IPKG_TMP)/CONTROL
	echo "Package: cpuoverclock" 							 >$(CPUOVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Source: $(CPUOVERCLOCK_URL)"						>>$(CPUOVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(CPUOVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(CPUOVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(CPUOVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(CPUOVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Version: $(CPUOVERCLOCK_VERSION)-$(CPUOVERCLOCK_VENDOR_VERSION)" 		>>$(CPUOVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Depends: pygtk, python-core, python-codecs, python-fcntl, python-io, python-math, python-stringold, python-xml" >>$(CPUOVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Description: CPU overclock utility"					>>$(CPUOVERCLOCK_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(CPUOVERCLOCK_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CPUOVERCLOCK_INSTALL
ROMPACKAGES += $(STATEDIR)/cpuoverclock.imageinstall
endif

cpuoverclock_imageinstall_deps = $(STATEDIR)/cpuoverclock.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/cpuoverclock.imageinstall: $(cpuoverclock_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install cpuoverclock
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

cpuoverclock_clean:
	rm -rf $(STATEDIR)/cpuoverclock.*
	rm -rf $(CPUOVERCLOCK_DIR)

# vim: syntax=make
