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
ifdef PTXCONF_GSPCAV1
PACKAGES += gspcav1
endif

#
# Paths and names
#
GSPCAV1_VENDOR_VERSION	= 1
GSPCAV1_VERSION		= 20060925
GSPCAV1			= gspcav1-$(GSPCAV1_VERSION)
GSPCAV1_SUFFIX		= tar.gz
GSPCAV1_URL		= http://mxhaard.free.fr/spca50x/Download/$(GSPCAV1).$(GSPCAV1_SUFFIX)
GSPCAV1_SOURCE		= $(SRCDIR)/$(GSPCAV1).$(GSPCAV1_SUFFIX)
GSPCAV1_DIR		= $(BUILDDIR)/$(GSPCAV1)
GSPCAV1_IPKG_TMP	= $(GSPCAV1_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gspcav1_get: $(STATEDIR)/gspcav1.get

gspcav1_get_deps = $(GSPCAV1_SOURCE)

$(STATEDIR)/gspcav1.get: $(gspcav1_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GSPCAV1))
	touch $@

$(GSPCAV1_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GSPCAV1_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gspcav1_extract: $(STATEDIR)/gspcav1.extract

gspcav1_extract_deps = $(STATEDIR)/gspcav1.get

$(STATEDIR)/gspcav1.extract: $(gspcav1_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GSPCAV1_DIR))
	@$(call extract, $(GSPCAV1_SOURCE))
	@$(call patchin, $(GSPCAV1))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gspcav1_prepare: $(STATEDIR)/gspcav1.prepare

#
# dependencies
#
gspcav1_prepare_deps = \
	$(STATEDIR)/gspcav1.extract \
	$(STATEDIR)/virtual-xchain.install

GSPCAV1_PATH	=  PATH=$(CROSS_PATH)
GSPCAV1_ENV 	=  $(CROSS_ENV)
#GSPCAV1_ENV	+=
GSPCAV1_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GSPCAV1_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GSPCAV1_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GSPCAV1_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GSPCAV1_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gspcav1.prepare: $(gspcav1_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GSPCAV1_DIR)/config.cache)
	#cd $(GSPCAV1_DIR) && \
	#	$(GSPCAV1_PATH) $(GSPCAV1_ENV) \
	#	./configure $(GSPCAV1_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gspcav1_compile: $(STATEDIR)/gspcav1.compile

gspcav1_compile_deps = $(STATEDIR)/gspcav1.prepare

$(STATEDIR)/gspcav1.compile: $(gspcav1_compile_deps)
	@$(call targetinfo, $@)
	$(GSPCAV1_PATH) $(MAKE) -C $(GSPCAV1_DIR) KERNELDIR=$(KERNEL_DIR) $(KERNEL_MAKEVARS) \
	    $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gspcav1_install: $(STATEDIR)/gspcav1.install

$(STATEDIR)/gspcav1.install: $(STATEDIR)/gspcav1.compile
	@$(call targetinfo, $@)
	#rm -rf $(GSPCAV1_IPKG_TMP)
	#$(GSPCAV1_PATH) $(MAKE) -C $(GSPCAV1_DIR) DESTDIR=$(GSPCAV1_IPKG_TMP) install
	#@$(call copyincludes, $(GSPCAV1_IPKG_TMP))
	#@$(call copylibraries,$(GSPCAV1_IPKG_TMP))
	#@$(call copymiscfiles,$(GSPCAV1_IPKG_TMP))
	#rm -rf $(GSPCAV1_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gspcav1_targetinstall: $(STATEDIR)/gspcav1.targetinstall

gspcav1_targetinstall_deps = $(STATEDIR)/gspcav1.compile

GSPCAV1_DEPLIST = 

$(STATEDIR)/gspcav1.targetinstall: $(gspcav1_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GSPCAV1_PATH) $(MAKE) -C $(GSPCAV1_DIR) install KERNELDIR=$(KERNEL_DIR) $(KERNEL_MAKEVARS) \
	     MODULE_INSTALLDIR=$(GSPCAV1_IPKG_TMP)/lib/modules/`grep "UTS_RELEASE" $(KERNEL_DIR)/include/linux/version.h | cut -d" " -f3`/kernel/drivers/usb/media \
	    MODULE_INSTALLDIR2=$(GSPCAV1_IPKG_TMP)/lib/modules/`grep "UTS_RELEASE" $(KERNEL_DIR)/include/linux/version.h | cut -d" " -f3`/kernel/drivers/media/video \
	    $(CROSS_ENV_CC)

	#PATH=$(CROSS_PATH) 						\
	#FEEDDIR=$(FEEDDIR) 						\
	#STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	#VERSION=$(GSPCAV1_VERSION)-$(GSPCAV1_VENDOR_VERSION)	 	\
	#ARCH=$(SHORT_TARGET) 						\
	#MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	#$(TOPDIR)/scripts/bin/make-locale-ipks.sh gspcav1 $(GSPCAV1_IPKG_TMP)

	#@$(call removedevfiles, $(GSPCAV1_IPKG_TMP))
	#@$(call stripfiles, $(GSPCAV1_IPKG_TMP))
	mkdir -p $(GSPCAV1_IPKG_TMP)/CONTROL
	echo "Package: gspcav1" 							 >$(GSPCAV1_IPKG_TMP)/CONTROL/control
	echo "Source: $(GSPCAV1_URL)"							>>$(GSPCAV1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GSPCAV1_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(GSPCAV1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GSPCAV1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GSPCAV1_IPKG_TMP)/CONTROL/control
	echo "Version: $(GSPCAV1_VERSION)-$(GSPCAV1_VENDOR_VERSION)" 			>>$(GSPCAV1_IPKG_TMP)/CONTROL/control
	echo "Depends: $(GSPCAV1_DEPLIST)" 						>>$(GSPCAV1_IPKG_TMP)/CONTROL/control
	echo "Description: Generic Softwares Package for Camera Adaptator (Spca5xx)"	>>$(GSPCAV1_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(GSPCAV1_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GSPCAV1_INSTALL
ROMPACKAGES += $(STATEDIR)/gspcav1.imageinstall
endif

gspcav1_imageinstall_deps = $(STATEDIR)/gspcav1.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gspcav1.imageinstall: $(gspcav1_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gspcav1
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gspcav1_clean:
	rm -rf $(STATEDIR)/gspcav1.*
	rm -rf $(GSPCAV1_DIR)

# vim: syntax=make
