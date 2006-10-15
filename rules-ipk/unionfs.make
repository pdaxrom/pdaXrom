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
ifdef PTXCONF_UNIONFS
PACKAGES += unionfs
endif

#
# Paths and names
#
UNIONFS_VENDOR_VERSION	= 1
UNIONFS_VERSION		= 1.3
UNIONFS			= unionfs-$(UNIONFS_VERSION)
UNIONFS_SUFFIX		= tar.gz
UNIONFS_URL		= ftp://ftp.fsl.cs.sunysb.edu/pub/unionfs/$(UNIONFS).$(UNIONFS_SUFFIX)
UNIONFS_SOURCE		= $(SRCDIR)/$(UNIONFS).$(UNIONFS_SUFFIX)
UNIONFS_DIR		= $(BUILDDIR)/$(UNIONFS)
UNIONFS_IPKG_TMP	= $(UNIONFS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

unionfs_get: $(STATEDIR)/unionfs.get

unionfs_get_deps = $(UNIONFS_SOURCE)

$(STATEDIR)/unionfs.get: $(unionfs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(UNIONFS))
	touch $@

$(UNIONFS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(UNIONFS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

unionfs_extract: $(STATEDIR)/unionfs.extract

unionfs_extract_deps = $(STATEDIR)/unionfs.get

$(STATEDIR)/unionfs.extract: $(unionfs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UNIONFS_DIR))
	@$(call extract, $(UNIONFS_SOURCE))
	@$(call patchin, $(UNIONFS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

unionfs_prepare: $(STATEDIR)/unionfs.prepare

#
# dependencies
#
unionfs_prepare_deps = \
	$(STATEDIR)/unionfs.extract \
	$(STATEDIR)/e2fsprogs.install \
	$(STATEDIR)/virtual-xchain.install

UNIONFS_PATH	=  PATH=$(CROSS_PATH)
UNIONFS_ENV 	=  $(CROSS_ENV)
#UNIONFS_ENV	+=
UNIONFS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#UNIONFS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
UNIONFS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
UNIONFS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
UNIONFS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/unionfs.prepare: $(unionfs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UNIONFS_DIR)/config.cache)
	#cd $(UNIONFS_DIR) && \
	#	$(UNIONFS_PATH) $(UNIONFS_ENV) \
	#	./configure $(UNIONFS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

unionfs_compile: $(STATEDIR)/unionfs.compile

unionfs_compile_deps = $(STATEDIR)/unionfs.prepare

$(STATEDIR)/unionfs.compile: $(unionfs_compile_deps)
	@$(call targetinfo, $@)
	cd $(UNIONFS_DIR) && $(UNIONFS_PATH) $(UNIONFS_ENV) $(MAKE) \
		LINUXSRC=$(KERNEL_DIR) \
		KVERS=`ls $(KERNEL_DIR)/ipkg_tmp/lib/modules` \
		EXTRACFLAGS=-DUNIONFS_UNSUPPORTED $(CROSS_ENV_CC) \
		PREFIX=$(UNIONFS_IPKG_TMP)/usr \
		MODPREFIX=$(UNIONFS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

unionfs_install: $(STATEDIR)/unionfs.install

$(STATEDIR)/unionfs.install: $(STATEDIR)/unionfs.compile
	@$(call targetinfo, $@)
	#rm -rf $(UNIONFS_IPKG_TMP)
	#$(UNIONFS_PATH) $(MAKE) -C $(UNIONFS_DIR) DESTDIR=$(UNIONFS_IPKG_TMP) install
	#@$(call copyincludes, $(UNIONFS_IPKG_TMP))
	#@$(call copylibraries,$(UNIONFS_IPKG_TMP))
	#@$(call copymiscfiles,$(UNIONFS_IPKG_TMP))
	#rm -rf $(UNIONFS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

unionfs_targetinstall: $(STATEDIR)/unionfs.targetinstall

unionfs_targetinstall_deps = $(STATEDIR)/unionfs.compile \
	$(STATEDIR)/e2fsprogs.targetinstall

UNIONFS_DEPLIST = 

$(STATEDIR)/unionfs.targetinstall: $(unionfs_targetinstall_deps)
	@$(call targetinfo, $@)
	cd $(UNIONFS_DIR) && $(UNIONFS_PATH) $(UNIONFS_ENV) $(MAKE) DESTDIR=$(UNIONFS_IPKG_TMP) install \
		LINUXSRC=$(KERNEL_DIR) \
		KVERS=`ls $(KERNEL_DIR)/ipkg_tmp/lib/modules` \
		EXTRACFLAGS=-DUNIONFS_UNSUPPORTED $(CROSS_ENV_CC) \
		PREFIX=$(UNIONFS_IPKG_TMP)/usr \
		MODPREFIX=$(UNIONFS_IPKG_TMP)

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(UNIONFS_VERSION)-$(UNIONFS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh unionfs $(UNIONFS_IPKG_TMP)

	@$(call removedevfiles, $(UNIONFS_IPKG_TMP))
	@$(call stripfiles, $(UNIONFS_IPKG_TMP))
	mkdir -p $(UNIONFS_IPKG_TMP)/CONTROL
	echo "Package: unionfs" 							 >$(UNIONFS_IPKG_TMP)/CONTROL/control
	echo "Source: $(UNIONFS_URL)"							>>$(UNIONFS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(UNIONFS_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(UNIONFS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(UNIONFS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(UNIONFS_IPKG_TMP)/CONTROL/control
	echo "Version: $(UNIONFS_VERSION)-$(UNIONFS_VENDOR_VERSION)" 			>>$(UNIONFS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(UNIONFS_DEPLIST)" 						>>$(UNIONFS_IPKG_TMP)/CONTROL/control
	echo "Description: Unionfs module and utils"					>>$(UNIONFS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(UNIONFS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_UNIONFS_INSTALL
ROMPACKAGES += $(STATEDIR)/unionfs.imageinstall
endif

unionfs_imageinstall_deps = $(STATEDIR)/unionfs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/unionfs.imageinstall: $(unionfs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install unionfs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

unionfs_clean:
	rm -rf $(STATEDIR)/unionfs.*
	rm -rf $(UNIONFS_DIR)

# vim: syntax=make
