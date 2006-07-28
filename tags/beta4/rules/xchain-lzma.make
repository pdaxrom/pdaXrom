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
ifdef PTXCONF_XCHAIN_LZMA
PACKAGES += xchain-lzma
endif

#
# Paths and names
#
#XCHAIN_LZMA_VERSION	= 417
XCHAIN_LZMA		= $(LZMA)
#XCHAIN_LZMA_SUFFIX	= tar.bz2
#XCHAIN_LZMA_URL		= http://www.7-zip.org/dl/$(XCHAIN_LZMA).$(XCHAIN_LZMA_SUFFIX)
#XCHAIN_LZMA_SOURCE	= $(SRCDIR)/$(XCHAIN_LZMA).$(XCHAIN_LZMA_SUFFIX)
XCHAIN_LZMA_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_LZMA)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-lzma_get: $(STATEDIR)/xchain-lzma.get

xchain-lzma_get_deps = $(XCHAIN_LZMA_SOURCE)

$(STATEDIR)/xchain-lzma.get: $(xchain-lzma_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_LZMA))
	touch $@

$(XCHAIN_LZMA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_LZMA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-lzma_extract: $(STATEDIR)/xchain-lzma.extract

xchain-lzma_extract_deps = $(STATEDIR)/lzma.get \
	 $(STATEDIR)/xchain-lzma.get

$(STATEDIR)/xchain-lzma.extract: $(xchain-lzma_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_LZMA_DIR))
	@$(call extract, $(LZMA_SOURCE), $(XCHAIN_LZMA_DIR))
	@$(call patchin, $(LZMA), $(XCHAIN_LZMA_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-lzma_prepare: $(STATEDIR)/xchain-lzma.prepare

#
# dependencies
#
xchain-lzma_prepare_deps = \
	$(STATEDIR)/xchain-lzma.extract

XCHAIN_LZMA_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_LZMA_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_LZMA_ENV	+=

#
# autoconf
#
XCHAIN_LZMA_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-lzma.prepare: $(xchain-lzma_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_LZMA_DIR)/config.cache)
	#cd $(XCHAIN_LZMA_DIR) && \
	#	$(XCHAIN_LZMA_PATH) $(XCHAIN_LZMA_ENV) \
	#	./configure $(XCHAIN_LZMA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-lzma_compile: $(STATEDIR)/xchain-lzma.compile

xchain-lzma_compile_deps = $(STATEDIR)/xchain-lzma.prepare

$(STATEDIR)/xchain-lzma.compile: $(xchain-lzma_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_LZMA_PATH) $(MAKE) -C $(XCHAIN_LZMA_DIR)/SRC/7zip/Compress/LZMA_Alone
	$(XCHAIN_LZMA_PATH) $(MAKE) -C $(XCHAIN_LZMA_DIR)/SRC/7zip/Compress/LZMA_Lib
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-lzma_install: $(STATEDIR)/xchain-lzma.install

$(STATEDIR)/xchain-lzma.install: $(STATEDIR)/xchain-lzma.compile
	@$(call targetinfo, $@)
	#$(XCHAIN_LZMA_PATH) $(MAKE) -C $(XCHAIN_LZMA_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-lzma_targetinstall: $(STATEDIR)/xchain-lzma.targetinstall

xchain-lzma_targetinstall_deps = $(STATEDIR)/xchain-lzma.compile

$(STATEDIR)/xchain-lzma.targetinstall: $(xchain-lzma_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-lzma_clean:
	rm -rf $(STATEDIR)/xchain-lzma.*
	rm -rf $(XCHAIN_LZMA_DIR)

# vim: syntax=make
