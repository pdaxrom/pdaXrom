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
ifdef PTXCONF_XFCE4-DEV-TOOLS
PACKAGES += xfce4-dev-tools
endif

#
# Paths and names
#
XFCE4-DEV-TOOLS_VENDOR_VERSION	= 1
XFCE4-DEV-TOOLS_VERSION	= 4.4.0
XFCE4-DEV-TOOLS		= xfce4-dev-tools-$(XFCE4-DEV-TOOLS_VERSION)
XFCE4-DEV-TOOLS_SUFFIX		= tar.bz2
XFCE4-DEV-TOOLS_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFCE4-DEV-TOOLS).$(XFCE4-DEV-TOOLS_SUFFIX)
XFCE4-DEV-TOOLS_SOURCE		= $(SRCDIR)/$(XFCE4-DEV-TOOLS).$(XFCE4-DEV-TOOLS_SUFFIX)
XFCE4-DEV-TOOLS_DIR		= $(BUILDDIR)/$(XFCE4-DEV-TOOLS)
XFCE4-DEV-TOOLS_IPKG_TMP	= $(XFCE4-DEV-TOOLS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfce4-dev-tools_get: $(STATEDIR)/xfce4-dev-tools.get

xfce4-dev-tools_get_deps = $(XFCE4-DEV-TOOLS_SOURCE)

$(STATEDIR)/xfce4-dev-tools.get: $(xfce4-dev-tools_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFCE4-DEV-TOOLS))
	touch $@

$(XFCE4-DEV-TOOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFCE4-DEV-TOOLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfce4-dev-tools_extract: $(STATEDIR)/xfce4-dev-tools.extract

xfce4-dev-tools_extract_deps = $(STATEDIR)/xfce4-dev-tools.get

$(STATEDIR)/xfce4-dev-tools.extract: $(xfce4-dev-tools_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-DEV-TOOLS_DIR))
	@$(call extract, $(XFCE4-DEV-TOOLS_SOURCE))
	@$(call patchin, $(XFCE4-DEV-TOOLS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfce4-dev-tools_prepare: $(STATEDIR)/xfce4-dev-tools.prepare

#
# dependencies
#
xfce4-dev-tools_prepare_deps = \
	$(STATEDIR)/xfce4-dev-tools.extract \
	$(STATEDIR)/virtual-xchain.install

XFCE4-DEV-TOOLS_PATH	=  PATH=$(CROSS_PATH)
XFCE4-DEV-TOOLS_ENV 	=  $(CROSS_ENV)
#XFCE4-DEV-TOOLS_ENV	+=
XFCE4-DEV-TOOLS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFCE4-DEV-TOOLS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFCE4-DEV-TOOLS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFCE4-DEV-TOOLS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFCE4-DEV-TOOLS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfce4-dev-tools.prepare: $(xfce4-dev-tools_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-DEV-TOOLS_DIR)/config.cache)
	cd $(XFCE4-DEV-TOOLS_DIR) && \
		$(XFCE4-DEV-TOOLS_PATH) $(XFCE4-DEV-TOOLS_ENV) \
		./configure $(XFCE4-DEV-TOOLS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfce4-dev-tools_compile: $(STATEDIR)/xfce4-dev-tools.compile

xfce4-dev-tools_compile_deps = $(STATEDIR)/xfce4-dev-tools.prepare

$(STATEDIR)/xfce4-dev-tools.compile: $(xfce4-dev-tools_compile_deps)
	@$(call targetinfo, $@)
	$(XFCE4-DEV-TOOLS_PATH) $(MAKE) -C $(XFCE4-DEV-TOOLS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfce4-dev-tools_install: $(STATEDIR)/xfce4-dev-tools.install

$(STATEDIR)/xfce4-dev-tools.install: $(STATEDIR)/xfce4-dev-tools.compile
	@$(call targetinfo, $@)
	rm -rf $(XFCE4-DEV-TOOLS_IPKG_TMP)
	$(XFCE4-DEV-TOOLS_PATH) $(MAKE) -C $(XFCE4-DEV-TOOLS_DIR) DESTDIR=$(XFCE4-DEV-TOOLS_IPKG_TMP) install
	@$(call copyincludes, $(XFCE4-DEV-TOOLS_IPKG_TMP))
	@$(call copylibraries,$(XFCE4-DEV-TOOLS_IPKG_TMP))
	@$(call copymiscfiles,$(XFCE4-DEV-TOOLS_IPKG_TMP))
	rm -rf $(XFCE4-DEV-TOOLS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfce4-dev-tools_targetinstall: $(STATEDIR)/xfce4-dev-tools.targetinstall

xfce4-dev-tools_targetinstall_deps = $(STATEDIR)/xfce4-dev-tools.compile

XFCE4-DEV-TOOLS_DEPLIST = 

$(STATEDIR)/xfce4-dev-tools.targetinstall: $(xfce4-dev-tools_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFCE4-DEV-TOOLS_PATH) $(MAKE) -C $(XFCE4-DEV-TOOLS_DIR) DESTDIR=$(XFCE4-DEV-TOOLS_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFCE4-DEV-TOOLS_VERSION)-$(XFCE4-DEV-TOOLS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfce4-dev-tools $(XFCE4-DEV-TOOLS_IPKG_TMP)

	@$(call removedevfiles, $(XFCE4-DEV-TOOLS_IPKG_TMP))
	@$(call stripfiles, $(XFCE4-DEV-TOOLS_IPKG_TMP))
	mkdir -p $(XFCE4-DEV-TOOLS_IPKG_TMP)/CONTROL
	echo "Package: xfce4-dev-tools" 							 >$(XFCE4-DEV-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFCE4-DEV-TOOLS_URL)"							>>$(XFCE4-DEV-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFCE4-DEV-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFCE4-DEV-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFCE4-DEV-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFCE4-DEV-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFCE4-DEV-TOOLS_VERSION)-$(XFCE4-DEV-TOOLS_VENDOR_VERSION)" 			>>$(XFCE4-DEV-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFCE4-DEV-TOOLS_DEPLIST)" 						>>$(XFCE4-DEV-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFCE4-DEV-TOOLS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFCE4-DEV-TOOLS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFCE4-DEV-TOOLS_INSTALL
ROMPACKAGES += $(STATEDIR)/xfce4-dev-tools.imageinstall
endif

xfce4-dev-tools_imageinstall_deps = $(STATEDIR)/xfce4-dev-tools.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfce4-dev-tools.imageinstall: $(xfce4-dev-tools_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfce4-dev-tools
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfce4-dev-tools_clean:
	rm -rf $(STATEDIR)/xfce4-dev-tools.*
	rm -rf $(XFCE4-DEV-TOOLS_DIR)

# vim: syntax=make
