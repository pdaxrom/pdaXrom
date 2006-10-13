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
ifdef PTXCONF_TFTP
PACKAGES += tftp
endif

#
# Paths and names
#
TFTP_VENDOR_VERSION	= 1
TFTP_VERSION		= 0.42
TFTP			= tftp-hpa-$(TFTP_VERSION)
TFTP_SUFFIX		= tar.bz2
TFTP_URL		= http://www.kernel.org/pub/software/network/tftp/$(TFTP).$(TFTP_SUFFIX)
TFTP_SOURCE		= $(SRCDIR)/$(TFTP).$(TFTP_SUFFIX)
TFTP_DIR		= $(BUILDDIR)/$(TFTP)
TFTP_IPKG_TMP		= $(TFTP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tftp_get: $(STATEDIR)/tftp.get

tftp_get_deps = $(TFTP_SOURCE)

$(STATEDIR)/tftp.get: $(tftp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TFTP))
	touch $@

$(TFTP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TFTP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tftp_extract: $(STATEDIR)/tftp.extract

tftp_extract_deps = $(STATEDIR)/tftp.get

$(STATEDIR)/tftp.extract: $(tftp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TFTP_DIR))
	@$(call extract, $(TFTP_SOURCE))
	@$(call patchin, $(TFTP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tftp_prepare: $(STATEDIR)/tftp.prepare

#
# dependencies
#
tftp_prepare_deps = \
	$(STATEDIR)/tftp.extract \
	$(STATEDIR)/virtual-xchain.install

TFTP_PATH	=  PATH=$(CROSS_PATH)
TFTP_ENV 	=  $(CROSS_ENV)
#TFTP_ENV	+=
TFTP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TFTP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
TFTP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
TFTP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TFTP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/tftp.prepare: $(tftp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TFTP_DIR)/config.cache)
	cd $(TFTP_DIR) && \
		$(TFTP_PATH) $(TFTP_ENV) \
		./configure $(TFTP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tftp_compile: $(STATEDIR)/tftp.compile

tftp_compile_deps = $(STATEDIR)/tftp.prepare

$(STATEDIR)/tftp.compile: $(tftp_compile_deps)
	@$(call targetinfo, $@)
	$(TFTP_PATH) $(MAKE) -C $(TFTP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tftp_install: $(STATEDIR)/tftp.install

$(STATEDIR)/tftp.install: $(STATEDIR)/tftp.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tftp_targetinstall: $(STATEDIR)/tftp.targetinstall

tftp_targetinstall_deps = $(STATEDIR)/tftp.compile

$(STATEDIR)/tftp.targetinstall: $(tftp_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TFTP_PATH) $(MAKE) -C $(TFTP_DIR) INSTALLROOT=$(TFTP_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(TFTP_VERSION)-$(TFTP_VENDOR_VERSION)		 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh tftp $(TFTP_IPKG_TMP)

	@$(call stripfiles, $(TFTP_IPKG_TMP))
	ln -sf in.tftpd $(TFTP_IPKG_TMP)/usr/sbin/tftpd
	mkdir -p $(TFTP_IPKG_TMP)/CONTROL
	echo "Package: tftp" 							 >$(TFTP_IPKG_TMP)/CONTROL/control
	echo "Source: $(TFTP_URL)"							>>$(TFTP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(TFTP_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(TFTP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(TFTP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(TFTP_IPKG_TMP)/CONTROL/control
	echo "Version: $(TFTP_VERSION)-$(TFTP_VENDOR_VERSION)" 			>>$(TFTP_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(TFTP_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(TFTP_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(TFTP_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TFTP_INSTALL
ROMPACKAGES += $(STATEDIR)/tftp.imageinstall
endif

tftp_imageinstall_deps = $(STATEDIR)/tftp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tftp.imageinstall: $(tftp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tftp
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tftp_clean:
	rm -rf $(STATEDIR)/tftp.*
	rm -rf $(TFTP_DIR)

# vim: syntax=make
