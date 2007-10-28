# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Adrian Crutchfield (InSearchOf@pdaxrom.org)
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_RENDERPROTO-X11R7.0
PACKAGES += renderproto-X11R7.0
endif

#
# Paths and names
#
RENDERPROTO-X11R7.0_VENDOR_VERSION	= 1
RENDERPROTO-X11R7.0_VERSION	= 0.9.2
RENDERPROTO-X11R7.0		= renderproto-X11R7.0-$(RENDERPROTO-X11R7.0_VERSION)
RENDERPROTO-X11R7.0_SUFFIX		= tar.bz2
RENDERPROTO-X11R7.0_URL		= http://xorg.freedesktop.org/releases/X11R7.2/src/everything/$(RENDERPROTO-X11R7.0).$(RENDERPROTO-X11R7.0_SUFFIX)
RENDERPROTO-X11R7.0_SOURCE		= $(SRCDIR)/$(RENDERPROTO-X11R7.0).$(RENDERPROTO-X11R7.0_SUFFIX)
RENDERPROTO-X11R7.0_DIR		= $(BUILDDIR)/$(RENDERPROTO-X11R7.0)
RENDERPROTO-X11R7.0_IPKG_TMP	= $(RENDERPROTO-X11R7.0_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

renderproto-X11R7.0_get: $(STATEDIR)/renderproto-X11R7.0.get

renderproto-X11R7.0_get_deps = $(RENDERPROTO-X11R7.0_SOURCE)

$(STATEDIR)/renderproto-X11R7.0.get: $(renderproto-X11R7.0_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(RENDERPROTO-X11R7.0))
	touch $@

$(RENDERPROTO-X11R7.0_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(RENDERPROTO-X11R7.0_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

renderproto-X11R7.0_extract: $(STATEDIR)/renderproto-X11R7.0.extract

renderproto-X11R7.0_extract_deps = $(STATEDIR)/renderproto-X11R7.0.get

$(STATEDIR)/renderproto-X11R7.0.extract: $(renderproto-X11R7.0_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RENDERPROTO-X11R7.0_DIR))
	@$(call extract, $(RENDERPROTO-X11R7.0_SOURCE))
	@$(call patchin, $(RENDERPROTO-X11R7.0))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

renderproto-X11R7.0_prepare: $(STATEDIR)/renderproto-X11R7.0.prepare

#
# dependencies
#
renderproto-X11R7.0_prepare_deps = \
	$(STATEDIR)/renderproto-X11R7.0.extract \
	$(STATEDIR)/virtual-xchain.install

RENDERPROTO-X11R7.0_PATH	=  PATH=$(CROSS_PATH)
RENDERPROTO-X11R7.0_ENV 	=  $(CROSS_ENV)
#RENDERPROTO-X11R7.0_ENV	+=
RENDERPROTO-X11R7.0_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#RENDERPROTO-X11R7.0_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
RENDERPROTO-X11R7.0_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
RENDERPROTO-X11R7.0_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
RENDERPROTO-X11R7.0_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/renderproto-X11R7.0.prepare: $(renderproto-X11R7.0_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RENDERPROTO-X11R7.0_DIR)/config.cache)
	cd $(RENDERPROTO-X11R7.0_DIR) && \
		$(RENDERPROTO-X11R7.0_PATH) $(RENDERPROTO-X11R7.0_ENV) \
		./configure $(RENDERPROTO-X11R7.0_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

renderproto-X11R7.0_compile: $(STATEDIR)/renderproto-X11R7.0.compile

renderproto-X11R7.0_compile_deps = $(STATEDIR)/renderproto-X11R7.0.prepare

$(STATEDIR)/renderproto-X11R7.0.compile: $(renderproto-X11R7.0_compile_deps)
	@$(call targetinfo, $@)
	$(RENDERPROTO-X11R7.0_PATH) $(MAKE) -C $(RENDERPROTO-X11R7.0_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

renderproto-X11R7.0_install: $(STATEDIR)/renderproto-X11R7.0.install

$(STATEDIR)/renderproto-X11R7.0.install: $(STATEDIR)/renderproto-X11R7.0.compile
	@$(call targetinfo, $@)
	rm -rf $(RENDERPROTO-X11R7.0_IPKG_TMP)
	$(RENDERPROTO-X11R7.0_PATH) $(MAKE) -C $(RENDERPROTO-X11R7.0_DIR) DESTDIR=$(RENDERPROTO-X11R7.0_IPKG_TMP) install
	@$(call copyincludes, $(RENDERPROTO-X11R7.0_IPKG_TMP))
	@$(call copylibraries,$(RENDERPROTO-X11R7.0_IPKG_TMP))
	@$(call copymiscfiles,$(RENDERPROTO-X11R7.0_IPKG_TMP))
	rm -rf $(RENDERPROTO-X11R7.0_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

renderproto-X11R7.0_targetinstall: $(STATEDIR)/renderproto-X11R7.0.targetinstall

renderproto-X11R7.0_targetinstall_deps = $(STATEDIR)/renderproto-X11R7.0.compile

RENDERPROTO-X11R7.0_DEPLIST = 

$(STATEDIR)/renderproto-X11R7.0.targetinstall: $(renderproto-X11R7.0_targetinstall_deps)
	@$(call targetinfo, $@)
	$(RENDERPROTO-X11R7.0_PATH) $(MAKE) -C $(RENDERPROTO-X11R7.0_DIR) DESTDIR=$(RENDERPROTO-X11R7.0_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(RENDERPROTO-X11R7.0_VERSION)-$(RENDERPROTO-X11R7.0_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh renderproto-x11r7.0 $(RENDERPROTO-X11R7.0_IPKG_TMP)

	@$(call removedevfiles, $(RENDERPROTO-X11R7.0_IPKG_TMP))
	@$(call stripfiles, $(RENDERPROTO-X11R7.0_IPKG_TMP))
	mkdir -p $(RENDERPROTO-X11R7.0_IPKG_TMP)/CONTROL
	echo "Package: renderproto-x11r7.0" 							 >$(RENDERPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Source: $(RENDERPROTO-X11R7.0_URL)"							>>$(RENDERPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(RENDERPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(RENDERPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield (InSearchOf@pdaxrom.org)" 							>>$(RENDERPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(RENDERPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Version: $(RENDERPROTO-X11R7.0_VERSION)-$(RENDERPROTO-X11R7.0_VENDOR_VERSION)" 			>>$(RENDERPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Depends: $(RENDERPROTO-X11R7.0_DEPLIST)" 						>>$(RENDERPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(RENDERPROTO-X11R7.0_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(RENDERPROTO-X11R7.0_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_RENDERPROTO-X11R7.0_INSTALL
ROMPACKAGES += $(STATEDIR)/renderproto-X11R7.0.imageinstall
endif

renderproto-X11R7.0_imageinstall_deps = $(STATEDIR)/renderproto-X11R7.0.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/renderproto-X11R7.0.imageinstall: $(renderproto-X11R7.0_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install renderproto-x11r7.0
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

renderproto-X11R7.0_clean:
	rm -rf $(STATEDIR)/renderproto-X11R7.0.*
	rm -rf $(RENDERPROTO-X11R7.0_DIR)

# vim: syntax=make
