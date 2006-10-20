# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_FUSE
PACKAGES += fuse
endif

#
# Paths and names
#
FUSE_VENDOR_VERSION	= 1
FUSE_VERSION		= 2.5.3
FUSE			= fuse-$(FUSE_VERSION)
FUSE_SUFFIX		= tar.gz
FUSE_URL		= http://puzzle.dl.sourceforge.net/sourceforge/fuse/$(FUSE).$(FUSE_SUFFIX)
FUSE_SOURCE		= $(SRCDIR)/$(FUSE).$(FUSE_SUFFIX)
FUSE_DIR		= $(BUILDDIR)/$(FUSE)
FUSE_IPKG_TMP		= $(FUSE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fuse_get: $(STATEDIR)/fuse.get

fuse_get_deps = $(FUSE_SOURCE)

$(STATEDIR)/fuse.get: $(fuse_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FUSE))
	touch $@

$(FUSE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FUSE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fuse_extract: $(STATEDIR)/fuse.extract

fuse_extract_deps = $(STATEDIR)/fuse.get

$(STATEDIR)/fuse.extract: $(fuse_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FUSE_DIR))
	@$(call extract, $(FUSE_SOURCE))
	@$(call patchin, $(FUSE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fuse_prepare: $(STATEDIR)/fuse.prepare

#
# dependencies
#
fuse_prepare_deps = \
	$(STATEDIR)/fuse.extract \
	$(STATEDIR)/virtual-xchain.install

FUSE_PATH	=  PATH=$(CROSS_PATH)
FUSE_ENV 	=  $(CROSS_ENV)
#FUSE_ENV	+=
FUSE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FUSE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
FUSE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
FUSE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FUSE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fuse.prepare: $(fuse_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FUSE_DIR)/config.cache)
	cd $(FUSE_DIR) && \
		$(FUSE_PATH) $(FUSE_ENV) \
		./configure $(FUSE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fuse_compile: $(STATEDIR)/fuse.compile

fuse_compile_deps = $(STATEDIR)/fuse.prepare

$(STATEDIR)/fuse.compile: $(fuse_compile_deps)
	@$(call targetinfo, $@)
	$(FUSE_PATH) $(MAKE) -C $(FUSE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fuse_install: $(STATEDIR)/fuse.install

$(STATEDIR)/fuse.install: $(STATEDIR)/fuse.compile
	@$(call targetinfo, $@)
	rm -rf $(FUSE_IPKG_TMP)
	$(FUSE_PATH) $(MAKE) -C $(FUSE_DIR) DESTDIR=$(FUSE_IPKG_TMP) install
	@$(call copyincludes, $(FUSE_IPKG_TMP))
	@$(call copylibraries,$(FUSE_IPKG_TMP))
	@$(call copymiscfiles,$(FUSE_IPKG_TMP))
	rm -rf $(FUSE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fuse_targetinstall: $(STATEDIR)/fuse.targetinstall

fuse_targetinstall_deps = $(STATEDIR)/fuse.compile

FUSE_DEPLIST = 

$(STATEDIR)/fuse.targetinstall: $(fuse_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FUSE_PATH) $(MAKE) -C $(FUSE_DIR) DESTDIR=$(FUSE_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(FUSE_VERSION)-$(FUSE_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh fuse $(FUSE_IPKG_TMP)

	@$(call removedevfiles, $(FUSE_IPKG_TMP))
	@$(call stripfiles, $(FUSE_IPKG_TMP))
	mkdir -p $(FUSE_IPKG_TMP)/CONTROL
	echo "Package: fuse" 								 >$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Source: $(FUSE_URL)"							>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Section: System"	 							>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Version: $(FUSE_VERSION)-$(FUSE_VENDOR_VERSION)" 				>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Depends: $(FUSE_DEPLIST)" 						>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Description: Filesystem in Userspace"					>>$(FUSE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(FUSE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FUSE_INSTALL
ROMPACKAGES += $(STATEDIR)/fuse.imageinstall
endif

fuse_imageinstall_deps = $(STATEDIR)/fuse.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fuse.imageinstall: $(fuse_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fuse
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fuse_clean:
	rm -rf $(STATEDIR)/fuse.*
	rm -rf $(FUSE_DIR)

# vim: syntax=make
