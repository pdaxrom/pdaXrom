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
ifdef PTXCONF_ORBIT2
PACKAGES += ORBit2
endif

#
# Paths and names
#
ORBIT2_VENDOR_VERSION	= 1
ORBIT2_VERSION		= 2.14.2
ORBIT2			= ORBit2-$(ORBIT2_VERSION)
ORBIT2_SUFFIX		= tar.bz2
ORBIT2_URL		= http://ftp.acc.umu.se/pub/gnome/sources/ORBit2/2.14/$(ORBIT2).$(ORBIT2_SUFFIX)
ORBIT2_SOURCE		= $(SRCDIR)/$(ORBIT2).$(ORBIT2_SUFFIX)
ORBIT2_DIR		= $(BUILDDIR)/$(ORBIT2)
ORBIT2_IPKG_TMP		= $(ORBIT2_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ORBit2_get: $(STATEDIR)/ORBit2.get

ORBit2_get_deps = $(ORBIT2_SOURCE)

$(STATEDIR)/ORBit2.get: $(ORBit2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ORBIT2))
	touch $@

$(ORBIT2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ORBIT2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ORBit2_extract: $(STATEDIR)/ORBit2.extract

ORBit2_extract_deps = $(STATEDIR)/ORBit2.get

$(STATEDIR)/ORBit2.extract: $(ORBit2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ORBIT2_DIR))
	@$(call extract, $(ORBIT2_SOURCE))
	@$(call patchin, $(ORBIT2))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ORBit2_prepare: $(STATEDIR)/ORBit2.prepare

#
# dependencies
#
ORBit2_prepare_deps = \
	$(STATEDIR)/ORBit2.extract \
	$(STATEDIR)/popt.install \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/libIDL082.install \
	$(STATEDIR)/xchain-ORBit2.install \
	$(STATEDIR)/virtual-xchain.install

ORBIT2_PATH	=  PATH=$(CROSS_PATH)
ORBIT2_ENV 	=  $(CROSS_ENV)
ORBIT2_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
ORBIT2_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ORBIT2_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ORBIT2_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
ORBIT2_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ORBIT2_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ORBit2.prepare: $(ORBit2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ORBIT2_DIR)/config.cache)
	cd $(ORBIT2_DIR) && \
		$(ORBIT2_PATH) $(ORBIT2_ENV) \
		./configure $(ORBIT2_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ORBit2_compile: $(STATEDIR)/ORBit2.compile

ORBit2_compile_deps = $(STATEDIR)/ORBit2.prepare

$(STATEDIR)/ORBit2.compile: $(ORBit2_compile_deps)
	@$(call targetinfo, $@)
	$(ORBIT2_PATH) $(MAKE) -C $(ORBIT2_DIR) IDL_COMPILER=$(PTXCONF_PREFIX)/bin/orbit-idl-2
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ORBit2_install: $(STATEDIR)/ORBit2.install

$(STATEDIR)/ORBit2.install: $(STATEDIR)/ORBit2.compile
	@$(call targetinfo, $@)
	rm -rf $(ORBIT2_IPKG_TMP)
	$(ORBIT2_PATH) $(MAKE) -C $(ORBIT2_DIR) DESTDIR=$(ORBIT2_IPKG_TMP) install
	@$(call copyincludes, $(ORBIT2_IPKG_TMP))
	@$(call copylibraries,$(ORBIT2_IPKG_TMP))
	@$(call copymiscfiles,$(ORBIT2_IPKG_TMP))
	rm -rf $(ORBIT2_IPKG_TMP)
	ln -sf $(PTXCONF_PREFIX)/bin/orbit-idl-2 $(CROSS_LIB_DIR)/bin/orbit-idl-2
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ORBit2_targetinstall: $(STATEDIR)/ORBit2.targetinstall

ORBit2_targetinstall_deps = $(STATEDIR)/ORBit2.compile \
	$(STATEDIR)/popt.targetinstall \
	$(STATEDIR)/glib22.targetinstall

$(STATEDIR)/ORBit2.targetinstall: $(ORBit2_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ORBIT2_PATH) $(MAKE) -C $(ORBIT2_DIR) DESTDIR=$(ORBIT2_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(ORBIT2_VERSION)-$(ORBIT2_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh orbit2 $(ORBIT2_IPKG_TMP)

	@$(call removedevfiles, $(ORBIT2_IPKG_TMP))
	@$(call stripfiles, $(ORBIT2_IPKG_TMP))
	mkdir -p $(ORBIT2_IPKG_TMP)/CONTROL
	echo "Package: orbit2" 								 >$(ORBIT2_IPKG_TMP)/CONTROL/control
	echo "Source: $(ORBIT2_URL)"							>>$(ORBIT2_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ORBIT2_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(ORBIT2_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ORBIT2_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ORBIT2_IPKG_TMP)/CONTROL/control
	echo "Version: $(ORBIT2_VERSION)-$(ORBIT2_VENDOR_VERSION)" 			>>$(ORBIT2_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_LIBICONV
	echo "Depends: glib2, libiconv, popt" 						>>$(ORBIT2_IPKG_TMP)/CONTROL/control
else
	echo "Depends: glib2, popt" 							>>$(ORBIT2_IPKG_TMP)/CONTROL/control
endif
	echo "Description: High-performance CORBA Object Request Broker"		>>$(ORBIT2_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ORBIT2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ORBIT2_INSTALL
ROMPACKAGES += $(STATEDIR)/ORBit2.imageinstall
endif

ORBit2_imageinstall_deps = $(STATEDIR)/ORBit2.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ORBit2.imageinstall: $(ORBit2_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install orbit2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ORBit2_clean:
	rm -rf $(STATEDIR)/ORBit2.*
	rm -rf $(ORBIT2_DIR)

# vim: syntax=make
