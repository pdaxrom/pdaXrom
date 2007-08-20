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
ifdef PTXCONF_FLUXBOX
PACKAGES += fluxbox
endif

#
# Paths and names
#
FLUXBOX_VENDOR_VERSION	= 1
FLUXBOX_VERSION		= 0.9.12
FLUXBOX			= fluxbox-$(FLUXBOX_VERSION)
FLUXBOX_SUFFIX		= tar.bz2
FLUXBOX_URL		= http://kent.dl.sourceforge.net/sourceforge/fluxbox/$(FLUXBOX).$(FLUXBOX_SUFFIX)
FLUXBOX_SOURCE		= $(SRCDIR)/$(FLUXBOX).$(FLUXBOX_SUFFIX)
FLUXBOX_DIR		= $(BUILDDIR)/$(FLUXBOX)
FLUXBOX_IPKG_TMP	= $(FLUXBOX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fluxbox_get: $(STATEDIR)/fluxbox.get

fluxbox_get_deps = $(FLUXBOX_SOURCE)

$(STATEDIR)/fluxbox.get: $(fluxbox_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FLUXBOX))
	touch $@

$(FLUXBOX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FLUXBOX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fluxbox_extract: $(STATEDIR)/fluxbox.extract

fluxbox_extract_deps = $(STATEDIR)/fluxbox.get

$(STATEDIR)/fluxbox.extract: $(fluxbox_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FLUXBOX_DIR))
	@$(call extract, $(FLUXBOX_SOURCE))
	@$(call patchin, $(FLUXBOX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fluxbox_prepare: $(STATEDIR)/fluxbox.prepare

#
# dependencies
#
fluxbox_prepare_deps = \
	$(STATEDIR)/fluxbox.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
fluxbox_prepare_deps += $(STATEDIR)/libiconv.install
endif

FLUXBOX_PATH	=  PATH=$(CROSS_PATH)
FLUXBOX_ENV 	=  $(CROSS_ENV)
FLUXBOX_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
FLUXBOX_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
FLUXBOX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
ifdef PTXCONF_LIBICONV
FLUXBOX_ENV	+= LDFLAGS=-liconv
endif

#
# autoconf
#
FLUXBOX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-kde \
	--disable-gnome \
	--enable-xft \
	--enable-xrender \
	--enable-xpm \
	--enable-randr

ifdef PTXCONF_XFREE430
FLUXBOX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FLUXBOX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fluxbox.prepare: $(fluxbox_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FLUXBOX_DIR)/config.cache)
	cd $(FLUXBOX_DIR) && \
		$(FLUXBOX_PATH) $(FLUXBOX_ENV) \
		./configure $(FLUXBOX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fluxbox_compile: $(STATEDIR)/fluxbox.compile

fluxbox_compile_deps = $(STATEDIR)/fluxbox.prepare

$(STATEDIR)/fluxbox.compile: $(fluxbox_compile_deps)
	@$(call targetinfo, $@)
	$(FLUXBOX_PATH) $(MAKE) -C $(FLUXBOX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fluxbox_install: $(STATEDIR)/fluxbox.install

$(STATEDIR)/fluxbox.install: $(STATEDIR)/fluxbox.compile
	@$(call targetinfo, $@)
	$(FLUXBOX_PATH) $(MAKE) -C $(FLUXBOX_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fluxbox_targetinstall: $(STATEDIR)/fluxbox.targetinstall

fluxbox_targetinstall_deps = $(STATEDIR)/fluxbox.compile \
	$(STATEDIR)/xfree430.targetinstall

ifdef PTXCONF_LIBICONV
fluxbox_targetinstall_deps += $(STATEDIR)/libiconv.targetinstall
endif

$(STATEDIR)/fluxbox.targetinstall: $(fluxbox_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FLUXBOX_PATH) $(MAKE) -C $(FLUXBOX_DIR) DESTDIR=$(FLUXBOX_IPKG_TMP) install
	rm -rf $(FLUXBOX_IPKG_TMP)/usr/man
	for FILE in `find $(FLUXBOX_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;		\
	    if [  "$$ZZZ" != "" ]; then				\
		$(CROSSSTRIP) $$FILE;				\
	    fi;							\
	done
	mkdir -p $(FLUXBOX_IPKG_TMP)/CONTROL
	echo "Package: fluxbox" 										 >$(FLUXBOX_IPKG_TMP)/CONTROL/control
	echo "Source: $(FLUXBOX_URL)"						>>$(FLUXBOX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(FLUXBOX_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 										>>$(FLUXBOX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(FLUXBOX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(FLUXBOX_IPKG_TMP)/CONTROL/control
	echo "Version: $(FLUXBOX_VERSION)-$(FLUXBOX_VENDOR_VERSION)" 						>>$(FLUXBOX_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_LIBICONV
	echo "Depends: xfree, libiconv, libz" 								>>$(FLUXBOX_IPKG_TMP)/CONTROL/control
else
	echo "Depends: xfree, libz" 									>>$(FLUXBOX_IPKG_TMP)/CONTROL/control
endif
	echo "Description: Fluxbox is yet another windowmanager for X."						>>$(FLUXBOX_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(FLUXBOX_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FLUXBOX_INSTALL
ROMPACKAGES += $(STATEDIR)/fluxbox.imageinstall
endif

fluxbox_imageinstall_deps = $(STATEDIR)/fluxbox.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fluxbox.imageinstall: $(fluxbox_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fluxbox
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fluxbox_clean:
	rm -rf $(STATEDIR)/fluxbox.*
	rm -rf $(FLUXBOX_DIR)

# vim: syntax=make
