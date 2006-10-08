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
ifdef PTXCONF_IFTOP
PACKAGES += iftop
endif

#
# Paths and names
#
IFTOP_VENDOR_VERSION	= 1
IFTOP_VERSION		= 0.17
IFTOP			= iftop-$(IFTOP_VERSION)
IFTOP_SUFFIX		= tar.gz
IFTOP_URL		= http://www.ex-parrot.com/~pdw/iftop/download/$(IFTOP).$(IFTOP_SUFFIX)
IFTOP_SOURCE		= $(SRCDIR)/$(IFTOP).$(IFTOP_SUFFIX)
IFTOP_DIR		= $(BUILDDIR)/$(IFTOP)
IFTOP_IPKG_TMP		= $(IFTOP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

iftop_get: $(STATEDIR)/iftop.get

iftop_get_deps = $(IFTOP_SOURCE)

$(STATEDIR)/iftop.get: $(iftop_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(IFTOP))
	touch $@

$(IFTOP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(IFTOP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

iftop_extract: $(STATEDIR)/iftop.extract

iftop_extract_deps = $(STATEDIR)/iftop.get

$(STATEDIR)/iftop.extract: $(iftop_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IFTOP_DIR))
	@$(call extract, $(IFTOP_SOURCE))
	@$(call patchin, $(IFTOP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

iftop_prepare: $(STATEDIR)/iftop.prepare

#
# dependencies
#
iftop_prepare_deps = \
	$(STATEDIR)/iftop.extract \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/libpcap.install \
	$(STATEDIR)/virtual-xchain.install

IFTOP_PATH	=  PATH=$(CROSS_PATH)
IFTOP_ENV 	=  $(CROSS_ENV)
#IFTOP_ENV	+=
IFTOP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#IFTOP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
IFTOP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
IFTOP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
IFTOP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/iftop.prepare: $(iftop_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IFTOP_DIR)/config.cache)
	cd $(IFTOP_DIR) && \
		$(IFTOP_PATH) $(IFTOP_ENV) \
		./configure $(IFTOP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

iftop_compile: $(STATEDIR)/iftop.compile

iftop_compile_deps = $(STATEDIR)/iftop.prepare

$(STATEDIR)/iftop.compile: $(iftop_compile_deps)
	@$(call targetinfo, $@)
	$(IFTOP_PATH) $(MAKE) -C $(IFTOP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

iftop_install: $(STATEDIR)/iftop.install

$(STATEDIR)/iftop.install: $(STATEDIR)/iftop.compile
	@$(call targetinfo, $@)
	rm -rf $(IFTOP_IPKG_TMP)
	$(IFTOP_PATH) $(MAKE) -C $(IFTOP_DIR) DESTDIR=$(IFTOP_IPKG_TMP) install
	@$(call copyincludes, $(IFTOP_IPKG_TMP))
	@$(call copylibraries,$(IFTOP_IPKG_TMP))
	@$(call copymiscfiles,$(IFTOP_IPKG_TMP))
	rm -rf $(IFTOP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

iftop_targetinstall: $(STATEDIR)/iftop.targetinstall

iftop_targetinstall_deps = $(STATEDIR)/iftop.compile \
	$(STATEDIR)/ncurses.targetinstall

IFTOP_DEPLIST = ncurses

$(STATEDIR)/iftop.targetinstall: $(iftop_targetinstall_deps)
	@$(call targetinfo, $@)
	$(IFTOP_PATH) $(MAKE) -C $(IFTOP_DIR) DESTDIR=$(IFTOP_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(IFTOP_VERSION)-$(IFTOP_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh iftop $(IFTOP_IPKG_TMP)

	@$(call removedevfiles, $(IFTOP_IPKG_TMP))
	@$(call stripfiles, $(IFTOP_IPKG_TMP))
	mkdir -p $(IFTOP_IPKG_TMP)/CONTROL
	echo "Package: iftop" 								 >$(IFTOP_IPKG_TMP)/CONTROL/control
	echo "Source: $(IFTOP_URL)"							>>$(IFTOP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(IFTOP_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(IFTOP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(IFTOP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(IFTOP_IPKG_TMP)/CONTROL/control
	echo "Version: $(IFTOP_VERSION)-$(IFTOP_VENDOR_VERSION)" 			>>$(IFTOP_IPKG_TMP)/CONTROL/control
	echo "Depends: $(IFTOP_DEPLIST)" 						>>$(IFTOP_IPKG_TMP)/CONTROL/control
	echo "Description: display bandwidth usage on an interface"			>>$(IFTOP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(IFTOP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_IFTOP_INSTALL
ROMPACKAGES += $(STATEDIR)/iftop.imageinstall
endif

iftop_imageinstall_deps = $(STATEDIR)/iftop.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/iftop.imageinstall: $(iftop_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install iftop
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

iftop_clean:
	rm -rf $(STATEDIR)/iftop.*
	rm -rf $(IFTOP_DIR)

# vim: syntax=make
