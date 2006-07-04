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
ifdef PTXCONF_STARDICT
PACKAGES += stardict
endif

#
# Paths and names
#
STARDICT_VENDOR_VERSION	= 1
STARDICT_VERSION	= 2.4.7
STARDICT		= stardict-$(STARDICT_VERSION)
STARDICT_SUFFIX		= tar.bz2
STARDICT_URL		= http://heanet.dl.sourceforge.net/sourceforge/stardict/$(STARDICT).$(STARDICT_SUFFIX)
STARDICT_SOURCE		= $(SRCDIR)/$(STARDICT).$(STARDICT_SUFFIX)
STARDICT_DIR		= $(BUILDDIR)/$(STARDICT)
STARDICT_IPKG_TMP	= $(STARDICT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

stardict_get: $(STATEDIR)/stardict.get

stardict_get_deps = $(STARDICT_SOURCE)

$(STATEDIR)/stardict.get: $(stardict_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(STARDICT))
	touch $@

$(STARDICT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(STARDICT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

stardict_extract: $(STATEDIR)/stardict.extract

stardict_extract_deps = $(STATEDIR)/stardict.get

$(STATEDIR)/stardict.extract: $(stardict_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(STARDICT_DIR))
	@$(call extract, $(STARDICT_SOURCE))
	@$(call patchin, $(STARDICT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

stardict_prepare: $(STATEDIR)/stardict.prepare

#
# dependencies
#
stardict_prepare_deps = \
	$(STATEDIR)/stardict.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

STARDICT_PATH	=  PATH=$(CROSS_PATH)
STARDICT_ENV 	=  $(CROSS_ENV)
#STARDICT_ENV	+=
STARDICT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#STARDICT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
STARDICT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-gnome-support \
	--disable-schemas-install

ifdef PTXCONF_XFREE430
STARDICT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
STARDICT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/stardict.prepare: $(stardict_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(STARDICT_DIR)/config.cache)
	cd $(STARDICT_DIR) && \
		$(STARDICT_PATH) $(STARDICT_ENV) \
		PKG_CONFIG=`which pkg-config` \
		./configure $(STARDICT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

stardict_compile: $(STATEDIR)/stardict.compile

stardict_compile_deps = $(STATEDIR)/stardict.prepare

$(STATEDIR)/stardict.compile: $(stardict_compile_deps)
	@$(call targetinfo, $@)
	$(STARDICT_PATH) $(MAKE) -C $(STARDICT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

stardict_install: $(STATEDIR)/stardict.install

$(STATEDIR)/stardict.install: $(STATEDIR)/stardict.compile
	@$(call targetinfo, $@)
	###$(STARDICT_PATH) $(MAKE) -C $(STARDICT_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

stardict_targetinstall: $(STATEDIR)/stardict.targetinstall

stardict_targetinstall_deps = $(STATEDIR)/stardict.compile \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/stardict.targetinstall: $(stardict_targetinstall_deps)
	@$(call targetinfo, $@)
	$(STARDICT_PATH) $(MAKE) -C $(STARDICT_DIR) DESTDIR=$(STARDICT_IPKG_TMP) install
	rm -rf $(STARDICT_IPKG_TMP)/usr/man
	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(STARDICT_VERSION) 		\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh stardict $(STARDICT_IPKG_TMP)
	rm -rf $(STARDICT_IPKG_TMP)/usr/share/locale
	$(CROSSSTRIP) $(STARDICT_IPKG_TMP)/usr/bin/*
	mkdir -p $(STARDICT_IPKG_TMP)/CONTROL
	echo "Package: stardict" 							 >$(STARDICT_IPKG_TMP)/CONTROL/control
	echo "Source: $(STARDICT_URL)"							>>$(STARDICT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(STARDICT_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 								>>$(STARDICT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(STARDICT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(STARDICT_IPKG_TMP)/CONTROL/control
	echo "Version: $(STARDICT_VERSION)-$(STARDICT_VENDOR_VERSION)" 			>>$(STARDICT_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 								>>$(STARDICT_IPKG_TMP)/CONTROL/control
	echo "Description: StarDict is a Cross-Platform and international dictionary written in Gtk2." >>$(STARDICT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(STARDICT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_STARDICT_INSTALL
ROMPACKAGES += $(STATEDIR)/stardict.imageinstall
endif

stardict_imageinstall_deps = $(STATEDIR)/stardict.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/stardict.imageinstall: $(stardict_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install stardict
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

stardict_clean:
	rm -rf $(STATEDIR)/stardict.*
	rm -rf $(STARDICT_DIR)

# vim: syntax=make
