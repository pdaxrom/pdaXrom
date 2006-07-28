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
ifdef PTXCONF_PORTMAP
PACKAGES += portmap
endif

#
# Paths and names
#
PORTMAP_VENDOR_VERSION	= 1
PORTMAP_VERSION		= 5
PORTMAP			= portmap_$(PORTMAP_VERSION)
PORTMAP_SUFFIX		= orig.tar.gz
PORTMAP_URL		= http://www.uk.debian.org/debian/pool/main/p/portmap/$(PORTMAP).$(PORTMAP_SUFFIX)
PORTMAP_SOURCE		= $(SRCDIR)/$(PORTMAP).$(PORTMAP_SUFFIX)
PORTMAP_DIR		= $(BUILDDIR)/portmap_5beta
PORTMAP_IPKG_TMP	= $(PORTMAP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

portmap_get: $(STATEDIR)/portmap.get

portmap_get_deps = $(PORTMAP_SOURCE)

$(STATEDIR)/portmap.get: $(portmap_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PORTMAP))
	touch $@

$(PORTMAP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PORTMAP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

portmap_extract: $(STATEDIR)/portmap.extract

portmap_extract_deps = $(STATEDIR)/portmap.get

$(STATEDIR)/portmap.extract: $(portmap_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(PORTMAP_DIR))
	@$(call extract, $(PORTMAP_SOURCE))
	@$(call patchin, $(PORTMAP), $(PORTMAP_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

portmap_prepare: $(STATEDIR)/portmap.prepare

#
# dependencies
#
portmap_prepare_deps = \
	$(STATEDIR)/portmap.extract \
	$(STATEDIR)/virtual-xchain.install

PORTMAP_PATH	=  PATH=$(CROSS_PATH)
PORTMAP_ENV 	=  $(CROSS_ENV)
#PORTMAP_ENV	+=
PORTMAP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PORTMAP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PORTMAP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PORTMAP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PORTMAP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/portmap.prepare: $(portmap_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PORTMAP_DIR)/config.cache)
	#cd $(PORTMAP_DIR) && \
	#	$(PORTMAP_PATH) $(PORTMAP_ENV) \
	#	./configure $(PORTMAP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

portmap_compile: $(STATEDIR)/portmap.compile

portmap_compile_deps = $(STATEDIR)/portmap.prepare

$(STATEDIR)/portmap.compile: $(portmap_compile_deps)
	@$(call targetinfo, $@)
	$(PORTMAP_PATH) $(PORTMAP_ENV) $(MAKE) -C $(PORTMAP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

portmap_install: $(STATEDIR)/portmap.install

$(STATEDIR)/portmap.install: $(STATEDIR)/portmap.compile
	@$(call targetinfo, $@)
	#$(PORTMAP_PATH) $(MAKE) -C $(PORTMAP_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

portmap_targetinstall: $(STATEDIR)/portmap.targetinstall

portmap_targetinstall_deps = $(STATEDIR)/portmap.compile

$(STATEDIR)/portmap.targetinstall: $(portmap_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PORTMAP_PATH) $(MAKE) -C $(PORTMAP_DIR) BASEDIR=$(PORTMAP_IPKG_TMP) install
	$(CROSSSTRIP) $(PORTMAP_IPKG_TMP)/sbin/*
	mkdir -p $(PORTMAP_IPKG_TMP)/CONTROL
	echo "Package: portmap" 							 >$(PORTMAP_IPKG_TMP)/CONTROL/control
	echo "Source: $(PORTMAP_URL)"							>>$(PORTMAP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PORTMAP_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(PORTMAP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PORTMAP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PORTMAP_IPKG_TMP)/CONTROL/control
	echo "Version: $(PORTMAP_VERSION)-$(PORTMAP_VENDOR_VERSION)" 			>>$(PORTMAP_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(PORTMAP_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(PORTMAP_IPKG_TMP)/CONTROL/control
	
	echo "#!/bin/sh"								 >$(PORTMAP_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/portmap start"						>>$(PORTMAP_IPKG_TMP)/CONTROL/postinst

	echo "#!/bin/sh"								 >$(PORTMAP_IPKG_TMP)/CONTROL/prerm
	echo "/etc/rc.d/init.d/portmap stop"						>>$(PORTMAP_IPKG_TMP)/CONTROL/prerm
	
	chmod 755 $(PORTMAP_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(PORTMAP_IPKG_TMP)/CONTROL/prerm
	
	cd $(FEEDDIR) && $(XMKIPKG) $(PORTMAP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PORTMAP_INSTALL
ROMPACKAGES += $(STATEDIR)/portmap.imageinstall
endif

portmap_imageinstall_deps = $(STATEDIR)/portmap.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/portmap.imageinstall: $(portmap_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install portmap
	rm -f $(ROOTDIR)/usr/lib/ipkg/info/portmap.postinst
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

portmap_clean:
	rm -rf $(STATEDIR)/portmap.*
	rm -rf $(PORTMAP_DIR)

# vim: syntax=make
