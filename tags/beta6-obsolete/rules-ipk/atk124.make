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
ifdef PTXCONF_ATK124
PACKAGES += atk124
endif

#
# Paths and names
#
ATK124_VENDOR_VERSION	= 1
ATK124_VERSION		= 1.12.1
ATK124			= atk-$(ATK124_VERSION)
ATK124_SUFFIX		= tar.bz2
ATK124_URL		= http://ftp.gnome.org/pub/gnome/sources/atk/1.12/$(ATK124).$(ATK124_SUFFIX)
ATK124_SOURCE		= $(SRCDIR)/$(ATK124).$(ATK124_SUFFIX)
ATK124_DIR		= $(BUILDDIR)/$(ATK124)
ATK124_IPKG_TMP	= $(ATK124_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

atk124_get: $(STATEDIR)/atk124.get

atk124_get_deps = $(ATK124_SOURCE)

$(STATEDIR)/atk124.get: $(atk124_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ATK124))
	touch $@

$(ATK124_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ATK124_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

atk124_extract: $(STATEDIR)/atk124.extract

atk124_extract_deps = $(STATEDIR)/atk124.get

$(STATEDIR)/atk124.extract: $(atk124_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ATK124_DIR))
	@$(call extract, $(ATK124_SOURCE))
	@$(call patchin, $(ATK124))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

atk124_prepare: $(STATEDIR)/atk124.prepare

#
# dependencies
#
atk124_prepare_deps = \
	$(STATEDIR)/atk124.extract \
	$(STATEDIR)/pango12.install \
	$(STATEDIR)/virtual-xchain.install

ATK124_PATH	=  PATH=$(CROSS_PATH)
ATK124_ENV 	=  $(CROSS_ENV)
ATK124_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
ATK124_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ATK124_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ATK124_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-debug \
	--enable-shared

ifdef PTXCONF_XFREE430
ATK124_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ATK124_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/atk124.prepare: $(atk124_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ATK124_DIR)/config.cache)
	cd $(ATK124_DIR) && \
		$(ATK124_PATH) $(ATK124_ENV) \
		./configure $(ATK124_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

atk124_compile: $(STATEDIR)/atk124.compile

atk124_compile_deps = $(STATEDIR)/atk124.prepare

$(STATEDIR)/atk124.compile: $(atk124_compile_deps)
	@$(call targetinfo, $@)
	$(ATK124_PATH) $(MAKE) -C $(ATK124_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

atk124_install: $(STATEDIR)/atk124.install

$(STATEDIR)/atk124.install: $(STATEDIR)/atk124.compile
	@$(call targetinfo, $@)
	rm -rf $(ATK124_IPKG_TMP)
	$(ATK124_PATH) $(MAKE) -C $(ATK124_DIR) DESTDIR=$(ATK124_IPKG_TMP) install
	@$(call copyincludes, $(ATK124_IPKG_TMP))
	@$(call copylibraries,$(ATK124_IPKG_TMP))
	@$(call copymiscfiles,$(ATK124_IPKG_TMP))
	rm -rf $(ATK124_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

atk124_targetinstall: $(STATEDIR)/atk124.targetinstall

atk124_targetinstall_deps = $(STATEDIR)/atk124.compile \
	$(STATEDIR)/pango12.targetinstall

$(STATEDIR)/atk124.targetinstall: $(atk124_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ATK124_PATH) $(MAKE) -C $(ATK124_DIR) DESTDIR=$(ATK124_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(ATK124_VERSION)-$(ATK124_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh atk $(ATK124_IPKG_TMP)

	@$(call removedevfiles, $(ATK124_IPKG_TMP))
	@$(call stripfiles, $(ATK124_IPKG_TMP))
	mkdir -p $(ATK124_IPKG_TMP)/CONTROL
	echo "Package: atk" 								 >$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Source: $(ATK124_URL)"							>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Version: $(ATK124_VERSION)-$(ATK124_VENDOR_VERSION)" 			>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Depends: pango, xfree"		 					>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Description: ATK Library"							>>$(ATK124_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(ATK124_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ATK124_INSTALL
ROMPACKAGES += $(STATEDIR)/atk124.imageinstall
endif

atk124_imageinstall_deps = $(STATEDIR)/atk124.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/atk124.imageinstall: $(atk124_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install atk
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

atk124_clean:
	rm -rf $(STATEDIR)/atk124.*
	rm -rf $(ATK124_DIR)

# vim: syntax=make
