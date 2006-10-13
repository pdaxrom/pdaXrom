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
ifdef PTXCONF_GEDIT
PACKAGES += gedit
endif

#
# Paths and names
#
GEDIT_VENDOR_VERSION	= 1
GEDIT_VERSION		= 2.14.1
GEDIT			= gedit-$(GEDIT_VERSION)
GEDIT_SUFFIX		= tar.bz2
GEDIT_URL		= http://ftp.acc.umu.se/pub/GNOME/sources/gedit/2.14/$(GEDIT).$(GEDIT_SUFFIX)
GEDIT_SOURCE		= $(SRCDIR)/$(GEDIT).$(GEDIT_SUFFIX)
GEDIT_DIR		= $(BUILDDIR)/$(GEDIT)
GEDIT_IPKG_TMP		= $(GEDIT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gedit_get: $(STATEDIR)/gedit.get

gedit_get_deps = $(GEDIT_SOURCE)

$(STATEDIR)/gedit.get: $(gedit_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GEDIT))
	touch $@

$(GEDIT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GEDIT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gedit_extract: $(STATEDIR)/gedit.extract

gedit_extract_deps = $(STATEDIR)/gedit.get

$(STATEDIR)/gedit.extract: $(gedit_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GEDIT_DIR))
	@$(call extract, $(GEDIT_SOURCE))
	@$(call patchin, $(GEDIT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gedit_prepare: $(STATEDIR)/gedit.prepare

#
# dependencies
#
gedit_prepare_deps = \
	$(STATEDIR)/gedit.extract \
	$(STATEDIR)/virtual-xchain.install

GEDIT_PATH	=  PATH=$(CROSS_PATH)
GEDIT_ENV 	=  $(CROSS_ENV)
#GEDIT_ENV	+=
GEDIT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GEDIT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GEDIT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GEDIT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GEDIT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gedit.prepare: $(gedit_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GEDIT_DIR)/config.cache)
	cd $(GEDIT_DIR) && \
		$(GEDIT_PATH) $(GEDIT_ENV) \
		./configure $(GEDIT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gedit_compile: $(STATEDIR)/gedit.compile

gedit_compile_deps = $(STATEDIR)/gedit.prepare

$(STATEDIR)/gedit.compile: $(gedit_compile_deps)
	@$(call targetinfo, $@)
	$(GEDIT_PATH) $(MAKE) -C $(GEDIT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gedit_install: $(STATEDIR)/gedit.install

$(STATEDIR)/gedit.install: $(STATEDIR)/gedit.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gedit_targetinstall: $(STATEDIR)/gedit.targetinstall

gedit_targetinstall_deps = $(STATEDIR)/gedit.compile

$(STATEDIR)/gedit.targetinstall: $(gedit_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GEDIT_PATH) $(MAKE) -C $(GEDIT_DIR) DESTDIR=$(GEDIT_IPKG_TMP) install
	mkdir -p $(GEDIT_IPKG_TMP)/CONTROL
	echo "Package: gedit" 								 >$(GEDIT_IPKG_TMP)/CONTROL/control
	echo "Source: $(GEDIT_URL)"							>>$(GEDIT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GEDIT_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 								>>$(GEDIT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GEDIT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GEDIT_IPKG_TMP)/CONTROL/control
	echo "Version: $(GEDIT_VERSION)-$(GEDIT_VENDOR_VERSION)" 			>>$(GEDIT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(GEDIT_IPKG_TMP)/CONTROL/control
	echo "Description: gedit is the official text editor of the GNOME desktop environment." >>$(GEDIT_IPKG_TMP)/CONTROL/control
	asasd
	@$(call makeipkg, $(GEDIT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GEDIT_INSTALL
ROMPACKAGES += $(STATEDIR)/gedit.imageinstall
endif

gedit_imageinstall_deps = $(STATEDIR)/gedit.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gedit.imageinstall: $(gedit_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gedit
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gedit_clean:
	rm -rf $(STATEDIR)/gedit.*
	rm -rf $(GEDIT_DIR)

# vim: syntax=make
