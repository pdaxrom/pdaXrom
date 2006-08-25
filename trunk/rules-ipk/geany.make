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
ifdef PTXCONF_GEANY
PACKAGES += geany
endif

#
# Paths and names
#
GEANY_VENDOR_VERSION	= 1
GEANY_VERSION		= 0.8
GEANY			= geany-$(GEANY_VERSION)
GEANY_SUFFIX		= tar.bz2
GEANY_URL		= http://ufpr.dl.sourceforge.net/sourceforge/geany/$(GEANY).$(GEANY_SUFFIX)
GEANY_SOURCE		= $(SRCDIR)/$(GEANY).$(GEANY_SUFFIX)
GEANY_DIR		= $(BUILDDIR)/$(GEANY)
GEANY_IPKG_TMP		= $(GEANY_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

geany_get: $(STATEDIR)/geany.get

geany_get_deps = $(GEANY_SOURCE)

$(STATEDIR)/geany.get: $(geany_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GEANY))
	touch $@

$(GEANY_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GEANY_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

geany_extract: $(STATEDIR)/geany.extract

geany_extract_deps = $(STATEDIR)/geany.get

$(STATEDIR)/geany.extract: $(geany_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GEANY_DIR))
	@$(call extract, $(GEANY_SOURCE))
	@$(call patchin, $(GEANY))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

geany_prepare: $(STATEDIR)/geany.prepare

#
# dependencies
#
geany_prepare_deps = \
	$(STATEDIR)/geany.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

GEANY_PATH	=  PATH=$(CROSS_PATH)
GEANY_ENV 	=  $(CROSS_ENV)
#GEANY_ENV	+=
GEANY_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GEANY_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GEANY_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GEANY_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GEANY_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/geany.prepare: $(geany_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GEANY_DIR)/config.cache)
	cd $(GEANY_DIR) && \
		$(GEANY_PATH) $(GEANY_ENV) \
		./configure $(GEANY_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

geany_compile: $(STATEDIR)/geany.compile

geany_compile_deps = $(STATEDIR)/geany.prepare

$(STATEDIR)/geany.compile: $(geany_compile_deps)
	@$(call targetinfo, $@)
	$(GEANY_PATH) $(MAKE) -C $(GEANY_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

geany_install: $(STATEDIR)/geany.install

$(STATEDIR)/geany.install: $(STATEDIR)/geany.compile
	@$(call targetinfo, $@)
	rm -rf $(GEANY_IPKG_TMP)
	$(GEANY_PATH) $(MAKE) -C $(GEANY_DIR) DESTDIR=$(GEANY_IPKG_TMP) install
	@$(call copyincludes, $(GEANY_IPKG_TMP))
	@$(call copylibraries,$(GEANY_IPKG_TMP))
	@$(call copymiscfiles,$(GEANY_IPKG_TMP))
	rm -rf $(GEANY_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

geany_targetinstall: $(STATEDIR)/geany.targetinstall

geany_targetinstall_deps = $(STATEDIR)/geany.compile \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/geany.targetinstall: $(geany_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GEANY_PATH) $(MAKE) -C $(GEANY_DIR) DESTDIR=$(GEANY_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(GEANY_VERSION)-$(GEANY_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh geany $(GEANY_IPKG_TMP)

	@$(call removedevfiles, $(GEANY_IPKG_TMP))
	@$(call stripfiles, $(GEANY_IPKG_TMP))
	mkdir -p $(GEANY_IPKG_TMP)/CONTROL
	echo "Package: geany" 								 >$(GEANY_IPKG_TMP)/CONTROL/control
	echo "Source: $(GEANY_URL)"							>>$(GEANY_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GEANY_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 							>>$(GEANY_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GEANY_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GEANY_IPKG_TMP)/CONTROL/control
	echo "Version: $(GEANY_VERSION)-$(GEANY_VENDOR_VERSION)" 			>>$(GEANY_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 								>>$(GEANY_IPKG_TMP)/CONTROL/control
	echo "Description: GTK2 IDE"							>>$(GEANY_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GEANY_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GEANY_INSTALL
ROMPACKAGES += $(STATEDIR)/geany.imageinstall
endif

geany_imageinstall_deps = $(STATEDIR)/geany.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/geany.imageinstall: $(geany_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install geany
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

geany_clean:
	rm -rf $(STATEDIR)/geany.*
	rm -rf $(GEANY_DIR)

# vim: syntax=make
