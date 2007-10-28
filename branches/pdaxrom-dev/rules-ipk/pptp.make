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
ifdef PTXCONF_PPTP
PACKAGES += pptp
endif

#
# Paths and names
#
PPTP_VENDOR_VERSION	= 1
PPTP_VERSION		= 1.7.1
PPTP			= pptp-$(PPTP_VERSION)
PPTP_SUFFIX		= tar.gz
PPTP_URL		= http://belnet.dl.sourceforge.net/sourceforge/pptpclient/$(PPTP).$(PPTP_SUFFIX)
PPTP_SOURCE		= $(SRCDIR)/$(PPTP).$(PPTP_SUFFIX)
PPTP_DIR		= $(BUILDDIR)/$(PPTP)
PPTP_IPKG_TMP		= $(PPTP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pptp_get: $(STATEDIR)/pptp.get

pptp_get_deps = $(PPTP_SOURCE)

$(STATEDIR)/pptp.get: $(pptp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PPTP))
	touch $@

$(PPTP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PPTP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pptp_extract: $(STATEDIR)/pptp.extract

pptp_extract_deps = $(STATEDIR)/pptp.get

$(STATEDIR)/pptp.extract: $(pptp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PPTP_DIR))
	@$(call extract, $(PPTP_SOURCE))
	@$(call patchin, $(PPTP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pptp_prepare: $(STATEDIR)/pptp.prepare

#
# dependencies
#
pptp_prepare_deps = \
	$(STATEDIR)/pptp.extract \
	$(STATEDIR)/virtual-xchain.install

PPTP_PATH	=  PATH=$(CROSS_PATH)
PPTP_ENV 	=  $(CROSS_ENV)
#PPTP_ENV	+=
PPTP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PPTP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PPTP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PPTP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PPTP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pptp.prepare: $(pptp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PPTP_DIR)/config.cache)
	#cd $(PPTP_DIR) && \
	#	$(PPTP_PATH) $(PPTP_ENV) \
	#	./configure $(PPTP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pptp_compile: $(STATEDIR)/pptp.compile

pptp_compile_deps = $(STATEDIR)/pptp.prepare

$(STATEDIR)/pptp.compile: $(pptp_compile_deps)
	@$(call targetinfo, $@)
	$(PPTP_PATH) $(PPTP_ENV) $(MAKE) -C $(PPTP_DIR) $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pptp_install: $(STATEDIR)/pptp.install

$(STATEDIR)/pptp.install: $(STATEDIR)/pptp.compile
	@$(call targetinfo, $@)
	$(PPTP_PATH) $(MAKE) -C $(PPTP_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pptp_targetinstall: $(STATEDIR)/pptp.targetinstall

pptp_targetinstall_deps = $(STATEDIR)/pptp.compile

$(STATEDIR)/pptp.targetinstall: $(pptp_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PPTP_PATH) $(MAKE) -C $(PPTP_DIR) DESTDIR=$(PPTP_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(PPTP_VERSION)-$(PPTP_VENDOR_VERSION)		 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh pptp $(PPTP_IPKG_TMP)

	@$(call removedevfiles, $(PPTP_IPKG_TMP))
	@$(call stripfiles,     $(PPTP_IPKG_TMP))


	#$(CROSSSTRIP) $(PPTP_IPKG_TMP)/usr/sbin/*
	#rm -rf $(PPTP_IPKG_TMP)/usr/share/man

	mkdir -p $(PPTP_IPKG_TMP)/CONTROL
	echo "Package: pptp" 											 >$(PPTP_IPKG_TMP)/CONTROL/control
	echo "Source: $(PPTP_URL)"										>>$(PPTP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(PPTP_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 										>>$(PPTP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(PPTP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(PPTP_IPKG_TMP)/CONTROL/control
	echo "Version: $(PPTP_VERSION)-$(PPTP_VENDOR_VERSION)" 							>>$(PPTP_IPKG_TMP)/CONTROL/control
	echo "Depends: " 											>>$(PPTP_IPKG_TMP)/CONTROL/control
	echo "Description: PPTP Client is a Linux, FreeBSD, NetBSD and OpenBSD client for the proprietary Microsoft Point-to-Point Tunneling Protocol, PPTP." >>$(PPTP_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(PPTP_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PPTP_INSTALL
ROMPACKAGES += $(STATEDIR)/pptp.imageinstall
endif

pptp_imageinstall_deps = $(STATEDIR)/pptp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pptp.imageinstall: $(pptp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pptp
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pptp_clean:
	rm -rf $(STATEDIR)/pptp.*
	rm -rf $(PPTP_DIR)

# vim: syntax=make
