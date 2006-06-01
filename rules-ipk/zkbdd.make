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
ifdef PTXCONF_ZKBDD
PACKAGES += zkbdd
endif

#
# Paths and names
#
ZKBDD_VENDOR_VERSION	= 1
ZKBDD_VERSION		= 0.2
ZKBDD			= zkbdd-src_$(ZKBDD_VERSION)
ZKBDD_SUFFIX		= tar.gz
ZKBDD_URL		= http://kopsisengineering.com/$(ZKBDD).$(ZKBDD_SUFFIX)
ZKBDD_SOURCE		= $(SRCDIR)/$(ZKBDD).$(ZKBDD_SUFFIX)
ZKBDD_DIR		= $(BUILDDIR)/zkbdd
ZKBDD_IPKG_TMP		= $(ZKBDD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

zkbdd_get: $(STATEDIR)/zkbdd.get

zkbdd_get_deps = $(ZKBDD_SOURCE)

$(STATEDIR)/zkbdd.get: $(zkbdd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ZKBDD))
	touch $@

$(ZKBDD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ZKBDD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

zkbdd_extract: $(STATEDIR)/zkbdd.extract

zkbdd_extract_deps = $(STATEDIR)/zkbdd.get

$(STATEDIR)/zkbdd.extract: $(zkbdd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(ZKBDD_DIR))
	@$(call extract, $(ZKBDD_SOURCE))
	@$(call patchin, $(ZKBDD), $(ZKBDD_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

zkbdd_prepare: $(STATEDIR)/zkbdd.prepare

#
# dependencies
#
zkbdd_prepare_deps = \
	$(STATEDIR)/zkbdd.extract \
	$(STATEDIR)/virtual-xchain.install

ZKBDD_PATH	=  PATH=$(CROSS_PATH)
ZKBDD_ENV 	=  $(CROSS_ENV)
#ZKBDD_ENV	+=
ZKBDD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ZKBDD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ZKBDD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ZKBDD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ZKBDD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/zkbdd.prepare: $(zkbdd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ZKBDD_DIR)/config.cache)
	#cd $(ZKBDD_DIR) && \
	#	$(ZKBDD_PATH) $(ZKBDD_ENV) \
	#	./configure $(ZKBDD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

zkbdd_compile: $(STATEDIR)/zkbdd.compile

zkbdd_compile_deps = $(STATEDIR)/zkbdd.prepare

$(STATEDIR)/zkbdd.compile: $(zkbdd_compile_deps)
	@$(call targetinfo, $@)
	$(ZKBDD_PATH) $(MAKE) -C $(ZKBDD_DIR)/lua-x $(CROSS_ENV_CC) AR="$(PTXCONF_GNU_TARGET)-ar rcu" $(CROSS_ENV_RANLIB) $(CROSS_ENV_STRIP)
	$(ZKBDD_PATH) $(MAKE) -C $(ZKBDD_DIR) $(CROSS_ENV_CC) AR="$(PTXCONF_GNU_TARGET)-ar rcu" $(CROSS_ENV_RANLIB) $(CROSS_ENV_STRIP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

zkbdd_install: $(STATEDIR)/zkbdd.install

$(STATEDIR)/zkbdd.install: $(STATEDIR)/zkbdd.compile
	@$(call targetinfo, $@)
	#$(ZKBDD_PATH) $(MAKE) -C $(ZKBDD_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

zkbdd_targetinstall: $(STATEDIR)/zkbdd.targetinstall

zkbdd_targetinstall_deps = $(STATEDIR)/zkbdd.compile

$(STATEDIR)/zkbdd.targetinstall: $(zkbdd_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(ZKBDD_PATH) $(MAKE) -C $(ZKBDD_DIR) DESTDIR=$(ZKBDD_IPKG_TMP) install
	mkdir -p $(ZKBDD_IPKG_TMP)/etc
	mkdir -p $(ZKBDD_IPKG_TMP)/usr/bin
	mkdir -p $(ZKBDD_IPKG_TMP)/usr/share/zkbdd
	cp -a $(ZKBDD_DIR)/zkbdd.conf 	$(ZKBDD_IPKG_TMP)/etc/
	cp -a $(ZKBDD_DIR)/zkbdd 	$(ZKBDD_IPKG_TMP)/usr/bin/
	cp -a $(ZKBDD_DIR)/drivers 	$(ZKBDD_IPKG_TMP)/usr/share/zkbdd/
	mkdir -p $(ZKBDD_IPKG_TMP)/CONTROL
	echo "Package: zkbdd" 								 >$(ZKBDD_IPKG_TMP)/CONTROL/control
	echo "Source: $(ZKBDD_URL)"							>>$(ZKBDD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ZKBDD_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(ZKBDD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ZKBDD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ZKBDD_IPKG_TMP)/CONTROL/control
	echo "Version: $(ZKBDD_VERSION)-$(ZKBDD_VENDOR_VERSION)" 			>>$(ZKBDD_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(ZKBDD_IPKG_TMP)/CONTROL/control
	echo "Description: IR Keyboard Drivers for the Sharp Zaurus"			>>$(ZKBDD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ZKBDD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ZKBDD_INSTALL
ROMPACKAGES += $(STATEDIR)/zkbdd.imageinstall
endif

zkbdd_imageinstall_deps = $(STATEDIR)/zkbdd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/zkbdd.imageinstall: $(zkbdd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install zkbdd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

zkbdd_clean:
	rm -rf $(STATEDIR)/zkbdd.*
	rm -rf $(ZKBDD_DIR)

# vim: syntax=make
