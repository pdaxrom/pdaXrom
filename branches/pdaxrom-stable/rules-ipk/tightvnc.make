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
ifdef PTXCONF_TIGHTVNC
PACKAGES += tightvnc
endif

#
# Paths and names
#
TIGHTVNC_VENDOR_VERSION	= 1
TIGHTVNC_VERSION	= 1.2.9
TIGHTVNC		= tightvnc-$(TIGHTVNC_VERSION)
TIGHTVNC_SUFFIX		= tar.bz2
TIGHTVNC_URL		= http://citkit.dl.sourceforge.net/sourceforge/vnc-tight/$(TIGHTVNC)_unixsrc.$(TIGHTVNC_SUFFIX)
TIGHTVNC_SOURCE		= $(SRCDIR)/$(TIGHTVNC)_unixsrc.$(TIGHTVNC_SUFFIX)
TIGHTVNC_DIR		= $(BUILDDIR)/vnc_unixsrc
TIGHTVNC_IPKG_TMP	= $(TIGHTVNC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tightvnc_get: $(STATEDIR)/tightvnc.get

tightvnc_get_deps = $(TIGHTVNC_SOURCE)

$(STATEDIR)/tightvnc.get: $(tightvnc_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TIGHTVNC))
	touch $@

$(TIGHTVNC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TIGHTVNC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tightvnc_extract: $(STATEDIR)/tightvnc.extract

tightvnc_extract_deps = $(STATEDIR)/tightvnc.get

$(STATEDIR)/tightvnc.extract: $(tightvnc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TIGHTVNC_DIR))
	@$(call extract, $(TIGHTVNC_SOURCE))
	@$(call patchin, $(TIGHTVNC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tightvnc_prepare: $(STATEDIR)/tightvnc.prepare

#
# dependencies
#
tightvnc_prepare_deps = \
	$(STATEDIR)/tightvnc.extract \
	$(STATEDIR)/virtual-xchain.install

TIGHTVNC_PATH	=  PATH=$(CROSS_PATH)
TIGHTVNC_ENV 	=  $(CROSS_ENV)
#TIGHTVNC_ENV	+=
TIGHTVNC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TIGHTVNC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
TIGHTVNC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
TIGHTVNC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TIGHTVNC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/tightvnc.prepare: $(tightvnc_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TIGHTVNC_DIR)/config.cache)
	cd $(TIGHTVNC_DIR) && imake -I$(XFREE430_DIR)/config/cf
	cd $(TIGHTVNC_DIR)/libvncauth && $(TIGHTVNC_PATH) $(TIGHTVNC_ENV) imake -I$(XFREE430_DIR)/config/cf
	cd $(TIGHTVNC_DIR)/vncconnect && $(TIGHTVNC_PATH) $(TIGHTVNC_ENV) imake -I$(XFREE430_DIR)/config/cf
	cd $(TIGHTVNC_DIR)/vncpasswd  && $(TIGHTVNC_PATH) $(TIGHTVNC_ENV) imake -I$(XFREE430_DIR)/config/cf
	cd $(TIGHTVNC_DIR)/vncviewer  && $(TIGHTVNC_PATH) $(TIGHTVNC_ENV) imake -I$(XFREE430_DIR)/config/cf
	#	$(TIGHTVNC_PATH) $(TIGHTVNC_ENV) 
	#	./configure $(TIGHTVNC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tightvnc_compile: $(STATEDIR)/tightvnc.compile

tightvnc_compile_deps = $(STATEDIR)/tightvnc.prepare

$(STATEDIR)/tightvnc.compile: $(tightvnc_compile_deps)
	@$(call targetinfo, $@)
	$(TIGHTVNC_PATH) $(MAKE) -C $(TIGHTVNC_DIR) $(CROSS_ENV_CC) $(CROSS_ENV_RANLIB) $(CROSS_ENV_STRIP) RMAN=true
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tightvnc_install: $(STATEDIR)/tightvnc.install

$(STATEDIR)/tightvnc.install: $(STATEDIR)/tightvnc.compile
	@$(call targetinfo, $@)
	$(TIGHTVNC_PATH) $(MAKE) -C $(TIGHTVNC_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tightvnc_targetinstall: $(STATEDIR)/tightvnc.targetinstall

tightvnc_targetinstall_deps = $(STATEDIR)/tightvnc.compile

$(STATEDIR)/tightvnc.targetinstall: $(tightvnc_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TIGHTVNC_PATH) $(MAKE) -C $(TIGHTVNC_DIR) DESTDIR=$(TIGHTVNC_IPKG_TMP) install
	$(CROSSSTRIP) $(TIGHTVNC_IPKG_TMP)/usr/X11R6/bin/vncviewer
	mkdir -p $(TIGHTVNC_IPKG_TMP)/etc/X11/app-defaults
	cp -a $(TIGHTVNC_DIR)/vncviewer/Vncviewer $(TIGHTVNC_IPKG_TMP)/etc/X11/app-defaults/
	mkdir -p $(TIGHTVNC_IPKG_TMP)/CONTROL
	echo "Package: tightvnc" 							 >$(TIGHTVNC_IPKG_TMP)/CONTROL/control
	echo "Source: $(TIGHTVNC_URL)"							>>$(TIGHTVNC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(TIGHTVNC_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 							>>$(TIGHTVNC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(TIGHTVNC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(TIGHTVNC_IPKG_TMP)/CONTROL/control
	echo "Version: $(TIGHTVNC_VERSION)-$(TIGHTVNC_VENDOR_VERSION)" 			>>$(TIGHTVNC_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree" 								>>$(TIGHTVNC_IPKG_TMP)/CONTROL/control
	echo "Description: TightVNC client. TightVNC is a free remote control software package derived from the popular VNC software." >>$(TIGHTVNC_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(TIGHTVNC_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TIGHTVNC_INSTALL
ROMPACKAGES += $(STATEDIR)/tightvnc.imageinstall
endif

tightvnc_imageinstall_deps = $(STATEDIR)/tightvnc.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tightvnc.imageinstall: $(tightvnc_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tightvnc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tightvnc_clean:
	rm -rf $(STATEDIR)/tightvnc.*
	rm -rf $(TIGHTVNC_DIR)

# vim: syntax=make
