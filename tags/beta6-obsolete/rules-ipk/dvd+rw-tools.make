# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_DVDRWTOOLS
PACKAGES += dvd+rw-tools
endif

#
# Paths and names
#
DVDRWTOOLS_VENDOR_VERSION	= 1
DVDRWTOOLS_VERSION		= 7.0
DVDRWTOOLS			= dvd+rw-tools-$(DVDRWTOOLS_VERSION)
DVDRWTOOLS_SUFFIX		= tar.gz
DVDRWTOOLS_URL			= http://fy.chalmers.se/~appro/linux/DVD+RW/tools/$(DVDRWTOOLS).$(DVDRWTOOLS_SUFFIX)
DVDRWTOOLS_SOURCE		= $(SRCDIR)/$(DVDRWTOOLS).$(DVDRWTOOLS_SUFFIX)
DVDRWTOOLS_DIR			= $(BUILDDIR)/$(DVDRWTOOLS)
DVDRWTOOLS_IPKG_TMP		= $(DVDRWTOOLS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dvd+rw-tools_get: $(STATEDIR)/dvd+rw-tools.get

dvd+rw-tools_get_deps = $(DVDRWTOOLS_SOURCE)

$(STATEDIR)/dvd+rw-tools.get: $(dvd+rw-tools_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DVDRWTOOLS))
	touch $@

$(DVDRWTOOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DVDRWTOOLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dvd+rw-tools_extract: $(STATEDIR)/dvd+rw-tools.extract

dvd+rw-tools_extract_deps = $(STATEDIR)/dvd+rw-tools.get

$(STATEDIR)/dvd+rw-tools.extract: $(dvd+rw-tools_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DVDRWTOOLS_DIR))
	@$(call extract, $(DVDRWTOOLS_SOURCE))
	@$(call patchin, $(DVDRWTOOLS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dvd+rw-tools_prepare: $(STATEDIR)/dvd+rw-tools.prepare

#
# dependencies
#
dvd+rw-tools_prepare_deps = \
	$(STATEDIR)/dvd+rw-tools.extract \
	$(STATEDIR)/virtual-xchain.install

DVDRWTOOLS_PATH	=  PATH=$(CROSS_PATH)
DVDRWTOOLS_ENV 	=  $(CROSS_ENV)
#DVDRWTOOLS_ENV	+=
DVDRWTOOLS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DVDRWTOOLS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
DVDRWTOOLS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
DVDRWTOOLS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DVDRWTOOLS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dvd+rw-tools.prepare: $(dvd+rw-tools_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DVDRWTOOLS_DIR)/config.cache)
	#cd $(DVDRWTOOLS_DIR) && \
	#	$(DVDRWTOOLS_PATH) $(DVDRWTOOLS_ENV) \
	#	./configure $(DVDRWTOOLS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dvd+rw-tools_compile: $(STATEDIR)/dvd+rw-tools.compile

dvd+rw-tools_compile_deps = $(STATEDIR)/dvd+rw-tools.prepare

$(STATEDIR)/dvd+rw-tools.compile: $(dvd+rw-tools_compile_deps)
	@$(call targetinfo, $@)
	$(DVDRWTOOLS_PATH) $(MAKE) -C $(DVDRWTOOLS_DIR) $(CROSS_ENV_CC) $(CROSS_ENV_CXX)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dvd+rw-tools_install: $(STATEDIR)/dvd+rw-tools.install

$(STATEDIR)/dvd+rw-tools.install: $(STATEDIR)/dvd+rw-tools.compile
	@$(call targetinfo, $@)
	#rm -rf $(DVDRWTOOLS_IPKG_TMP)
	#$(DVDRWTOOLS_PATH) $(MAKE) -C $(DVDRWTOOLS_DIR) prefix=$(DVDRWTOOLS_IPKG_TMP)/usr install
	#@$(call copyincludes, $(DVDRWTOOLS_IPKG_TMP))
	#@$(call copylibraries,$(DVDRWTOOLS_IPKG_TMP))
	#@$(call copymiscfiles,$(DVDRWTOOLS_IPKG_TMP))
	#rm -rf $(DVDRWTOOLS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dvd+rw-tools_targetinstall: $(STATEDIR)/dvd+rw-tools.targetinstall

dvd+rw-tools_targetinstall_deps = $(STATEDIR)/dvd+rw-tools.compile

DVDRWTOOLS_DEPLIST = 

$(STATEDIR)/dvd+rw-tools.targetinstall: $(dvd+rw-tools_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DVDRWTOOLS_PATH) $(MAKE) -C $(DVDRWTOOLS_DIR) prefix=$(DVDRWTOOLS_IPKG_TMP)/usr install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(DVDRWTOOLS_VERSION)-$(DVDRWTOOLS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh dvd+rw-tools $(DVDRWTOOLS_IPKG_TMP)

	@$(call removedevfiles, $(DVDRWTOOLS_IPKG_TMP))
	@$(call stripfiles, $(DVDRWTOOLS_IPKG_TMP))
	mkdir -p $(DVDRWTOOLS_IPKG_TMP)/CONTROL
	echo "Package: dvd+rw-tools" 							 >$(DVDRWTOOLS_IPKG_TMP)/CONTROL/control
	echo "Source: $(DVDRWTOOLS_URL)"						>>$(DVDRWTOOLS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DVDRWTOOLS_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(DVDRWTOOLS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DVDRWTOOLS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DVDRWTOOLS_IPKG_TMP)/CONTROL/control
	echo "Version: $(DVDRWTOOLS_VERSION)-$(DVDRWTOOLS_VENDOR_VERSION)" 		>>$(DVDRWTOOLS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(DVDRWTOOLS_DEPLIST)" 						>>$(DVDRWTOOLS_IPKG_TMP)/CONTROL/control
	echo "Description: DVD+RW tools"						>>$(DVDRWTOOLS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(DVDRWTOOLS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DVDRWTOOLS_INSTALL
ROMPACKAGES += $(STATEDIR)/dvd+rw-tools.imageinstall
endif

dvd+rw-tools_imageinstall_deps = $(STATEDIR)/dvd+rw-tools.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dvd+rw-tools.imageinstall: $(dvd+rw-tools_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dvd+rw-tools
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dvd+rw-tools_clean:
	rm -rf $(STATEDIR)/dvd+rw-tools.*
	rm -rf $(DVDRWTOOLS_DIR)

# vim: syntax=make
