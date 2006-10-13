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
ifdef PTXCONF_LIRC
PACKAGES += lirc
endif

#
# Paths and names
#
LIRC_VENDOR_VERSION	= 1
LIRC_VERSION		= 0.7.2
LIRC			= lirc-$(LIRC_VERSION)
LIRC_SUFFIX		= tar.bz2
LIRC_URL		= http://kent.dl.sourceforge.net/sourceforge/lirc/$(LIRC).$(LIRC_SUFFIX)
LIRC_SOURCE		= $(SRCDIR)/$(LIRC).$(LIRC_SUFFIX)
LIRC_DIR		= $(BUILDDIR)/$(LIRC)
LIRC_IPKG_TMP		= $(LIRC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lirc_get: $(STATEDIR)/lirc.get

lirc_get_deps = $(LIRC_SOURCE)

$(STATEDIR)/lirc.get: $(lirc_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIRC))
	touch $@

$(LIRC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIRC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lirc_extract: $(STATEDIR)/lirc.extract

lirc_extract_deps = $(STATEDIR)/lirc.get

$(STATEDIR)/lirc.extract: $(lirc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIRC_DIR))
	@$(call extract, $(LIRC_SOURCE))
	@$(call patchin, $(LIRC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lirc_prepare: $(STATEDIR)/lirc.prepare

#
# dependencies
#
lirc_prepare_deps = \
	$(STATEDIR)/lirc.extract \
	$(STATEDIR)/virtual-xchain.install

LIRC_PATH	=  PATH=$(CROSS_PATH)
LIRC_ENV 	=  $(CROSS_ENV)
#LIRC_ENV	+=
LIRC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIRC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIRC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LIRC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIRC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/lirc.prepare: $(lirc_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIRC_DIR)/config.cache)
	cd $(LIRC_DIR) && \
		$(LIRC_PATH) $(LIRC_ENV) \
		./configure $(LIRC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lirc_compile: $(STATEDIR)/lirc.compile

lirc_compile_deps = $(STATEDIR)/lirc.prepare

$(STATEDIR)/lirc.compile: $(lirc_compile_deps)
	@$(call targetinfo, $@)
	$(LIRC_PATH) $(MAKE) -C $(LIRC_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lirc_install: $(STATEDIR)/lirc.install

$(STATEDIR)/lirc.install: $(STATEDIR)/lirc.compile
	@$(call targetinfo, $@)
	$(LIRC_PATH) $(MAKE) -C $(LIRC_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lirc_targetinstall: $(STATEDIR)/lirc.targetinstall

lirc_targetinstall_deps = $(STATEDIR)/lirc.compile

$(STATEDIR)/lirc.targetinstall: $(lirc_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIRC_PATH) $(MAKE) -C $(LIRC_DIR) DESTDIR=$(LIRC_IPKG_TMP) install
	mkdir -p $(LIRC_IPKG_TMP)/CONTROL
	echo "Package: lirc" 								 >$(LIRC_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIRC_URL)"							>>$(LIRC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIRC_IPKG_TMP)/CONTROL/control
	echo "Section: Drivers" 							>>$(LIRC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIRC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIRC_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIRC_VERSION)-$(LIRC_VENDOR_VERSION)" 				>>$(LIRC_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LIRC_IPKG_TMP)/CONTROL/control
	echo "Description:  LIRC is a package that allows you to decode and send infra-red signals of many (but not all) commonly used remote controls." >>$(LIRC_IPKG_TMP)/CONTROL/control
	asdasd
	@$(call makeipkg, $(LIRC_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIRC_INSTALL
ROMPACKAGES += $(STATEDIR)/lirc.imageinstall
endif

lirc_imageinstall_deps = $(STATEDIR)/lirc.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/lirc.imageinstall: $(lirc_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lirc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lirc_clean:
	rm -rf $(STATEDIR)/lirc.*
	rm -rf $(LIRC_DIR)

# vim: syntax=make
