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
ifdef PTXCONF_QUAGGA
PACKAGES += quagga
endif

#
# Paths and names
#
QUAGGA_VENDOR_VERSION	= 1
QUAGGA_VERSION	= 0.99.5
QUAGGA		= quagga-$(QUAGGA_VERSION)
QUAGGA_SUFFIX		= tar.gz
QUAGGA_URL		= http://www.quagga.net/download/$(QUAGGA).$(QUAGGA_SUFFIX)
QUAGGA_SOURCE		= $(SRCDIR)/$(QUAGGA).$(QUAGGA_SUFFIX)
QUAGGA_DIR		= $(BUILDDIR)/$(QUAGGA)
QUAGGA_IPKG_TMP	= $(QUAGGA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

quagga_get: $(STATEDIR)/quagga.get

quagga_get_deps = $(QUAGGA_SOURCE)

$(STATEDIR)/quagga.get: $(quagga_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QUAGGA))
	touch $@

$(QUAGGA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QUAGGA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

quagga_extract: $(STATEDIR)/quagga.extract

quagga_extract_deps = $(STATEDIR)/quagga.get

$(STATEDIR)/quagga.extract: $(quagga_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QUAGGA_DIR))
	@$(call extract, $(QUAGGA_SOURCE))
	@$(call patchin, $(QUAGGA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

quagga_prepare: $(STATEDIR)/quagga.prepare

#
# dependencies
#
quagga_prepare_deps = \
	$(STATEDIR)/quagga.extract \
	$(STATEDIR)/virtual-xchain.install

QUAGGA_PATH	=  PATH=$(CROSS_PATH)
QUAGGA_ENV 	=  $(CROSS_ENV)
#QUAGGA_ENV	+=
QUAGGA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#QUAGGA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
QUAGGA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-netlink \
	--sysconfdir=/etc/quagga

ifdef PTXCONF_XFREE430
QUAGGA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
QUAGGA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/quagga.prepare: $(quagga_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QUAGGA_DIR)/config.cache)
	cd $(QUAGGA_DIR) && \
		$(QUAGGA_PATH) $(QUAGGA_ENV) \
		./configure $(QUAGGA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

quagga_compile: $(STATEDIR)/quagga.compile

quagga_compile_deps = $(STATEDIR)/quagga.prepare

$(STATEDIR)/quagga.compile: $(quagga_compile_deps)
	@$(call targetinfo, $@)
	$(QUAGGA_PATH) $(MAKE) -C $(QUAGGA_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

quagga_install: $(STATEDIR)/quagga.install

$(STATEDIR)/quagga.install: $(STATEDIR)/quagga.compile
	@$(call targetinfo, $@)
	rm -rf $(QUAGGA_IPKG_TMP)
	$(QUAGGA_PATH) $(MAKE) -C $(QUAGGA_DIR) DESTDIR=$(QUAGGA_IPKG_TMP) install
	@$(call copyincludes, $(QUAGGA_IPKG_TMP))
	@$(call copylibraries,$(QUAGGA_IPKG_TMP))
	@$(call copymiscfiles,$(QUAGGA_IPKG_TMP))
	rm -rf $(QUAGGA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

quagga_targetinstall: $(STATEDIR)/quagga.targetinstall

quagga_targetinstall_deps = $(STATEDIR)/quagga.compile

QUAGGA_DEPLIST = 

$(STATEDIR)/quagga.targetinstall: $(quagga_targetinstall_deps)
	@$(call targetinfo, $@)
	$(QUAGGA_PATH) $(MAKE) -C $(QUAGGA_DIR) DESTDIR=$(QUAGGA_IPKG_TMP) install

	install -d $(QUAGGA_IPKG_TMP)/etc/{rc.d/init.d,sysconfig,logrotate.d,pam.d} \
	    $(QUAGGA_IPKG_TMP)/var/log/quagga

	mkdir -p $(QUAGGA_IPKG_TMP)/etc/rc.d/init.d
	mkdir -p $(QUAGGA_IPKG_TMP)/etc/{sysconfig,pam.d,logrotate.d}

	install -m755 $(QUAGGA_DIR)/redhat/zebra.init 		$(QUAGGA_IPKG_TMP)/etc/rc.d/init.d/zebra
	install -m755 $(QUAGGA_DIR)/redhat/bgpd.init 		$(QUAGGA_IPKG_TMP)/etc/rc.d/init.d/bgpd

	install -m755 $(QUAGGA_DIR)/redhat/ospf6d.init 		$(QUAGGA_IPKG_TMP)/etc/rc.d/init.d/ospf6d
	install -m755 $(QUAGGA_DIR)/redhat/ripngd.init 		$(QUAGGA_IPKG_TMP)/etc/rc.d/init.d/ripngd

	install -m755 $(QUAGGA_DIR)/redhat/ospfd.init 		$(QUAGGA_IPKG_TMP)/etc/rc.d/init.d/ospfd
	install -m755 $(QUAGGA_DIR)/redhat/ripd.init 		$(QUAGGA_IPKG_TMP)/etc/rc.d/init.d/ripd
	install -m644 $(QUAGGA_DIR)/redhat/quagga.sysconfig 	$(QUAGGA_IPKG_TMP)/etc/sysconfig/quagga
	install -m644 $(QUAGGA_DIR)/redhat/quagga.pam 		$(QUAGGA_IPKG_TMP)/etc/pam.d/quagga
	install -m644 $(QUAGGA_DIR)/redhat/quagga.logrotate 	$(QUAGGA_IPKG_TMP)/etc/logrotate.d/quagga
	install -d -m770 $(QUAGGA_IPKG_TMP)/var/run/quagga

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(QUAGGA_VERSION)-$(QUAGGA_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh quagga $(QUAGGA_IPKG_TMP)

	@$(call removedevfiles, $(QUAGGA_IPKG_TMP))
	@$(call stripfiles, $(QUAGGA_IPKG_TMP))
	mkdir -p $(QUAGGA_IPKG_TMP)/CONTROL
	echo "Package: quagga" 								 >$(QUAGGA_IPKG_TMP)/CONTROL/control
	echo "Source: $(QUAGGA_URL)"							>>$(QUAGGA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(QUAGGA_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(QUAGGA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(QUAGGA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(QUAGGA_IPKG_TMP)/CONTROL/control
	echo "Version: $(QUAGGA_VERSION)-$(QUAGGA_VENDOR_VERSION)" 			>>$(QUAGGA_IPKG_TMP)/CONTROL/control
	echo "Depends: $(QUAGGA_DEPLIST)" 						>>$(QUAGGA_IPKG_TMP)/CONTROL/control
	echo "Description: Quagga Routing Suite"					>>$(QUAGGA_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(QUAGGA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QUAGGA_INSTALL
ROMPACKAGES += $(STATEDIR)/quagga.imageinstall
endif

quagga_imageinstall_deps = $(STATEDIR)/quagga.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/quagga.imageinstall: $(quagga_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install quagga
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

quagga_clean:
	rm -rf $(STATEDIR)/quagga.*
	rm -rf $(QUAGGA_DIR)

# vim: syntax=make
