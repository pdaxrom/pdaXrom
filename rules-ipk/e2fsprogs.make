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
ifdef PTXCONF_E2FSPROGS
PACKAGES += e2fsprogs
endif

#
# Paths and names
#
E2FSPROGS_VENDOR_VERSION	= 1
E2FSPROGS_VERSION		= 1.39
E2FSPROGS			= e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_SUFFIX		= tar.gz
E2FSPROGS_URL			= http://mesh.dl.sourceforge.net/sourceforge/e2fsprogs/$(E2FSPROGS).$(E2FSPROGS_SUFFIX)
E2FSPROGS_SOURCE		= $(SRCDIR)/$(E2FSPROGS).$(E2FSPROGS_SUFFIX)
E2FSPROGS_DIR			= $(BUILDDIR)/$(E2FSPROGS)
E2FSPROGS_BUILD_DIR		= $(BUILDDIR)/$(E2FSPROGS)-build
E2FSPROGS_IPKG_TMP		= $(E2FSPROGS_BUILD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

e2fsprogs_get: $(STATEDIR)/e2fsprogs.get

e2fsprogs_get_deps = $(E2FSPROGS_SOURCE)

$(STATEDIR)/e2fsprogs.get: $(e2fsprogs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(E2FSPROGS))
	touch $@

$(E2FSPROGS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(E2FSPROGS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

e2fsprogs_extract: $(STATEDIR)/e2fsprogs.extract

e2fsprogs_extract_deps = $(STATEDIR)/e2fsprogs.get

$(STATEDIR)/e2fsprogs.extract: $(e2fsprogs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(E2FSPROGS_DIR))
	@$(call extract, $(E2FSPROGS_SOURCE))
	@$(call patchin, $(E2FSPROGS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

e2fsprogs_prepare: $(STATEDIR)/e2fsprogs.prepare

#
# dependencies
#
e2fsprogs_prepare_deps = \
	$(STATEDIR)/e2fsprogs.extract \
	$(STATEDIR)/virtual-xchain.install

E2FSPROGS_PATH	=  PATH=$(CROSS_PATH)
E2FSPROGS_ENV 	=  $(CROSS_ENV)
E2FSPROGS_ENV	+= BUILD_CC=$(HOSTCC)
E2FSPROGS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#E2FSPROGS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
E2FSPROGS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/ \
	--sysconfdir=/etc \
	--with-cc=$(PTXCONF_GNU_TARGET)-gcc \
	--with-linker=$(PTXCONF_GNU_TARGET)-ld \
	--enable-elf-shlibs \
	--enable-dynamic-e2fsck \
	--enable-compression \
	--disable-nls

ifdef PTXCONF_XFREE430
E2FSPROGS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
E2FSPROGS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/e2fsprogs.prepare: $(e2fsprogs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(E2FSPROGS_DIR)/config.cache)
	mkdir -p $(E2FSPROGS_BUILD_DIR) && \
	cd $(E2FSPROGS_BUILD_DIR) && \
		$(E2FSPROGS_PATH) $(E2FSPROGS_ENV) \
		$(E2FSPROGS_DIR)/configure $(E2FSPROGS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

e2fsprogs_compile: $(STATEDIR)/e2fsprogs.compile

e2fsprogs_compile_deps = $(STATEDIR)/e2fsprogs.prepare

$(STATEDIR)/e2fsprogs.compile: $(e2fsprogs_compile_deps)
	@$(call targetinfo, $@)
	$(E2FSPROGS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/util BUILD_CC=gcc
	$(E2FSPROGS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR) BUILD_CC=gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

e2fsprogs_install: $(STATEDIR)/e2fsprogs.install

$(STATEDIR)/e2fsprogs.install: $(STATEDIR)/e2fsprogs.compile
	@$(call targetinfo, $@)
	rm -rf $(E2FSPROGS_IPKG_TMP)
	$(E2FSPROGS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR) DESTDIR=$(E2FSPROGS_IPKG_TMP) install

	install -m 644 -D $(E2FSPROGS_DIR)/lib/uuid/uuid.h		$(CROSS_LIB_DIR)/include/uuid/uuid.h
	install -m 755    $(E2FSPROGS_BUILD_DIR)/lib/libuuid.so.1.2	$(CROSS_LIB_DIR)/lib
	ln -sf libuuid.so.1.2 $(CROSS_LIB_DIR)/lib/libuuid.so.1
	ln -sf libuuid.so.1.2 $(CROSS_LIB_DIR)/lib/libuuid.so

	rm -rf $(E2FSPROGS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

e2fsprogs_targetinstall: $(STATEDIR)/e2fsprogs.targetinstall

e2fsprogs_targetinstall_deps = $(STATEDIR)/e2fsprogs.compile

E2FSPROGS_DEPLIST = 

$(STATEDIR)/e2fsprogs.targetinstall: $(e2fsprogs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(E2FSPROGS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR) DESTDIR=$(E2FSPROGS_IPKG_TMP) install

	ln -sf mke2fs 	$(E2FSPROGS_IPKG_TMP)/sbin/mkfs.ext2
	ln -sf mke2fs 	$(E2FSPROGS_IPKG_TMP)/sbin/mkfs.ext3
	ln -sf tune2fs 	$(E2FSPROGS_IPKG_TMP)/sbin/e2label
	ln -sf tune2fs 	$(E2FSPROGS_IPKG_TMP)/sbin/findfs
	ln -sf e2fsck 	$(E2FSPROGS_IPKG_TMP)/sbin/fsck.ext2
	ln -sf e2fsck 	$(E2FSPROGS_IPKG_TMP)/sbin/fsck.ext3

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(E2FSPROGS_VERSION)-$(E2FSPROGS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh e2fsprogs $(E2FSPROGS_IPKG_TMP)

	@$(call removedevfiles, $(E2FSPROGS_IPKG_TMP))
	@$(call stripfiles, $(E2FSPROGS_IPKG_TMP))
	mkdir -p $(E2FSPROGS_IPKG_TMP)/CONTROL
	echo "Package: e2fsprogs" 							 >$(E2FSPROGS_IPKG_TMP)/CONTROL/control
	echo "Source: $(E2FSPROGS_URL)"							>>$(E2FSPROGS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(E2FSPROGS_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(E2FSPROGS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(E2FSPROGS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(E2FSPROGS_IPKG_TMP)/CONTROL/control
	echo "Version: $(E2FSPROGS_VERSION)-$(E2FSPROGS_VENDOR_VERSION)" 		>>$(E2FSPROGS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(E2FSPROGS_DEPLIST)" 						>>$(E2FSPROGS_IPKG_TMP)/CONTROL/control
	echo "Description: Ext2/3 system utilities"					>>$(E2FSPROGS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(E2FSPROGS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_E2FSPROGS_INSTALL
ROMPACKAGES += $(STATEDIR)/e2fsprogs.imageinstall
endif

e2fsprogs_imageinstall_deps = $(STATEDIR)/e2fsprogs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/e2fsprogs.imageinstall: $(e2fsprogs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install e2fsprogs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

e2fsprogs_clean:
	rm -rf $(STATEDIR)/e2fsprogs.*
	rm -rf $(E2FSPROGS_DIR)
	rm -rf $(E2FSPROGS_BUILD_DIR)
	
# vim: syntax=make
