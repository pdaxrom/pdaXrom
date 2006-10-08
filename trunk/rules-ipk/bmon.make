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
ifdef PTXCONF_BMON
PACKAGES += bmon
endif

#
# Paths and names
#
BMON_VENDOR_VERSION	= 1
BMON_VERSION		= 2.1.0
BMON			= bmon-$(BMON_VERSION)
BMON_SUFFIX		= tar.gz
BMON_URL		= http://people.suug.ch/~tgr/bmon/files/$(BMON).$(BMON_SUFFIX)
BMON_SOURCE		= $(SRCDIR)/$(BMON).$(BMON_SUFFIX)
BMON_DIR		= $(BUILDDIR)/$(BMON)
BMON_IPKG_TMP		= $(BMON_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

bmon_get: $(STATEDIR)/bmon.get

bmon_get_deps = $(BMON_SOURCE)

$(STATEDIR)/bmon.get: $(bmon_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BMON))
	touch $@

$(BMON_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BMON_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

bmon_extract: $(STATEDIR)/bmon.extract

bmon_extract_deps = $(STATEDIR)/bmon.get

$(STATEDIR)/bmon.extract: $(bmon_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BMON_DIR))
	@$(call extract, $(BMON_SOURCE))
	@$(call patchin, $(BMON))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

bmon_prepare: $(STATEDIR)/bmon.prepare

#
# dependencies
#
bmon_prepare_deps = \
	$(STATEDIR)/bmon.extract \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/virtual-xchain.install

BMON_PATH	=  PATH=$(CROSS_PATH)
BMON_ENV 	=  $(CROSS_ENV)
#BMON_ENV	+=
BMON_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BMON_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
BMON_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
BMON_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BMON_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/bmon.prepare: $(bmon_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BMON_DIR)/config.cache)
	cd $(BMON_DIR) && \
		$(BMON_PATH) $(BMON_ENV) \
		./configure $(BMON_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

bmon_compile: $(STATEDIR)/bmon.compile

bmon_compile_deps = $(STATEDIR)/bmon.prepare

$(STATEDIR)/bmon.compile: $(bmon_compile_deps)
	@$(call targetinfo, $@)
	$(BMON_PATH) $(MAKE) -C $(BMON_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bmon_install: $(STATEDIR)/bmon.install

$(STATEDIR)/bmon.install: $(STATEDIR)/bmon.compile
	@$(call targetinfo, $@)
	rm -rf $(BMON_IPKG_TMP)
	$(BMON_PATH) $(MAKE) -C $(BMON_DIR) DESTDIR=$(BMON_IPKG_TMP) install
	@$(call copyincludes, $(BMON_IPKG_TMP))
	@$(call copylibraries,$(BMON_IPKG_TMP))
	@$(call copymiscfiles,$(BMON_IPKG_TMP))
	rm -rf $(BMON_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

bmon_targetinstall: $(STATEDIR)/bmon.targetinstall

bmon_targetinstall_deps = $(STATEDIR)/bmon.compile \
	$(STATEDIR)/ncurses.targetinstall

BMON_DEPLIST = ncurses

$(STATEDIR)/bmon.targetinstall: $(bmon_targetinstall_deps)
	@$(call targetinfo, $@)
	$(BMON_PATH) $(MAKE) -C $(BMON_DIR) DESTDIR=$(BMON_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(BMON_VERSION)-$(BMON_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh bmon $(BMON_IPKG_TMP)

	@$(call removedevfiles, $(BMON_IPKG_TMP))
	@$(call stripfiles, $(BMON_IPKG_TMP))
	mkdir -p $(BMON_IPKG_TMP)/CONTROL
	echo "Package: bmon" 								 >$(BMON_IPKG_TMP)/CONTROL/control
	echo "Source: $(BMON_URL)"							>>$(BMON_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(BMON_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(BMON_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(BMON_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(BMON_IPKG_TMP)/CONTROL/control
	echo "Version: $(BMON_VERSION)-$(BMON_VENDOR_VERSION)" 				>>$(BMON_IPKG_TMP)/CONTROL/control
	echo "Depends: $(BMON_DEPLIST)" 						>>$(BMON_IPKG_TMP)/CONTROL/control
	echo "Description: Portable bandwidth monitor and rate estimator"		>>$(BMON_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BMON_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BMON_INSTALL
ROMPACKAGES += $(STATEDIR)/bmon.imageinstall
endif

bmon_imageinstall_deps = $(STATEDIR)/bmon.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/bmon.imageinstall: $(bmon_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install bmon
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bmon_clean:
	rm -rf $(STATEDIR)/bmon.*
	rm -rf $(BMON_DIR)

# vim: syntax=make
