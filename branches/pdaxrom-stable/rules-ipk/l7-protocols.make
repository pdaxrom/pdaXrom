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
ifdef PTXCONF_L7-PROTOCOLS
PACKAGES += l7-protocols
endif

#
# Paths and names
#
L7-PROTOCOLS_VENDOR_VERSION	= 1
L7-PROTOCOLS_VERSION		= 2006-09-10
L7-PROTOCOLS			= l7-protocols-$(L7-PROTOCOLS_VERSION)
L7-PROTOCOLS_SUFFIX		= tar.gz
L7-PROTOCOLS_URL		= http://belnet.dl.sourceforge.net/sourceforge/l7-filter/$(L7-PROTOCOLS).$(L7-PROTOCOLS_SUFFIX)
L7-PROTOCOLS_SOURCE		= $(SRCDIR)/$(L7-PROTOCOLS).$(L7-PROTOCOLS_SUFFIX)
L7-PROTOCOLS_DIR		= $(BUILDDIR)/$(L7-PROTOCOLS)
L7-PROTOCOLS_IPKG_TMP		= $(L7-PROTOCOLS_DIR)-ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

l7-protocols_get: $(STATEDIR)/l7-protocols.get

l7-protocols_get_deps = $(L7-PROTOCOLS_SOURCE)

$(STATEDIR)/l7-protocols.get: $(l7-protocols_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(L7-PROTOCOLS))
	touch $@

$(L7-PROTOCOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(L7-PROTOCOLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

l7-protocols_extract: $(STATEDIR)/l7-protocols.extract

l7-protocols_extract_deps = $(STATEDIR)/l7-protocols.get

$(STATEDIR)/l7-protocols.extract: $(l7-protocols_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(L7-PROTOCOLS_DIR))
	@$(call extract, $(L7-PROTOCOLS_SOURCE))
	@$(call patchin, $(L7-PROTOCOLS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

l7-protocols_prepare: $(STATEDIR)/l7-protocols.prepare

#
# dependencies
#
l7-protocols_prepare_deps = \
	$(STATEDIR)/l7-protocols.extract \
	$(STATEDIR)/virtual-xchain.install

L7-PROTOCOLS_PATH	=  PATH=$(CROSS_PATH)
L7-PROTOCOLS_ENV 	=  $(CROSS_ENV)
#L7-PROTOCOLS_ENV	+=
L7-PROTOCOLS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#L7-PROTOCOLS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
L7-PROTOCOLS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
L7-PROTOCOLS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
L7-PROTOCOLS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/l7-protocols.prepare: $(l7-protocols_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(L7-PROTOCOLS_DIR)/config.cache)
	#cd $(L7-PROTOCOLS_DIR) && \
	#	$(L7-PROTOCOLS_PATH) $(L7-PROTOCOLS_ENV) \
	#	./configure $(L7-PROTOCOLS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

l7-protocols_compile: $(STATEDIR)/l7-protocols.compile

l7-protocols_compile_deps = $(STATEDIR)/l7-protocols.prepare

$(STATEDIR)/l7-protocols.compile: $(l7-protocols_compile_deps)
	@$(call targetinfo, $@)
	#$(L7-PROTOCOLS_PATH) $(MAKE) -C $(L7-PROTOCOLS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

l7-protocols_install: $(STATEDIR)/l7-protocols.install

$(STATEDIR)/l7-protocols.install: $(STATEDIR)/l7-protocols.compile
	@$(call targetinfo, $@)
	#rm -rf $(L7-PROTOCOLS_IPKG_TMP)
	#$(L7-PROTOCOLS_PATH) $(MAKE) -C $(L7-PROTOCOLS_DIR) DESTDIR=$(L7-PROTOCOLS_IPKG_TMP) install
	#@$(call copyincludes, $(L7-PROTOCOLS_IPKG_TMP))
	#@$(call copylibraries,$(L7-PROTOCOLS_IPKG_TMP))
	#@$(call copymiscfiles,$(L7-PROTOCOLS_IPKG_TMP))
	#rm -rf $(L7-PROTOCOLS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

l7-protocols_targetinstall: $(STATEDIR)/l7-protocols.targetinstall

l7-protocols_targetinstall_deps = $(STATEDIR)/l7-protocols.compile

L7-PROTOCOLS_DEPLIST = 

$(STATEDIR)/l7-protocols.targetinstall: $(l7-protocols_targetinstall_deps)
	@$(call targetinfo, $@)

	#mkdir -p $(L7-PROTOCOLS_IPKG_TMP)/etc

	$(L7-PROTOCOLS_PATH) $(MAKE) -C $(L7-PROTOCOLS_DIR) PREFIX=$(L7-PROTOCOLS_IPKG_TMP) install

	#PATH=$(CROSS_PATH) 						\
	#FEEDDIR=$(FEEDDIR) 						\
	#STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	#VERSION=$(L7-PROTOCOLS_VERSION)-$(L7-PROTOCOLS_VENDOR_VERSION)	 	\
	#ARCH=$(SHORT_TARGET) 						\
	#MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	#$(TOPDIR)/scripts/bin/make-locale-ipks.sh l7-protocols $(L7-PROTOCOLS_IPKG_TMP)

	#@$(call removedevfiles, $(L7-PROTOCOLS_IPKG_TMP))
	#@$(call stripfiles, $(L7-PROTOCOLS_IPKG_TMP))

	mkdir -p $(L7-PROTOCOLS_IPKG_TMP)/CONTROL
	echo "Package: l7-protocols" 							 >$(L7-PROTOCOLS_IPKG_TMP)/CONTROL/control
	echo "Source: $(L7-PROTOCOLS_URL)"							>>$(L7-PROTOCOLS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(L7-PROTOCOLS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(L7-PROTOCOLS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(L7-PROTOCOLS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(L7-PROTOCOLS_IPKG_TMP)/CONTROL/control
	echo "Version: $(L7-PROTOCOLS_VERSION)-$(L7-PROTOCOLS_VENDOR_VERSION)" 			>>$(L7-PROTOCOLS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(L7-PROTOCOLS_DEPLIST)" 						>>$(L7-PROTOCOLS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(L7-PROTOCOLS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(L7-PROTOCOLS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_L7-PROTOCOLS_INSTALL
ROMPACKAGES += $(STATEDIR)/l7-protocols.imageinstall
endif

l7-protocols_imageinstall_deps = $(STATEDIR)/l7-protocols.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/l7-protocols.imageinstall: $(l7-protocols_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install l7-protocols
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

l7-protocols_clean:
	rm -rf $(STATEDIR)/l7-protocols.*
	rm -rf $(L7-PROTOCOLS_DIR)
	rm -rf $(L7-PROTOCOLS_IPKG_TMP)

# vim: syntax=make
