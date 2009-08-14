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
ifdef PTXCONF_GTK-XFCE-ENGINE
PACKAGES += gtk-xfce-engine
endif

#
# Paths and names
#
GTK-XFCE-ENGINE_VENDOR_VERSION	= 1
GTK-XFCE-ENGINE_VERSION	= 2.4.0
GTK-XFCE-ENGINE		= gtk-xfce-engine-$(GTK-XFCE-ENGINE_VERSION)
GTK-XFCE-ENGINE_SUFFIX		= tar.bz2
GTK-XFCE-ENGINE_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(GTK-XFCE-ENGINE).$(GTK-XFCE-ENGINE_SUFFIX)
GTK-XFCE-ENGINE_SOURCE		= $(SRCDIR)/$(GTK-XFCE-ENGINE).$(GTK-XFCE-ENGINE_SUFFIX)
GTK-XFCE-ENGINE_DIR		= $(BUILDDIR)/$(GTK-XFCE-ENGINE)
GTK-XFCE-ENGINE_IPKG_TMP	= $(GTK-XFCE-ENGINE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gtk-xfce-engine_get: $(STATEDIR)/gtk-xfce-engine.get

gtk-xfce-engine_get_deps = $(GTK-XFCE-ENGINE_SOURCE)

$(STATEDIR)/gtk-xfce-engine.get: $(gtk-xfce-engine_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GTK-XFCE-ENGINE))
	touch $@

$(GTK-XFCE-ENGINE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GTK-XFCE-ENGINE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gtk-xfce-engine_extract: $(STATEDIR)/gtk-xfce-engine.extract

gtk-xfce-engine_extract_deps = $(STATEDIR)/gtk-xfce-engine.get

$(STATEDIR)/gtk-xfce-engine.extract: $(gtk-xfce-engine_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTK-XFCE-ENGINE_DIR))
	@$(call extract, $(GTK-XFCE-ENGINE_SOURCE))
	@$(call patchin, $(GTK-XFCE-ENGINE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gtk-xfce-engine_prepare: $(STATEDIR)/gtk-xfce-engine.prepare

#
# dependencies
#
gtk-xfce-engine_prepare_deps = \
	$(STATEDIR)/gtk-xfce-engine.extract \
	$(STATEDIR)/virtual-xchain.install

GTK-XFCE-ENGINE_PATH	=  PATH=$(CROSS_PATH)
GTK-XFCE-ENGINE_ENV 	=  $(CROSS_ENV)
#GTK-XFCE-ENGINE_ENV	+=
GTK-XFCE-ENGINE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GTK-XFCE-ENGINE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GTK-XFCE-ENGINE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GTK-XFCE-ENGINE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GTK-XFCE-ENGINE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gtk-xfce-engine.prepare: $(gtk-xfce-engine_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTK-XFCE-ENGINE_DIR)/config.cache)
	cd $(GTK-XFCE-ENGINE_DIR) && \
		$(GTK-XFCE-ENGINE_PATH) $(GTK-XFCE-ENGINE_ENV) \
		./configure $(GTK-XFCE-ENGINE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gtk-xfce-engine_compile: $(STATEDIR)/gtk-xfce-engine.compile

gtk-xfce-engine_compile_deps = $(STATEDIR)/gtk-xfce-engine.prepare

$(STATEDIR)/gtk-xfce-engine.compile: $(gtk-xfce-engine_compile_deps)
	@$(call targetinfo, $@)
	$(GTK-XFCE-ENGINE_PATH) $(MAKE) -C $(GTK-XFCE-ENGINE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gtk-xfce-engine_install: $(STATEDIR)/gtk-xfce-engine.install

$(STATEDIR)/gtk-xfce-engine.install: $(STATEDIR)/gtk-xfce-engine.compile
	@$(call targetinfo, $@)
	rm -rf $(GTK-XFCE-ENGINE_IPKG_TMP)
	$(GTK-XFCE-ENGINE_PATH) $(MAKE) -C $(GTK-XFCE-ENGINE_DIR) DESTDIR=$(GTK-XFCE-ENGINE_IPKG_TMP) install
	@$(call copyincludes, $(GTK-XFCE-ENGINE_IPKG_TMP))
	@$(call copylibraries,$(GTK-XFCE-ENGINE_IPKG_TMP))
	@$(call copymiscfiles,$(GTK-XFCE-ENGINE_IPKG_TMP))
	rm -rf $(GTK-XFCE-ENGINE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gtk-xfce-engine_targetinstall: $(STATEDIR)/gtk-xfce-engine.targetinstall

gtk-xfce-engine_targetinstall_deps = $(STATEDIR)/gtk-xfce-engine.compile

GTK-XFCE-ENGINE_DEPLIST = 

$(STATEDIR)/gtk-xfce-engine.targetinstall: $(gtk-xfce-engine_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GTK-XFCE-ENGINE_PATH) $(MAKE) -C $(GTK-XFCE-ENGINE_DIR) DESTDIR=$(GTK-XFCE-ENGINE_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(GTK-XFCE-ENGINE_VERSION)-$(GTK-XFCE-ENGINE_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh gtk-xfce-engine $(GTK-XFCE-ENGINE_IPKG_TMP)

	@$(call removedevfiles, $(GTK-XFCE-ENGINE_IPKG_TMP))
	@$(call stripfiles, $(GTK-XFCE-ENGINE_IPKG_TMP))
	mkdir -p $(GTK-XFCE-ENGINE_IPKG_TMP)/CONTROL
	echo "Package: gtk-xfce-engine" 							 >$(GTK-XFCE-ENGINE_IPKG_TMP)/CONTROL/control
	echo "Source: $(GTK-XFCE-ENGINE_URL)"							>>$(GTK-XFCE-ENGINE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GTK-XFCE-ENGINE_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(GTK-XFCE-ENGINE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(GTK-XFCE-ENGINE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GTK-XFCE-ENGINE_IPKG_TMP)/CONTROL/control
	echo "Version: $(GTK-XFCE-ENGINE_VERSION)-$(GTK-XFCE-ENGINE_VENDOR_VERSION)" 			>>$(GTK-XFCE-ENGINE_IPKG_TMP)/CONTROL/control
	echo "Depends: $(GTK-XFCE-ENGINE_DEPLIST)" 						>>$(GTK-XFCE-ENGINE_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(GTK-XFCE-ENGINE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(GTK-XFCE-ENGINE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GTK-XFCE-ENGINE_INSTALL
ROMPACKAGES += $(STATEDIR)/gtk-xfce-engine.imageinstall
endif

gtk-xfce-engine_imageinstall_deps = $(STATEDIR)/gtk-xfce-engine.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gtk-xfce-engine.imageinstall: $(gtk-xfce-engine_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gtk-xfce-engine
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gtk-xfce-engine_clean:
	rm -rf $(STATEDIR)/gtk-xfce-engine.*
	rm -rf $(GTK-XFCE-ENGINE_DIR)

# vim: syntax=make
