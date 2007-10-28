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
ifdef PTXCONF_MTPAINT
PACKAGES += mtPaint
endif

#
# Paths and names
#
MTPAINT_VENDOR_VERSION	= 1
MTPAINT_VERSION		= 2.20
MTPAINT			= mtpaint-$(MTPAINT_VERSION)
MTPAINT_SUFFIX		= tar.bz2
MTPAINT_URL		= http://citkit.dl.sourceforge.net/sourceforge/mtpaint/$(MTPAINT).$(MTPAINT_SUFFIX)
MTPAINT_SOURCE		= $(SRCDIR)/$(MTPAINT).$(MTPAINT_SUFFIX)
MTPAINT_DIR		= $(BUILDDIR)/$(MTPAINT)
MTPAINT_IPKG_TMP	= $(MTPAINT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mtPaint_get: $(STATEDIR)/mtPaint.get

mtPaint_get_deps = $(MTPAINT_SOURCE)

$(STATEDIR)/mtPaint.get: $(mtPaint_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MTPAINT))
	touch $@

$(MTPAINT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MTPAINT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mtPaint_extract: $(STATEDIR)/mtPaint.extract

mtPaint_extract_deps = $(STATEDIR)/mtPaint.get

$(STATEDIR)/mtPaint.extract: $(mtPaint_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MTPAINT_DIR))
	@$(call extract, $(MTPAINT_SOURCE))
	@$(call patchin, $(MTPAINT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mtPaint_prepare: $(STATEDIR)/mtPaint.prepare

#
# dependencies
#
mtPaint_prepare_deps = \
	$(STATEDIR)/mtPaint.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/tiff.install \
	$(STATEDIR)/libungif.install \
	$(STATEDIR)/virtual-xchain.install

MTPAINT_PATH	=  PATH=$(CROSS_PATH)
MTPAINT_ENV 	=  $(CROSS_ENV)
#MTPAINT_ENV	+=
MTPAINT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MTPAINT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MTPAINT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MTPAINT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MTPAINT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mtPaint.prepare: $(mtPaint_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MTPAINT_DIR)/config.cache)
	cd $(MTPAINT_DIR) && \
		$(MTPAINT_PATH) $(MTPAINT_ENV) \
		CROSS_PREFIX=$(CROSS_LIB_DIR) \
		./configure $(MTPAINT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mtPaint_compile: $(STATEDIR)/mtPaint.compile

mtPaint_compile_deps = $(STATEDIR)/mtPaint.prepare

$(STATEDIR)/mtPaint.compile: $(mtPaint_compile_deps)
	@$(call targetinfo, $@)
	$(MTPAINT_PATH) $(MTPAINT_ENV) $(MAKE) -C $(MTPAINT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mtPaint_install: $(STATEDIR)/mtPaint.install

$(STATEDIR)/mtPaint.install: $(STATEDIR)/mtPaint.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mtPaint_targetinstall: $(STATEDIR)/mtPaint.targetinstall

mtPaint_targetinstall_deps = $(STATEDIR)/mtPaint.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/tiff.targetinstall \
	$(STATEDIR)/libungif.targetinstall

$(STATEDIR)/mtPaint.targetinstall: $(mtPaint_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(MTPAINT_PATH) $(MAKE) -C $(MTPAINT_DIR) DESTDIR=$(MTPAINT_IPKG_TMP) install
	$(INSTALL) -D $(MTPAINT_DIR)/src/mtpaint $(MTPAINT_IPKG_TMP)/usr/bin/mtpaint
	$(INSTALL) -m 644 -D $(TOPDIR)/config/pics/mtpaint.png $(MTPAINT_IPKG_TMP)/usr/share/pixmaps/mtpaint.png
	$(INSTALL) -m 644 -D $(TOPDIR)/config/pics/mtpaint.desktop $(MTPAINT_IPKG_TMP)/usr/share/applications/mtpaint.desktop
	$(CROSSSTRIP) $(MTPAINT_IPKG_TMP)/usr/bin/mtpaint
	mkdir -p $(MTPAINT_IPKG_TMP)/CONTROL
	echo "Package: mtpaint" 							 >$(MTPAINT_IPKG_TMP)/CONTROL/control
	echo "Source: $(MTPAINT_URL)"							>>$(MTPAINT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MTPAINT_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(MTPAINT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(MTPAINT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MTPAINT_IPKG_TMP)/CONTROL/control
	echo "Version: $(MTPAINT_VERSION)-$(MTPAINT_VENDOR_VERSION)" 			>>$(MTPAINT_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libungif, libjpeg, libtiff" 				>>$(MTPAINT_IPKG_TMP)/CONTROL/control
	echo "Description: mtPaint is a simple painting program"			>>$(MTPAINT_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(MTPAINT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MTPAINT_INSTALL
ROMPACKAGES += $(STATEDIR)/mtPaint.imageinstall
endif

mtPaint_imageinstall_deps = $(STATEDIR)/mtPaint.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mtPaint.imageinstall: $(mtPaint_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mtpaint
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mtPaint_clean:
	rm -rf $(STATEDIR)/mtPaint.*
	rm -rf $(MTPAINT_DIR)

# vim: syntax=make
