# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Adrian Crutchfield
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_MRXVT
PACKAGES += mrxvt
endif

#
# Paths and names
#
MRXVT_VENDOR_VERSION	= 1
MRXVT_VERSION	= 0.5.1
MRXVT		= mrxvt-$(MRXVT_VERSION)
MRXVT_SUFFIX		= tar.gz
MRXVT_URL		= http://umn.dl.sourceforge.net/sourceforge/materm//$(MRXVT).$(MRXVT_SUFFIX)
MRXVT_SOURCE		= $(SRCDIR)/$(MRXVT).$(MRXVT_SUFFIX)
MRXVT_DIR		= $(BUILDDIR)/$(MRXVT)
MRXVT_IPKG_TMP	= $(MRXVT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mrxvt_get: $(STATEDIR)/mrxvt.get

mrxvt_get_deps = $(MRXVT_SOURCE)

$(STATEDIR)/mrxvt.get: $(mrxvt_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MRXVT))
	touch $@

$(MRXVT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MRXVT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mrxvt_extract: $(STATEDIR)/mrxvt.extract

mrxvt_extract_deps = $(STATEDIR)/mrxvt.get

$(STATEDIR)/mrxvt.extract: $(mrxvt_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MRXVT_DIR))
	@$(call extract, $(MRXVT_SOURCE))
	@$(call patchin, $(MRXVT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mrxvt_prepare: $(STATEDIR)/mrxvt.prepare

#
# dependencies
#
mrxvt_prepare_deps = \
	$(STATEDIR)/mrxvt.extract \
	$(STATEDIR)/virtual-xchain.install

MRXVT_PATH	=  PATH=$(CROSS_PATH)
MRXVT_ENV 	=  $(CROSS_ENV)
#MRXVT_ENV	+=
MRXVT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MRXVT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MRXVT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-everything \
	--disable-debug 

ifdef PTXCONF_XFREE430
MRXVT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MRXVT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mrxvt.prepare: $(mrxvt_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MRXVT_DIR)/config.cache)
	cd $(MRXVT_DIR) && \
		$(MRXVT_PATH) $(MRXVT_ENV) \
		./configure $(MRXVT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mrxvt_compile: $(STATEDIR)/mrxvt.compile

mrxvt_compile_deps = $(STATEDIR)/mrxvt.prepare

$(STATEDIR)/mrxvt.compile: $(mrxvt_compile_deps)
	@$(call targetinfo, $@)
	$(MRXVT_PATH) $(MAKE) -C $(MRXVT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mrxvt_install: $(STATEDIR)/mrxvt.install

$(STATEDIR)/mrxvt.install: $(STATEDIR)/mrxvt.compile
	@$(call targetinfo, $@)
	rm -rf $(MRXVT_IPKG_TMP)
	$(MRXVT_PATH) $(MAKE) -C $(MRXVT_DIR) DESTDIR=$(MRXVT_IPKG_TMP) install
	@$(call copyincludes, $(MRXVT_IPKG_TMP))
	@$(call copylibraries,$(MRXVT_IPKG_TMP))
	@$(call copymiscfiles,$(MRXVT_IPKG_TMP))
	rm -rf $(MRXVT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mrxvt_targetinstall: $(STATEDIR)/mrxvt.targetinstall

mrxvt_targetinstall_deps = $(STATEDIR)/mrxvt.compile

MRXVT_DEPLIST = 

$(STATEDIR)/mrxvt.targetinstall: $(mrxvt_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MRXVT_PATH) $(MAKE) -C $(MRXVT_DIR) DESTDIR=$(MRXVT_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(MRXVT_VERSION)-$(MRXVT_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh mrxvt $(MRXVT_IPKG_TMP)

	@$(call removedevfiles, $(MRXVT_IPKG_TMP))
	@$(call stripfiles, $(MRXVT_IPKG_TMP))
	mkdir -p $(MRXVT_IPKG_TMP)/CONTROL
	echo "Package: mrxvt" 							 >$(MRXVT_IPKG_TMP)/CONTROL/control
	echo "Source: $(MRXVT_URL)"							>>$(MRXVT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MRXVT_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(MRXVT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(MRXVT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MRXVT_IPKG_TMP)/CONTROL/control
	echo "Version: $(MRXVT_VERSION)-$(MRXVT_VENDOR_VERSION)" 			>>$(MRXVT_IPKG_TMP)/CONTROL/control
	echo "Depends: $(MRXVT_DEPLIST)" 						>>$(MRXVT_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(MRXVT_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(MRXVT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MRXVT_INSTALL
ROMPACKAGES += $(STATEDIR)/mrxvt.imageinstall
endif

mrxvt_imageinstall_deps = $(STATEDIR)/mrxvt.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mrxvt.imageinstall: $(mrxvt_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mrxvt
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mrxvt_clean:
	rm -rf $(STATEDIR)/mrxvt.*
	rm -rf $(MRXVT_DIR)

# vim: syntax=make
