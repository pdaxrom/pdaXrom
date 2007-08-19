# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Adrian Crutchfield (InSearchOf@pdaxr.org)
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_XORG-SERVER-X11R7.2
PACKAGES += xorg-server-X11R7.2
endif

#
# Paths and names
#
XORG-SERVER-X11R7.2_VENDOR_VERSION	= 1
XORG-SERVER-X11R7.2_VERSION	= 1.2.0
XORG-SERVER-X11R7.2		= xorg-server-X11R7.2-$(XORG-SERVER-X11R7.2_VERSION)
XORG-SERVER-X11R7.2_SUFFIX		= tar.bz2
XORG-SERVER-X11R7.2_URL		= http://xorg.freedesktop.org/releases/X11R7.2/src/xserver/$(XORG-SERVER-X11R7.2).$(XORG-SERVER-X11R7.2_SUFFIX)
XORG-SERVER-X11R7.2_SOURCE		= $(SRCDIR)/$(XORG-SERVER-X11R7.2).$(XORG-SERVER-X11R7.2_SUFFIX)
XORG-SERVER-X11R7.2_DIR		= $(BUILDDIR)/$(XORG-SERVER-X11R7.2)
XORG-SERVER-X11R7.2_IPKG_TMP	= $(XORG-SERVER-X11R7.2_DIR)/ipkg_tmp


# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xorg-server-X11R7.2_get: $(STATEDIR)/xorg-server-X11R7.2.get

xorg-server-X11R7.2_get_deps = $(XORG-SERVER-X11R7.2_SOURCE)

$(STATEDIR)/xorg-server-X11R7.2.get: $(xorg-server-X11R7.2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XORG-SERVER-X11R7.2))
	touch $@

$(XORG-SERVER-X11R7.2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XORG-SERVER-X11R7.2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xorg-server-X11R7.2_extract: $(STATEDIR)/xorg-server-X11R7.2.extract

xorg-server-X11R7.2_extract_deps = $(STATEDIR)/xorg-server-X11R7.2.get

$(STATEDIR)/xorg-server-X11R7.2.extract: $(xorg-server-X11R7.2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XORG-SERVER-X11R7.2_DIR))
	@$(call extract, $(XORG-SERVER-X11R7.2_SOURCE))
	@$(call patchin, $(XORG-SERVER-X11R7.2))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xorg-server-X11R7.2_prepare: $(STATEDIR)/xorg-server-X11R7.2.prepare

#
# dependencies
#
xorg-server-X11R7.2_prepare_deps = \
	$(STATEDIR)/xorg-server-X11R7.2.extract \
	$(STATEDIR)/virtual-xchain.install

XORG-SERVER-X11R7.2_PATH	=  PATH=$(CROSS_PATH)
XORG-SERVER-X11R7.2_ENV 	=  $(CROSS_ENV)
#XORG-SERVER-X11R7.2_ENV	+=
XORG-SERVER-X11R7.2_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XORG-SERVER-X11R7.2_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XORG-SERVER-X11R7.2_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-composite --enable-kdrive \
        --disable-dga --disable-dri --disable-xinerama \
        --disable-xf86misc --disable-xf86vidmode \
        --disable-xorg --disable-xorgcfg \
        --disable-xkb --disable-xnest --disable-xvfb \
        --disable-xevie --disable-xprint --disable-xtrap \
        --enable-tslib --enable-xcalibrate \
	--disable-sgml
ifdef PTXCONF_XFREE430
XORG-SERVER-X11R7.2_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XORG-SERVER-X11R7.2_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xorg-server-X11R7.2.prepare: $(xorg-server-X11R7.2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XORG-SERVER-X11R7.2_DIR)/config.cache)
	cd $(XORG-SERVER-X11R7.2_DIR) && \
		$(XORG-SERVER-X11R7.2_PATH) $(XORG-SERVER-X11R7.2_ENV) \
		./configure $(XORG-SERVER-X11R7.2_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xorg-server-X11R7.2_compile: $(STATEDIR)/xorg-server-X11R7.2.compile

xorg-server-X11R7.2_compile_deps = $(STATEDIR)/xorg-server-X11R7.2.prepare

$(STATEDIR)/xorg-server-X11R7.2.compile: $(xorg-server-X11R7.2_compile_deps)
	@$(call targetinfo, $@)
	$(XORG-SERVER-X11R7.2_PATH) $(MAKE) -C $(XORG-SERVER-X11R7.2_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xorg-server-X11R7.2_install: $(STATEDIR)/xorg-server-X11R7.2.install

$(STATEDIR)/xorg-server-X11R7.2.install: $(STATEDIR)/xorg-server-X11R7.2.compile
	@$(call targetinfo, $@)
	rm -rf $(XORG-SERVER-X11R7.2_IPKG_TMP)
	$(XORG-SERVER-X11R7.2_PATH) $(MAKE) -C $(XORG-SERVER-X11R7.2_DIR) DESTDIR=$(XORG-SERVER-X11R7.2_IPKG_TMP) install
	@$(call copyincludes, $(XORG-SERVER-X11R7.2_IPKG_TMP))
	@$(call copylibraries,$(XORG-SERVER-X11R7.2_IPKG_TMP))
	@$(call copymiscfiles,$(XORG-SERVER-X11R7.2_IPKG_TMP))
	rm -rf $(XORG-SERVER-X11R7.2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xorg-server-X11R7.2_targetinstall: $(STATEDIR)/xorg-server-X11R7.2.targetinstall

xorg-server-X11R7.2_targetinstall_deps = $(STATEDIR)/xorg-server-X11R7.2.compile

XORG-SERVER-X11R7.2_DEPLIST = 

$(STATEDIR)/xorg-server-X11R7.2.targetinstall: $(xorg-server-X11R7.2_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XORG-SERVER-X11R7.2_PATH) $(MAKE) -C $(XORG-SERVER-X11R7.2_DIR) DESTDIR=$(XORG-SERVER-X11R7.2_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XORG-SERVER-X11R7.2_VERSION)-$(XORG-SERVER-X11R7.2_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xorg-server-x11r7.2 $(XORG-SERVER-X11R7.2_IPKG_TMP)

	@$(call removedevfiles, $(XORG-SERVER-X11R7.2_IPKG_TMP))
	@$(call stripfiles, $(XORG-SERVER-X11R7.2_IPKG_TMP))
	mkdir -p $(XORG-SERVER-X11R7.2_IPKG_TMP)/CONTROL
	echo "Package: xorg-server-x11r7.2" 							 >$(XORG-SERVER-X11R7.2_IPKG_TMP)/CONTROL/control
	echo "Source: $(XORG-SERVER-X11R7.2_URL)"							>>$(XORG-SERVER-X11R7.2_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XORG-SERVER-X11R7.2_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XORG-SERVER-X11R7.2_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield (InSearchOf@pdaxr.org)" 							>>$(XORG-SERVER-X11R7.2_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XORG-SERVER-X11R7.2_IPKG_TMP)/CONTROL/control
	echo "Version: $(XORG-SERVER-X11R7.2_VERSION)-$(XORG-SERVER-X11R7.2_VENDOR_VERSION)" 			>>$(XORG-SERVER-X11R7.2_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XORG-SERVER-X11R7.2_DEPLIST)" 						>>$(XORG-SERVER-X11R7.2_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XORG-SERVER-X11R7.2_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XORG-SERVER-X11R7.2_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XORG-SERVER-X11R7.2_INSTALL
ROMPACKAGES += $(STATEDIR)/xorg-server-X11R7.2.imageinstall
endif

xorg-server-X11R7.2_imageinstall_deps = $(STATEDIR)/xorg-server-X11R7.2.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xorg-server-X11R7.2.imageinstall: $(xorg-server-X11R7.2_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xorg-server-x11r7.2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xorg-server-X11R7.2_clean:
	rm -rf $(STATEDIR)/xorg-server-X11R7.2.*
	rm -rf $(XORG-SERVER-X11R7.2_DIR)

# vim: syntax=make
