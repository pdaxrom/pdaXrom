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
ifdef PTXCONF_GAL
PACKAGES += gal
endif

#
# Paths and names
#
GAL_VENDOR_VERSION	= 1
GAL_VERSION		= 2.5.3
GAL			= gal-$(GAL_VERSION)
GAL_SUFFIX		= tar.bz2
GAL_URL			= http://ftp.gnome.org/pub/gnome/sources/gal/2.5/$(GAL).$(GAL_SUFFIX)
GAL_SOURCE		= $(SRCDIR)/$(GAL).$(GAL_SUFFIX)
GAL_DIR			= $(BUILDDIR)/$(GAL)
GAL_IPKG_TMP		= $(GAL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gal_get: $(STATEDIR)/gal.get

gal_get_deps = $(GAL_SOURCE)

$(STATEDIR)/gal.get: $(gal_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GAL))
	touch $@

$(GAL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GAL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gal_extract: $(STATEDIR)/gal.extract

gal_extract_deps = $(STATEDIR)/gal.get

$(STATEDIR)/gal.extract: $(gal_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GAL_DIR))
	@$(call extract, $(GAL_SOURCE))
	@$(call patchin, $(GAL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gal_prepare: $(STATEDIR)/gal.prepare

#
# dependencies
#
gal_prepare_deps = \
	$(STATEDIR)/gal.extract \
	$(STATEDIR)/libgnomeiu.install \
	$(STATEDIR)/libgnomeprintiu.install \
	$(STATEDIR)/virtual-xchain.install

GAL_PATH	=  PATH=$(CROSS_PATH)
GAL_ENV 	=  $(CROSS_ENV)
#GAL_ENV	+=
GAL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GAL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GAL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GAL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GAL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gal.prepare: $(gal_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GAL_DIR)/config.cache)
	cd $(GAL_DIR) && \
		$(GAL_PATH) $(GAL_ENV) \
		./configure $(GAL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gal_compile: $(STATEDIR)/gal.compile

gal_compile_deps = $(STATEDIR)/gal.prepare

$(STATEDIR)/gal.compile: $(gal_compile_deps)
	@$(call targetinfo, $@)
	$(GAL_PATH) $(MAKE) -C $(GAL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gal_install: $(STATEDIR)/gal.install

$(STATEDIR)/gal.install: $(STATEDIR)/gal.compile
	@$(call targetinfo, $@)
	rm -rf $(GAL_IPKG_TMP)
	$(GAL_PATH) $(MAKE) -C $(GAL_DIR) DESTDIR=$(GAL_IPKG_TMP) install
	@$(call copyincludes, $(GAL_IPKG_TMP))
	@$(call copylibraries,$(GAL_IPKG_TMP))
	@$(call copymiscfiles,$(GAL_IPKG_TMP))
	rm -rf $(GAL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gal_targetinstall: $(STATEDIR)/gal.targetinstall

gal_targetinstall_deps = $(STATEDIR)/gal.compile \
	$(STATEDIR)/libgnomeiu.targetinstall \
	$(STATEDIR)/libgnomeprintiu.targetinstall

$(STATEDIR)/gal.targetinstall: $(gal_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GAL_PATH) $(MAKE) -C $(GAL_DIR) DESTDIR=$(GAL_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(GAL_VERSION)-$(GAL_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh gal $(GAL_IPKG_TMP)

	@$(call removedevfiles, $(GAL_IPKG_TMP))
	@$(call stripfiles, $(GAL_IPKG_TMP))
	mkdir -p $(GAL_IPKG_TMP)/CONTROL
	echo "Package: gal" 								 >$(GAL_IPKG_TMP)/CONTROL/control
	echo "Source: $(GAL_URL)"							>>$(GAL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GAL_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(GAL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GAL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GAL_IPKG_TMP)/CONTROL/control
	echo "Version: $(GAL_VERSION)-$(GAL_VENDOR_VERSION)" 				>>$(GAL_IPKG_TMP)/CONTROL/control
	echo "Depends: libgnomeui, libgnomeprintui" 					>>$(GAL_IPKG_TMP)/CONTROL/control
	echo "Description: The GAL package contains library functions that came from Evolution  and Gnumeric." >>$(GAL_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(GAL_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GAL_INSTALL
ROMPACKAGES += $(STATEDIR)/gal.imageinstall
endif

gal_imageinstall_deps = $(STATEDIR)/gal.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gal.imageinstall: $(gal_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gal
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gal_clean:
	rm -rf $(STATEDIR)/gal.*
	rm -rf $(GAL_DIR)

# vim: syntax=make
