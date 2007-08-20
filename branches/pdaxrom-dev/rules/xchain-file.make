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
ifdef PTXCONF_XCHAIN_FILE
PACKAGES += xchain-file
endif

#
# Paths and names
#
XCHAIN_FILE		= file-$(FILE_VERSION)
XCHAIN_FILE_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_FILE)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-file_get: $(STATEDIR)/xchain-file.get

xchain-file_get_deps = $(XCHAIN_FILE_SOURCE)

$(STATEDIR)/xchain-file.get: $(xchain-file_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_FILE))
	touch $@

$(XCHAIN_FILE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_FILE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-file_extract: $(STATEDIR)/xchain-file.extract

xchain-file_extract_deps = $(STATEDIR)/file.get

$(STATEDIR)/xchain-file.extract: $(xchain-file_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_FILE_DIR))
	@$(call extract, $(FILE_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_FILE), $(XCHAIN_FILE_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-file_prepare: $(STATEDIR)/xchain-file.prepare

#
# dependencies
#
xchain-file_prepare_deps = \
	$(STATEDIR)/xchain-file.extract

XCHAIN_FILE_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_FILE_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_FILE_ENV	+=

#
# autoconf
#
XCHAIN_FILE_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-file.prepare: $(xchain-file_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_FILE_DIR)/config.cache)
	cd $(XCHAIN_FILE_DIR) && \
		$(XCHAIN_FILE_PATH) $(XCHAIN_FILE_ENV) \
		./configure $(XCHAIN_FILE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-file_compile: $(STATEDIR)/xchain-file.compile

xchain-file_compile_deps = $(STATEDIR)/xchain-file.prepare

$(STATEDIR)/xchain-file.compile: $(xchain-file_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_FILE_PATH) $(MAKE) -C $(XCHAIN_FILE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-file_install: $(STATEDIR)/xchain-file.install

$(STATEDIR)/xchain-file.install: $(STATEDIR)/xchain-file.compile
	@$(call targetinfo, $@)
	$(XCHAIN_FILE_PATH) $(MAKE) -C $(XCHAIN_FILE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-file_targetinstall: $(STATEDIR)/xchain-file.targetinstall

xchain-file_targetinstall_deps = $(STATEDIR)/xchain-file.compile

$(STATEDIR)/xchain-file.targetinstall: $(xchain-file_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-file_clean:
	rm -rf $(STATEDIR)/xchain-file.*
	rm -rf $(XCHAIN_FILE_DIR)

# vim: syntax=make
