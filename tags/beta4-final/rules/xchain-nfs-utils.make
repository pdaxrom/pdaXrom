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
ifdef PTXCONF_XCHAIN_NFS-UTILS
PACKAGES += xchain-nfs-utils
endif

#
# Paths and names
#
XCHAIN_NFS-UTILS		= nfs-utils-$(NFS-UTILS_VERSION)
XCHAIN_NFS-UTILS_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_NFS-UTILS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-nfs-utils_get: $(STATEDIR)/xchain-nfs-utils.get

xchain-nfs-utils_get_deps = $(XCHAIN_NFS-UTILS_SOURCE)

$(STATEDIR)/xchain-nfs-utils.get: $(xchain-nfs-utils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NFS-UTILS))
	touch $@

$(XCHAIN_NFS-UTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NFS-UTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-nfs-utils_extract: $(STATEDIR)/xchain-nfs-utils.extract

xchain-nfs-utils_extract_deps = $(STATEDIR)/xchain-nfs-utils.get

$(STATEDIR)/xchain-nfs-utils.extract: $(xchain-nfs-utils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_NFS-UTILS_DIR))
	@$(call extract, $(NFS-UTILS_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(NFS-UTILS), $(XCHAIN_NFS-UTILS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-nfs-utils_prepare: $(STATEDIR)/xchain-nfs-utils.prepare

#
# dependencies
#
xchain-nfs-utils_prepare_deps = \
	$(STATEDIR)/xchain-nfs-utils.extract

XCHAIN_NFS-UTILS_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_NFS-UTILS_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_NFS-UTILS_ENV	+=

#
# autoconf
#
XCHAIN_NFS-UTILS_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST) \
	--enable-nfsv3 \
	--disable-nfsv4 \
	--disable-gss
	
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-nfs-utils.prepare: $(xchain-nfs-utils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_NFS-UTILS_DIR)/config.cache)
	cd $(XCHAIN_NFS-UTILS_DIR) && \
		$(XCHAIN_NFS-UTILS_PATH) $(XCHAIN_NFS-UTILS_ENV) \
		./configure $(XCHAIN_NFS-UTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-nfs-utils_compile: $(STATEDIR)/xchain-nfs-utils.compile

xchain-nfs-utils_compile_deps = $(STATEDIR)/xchain-nfs-utils.prepare

$(STATEDIR)/xchain-nfs-utils.compile: $(xchain-nfs-utils_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_NFS-UTILS_PATH) $(MAKE) -C $(XCHAIN_NFS-UTILS_DIR)
	###/tools/rpcgen
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-nfs-utils_install: $(STATEDIR)/xchain-nfs-utils.install

$(STATEDIR)/xchain-nfs-utils.install: $(STATEDIR)/xchain-nfs-utils.compile
	@$(call targetinfo, $@)
	$(XCHAIN_NFS-UTILS_PATH) $(MAKE) -C $(XCHAIN_NFS-UTILS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-nfs-utils_targetinstall: $(STATEDIR)/xchain-nfs-utils.targetinstall

xchain-nfs-utils_targetinstall_deps = $(STATEDIR)/xchain-nfs-utils.compile

$(STATEDIR)/xchain-nfs-utils.targetinstall: $(xchain-nfs-utils_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-nfs-utils_clean:
	rm -rf $(STATEDIR)/xchain-nfs-utils.*
	rm -rf $(XCHAIN_NFS-UTILS_DIR)

# vim: syntax=make
