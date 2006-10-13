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
ifdef PTXCONF_NFS-UTILS
PACKAGES += nfs-utils
endif

#
# Paths and names
#
NFS-UTILS_VENDOR_VERSION	= 1
NFS-UTILS_VERSION		= 1.0.7
NFS-UTILS			= nfs-utils-$(NFS-UTILS_VERSION)
NFS-UTILS_SUFFIX		= tar.gz
NFS-UTILS_URL			= http://citkit.dl.sourceforge.net/sourceforge/nfs/$(NFS-UTILS).$(NFS-UTILS_SUFFIX)
NFS-UTILS_SOURCE		= $(SRCDIR)/$(NFS-UTILS).$(NFS-UTILS_SUFFIX)
NFS-UTILS_DIR			= $(BUILDDIR)/$(NFS-UTILS)
NFS-UTILS_IPKG_TMP		= $(NFS-UTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nfs-utils_get: $(STATEDIR)/nfs-utils.get

nfs-utils_get_deps = $(NFS-UTILS_SOURCE)

$(STATEDIR)/nfs-utils.get: $(nfs-utils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NFS-UTILS))
	touch $@

$(NFS-UTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NFS-UTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nfs-utils_extract: $(STATEDIR)/nfs-utils.extract

nfs-utils_extract_deps = $(STATEDIR)/nfs-utils.get

$(STATEDIR)/nfs-utils.extract: $(nfs-utils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NFS-UTILS_DIR))
	@$(call extract, $(NFS-UTILS_SOURCE))
	@$(call patchin, $(NFS-UTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nfs-utils_prepare: $(STATEDIR)/nfs-utils.prepare

#
# dependencies
#
nfs-utils_prepare_deps = \
	$(STATEDIR)/nfs-utils.extract \
	$(STATEDIR)/xchain-nfs-utils.compile \
	$(STATEDIR)/virtual-xchain.install

NFS-UTILS_PATH	=  PATH=$(CROSS_PATH)
NFS-UTILS_ENV 	=  $(CROSS_ENV)
#NFS-UTILS_ENV	+=
NFS-UTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NFS-UTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
NFS-UTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-nfsv3 \
	--disable-nfsv4 \
	--disable-gss
	
ifdef PTXCONF_XFREE430
NFS-UTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NFS-UTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/nfs-utils.prepare: $(nfs-utils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NFS-UTILS_DIR)/config.cache)
	cd $(NFS-UTILS_DIR) && \
		$(NFS-UTILS_PATH) $(NFS-UTILS_ENV) \
		./configure $(NFS-UTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nfs-utils_compile: $(STATEDIR)/nfs-utils.compile

nfs-utils_compile_deps = $(STATEDIR)/nfs-utils.prepare

$(STATEDIR)/nfs-utils.compile: $(nfs-utils_compile_deps)
	@$(call targetinfo, $@)
	$(NFS-UTILS_PATH) $(MAKE) -C $(NFS-UTILS_DIR) RPCGEN=$(XCHAIN_NFS-UTILS_DIR)/tools/rpcgen/rpcgen
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nfs-utils_install: $(STATEDIR)/nfs-utils.install

$(STATEDIR)/nfs-utils.install: $(STATEDIR)/nfs-utils.compile
	@$(call targetinfo, $@)
	###$(NFS-UTILS_PATH) $(MAKE) -C $(NFS-UTILS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nfs-utils_targetinstall: $(STATEDIR)/nfs-utils.targetinstall

nfs-utils_targetinstall_deps = $(STATEDIR)/nfs-utils.compile

$(STATEDIR)/nfs-utils.targetinstall: $(nfs-utils_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NFS-UTILS_PATH) $(MAKE) -C $(NFS-UTILS_DIR) install_prefix=$(NFS-UTILS_IPKG_TMP) install
	$(INSTALL) -D $(TOPDIR)/config/pics/nfs-kernel-server.init $(NFS-UTILS_IPKG_TMP)/etc/rc.d/init.d/nfs-kernel-server
	mkdir -p $(NFS-UTILS_IPKG_TMP)/etc/rc.d/{rc0.d,rc5.d,rc6.d}
	ln -sf ../init.d/nfs-kernel-server $(NFS-UTILS_IPKG_TMP)/etc/rc.d/rc0.d/K49nfs-kernel-server
	ln -sf ../init.d/nfs-kernel-server $(NFS-UTILS_IPKG_TMP)/etc/rc.d/rc5.d/S51nfs-kernel-server
	ln -sf ../init.d/nfs-kernel-server $(NFS-UTILS_IPKG_TMP)/etc/rc.d/rc6.d/K49nfs-kernel-server
	rm -rf $(NFS-UTILS_IPKG_TMP)/usr/man
	touch $(NFS-UTILS_IPKG_TMP)/etc/exports

	for FILE in `find $(NFS-UTILS_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done

	mkdir -p $(NFS-UTILS_IPKG_TMP)/CONTROL
	echo "Package: nfs-utils" 										 >$(NFS-UTILS_IPKG_TMP)/CONTROL/control
	echo "Source: $(NFS-UTILS_URL)"										>>$(NFS-UTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(NFS-UTILS_IPKG_TMP)/CONTROL/control
	echo "Section: Utils" 											>>$(NFS-UTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(NFS-UTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(NFS-UTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(NFS-UTILS_VERSION)-$(NFS-UTILS_VENDOR_VERSION)" 					>>$(NFS-UTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: portmap" 										>>$(NFS-UTILS_IPKG_TMP)/CONTROL/control
	echo "Description: nfs-utils provides the required support programs for using the Linux kernel's NFS support, either as a client or as a server (or as both).">>$(NFS-UTILS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(NFS-UTILS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NFS-UTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/nfs-utils.imageinstall
endif

nfs-utils_imageinstall_deps = $(STATEDIR)/nfs-utils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/nfs-utils.imageinstall: $(nfs-utils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nfs-utils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nfs-utils_clean:
	rm -rf $(STATEDIR)/nfs-utils.*
	rm -rf $(NFS-UTILS_DIR)

# vim: syntax=make
