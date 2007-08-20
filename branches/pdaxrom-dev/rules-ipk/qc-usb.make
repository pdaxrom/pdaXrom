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
ifdef PTXCONF_QC-USB
PACKAGES += qc-usb
endif

#
# Paths and names
#
QC-USB_VENDOR_VERSION	= 1
QC-USB_VERSION	= 0.6.4
QC-USB		= qc-usb-$(QC-USB_VERSION)
QC-USB_SUFFIX		= tar.gz
QC-USB_URL		= http://belnet.dl.sourceforge.net/sourceforge/qce-ga/$(QC-USB).$(QC-USB_SUFFIX)
QC-USB_SOURCE		= $(SRCDIR)/$(QC-USB).$(QC-USB_SUFFIX)
QC-USB_DIR		= $(BUILDDIR)/$(QC-USB)
QC-USB_IPKG_TMP	= $(QC-USB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

qc-usb_get: $(STATEDIR)/qc-usb.get

qc-usb_get_deps = $(QC-USB_SOURCE)

$(STATEDIR)/qc-usb.get: $(qc-usb_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QC-USB))
	touch $@

$(QC-USB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QC-USB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

qc-usb_extract: $(STATEDIR)/qc-usb.extract

qc-usb_extract_deps = $(STATEDIR)/qc-usb.get

$(STATEDIR)/qc-usb.extract: $(qc-usb_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QC-USB_DIR))
	@$(call extract, $(QC-USB_SOURCE))
	@$(call patchin, $(QC-USB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

qc-usb_prepare: $(STATEDIR)/qc-usb.prepare

#
# dependencies
#
qc-usb_prepare_deps = \
	$(STATEDIR)/qc-usb.extract \
	$(STATEDIR)/virtual-xchain.install

QC-USB_PATH	=  PATH=$(CROSS_PATH)
QC-USB_ENV 	=  $(CROSS_ENV)
#QC-USB_ENV	+=
QC-USB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#QC-USB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
QC-USB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
QC-USB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
QC-USB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/qc-usb.prepare: $(qc-usb_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QC-USB_DIR)/config.cache)
	#cd $(QC-USB_DIR) && \
	#	$(QC-USB_PATH) $(QC-USB_ENV) \
	#	./configure $(QC-USB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

qc-usb_compile: $(STATEDIR)/qc-usb.compile

qc-usb_compile_deps = $(STATEDIR)/qc-usb.prepare

$(STATEDIR)/qc-usb.compile: $(qc-usb_compile_deps)
	@$(call targetinfo, $@)
	$(QC-USB_PATH) $(MAKE) -C $(QC-USB_DIR) LINUX_DIR=$(KERNEL_DIR) $(CROSS_ENV_CC) all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

qc-usb_install: $(STATEDIR)/qc-usb.install

$(STATEDIR)/qc-usb.install: $(STATEDIR)/qc-usb.compile
	@$(call targetinfo, $@)
	#rm -rf $(QC-USB_IPKG_TMP)
	#$(QC-USB_PATH) $(MAKE) -C $(QC-USB_DIR) DESTDIR=$(QC-USB_IPKG_TMP) install
	#@$(call copyincludes, $(QC-USB_IPKG_TMP))
	#@$(call copylibraries,$(QC-USB_IPKG_TMP))
	#@$(call copymiscfiles,$(QC-USB_IPKG_TMP))
	#rm -rf $(QC-USB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

qc-usb_targetinstall: $(STATEDIR)/qc-usb.targetinstall

qc-usb_targetinstall_deps = $(STATEDIR)/qc-usb.compile

QC-USB_DEPLIST = 

$(STATEDIR)/qc-usb.targetinstall: $(qc-usb_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(QC-USB_PATH) $(MAKE) -C $(QC-USB_DIR) PREFIX=$(QC-USB_IPKG_TMP)/usr install \
	#	MODULE_DIR=

	#install -D $(QC-USB_DIR)/show 		$(QC-USB_IPKG_TMP)/usr/bin/qcshow
	install -D $(QC-USB_DIR)/qcset 		$(QC-USB_IPKG_TMP)/usr/bin/qcset
	install -D $(QC-USB_DIR)/quickcam.ko 	$(QC-USB_IPKG_TMP)/lib/modules/`grep "UTS_RELEASE" $(KERNEL_DIR)/include/linux/version.h | cut -d" " -f3 | sed 's/\"//g'`/kernel/drivers/usb/media/quickcam.ko

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(QC-USB_VERSION)-$(QC-USB_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh qc-usb $(QC-USB_IPKG_TMP)

	@$(call removedevfiles, $(QC-USB_IPKG_TMP))
	@$(call stripfiles, $(QC-USB_IPKG_TMP))
	mkdir -p $(QC-USB_IPKG_TMP)/CONTROL
	echo "Package: qc-usb" 								 >$(QC-USB_IPKG_TMP)/CONTROL/control
	echo "Source: $(QC-USB_URL)"							>>$(QC-USB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(QC-USB_IPKG_TMP)/CONTROL/control
	echo "Section: System"	 							>>$(QC-USB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(QC-USB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(QC-USB_IPKG_TMP)/CONTROL/control
	echo "Version: $(QC-USB_VERSION)-$(QC-USB_VENDOR_VERSION)" 			>>$(QC-USB_IPKG_TMP)/CONTROL/control
	echo "Depends: $(QC-USB_DEPLIST)" 						>>$(QC-USB_IPKG_TMP)/CONTROL/control
	echo "Description: Logitech QuickCam module and tool"				>>$(QC-USB_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(QC-USB_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QC-USB_INSTALL
ROMPACKAGES += $(STATEDIR)/qc-usb.imageinstall
endif

qc-usb_imageinstall_deps = $(STATEDIR)/qc-usb.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/qc-usb.imageinstall: $(qc-usb_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install qc-usb
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

qc-usb_clean:
	rm -rf $(STATEDIR)/qc-usb.*
	rm -rf $(QC-USB_DIR)

# vim: syntax=make
