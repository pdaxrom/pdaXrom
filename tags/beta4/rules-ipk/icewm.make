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
ifdef PTXCONF_ICEWM
PACKAGES += icewm
endif

#
# Paths and names
#
ICEWM_VENDOR_VERSION	= 1
ICEWM_VERSION		= 1.2.20
ICEWM			= icewm-$(ICEWM_VERSION)
ICEWM_SUFFIX		= tar.gz
ICEWM_URL		= http://heanet.dl.sourceforge.net/sourceforge/icewm/$(ICEWM).$(ICEWM_SUFFIX)
ICEWM_SOURCE		= $(SRCDIR)/$(ICEWM).$(ICEWM_SUFFIX)
ICEWM_DIR		= $(BUILDDIR)/$(ICEWM)
ICEWM_IPKG_TMP		= $(ICEWM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

icewm_get: $(STATEDIR)/icewm.get

icewm_get_deps = $(ICEWM_SOURCE)

$(STATEDIR)/icewm.get: $(icewm_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ICEWM))
	touch $@

$(ICEWM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ICEWM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

icewm_extract: $(STATEDIR)/icewm.extract

icewm_extract_deps = $(STATEDIR)/icewm.get

$(STATEDIR)/icewm.extract: $(icewm_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ICEWM_DIR))
	@$(call extract, $(ICEWM_SOURCE))
	@$(call patchin, $(ICEWM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

icewm_prepare: $(STATEDIR)/icewm.prepare

#
# dependencies
#
icewm_prepare_deps = \
	$(STATEDIR)/icewm.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/audiofile.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
icewm_prepare_deps += $(STATEDIR)/libiconv.install
endif

ifdef PTXCONF_ICEWM_IMLIB
icewm_prepare_deps += $(STATEDIR)/imlib.install
endif

ICEWM_PATH	=  PATH=$(CROSS_PATH)
ICEWM_ENV 	=  $(CROSS_ENV)
ICEWM_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
ICEWM_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
ICEWM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ICEWM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

ICEWM_DEPENDS	= "xfree, esound, audiofile"

ifdef PTXCONF_LIBICONV
ICEWM_DEPENDS_LIBICONV	=", libiconv"
endif

ifdef PTXCONF_ICEWM_IMLIB
ICEWM_DEPENDS_IMLIB	=", imlib"
endif

#
# autoconf
#
ICEWM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--enable-gradients \
	--enable-antialiasing \
	--enable-xrandr \
	--enable-guievents \
	--disable-xinerama \
	--with-icesound=ESound \
	--enable-sm

ifdef PTXCONF_ICEWM_IMLIB
ICEWM_AUTOCONF += --with-imlib
else
ICEWM_AUTOCONF += --without-imlib
endif

#ifndef PTXCONF_LIBICONV
#ICEWM_AUTOCONF += --disable-i18n
#ICEWM_AUTOCONF += --disable-nls
#endif

#	--disable-taskbar \
#	--enable-lite

#	--disable-prefs \
#	--disable-menuconf \
#	--disable-winoptions	

ifdef PTXCONF_XFREE430
ICEWM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ICEWM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/icewm.prepare: $(icewm_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ICEWM_DIR)/config.cache)
	cd $(ICEWM_DIR) && $(ICEWM_PATH) ./autogen.sh
	@$(call clean, $(ICEWM_DIR)/config.cache)
	cd $(ICEWM_DIR) && \
		$(ICEWM_PATH) $(ICEWM_ENV) \
		./configure $(ICEWM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

icewm_compile: $(STATEDIR)/icewm.compile

icewm_compile_deps = $(STATEDIR)/icewm.prepare

$(STATEDIR)/icewm.compile: $(icewm_compile_deps)
	@$(call targetinfo, $@)
	$(ICEWM_PATH) $(MAKE) -C $(ICEWM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

icewm_install: $(STATEDIR)/icewm.install

$(STATEDIR)/icewm.install: $(STATEDIR)/icewm.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

icewm_targetinstall: $(STATEDIR)/icewm.targetinstall

icewm_targetinstall_deps = $(STATEDIR)/icewm.compile \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/esound.targetinstall \
	$(STATEDIR)/audiofile.targetinstall

ifdef PTXCONF_LIBICONV
icewm_prepare_deps += $(STATEDIR)/libiconv.targetinstall
endif

ifdef PTXCONF_ICEWM_IMLIB
icewm_targetinstall_deps += $(STATEDIR)/imlib.targetinstall
endif

$(STATEDIR)/icewm.targetinstall: $(icewm_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ICEWM_PATH) $(MAKE) -C $(ICEWM_DIR) DESTDIR=$(ICEWM_IPKG_TMP) install
	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(ICEWM_VERSION)-$(ICEWM_VENDOR_VERSION) 		\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh icewm $(ICEWM_IPKG_TMP)
	$(INSTALL) -m 755 $(ICEWM_DIR)/src/genpref $(ICEWM_IPKG_TMP)/usr/share/icewm/
	$(CROSSSTRIP) $(ICEWM_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(ICEWM_IPKG_TMP)/usr/share/icewm/genpref
	touch $(ICEWM_IPKG_TMP)/usr/share/icewm/preferences
	mkdir -p $(ICEWM_IPKG_TMP)/CONTROL
	echo "Package: icewm" 											 >$(ICEWM_IPKG_TMP)/CONTROL/control
	echo "Source: $(ICEWM_URL)"						>>$(ICEWM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(ICEWM_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 											>>$(ICEWM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(ICEWM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(ICEWM_IPKG_TMP)/CONTROL/control
	echo "Version: $(ICEWM_VERSION)-$(ICEWM_VENDOR_VERSION)"			 			>>$(ICEWM_IPKG_TMP)/CONTROL/control
#ifdef PTXCONF_LIBICONV
#	echo "Depends: xfree, libiconv, esound, audiofile" 							>>$(ICEWM_IPKG_TMP)/CONTROL/control
#else
#	echo "Depends: xfree, esound, audiofile" 								>>$(ICEWM_IPKG_TMP)/CONTROL/control
#endif
	echo "Depends: $(ICEWM_DEPENDS)$(ICEWM_DEPENDS_LIBICONV)$(ICEWM_DEPENDS_IMLIB)"				>>$(ICEWM_IPKG_TMP)/CONTROL/control
	echo "Description:  IceWM is a window manager for the X11 Window System. The goal of IceWM is speed, simplicity, and not getting in the user's way." >>$(ICEWM_IPKG_TMP)/CONTROL/control

	echo "#!/bin/bash"											 >$(ICEWM_IPKG_TMP)/CONTROL/postinst
	echo "/usr/share/icewm/genpref > /usr/share/icewm/preferences"						>>$(ICEWM_IPKG_TMP)/CONTROL/postinst
	echo "rm -f /usr/share/icewm/genpref"									>>$(ICEWM_IPKG_TMP)/CONTROL/postinst
	echo "touch /usr/share/icewm/genpref"									>>$(ICEWM_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(ICEWM_IPKG_TMP)/CONTROL/postinst

	cd $(FEEDDIR) && $(XMKIPKG) $(ICEWM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ICEWM_INSTALL
ROMPACKAGES += $(STATEDIR)/icewm.imageinstall
endif

icewm_imageinstall_deps = $(STATEDIR)/icewm.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/icewm.imageinstall: $(icewm_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install icewm
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

icewm_clean:
	rm -rf $(STATEDIR)/icewm.*
	rm -rf $(ICEWM_DIR)

# vim: syntax=make
