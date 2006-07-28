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
ifdef PTXCONF_FVWM
PACKAGES += fvwm
endif

#
# Paths and names
#
FVWM_VENDOR_VERSION	= 1
FVWM_VERSION		= 2.5.12
FVWM			= fvwm-$(FVWM_VERSION)
FVWM_SUFFIX		= tar.bz2
FVWM_URL		= ftp://ftp.fvwm.org/pub/fvwm/version-2/$(FVWM).$(FVWM_SUFFIX)
FVWM_SOURCE		= $(SRCDIR)/$(FVWM).$(FVWM_SUFFIX)
FVWM_DIR		= $(BUILDDIR)/$(FVWM)
FVWM_IPKG_TMP		= $(FVWM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fvwm_get: $(STATEDIR)/fvwm.get

fvwm_get_deps = $(FVWM_SOURCE)

$(STATEDIR)/fvwm.get: $(fvwm_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FVWM))
	touch $@

$(FVWM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FVWM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fvwm_extract: $(STATEDIR)/fvwm.extract

fvwm_extract_deps = $(STATEDIR)/fvwm.get

$(STATEDIR)/fvwm.extract: $(fvwm_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FVWM_DIR))
	@$(call extract, $(FVWM_SOURCE))
	@$(call patchin, $(FVWM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fvwm_prepare: $(STATEDIR)/fvwm.prepare

#
# dependencies
#
fvwm_prepare_deps = \
	$(STATEDIR)/fvwm.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/imlib.install \
	$(STATEDIR)/virtual-xchain.install

FVWM_PATH	=  PATH=$(CROSS_PATH)
FVWM_ENV 	=  $(CROSS_ENV)
FVWM_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
FVWM_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
##FVWM_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
##FVWM_ENV	+= CXXFLAGS="-O2 -fomit-frame-pointer"
FVWM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FVWM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
FVWM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--without-gnome \
	--disable-bidi \
	--disable-perllib \
	--disable-imlibtest \
	--libexecdir=/usr/lib

ifdef PTXCONF_XFREE430
FVWM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FVWM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fvwm.prepare: $(fvwm_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FVWM_DIR)/config.cache)
	cd $(FVWM_DIR) && $(FVWM_PATH) aclocal
	cd $(FVWM_DIR) && $(FVWM_PATH) automake --add-missing
	cd $(FVWM_DIR) && $(FVWM_PATH) autoconf
	@$(call clean, $(FVWM_DIR)/config.cache)
	cd $(FVWM_DIR) && \
		$(FVWM_PATH) $(FVWM_ENV) \
		./configure $(FVWM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fvwm_compile: $(STATEDIR)/fvwm.compile

fvwm_compile_deps = $(STATEDIR)/fvwm.prepare

$(STATEDIR)/fvwm.compile: $(fvwm_compile_deps)
	@$(call targetinfo, $@)
	$(FVWM_PATH) $(MAKE) -C $(FVWM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fvwm_install: $(STATEDIR)/fvwm.install

$(STATEDIR)/fvwm.install: $(STATEDIR)/fvwm.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fvwm_targetinstall: $(STATEDIR)/fvwm.targetinstall

fvwm_targetinstall_deps = $(STATEDIR)/fvwm.compile \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/imlib.targetinstall

$(STATEDIR)/fvwm.targetinstall: $(fvwm_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FVWM_PATH) $(MAKE) -C $(FVWM_DIR) DESTDIR=$(FVWM_IPKG_TMP) install
	rm -rf $(FVWM_IPKG_TMP)/usr/man
	rm -rf $(FVWM_IPKG_TMP)/usr/share/locale
	for FILE in `find $(FVWM_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;		\
	    if [  "$$ZZZ" != "" ]; then				\
		$(CROSSSTRIP) $$FILE;				\
	    fi;							\
	done
	mkdir -p $(FVWM_IPKG_TMP)/CONTROL
	echo "Package: fvwm" 											 >$(FVWM_IPKG_TMP)/CONTROL/control
	echo "Source: $(FVWM_URL)"						>>$(FVWM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(FVWM_IPKG_TMP)/CONTROL/control
	echo "Section: X11"				 							>>$(FVWM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(FVWM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(FVWM_IPKG_TMP)/CONTROL/control
	echo "Version: $(FVWM_VERSION)-$(FVWM_VENDOR_VERSION)" 							>>$(FVWM_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree, imlib" 										>>$(FVWM_IPKG_TMP)/CONTROL/control
	echo "Description: FVWM is an extremely powerful ICCCM-compliant multiple virtual desktop window manager for the X  Window system." >>$(FVWM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FVWM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FVWM_INSTALL
ROMPACKAGES += $(STATEDIR)/fvwm.imageinstall
endif

fvwm_imageinstall_deps = $(STATEDIR)/fvwm.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fvwm.imageinstall: $(fvwm_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fvwm
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fvwm_clean:
	rm -rf $(STATEDIR)/fvwm.*
	rm -rf $(FVWM_DIR)

# vim: syntax=make
