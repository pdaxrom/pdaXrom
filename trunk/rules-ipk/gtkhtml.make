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
ifdef PTXCONF_GTKHTML
PACKAGES += gtkhtml
endif

#
# Paths and names
#
GTKHTML_VENDOR_VERSION	= 1
GTKHTML_VERSION		= 3.11.91
GTKHTML			= gtkhtml-$(GTKHTML_VERSION)
GTKHTML_SUFFIX		= tar.bz2
GTKHTML_URL		= http://ftp.gnome.org/pub/gnome/sources/gtkhtml/3.11/$(GTKHTML).$(GTKHTML_SUFFIX)
GTKHTML_SOURCE		= $(SRCDIR)/$(GTKHTML).$(GTKHTML_SUFFIX)
GTKHTML_DIR		= $(BUILDDIR)/$(GTKHTML)
GTKHTML_IPKG_TMP	= $(GTKHTML_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gtkhtml_get: $(STATEDIR)/gtkhtml.get

gtkhtml_get_deps = $(GTKHTML_SOURCE)

$(STATEDIR)/gtkhtml.get: $(gtkhtml_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GTKHTML))
	touch $@

$(GTKHTML_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GTKHTML_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gtkhtml_extract: $(STATEDIR)/gtkhtml.extract

gtkhtml_extract_deps = $(STATEDIR)/gtkhtml.get

$(STATEDIR)/gtkhtml.extract: $(gtkhtml_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTKHTML_DIR))
	@$(call extract, $(GTKHTML_SOURCE))
	@$(call patchin, $(GTKHTML))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gtkhtml_prepare: $(STATEDIR)/gtkhtml.prepare

#
# dependencies
#
gtkhtml_prepare_deps = \
	$(STATEDIR)/gtkhtml.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/gail.install \
	$(STATEDIR)/libsoup.install \
	$(STATEDIR)/virtual-xchain.install

GTKHTML_PATH	=  PATH=$(CROSS_PATH)
GTKHTML_ENV 	=  $(CROSS_ENV)
#GTKHTML_ENV	+=
GTKHTML_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GTKHTML_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GTKHTML_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GTKHTML_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GTKHTML_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gtkhtml.prepare: $(gtkhtml_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTKHTML_DIR)/config.cache)
	cd $(GTKHTML_DIR) && \
		$(GTKHTML_PATH) $(GTKHTML_ENV) \
		./configure $(GTKHTML_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gtkhtml_compile: $(STATEDIR)/gtkhtml.compile

gtkhtml_compile_deps = $(STATEDIR)/gtkhtml.prepare

$(STATEDIR)/gtkhtml.compile: $(gtkhtml_compile_deps)
	@$(call targetinfo, $@)
	$(GTKHTML_PATH) $(MAKE) -C $(GTKHTML_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gtkhtml_install: $(STATEDIR)/gtkhtml.install

$(STATEDIR)/gtkhtml.install: $(STATEDIR)/gtkhtml.compile
	@$(call targetinfo, $@)
	rm -rf $(GTKHTML_IPKG_TMP)
	$(GTKHTML_PATH) $(MAKE) -C $(GTKHTML_DIR) DESTDIR=$(GTKHTML_IPKG_TMP) install
	@$(call copyincludes, $(GTKHTML_IPKG_TMP))
	@$(call copylibraries,$(GTKHTML_IPKG_TMP))
	@$(call copymiscfiles,$(GTKHTML_IPKG_TMP))
	rm -rf $(GTKHTML_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gtkhtml_targetinstall: $(STATEDIR)/gtkhtml.targetinstall

gtkhtml_targetinstall_deps = $(STATEDIR)/gtkhtml.compile \
	$(STATEDIR)/gail.targetinstall \
	$(STATEDIR)/libsoup.targetinstall \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/gtkhtml.targetinstall: $(gtkhtml_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GTKHTML_PATH) $(MAKE) -C $(GTKHTML_DIR) DESTDIR=$(GTKHTML_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(GTKHTML_VERSION)-$(GTKHTML_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh gtkhtml $(GTKHTML_IPKG_TMP)

	@$(call removedevfiles, $(GTKHTML_IPKG_TMP))
	@$(call stripfiles, $(GTKHTML_IPKG_TMP))
	mkdir -p $(GTKHTML_IPKG_TMP)/CONTROL
	echo "Package: gtkhtml" 							 >$(GTKHTML_IPKG_TMP)/CONTROL/control
	echo "Source: $(GTKHTML_URL)"							>>$(GTKHTML_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GTKHTML_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome" 								>>$(GTKHTML_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GTKHTML_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GTKHTML_IPKG_TMP)/CONTROL/control
	echo "Version: $(GTKHTML_VERSION)-$(GTKHTML_VENDOR_VERSION)" 			>>$(GTKHTML_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, gail, libsoup" 						>>$(GTKHTML_IPKG_TMP)/CONTROL/control
	echo "Description: gtk html engine"						>>$(GTKHTML_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GTKHTML_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GTKHTML_INSTALL
ROMPACKAGES += $(STATEDIR)/gtkhtml.imageinstall
endif

gtkhtml_imageinstall_deps = $(STATEDIR)/gtkhtml.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gtkhtml.imageinstall: $(gtkhtml_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gtkhtml
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gtkhtml_clean:
	rm -rf $(STATEDIR)/gtkhtml.*
	rm -rf $(GTKHTML_DIR)

# vim: syntax=make
