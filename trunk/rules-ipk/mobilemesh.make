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
ifdef PTXCONF_MOBILEMESH
PACKAGES += mobilemesh
endif

#
# Paths and names
#
MOBILEMESH_VENDOR_VERSION	= 1
MOBILEMESH_VERSION		= 1.2
MOBILEMESH			= mobilemesh_$(MOBILEMESH_VERSION)
MOBILEMESH_SUFFIX		= tgz
MOBILEMESH_URL			= http://meshcube.org/download/$(MOBILEMESH).$(MOBILEMESH_SUFFIX)
MOBILEMESH_SOURCE		= $(SRCDIR)/$(MOBILEMESH).$(MOBILEMESH_SUFFIX)
MOBILEMESH_DIR			= $(BUILDDIR)/mobilemesh
MOBILEMESH_IPKG_TMP		= $(MOBILEMESH_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mobilemesh_get: $(STATEDIR)/mobilemesh.get

mobilemesh_get_deps = $(MOBILEMESH_SOURCE)

$(STATEDIR)/mobilemesh.get: $(mobilemesh_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MOBILEMESH))
	touch $@

$(MOBILEMESH_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MOBILEMESH_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mobilemesh_extract: $(STATEDIR)/mobilemesh.extract

mobilemesh_extract_deps = $(STATEDIR)/mobilemesh.get

$(STATEDIR)/mobilemesh.extract: $(mobilemesh_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, 	 $(MOBILEMESH_DIR))
	@$(call extract, $(MOBILEMESH_SOURCE))
	@$(call patchin, $(MOBILEMESH), $(MOBILEMESH_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mobilemesh_prepare: $(STATEDIR)/mobilemesh.prepare

#
# dependencies
#
mobilemesh_prepare_deps = \
	$(STATEDIR)/mobilemesh.extract \
	$(STATEDIR)/virtual-xchain.install

MOBILEMESH_PATH	=  PATH=$(CROSS_PATH)
MOBILEMESH_ENV 	=  $(CROSS_ENV)
#MOBILEMESH_ENV	+=
MOBILEMESH_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MOBILEMESH_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MOBILEMESH_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MOBILEMESH_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MOBILEMESH_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mobilemesh.prepare: $(mobilemesh_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MOBILEMESH_DIR)/config.cache)
	#cd $(MOBILEMESH_DIR) && \
	#	$(MOBILEMESH_PATH) $(MOBILEMESH_ENV) \
	#	./configure $(MOBILEMESH_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mobilemesh_compile: $(STATEDIR)/mobilemesh.compile

mobilemesh_compile_deps = $(STATEDIR)/mobilemesh.prepare

$(STATEDIR)/mobilemesh.compile: $(mobilemesh_compile_deps)
	@$(call targetinfo, $@)
	$(MOBILEMESH_PATH) $(MAKE) -C $(MOBILEMESH_DIR) $(CROSS_ENV_CC) $(CROSS_ENV_CXX) $(CROSS_ENV_STRIP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mobilemesh_install: $(STATEDIR)/mobilemesh.install

$(STATEDIR)/mobilemesh.install: $(STATEDIR)/mobilemesh.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mobilemesh_targetinstall: $(STATEDIR)/mobilemesh.targetinstall

mobilemesh_targetinstall_deps = $(STATEDIR)/mobilemesh.compile

$(STATEDIR)/mobilemesh.targetinstall: $(mobilemesh_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(MOBILEMESH_IPKG_TMP)/usr/sbin
	$(MOBILEMESH_PATH) $(MAKE) -C $(MOBILEMESH_DIR) DESTDIR=$(MOBILEMESH_IPKG_TMP) install $(CROSS_ENV_STRIP)
	mkdir -p $(MOBILEMESH_IPKG_TMP)/CONTROL
	echo "Package: mobilemesh" 							 >$(MOBILEMESH_IPKG_TMP)/CONTROL/control
	echo "Source: $(MOBILEMESH_URL)"						>>$(MOBILEMESH_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MOBILEMESH_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(MOBILEMESH_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(MOBILEMESH_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MOBILEMESH_IPKG_TMP)/CONTROL/control
	echo "Version: $(MOBILEMESH_VERSION)-$(MOBILEMESH_VENDOR_VERSION)" 		>>$(MOBILEMESH_IPKG_TMP)/CONTROL/control
	echo "Depends: iproute2, openssl" 						>>$(MOBILEMESH_IPKG_TMP)/CONTROL/control
	echo "Description: Mobile ad hoc networking allows users to exchange information in a wireless environment without the need for a fixed infrastructure." >>$(MOBILEMESH_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MOBILEMESH_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MOBILEMESH_INSTALL
ROMPACKAGES += $(STATEDIR)/mobilemesh.imageinstall
endif

mobilemesh_imageinstall_deps = $(STATEDIR)/mobilemesh.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mobilemesh.imageinstall: $(mobilemesh_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mobilemesh
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mobilemesh_clean:
	rm -rf $(STATEDIR)/mobilemesh.*
	rm -rf $(MOBILEMESH_DIR)

# vim: syntax=make
