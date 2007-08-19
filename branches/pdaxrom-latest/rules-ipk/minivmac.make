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
ifdef PTXCONF_MINIVMAC
PACKAGES += minivmac
endif

#
# Paths and names
#
MINIVMAC_VENDOR_VERSION	= 1
MINIVMAC_VERSION	= 2.7.0
MINIVMAC		= minivmac-$(MINIVMAC_VERSION).src
MINIVMAC_SUFFIX		= tgz
MINIVMAC_URL		= http://citkit.dl.sourceforge.net/sourceforge/minivmac/$(MINIVMAC).$(MINIVMAC_SUFFIX)
MINIVMAC_SOURCE		= $(SRCDIR)/$(MINIVMAC).$(MINIVMAC_SUFFIX)
MINIVMAC_DIR		= $(BUILDDIR)/$(MINIVMAC)
MINIVMAC_IPKG_TMP	= $(MINIVMAC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

minivmac_get: $(STATEDIR)/minivmac.get

minivmac_get_deps = $(MINIVMAC_SOURCE)

$(STATEDIR)/minivmac.get: $(minivmac_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MINIVMAC))
	touch $@

$(MINIVMAC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MINIVMAC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

minivmac_extract: $(STATEDIR)/minivmac.extract

minivmac_extract_deps = $(STATEDIR)/minivmac.get

$(STATEDIR)/minivmac.extract: $(minivmac_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(MINIVMAC_DIR))
	@$(call extract, $(MINIVMAC_SOURCE), $(MINIVMAC_DIR))
	@$(call patchin, $(MINIVMAC), $(MINIVMAC_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

minivmac_prepare: $(STATEDIR)/minivmac.prepare

#
# dependencies
#
minivmac_prepare_deps = \
	$(STATEDIR)/minivmac.extract \
	$(STATEDIR)/virtual-xchain.install

MINIVMAC_PATH	=  PATH=$(CROSS_PATH)
MINIVMAC_ENV 	=  $(CROSS_ENV)
#MINIVMAC_ENV	+=
MINIVMAC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MINIVMAC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MINIVMAC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MINIVMAC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MINIVMAC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/minivmac.prepare: $(minivmac_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MINIVMAC_DIR)/config.cache)
	#cd $(MINIVMAC_DIR) && \
	#	$(MINIVMAC_PATH) $(MINIVMAC_ENV) \
	#	./configure $(MINIVMAC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

minivmac_compile: $(STATEDIR)/minivmac.compile

minivmac_compile_deps = $(STATEDIR)/minivmac.prepare

$(STATEDIR)/minivmac.compile: $(minivmac_compile_deps)
	@$(call targetinfo, $@)
	cd $(MINIVMAC_DIR)/source && $(MINIVMAC_PATH) host_cc=gcc my_cc=$(PTXCONF_GNU_TARGET)-gcc sh build/bash
	###$(MAKE) -C $(MINIVMAC_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

minivmac_install: $(STATEDIR)/minivmac.install

$(STATEDIR)/minivmac.install: $(STATEDIR)/minivmac.compile
	@$(call targetinfo, $@)
	###$(MINIVMAC_PATH) $(MAKE) -C $(MINIVMAC_DIR) install
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

minivmac_targetinstall: $(STATEDIR)/minivmac.targetinstall

minivmac_targetinstall_deps = $(STATEDIR)/minivmac.compile

$(STATEDIR)/minivmac.targetinstall: $(minivmac_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(MINIVMAC_PATH) $(MAKE) -C $(MINIVMAC_DIR) DESTDIR=$(MINIVMAC_IPKG_TMP) install
	mkdir -p $(MINIVMAC_IPKG_TMP)/usr/bin
	cp -a $(MINIVMAC_DIR)/source/output/minivmac $(MINIVMAC_IPKG_TMP)/usr/bin
	$(CROSSSTRIP) $(MINIVMAC_IPKG_TMP)/usr/bin/minivmac
	mkdir -p $(MINIVMAC_IPKG_TMP)/CONTROL
	echo "Package: minivmac" 							 >$(MINIVMAC_IPKG_TMP)/CONTROL/control
	echo "Source: $(MINIVMAC_URL)"						>>$(MINIVMAC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MINIVMAC_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(MINIVMAC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(MINIVMAC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MINIVMAC_IPKG_TMP)/CONTROL/control
	echo "Version: $(MINIVMAC_VERSION)-$(MINIVMAC_VENDOR_VERSION)" 			>>$(MINIVMAC_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree" 								>>$(MINIVMAC_IPKG_TMP)/CONTROL/control
	echo "Description: Mini vMac emulates a Macintosh Plus, one of the earliest of Macintosh computers, sold between 1986 and 1990." >>$(MINIVMAC_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(MINIVMAC_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MINIVMAC_INSTALL
ROMPACKAGES += $(STATEDIR)/minivmac.imageinstall
endif

minivmac_imageinstall_deps = $(STATEDIR)/minivmac.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/minivmac.imageinstall: $(minivmac_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install minivmac
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

minivmac_clean:
	rm -rf $(STATEDIR)/minivmac.*
	rm -rf $(MINIVMAC_DIR)

# vim: syntax=make
