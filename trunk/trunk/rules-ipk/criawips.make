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
ifdef PTXCONF_CRIAWIPS
PACKAGES += criawips
endif

#
# Paths and names
#
CRIAWIPS_VENDOR_VERSION	= 1
CRIAWIPS_VERSION	= 0.0.8a
CRIAWIPS		= criawips-$(CRIAWIPS_VERSION)
CRIAWIPS_SUFFIX		= tar.gz
CRIAWIPS_URL		= http://savannah.nongnu.org/download/criawips/$(CRIAWIPS).$(CRIAWIPS_SUFFIX)
CRIAWIPS_SOURCE		= $(SRCDIR)/$(CRIAWIPS).$(CRIAWIPS_SUFFIX)
CRIAWIPS_DIR		= $(BUILDDIR)/$(CRIAWIPS)
CRIAWIPS_IPKG_TMP	= $(CRIAWIPS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

criawips_get: $(STATEDIR)/criawips.get

criawips_get_deps = $(CRIAWIPS_SOURCE)

$(STATEDIR)/criawips.get: $(criawips_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CRIAWIPS))
	touch $@

$(CRIAWIPS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CRIAWIPS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

criawips_extract: $(STATEDIR)/criawips.extract

criawips_extract_deps = $(STATEDIR)/criawips.get

$(STATEDIR)/criawips.extract: $(criawips_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CRIAWIPS_DIR))
	@$(call extract, $(CRIAWIPS_SOURCE))
	@$(call patchin, $(CRIAWIPS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

criawips_prepare: $(STATEDIR)/criawips.prepare

#
# dependencies
#
criawips_prepare_deps = \
	$(STATEDIR)/criawips.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libglade.install \
	$(STATEDIR)/libgsf.install \
	$(STATEDIR)/libgnome.install \
	$(STATEDIR)/libgnomeui.install \
	$(STATEDIR)/virtual-xchain.install

CRIAWIPS_PATH	=  PATH=$(CROSS_PATH)
CRIAWIPS_ENV 	=  $(CROSS_ENV)
CRIAWIPS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
CRIAWIPS_ENV	+= CXXFLAGS="-O2 -fomit-frame-pointer"
CRIAWIPS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CRIAWIPS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
CRIAWIPS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-developer \
	--disable-debug \
	--enable-shared \
	--disable-static \
	--disable-schemas-install \
	--disable-update-mimedb \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
CRIAWIPS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CRIAWIPS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/criawips.prepare: $(criawips_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CRIAWIPS_DIR)/config.cache)
	cd $(CRIAWIPS_DIR) && \
		$(CRIAWIPS_PATH) $(CRIAWIPS_ENV) \
		./configure $(CRIAWIPS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

criawips_compile: $(STATEDIR)/criawips.compile

criawips_compile_deps = $(STATEDIR)/criawips.prepare

$(STATEDIR)/criawips.compile: $(criawips_compile_deps)
	@$(call targetinfo, $@)
	$(CRIAWIPS_PATH) $(MAKE) -C $(CRIAWIPS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

criawips_install: $(STATEDIR)/criawips.install

$(STATEDIR)/criawips.install: $(STATEDIR)/criawips.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

criawips_targetinstall: $(STATEDIR)/criawips.targetinstall

criawips_targetinstall_deps = $(STATEDIR)/criawips.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libglade.targetinstall \
	$(STATEDIR)/libgsf.targetinstall \
	$(STATEDIR)/libgnome.targetinstall \
	$(STATEDIR)/libgnomeui.targetinstall

$(STATEDIR)/criawips.targetinstall: $(criawips_targetinstall_deps)
	@$(call targetinfo, $@)
	$(CRIAWIPS_PATH) $(MAKE) -C $(CRIAWIPS_DIR) DESTDIR=$(CRIAWIPS_IPKG_TMP) install
	rm -rf $(CRIAWIPS_IPKG_TMP)/usr/man
	rm -rf $(CRIAWIPS_IPKG_TMP)/usr/share/gtk-doc
	rm -rf $(CRIAWIPS_IPKG_TMP)/usr/share/locale
	$(CROSSSTRIP) $(CRIAWIPS_IPKG_TMP)/usr/bin/*
	mkdir -p $(CRIAWIPS_IPKG_TMP)/CONTROL
	echo "Package: criawips" 										 >$(CRIAWIPS_IPKG_TMP)/CONTROL/control
	echo "Source: $(CRIAWIPS_URL)"										>>$(CRIAWIPS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(CRIAWIPS_IPKG_TMP)/CONTROL/control
	echo "Section: Office"	 										>>$(CRIAWIPS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(CRIAWIPS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(CRIAWIPS_IPKG_TMP)/CONTROL/control
	echo "Version: $(CRIAWIPS_VERSION)-$(CRIAWIPS_VENDOR_VERSION)" 						>>$(CRIAWIPS_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libglade, libgsf, libgnome, libgnomeui" 						>>$(CRIAWIPS_IPKG_TMP)/CONTROL/control
	echo "Description: The criawips project aims to create a full featured presentation application that integrated smoothly into the GNOME desktop environment." >>$(CRIAWIPS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(CRIAWIPS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CRIAWIPS_INSTALL
ROMPACKAGES += $(STATEDIR)/criawips.imageinstall
endif

criawips_imageinstall_deps = $(STATEDIR)/criawips.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/criawips.imageinstall: $(criawips_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install criawips
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

criawips_clean:
	rm -rf $(STATEDIR)/criawips.*
	rm -rf $(CRIAWIPS_DIR)

# vim: syntax=make
