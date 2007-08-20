# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Adrian Crutchfield
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_XFCE4-MIXER
PACKAGES += xfce4-mixer
endif

#
# Paths and names
#
XFCE4-MIXER_VENDOR_VERSION	= 1
XFCE4-MIXER_VERSION	= 4.4.0
XFCE4-MIXER		= xfce4-mixer-$(XFCE4-MIXER_VERSION)
XFCE4-MIXER_SUFFIX		= tar.bz2
XFCE4-MIXER_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFCE4-MIXER).$(XFCE4-MIXER_SUFFIX)
XFCE4-MIXER_SOURCE		= $(SRCDIR)/$(XFCE4-MIXER).$(XFCE4-MIXER_SUFFIX)
XFCE4-MIXER_DIR		= $(BUILDDIR)/$(XFCE4-MIXER)
XFCE4-MIXER_IPKG_TMP	= $(XFCE4-MIXER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfce4-mixer_get: $(STATEDIR)/xfce4-mixer.get

xfce4-mixer_get_deps = $(XFCE4-MIXER_SOURCE)

$(STATEDIR)/xfce4-mixer.get: $(xfce4-mixer_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFCE4-MIXER))
	touch $@

$(XFCE4-MIXER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFCE4-MIXER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfce4-mixer_extract: $(STATEDIR)/xfce4-mixer.extract

xfce4-mixer_extract_deps = $(STATEDIR)/xfce4-mixer.get

$(STATEDIR)/xfce4-mixer.extract: $(xfce4-mixer_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-MIXER_DIR))
	@$(call extract, $(XFCE4-MIXER_SOURCE))
	@$(call patchin, $(XFCE4-MIXER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfce4-mixer_prepare: $(STATEDIR)/xfce4-mixer.prepare

#
# dependencies
#
xfce4-mixer_prepare_deps = \
	$(STATEDIR)/xfce4-mixer.extract \
	$(STATEDIR)/virtual-xchain.install

XFCE4-MIXER_PATH	=  PATH=$(CROSS_PATH)
XFCE4-MIXER_ENV 	=  $(CROSS_ENV)
#XFCE4-MIXER_ENV	+=
XFCE4-MIXER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFCE4-MIXER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFCE4-MIXER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFCE4-MIXER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFCE4-MIXER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfce4-mixer.prepare: $(xfce4-mixer_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-MIXER_DIR)/config.cache)
	cd $(XFCE4-MIXER_DIR) && \
		$(XFCE4-MIXER_PATH) $(XFCE4-MIXER_ENV) \
		./configure $(XFCE4-MIXER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfce4-mixer_compile: $(STATEDIR)/xfce4-mixer.compile

xfce4-mixer_compile_deps = $(STATEDIR)/xfce4-mixer.prepare

$(STATEDIR)/xfce4-mixer.compile: $(xfce4-mixer_compile_deps)
	@$(call targetinfo, $@)
	$(XFCE4-MIXER_PATH) $(MAKE) -C $(XFCE4-MIXER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfce4-mixer_install: $(STATEDIR)/xfce4-mixer.install

$(STATEDIR)/xfce4-mixer.install: $(STATEDIR)/xfce4-mixer.compile
	@$(call targetinfo, $@)
	rm -rf $(XFCE4-MIXER_IPKG_TMP)
	$(XFCE4-MIXER_PATH) $(MAKE) -C $(XFCE4-MIXER_DIR) DESTDIR=$(XFCE4-MIXER_IPKG_TMP) install
	@$(call copyincludes, $(XFCE4-MIXER_IPKG_TMP))
	@$(call copylibraries,$(XFCE4-MIXER_IPKG_TMP))
	@$(call copymiscfiles,$(XFCE4-MIXER_IPKG_TMP))
	rm -rf $(XFCE4-MIXER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfce4-mixer_targetinstall: $(STATEDIR)/xfce4-mixer.targetinstall

xfce4-mixer_targetinstall_deps = $(STATEDIR)/xfce4-mixer.compile

XFCE4-MIXER_DEPLIST = 

$(STATEDIR)/xfce4-mixer.targetinstall: $(xfce4-mixer_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFCE4-MIXER_PATH) $(MAKE) -C $(XFCE4-MIXER_DIR) DESTDIR=$(XFCE4-MIXER_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFCE4-MIXER_VERSION)-$(XFCE4-MIXER_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfce4-mixer $(XFCE4-MIXER_IPKG_TMP)

	@$(call removedevfiles, $(XFCE4-MIXER_IPKG_TMP))
	@$(call stripfiles, $(XFCE4-MIXER_IPKG_TMP))
	mkdir -p $(XFCE4-MIXER_IPKG_TMP)/CONTROL
	echo "Package: xfce4-mixer" 							 >$(XFCE4-MIXER_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFCE4-MIXER_URL)"							>>$(XFCE4-MIXER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFCE4-MIXER_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFCE4-MIXER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFCE4-MIXER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFCE4-MIXER_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFCE4-MIXER_VERSION)-$(XFCE4-MIXER_VENDOR_VERSION)" 			>>$(XFCE4-MIXER_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFCE4-MIXER_DEPLIST)" 						>>$(XFCE4-MIXER_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFCE4-MIXER_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFCE4-MIXER_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFCE4-MIXER_INSTALL
ROMPACKAGES += $(STATEDIR)/xfce4-mixer.imageinstall
endif

xfce4-mixer_imageinstall_deps = $(STATEDIR)/xfce4-mixer.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfce4-mixer.imageinstall: $(xfce4-mixer_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfce4-mixer
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfce4-mixer_clean:
	rm -rf $(STATEDIR)/xfce4-mixer.*
	rm -rf $(XFCE4-MIXER_DIR)

# vim: syntax=make
