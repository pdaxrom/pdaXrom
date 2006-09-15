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
ifdef PTXCONF_OPENLDAP
PACKAGES += openldap
endif

#
# Paths and names
#
OPENLDAP_VENDOR_VERSION	= 1
OPENLDAP_VERSION	= 2.3.25
OPENLDAP		= openldap-$(OPENLDAP_VERSION)
OPENLDAP_SUFFIX		= tgz
OPENLDAP_URL		= ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/$(OPENLDAP).$(OPENLDAP_SUFFIX)
OPENLDAP_SOURCE		= $(SRCDIR)/$(OPENLDAP).$(OPENLDAP_SUFFIX)
OPENLDAP_DIR		= $(BUILDDIR)/$(OPENLDAP)
OPENLDAP_IPKG_TMP	= $(OPENLDAP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

openldap_get: $(STATEDIR)/openldap.get

openldap_get_deps = $(OPENLDAP_SOURCE)

$(STATEDIR)/openldap.get: $(openldap_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OPENLDAP))
	touch $@

$(OPENLDAP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OPENLDAP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

openldap_extract: $(STATEDIR)/openldap.extract

openldap_extract_deps = $(STATEDIR)/openldap.get

$(STATEDIR)/openldap.extract: $(openldap_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENLDAP_DIR))
	@$(call extract, $(OPENLDAP_SOURCE))
	@$(call patchin, $(OPENLDAP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

openldap_prepare: $(STATEDIR)/openldap.prepare

#
# dependencies
#
openldap_prepare_deps = \
	$(STATEDIR)/openldap.extract \
	$(STATEDIR)/virtual-xchain.install

OPENLDAP_PATH	=  PATH=$(CROSS_PATH)
OPENLDAP_ENV 	=  $(CROSS_ENV)
#OPENLDAP_ENV	+=
OPENLDAP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OPENLDAP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
OPENLDAP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--with-yielding_select=yes \
	--enable-dynamic \
	--enable-bdb=no \
	--enable-hdb=no \
	--libexecdir=/usr/sbin

ifdef PTXCONF_XFREE430
OPENLDAP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OPENLDAP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/openldap.prepare: $(openldap_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENLDAP_DIR)/config.cache)
	cd $(OPENLDAP_DIR) && \
		$(OPENLDAP_PATH) $(OPENLDAP_ENV) \
		ac_cv_func_memcmp_working=yes \
		./configure $(OPENLDAP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

openldap_compile: $(STATEDIR)/openldap.compile

openldap_compile_deps = $(STATEDIR)/openldap.prepare

$(STATEDIR)/openldap.compile: $(openldap_compile_deps)
	@$(call targetinfo, $@)
	$(OPENLDAP_PATH) $(MAKE) -C $(OPENLDAP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

openldap_install: $(STATEDIR)/openldap.install

$(STATEDIR)/openldap.install: $(STATEDIR)/openldap.compile
	@$(call targetinfo, $@)
	rm -rf $(OPENLDAP_IPKG_TMP)
	$(OPENLDAP_PATH) $(MAKE) -C $(OPENLDAP_DIR) DESTDIR=$(OPENLDAP_IPKG_TMP) install
	@$(call copyincludes, $(OPENLDAP_IPKG_TMP))
	@$(call copylibraries,$(OPENLDAP_IPKG_TMP))
	@$(call copymiscfiles,$(OPENLDAP_IPKG_TMP))
	rm -rf $(OPENLDAP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

openldap_targetinstall: $(STATEDIR)/openldap.targetinstall

openldap_targetinstall_deps = $(STATEDIR)/openldap.compile

$(STATEDIR)/openldap.targetinstall: $(openldap_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OPENLDAP_PATH) $(MAKE) -C $(OPENLDAP_DIR) DESTDIR=$(OPENLDAP_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(OPENLDAP_VERSION)-$(OPENLDAP_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh openldap $(OPENLDAP_IPKG_TMP)

	@$(call removedevfiles, $(OPENLDAP_IPKG_TMP))
	@$(call stripfiles, $(OPENLDAP_IPKG_TMP))
	mkdir -p $(OPENLDAP_IPKG_TMP)/CONTROL
	echo "Package: openldap" 							 >$(OPENLDAP_IPKG_TMP)/CONTROL/control
	echo "Source: $(OPENLDAP_URL)"							>>$(OPENLDAP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(OPENLDAP_IPKG_TMP)/CONTROL/control
	echo "Section: Security" 							>>$(OPENLDAP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(OPENLDAP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(OPENLDAP_IPKG_TMP)/CONTROL/control
	echo "Version: $(OPENLDAP_VERSION)-$(OPENLDAP_VENDOR_VERSION)" 			>>$(OPENLDAP_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(OPENLDAP_IPKG_TMP)/CONTROL/control
	echo "Description: OpenLDAP Software is an open source implementation of the Lightweight Directory Access Protocol." >>$(OPENLDAP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OPENLDAP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OPENLDAP_INSTALL
ROMPACKAGES += $(STATEDIR)/openldap.imageinstall
endif

openldap_imageinstall_deps = $(STATEDIR)/openldap.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/openldap.imageinstall: $(openldap_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install openldap
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

openldap_clean:
	rm -rf $(STATEDIR)/openldap.*
	rm -rf $(OPENLDAP_DIR)

# vim: syntax=make
