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
ifdef PTXCONF_NETPERF
PACKAGES += netperf
endif

#
# Paths and names
#
NETPERF_VENDOR_VERSION	= 1
NETPERF_VERSION		= 2.4.2
NETPERF			= netperf-$(NETPERF_VERSION)
NETPERF_SUFFIX		= tar.gz
NETPERF_URL		= ftp://ftp.netperf.org/netperf/$(NETPERF).$(NETPERF_SUFFIX)
NETPERF_SOURCE		= $(SRCDIR)/$(NETPERF).$(NETPERF_SUFFIX)
NETPERF_DIR		= $(BUILDDIR)/$(NETPERF)
NETPERF_IPKG_TMP	= $(NETPERF_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

netperf_get: $(STATEDIR)/netperf.get

netperf_get_deps = $(NETPERF_SOURCE)

$(STATEDIR)/netperf.get: $(netperf_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NETPERF))
	touch $@

$(NETPERF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NETPERF_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

netperf_extract: $(STATEDIR)/netperf.extract

netperf_extract_deps = $(STATEDIR)/netperf.get

$(STATEDIR)/netperf.extract: $(netperf_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NETPERF_DIR))
	@$(call extract, $(NETPERF_SOURCE))
	@$(call patchin, $(NETPERF))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

netperf_prepare: $(STATEDIR)/netperf.prepare

#
# dependencies
#
netperf_prepare_deps = \
	$(STATEDIR)/netperf.extract \
	$(STATEDIR)/virtual-xchain.install

NETPERF_PATH	=  PATH=$(CROSS_PATH)
NETPERF_ENV 	=  $(CROSS_ENV)
#NETPERF_ENV	+=
NETPERF_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NETPERF_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
NETPERF_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
NETPERF_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NETPERF_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/netperf.prepare: $(netperf_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NETPERF_DIR)/config.cache)
	cd $(NETPERF_DIR) && \
		$(NETPERF_PATH) $(NETPERF_ENV) \
		./configure $(NETPERF_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

netperf_compile: $(STATEDIR)/netperf.compile

netperf_compile_deps = $(STATEDIR)/netperf.prepare

$(STATEDIR)/netperf.compile: $(netperf_compile_deps)
	@$(call targetinfo, $@)
	$(NETPERF_PATH) $(MAKE) -C $(NETPERF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

netperf_install: $(STATEDIR)/netperf.install

$(STATEDIR)/netperf.install: $(STATEDIR)/netperf.compile
	@$(call targetinfo, $@)
	rm -rf $(NETPERF_IPKG_TMP)
	$(NETPERF_PATH) $(MAKE) -C $(NETPERF_DIR) DESTDIR=$(NETPERF_IPKG_TMP) install
	@$(call copyincludes, $(NETPERF_IPKG_TMP))
	@$(call copylibraries,$(NETPERF_IPKG_TMP))
	@$(call copymiscfiles,$(NETPERF_IPKG_TMP))
	rm -rf $(NETPERF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

netperf_targetinstall: $(STATEDIR)/netperf.targetinstall

netperf_targetinstall_deps = $(STATEDIR)/netperf.compile

NETPERF_DEPLIST = 

$(STATEDIR)/netperf.targetinstall: $(netperf_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NETPERF_PATH) $(MAKE) -C $(NETPERF_DIR) DESTDIR=$(NETPERF_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(NETPERF_VERSION)-$(NETPERF_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh netperf $(NETPERF_IPKG_TMP)

	@$(call removedevfiles, $(NETPERF_IPKG_TMP))
	@$(call stripfiles, $(NETPERF_IPKG_TMP))
	mkdir -p $(NETPERF_IPKG_TMP)/CONTROL
	echo "Package: netperf" 							 >$(NETPERF_IPKG_TMP)/CONTROL/control
	echo "Source: $(NETPERF_URL)"							>>$(NETPERF_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(NETPERF_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(NETPERF_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(NETPERF_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(NETPERF_IPKG_TMP)/CONTROL/control
	echo "Version: $(NETPERF_VERSION)-$(NETPERF_VENDOR_VERSION)" 			>>$(NETPERF_IPKG_TMP)/CONTROL/control
	echo "Depends: $(NETPERF_DEPLIST)" 						>>$(NETPERF_IPKG_TMP)/CONTROL/control
	echo "Description: network benchmarking"					>>$(NETPERF_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(NETPERF_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NETPERF_INSTALL
ROMPACKAGES += $(STATEDIR)/netperf.imageinstall
endif

netperf_imageinstall_deps = $(STATEDIR)/netperf.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/netperf.imageinstall: $(netperf_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install netperf
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

netperf_clean:
	rm -rf $(STATEDIR)/netperf.*
	rm -rf $(NETPERF_DIR)

# vim: syntax=make
