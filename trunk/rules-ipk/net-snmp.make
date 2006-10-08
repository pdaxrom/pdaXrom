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
ifdef PTXCONF_NET-SNMP
PACKAGES += net-snmp
endif

#
# Paths and names
#
NET-SNMP_VENDOR_VERSION	= 1
NET-SNMP_VERSION	= 5.4.pre3
NET-SNMP		= net-snmp-$(NET-SNMP_VERSION)
NET-SNMP_SUFFIX		= tar.gz
NET-SNMP_URL		= http://belnet.dl.sourceforge.net/sourceforge/net-snmp/$(NET-SNMP).$(NET-SNMP_SUFFIX)
NET-SNMP_SOURCE		= $(SRCDIR)/$(NET-SNMP).$(NET-SNMP_SUFFIX)
NET-SNMP_DIR		= $(BUILDDIR)/$(NET-SNMP)
NET-SNMP_IPKG_TMP	= $(NET-SNMP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

net-snmp_get: $(STATEDIR)/net-snmp.get

net-snmp_get_deps = $(NET-SNMP_SOURCE)

$(STATEDIR)/net-snmp.get: $(net-snmp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NET-SNMP))
	touch $@

$(NET-SNMP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NET-SNMP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

net-snmp_extract: $(STATEDIR)/net-snmp.extract

net-snmp_extract_deps = $(STATEDIR)/net-snmp.get

$(STATEDIR)/net-snmp.extract: $(net-snmp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NET-SNMP_DIR))
	@$(call extract, $(NET-SNMP_SOURCE))
	@$(call patchin, $(NET-SNMP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

net-snmp_prepare: $(STATEDIR)/net-snmp.prepare

#
# dependencies
#
net-snmp_prepare_deps = \
	$(STATEDIR)/net-snmp.extract \
	$(STATEDIR)/virtual-xchain.install

NET-SNMP_PATH	=  PATH=$(CROSS_PATH)
NET-SNMP_ENV 	=  $(CROSS_ENV)
#NET-SNMP_ENV	+=
NET-SNMP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NET-SNMP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
NET-SNMP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
NET-SNMP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NET-SNMP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/net-snmp.prepare: $(net-snmp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NET-SNMP_DIR)/config.cache)
	cd $(NET-SNMP_DIR) && \
		$(NET-SNMP_PATH) $(NET-SNMP_ENV) \
		./configure $(NET-SNMP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

net-snmp_compile: $(STATEDIR)/net-snmp.compile

net-snmp_compile_deps = $(STATEDIR)/net-snmp.prepare

$(STATEDIR)/net-snmp.compile: $(net-snmp_compile_deps)
	@$(call targetinfo, $@)
	$(NET-SNMP_PATH) $(MAKE) -C $(NET-SNMP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

net-snmp_install: $(STATEDIR)/net-snmp.install

$(STATEDIR)/net-snmp.install: $(STATEDIR)/net-snmp.compile
	@$(call targetinfo, $@)
	rm -rf $(NET-SNMP_IPKG_TMP)
	$(NET-SNMP_PATH) $(MAKE) -C $(NET-SNMP_DIR) DESTDIR=$(NET-SNMP_IPKG_TMP) install
	@$(call copyincludes, $(NET-SNMP_IPKG_TMP))
	@$(call copylibraries,$(NET-SNMP_IPKG_TMP))
	@$(call copymiscfiles,$(NET-SNMP_IPKG_TMP))
	rm -rf $(NET-SNMP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

net-snmp_targetinstall: $(STATEDIR)/net-snmp.targetinstall

net-snmp_targetinstall_deps = $(STATEDIR)/net-snmp.compile

NET-SNMP_DEPLIST = 

$(STATEDIR)/net-snmp.targetinstall: $(net-snmp_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NET-SNMP_PATH) $(MAKE) -C $(NET-SNMP_DIR) DESTDIR=$(NET-SNMP_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(NET-SNMP_VERSION)-$(NET-SNMP_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh net-snmp $(NET-SNMP_IPKG_TMP)

	@$(call removedevfiles, $(NET-SNMP_IPKG_TMP))
	@$(call stripfiles, $(NET-SNMP_IPKG_TMP))
	mkdir -p $(NET-SNMP_IPKG_TMP)/CONTROL
	echo "Package: net-snmp" 							 >$(NET-SNMP_IPKG_TMP)/CONTROL/control
	echo "Source: $(NET-SNMP_URL)"							>>$(NET-SNMP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(NET-SNMP_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(NET-SNMP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(NET-SNMP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(NET-SNMP_IPKG_TMP)/CONTROL/control
	echo "Version: $(NET-SNMP_VERSION)-$(NET-SNMP_VENDOR_VERSION)" 			>>$(NET-SNMP_IPKG_TMP)/CONTROL/control
	echo "Depends: $(NET-SNMP_DEPLIST)" 						>>$(NET-SNMP_IPKG_TMP)/CONTROL/control
	echo "Description: net-snmp provides tools and libraries relating to the Simple Network Management Protocol" >>$(NET-SNMP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NET-SNMP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NET-SNMP_INSTALL
ROMPACKAGES += $(STATEDIR)/net-snmp.imageinstall
endif

net-snmp_imageinstall_deps = $(STATEDIR)/net-snmp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/net-snmp.imageinstall: $(net-snmp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install net-snmp
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

net-snmp_clean:
	rm -rf $(STATEDIR)/net-snmp.*
	rm -rf $(NET-SNMP_DIR)

# vim: syntax=make
