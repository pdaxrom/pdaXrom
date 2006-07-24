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
ifdef PTXCONF_BC
PACKAGES += bc
endif

#
# Paths and names
#
BC_VENDOR_VERSION	= 1
BC_VERSION		= 1.06
BC			= bc-$(BC_VERSION)
BC_SUFFIX		= tar.gz
BC_URL			= ftp://ftp.gnu.org/pub/gnu/bc/$(BC).$(BC_SUFFIX)
BC_SOURCE		= $(SRCDIR)/$(BC).$(BC_SUFFIX)
BC_DIR			= $(BUILDDIR)/$(BC)
BC_IPKG_TMP		= $(BC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

bc_get: $(STATEDIR)/bc.get

bc_get_deps = $(BC_SOURCE)

$(STATEDIR)/bc.get: $(bc_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BC))
	touch $@

$(BC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

bc_extract: $(STATEDIR)/bc.extract

bc_extract_deps = $(STATEDIR)/bc.get

$(STATEDIR)/bc.extract: $(bc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BC_DIR))
	@$(call extract, $(BC_SOURCE))
	@$(call patchin, $(BC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

bc_prepare: $(STATEDIR)/bc.prepare

#
# dependencies
#
bc_prepare_deps = \
	$(STATEDIR)/bc.extract \
	$(STATEDIR)/virtual-xchain.install

BC_PATH	=  PATH=$(CROSS_PATH)
BC_ENV 	=  $(CROSS_ENV)
#BC_ENV	+=
BC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
BC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
BC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/bc.prepare: $(bc_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BC_DIR)/config.cache)
	cd $(BC_DIR) && \
		$(BC_PATH) $(BC_ENV) \
		./configure $(BC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

bc_compile: $(STATEDIR)/bc.compile

bc_compile_deps = $(STATEDIR)/bc.prepare

$(STATEDIR)/bc.compile: $(bc_compile_deps)
	@$(call targetinfo, $@)
	$(BC_PATH) $(MAKE) -C $(BC_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bc_install: $(STATEDIR)/bc.install

$(STATEDIR)/bc.install: $(STATEDIR)/bc.compile
	@$(call targetinfo, $@)
	$(BC_PATH) $(MAKE) -C $(BC_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

bc_targetinstall: $(STATEDIR)/bc.targetinstall

bc_targetinstall_deps = $(STATEDIR)/bc.compile

$(STATEDIR)/bc.targetinstall: $(bc_targetinstall_deps)
	@$(call targetinfo, $@)
	$(BC_PATH) $(MAKE) -C $(BC_DIR) DESTDIR=$(BC_IPKG_TMP) install
	rm -rf $(BC_IPKG_TMP)/usr/info
	rm -rf $(BC_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(BC_IPKG_TMP)/usr/bin/*
	mkdir -p $(BC_IPKG_TMP)/CONTROL
	echo "Package: bc" 								 >$(BC_IPKG_TMP)/CONTROL/control
	echo "Source: $(BC_URL)"							>>$(BC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(BC_IPKG_TMP)/CONTROL/control
	echo "Section: Console" 							>>$(BC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(BC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(BC_IPKG_TMP)/CONTROL/control
	echo "Version: $(BC_VERSION)-$(BC_VENDOR_VERSION)" 				>>$(BC_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(BC_IPKG_TMP)/CONTROL/control
	echo "Description: bc is an arbitrary precision numeric processing language. Syntax is similar to C, but differs in many substantial areas. It supports interactive execution of statements. bc is a utility included in the POSIX P1003.2/D11 draft standard." >>$(BC_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BC_INSTALL
ROMPACKAGES += $(STATEDIR)/bc.imageinstall
endif

bc_imageinstall_deps = $(STATEDIR)/bc.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/bc.imageinstall: $(bc_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install bc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bc_clean:
	rm -rf $(STATEDIR)/bc.*
	rm -rf $(BC_DIR)

# vim: syntax=make
