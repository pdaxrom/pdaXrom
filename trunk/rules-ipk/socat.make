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
ifdef PTXCONF_SOCAT
PACKAGES += socat
endif

#
# Paths and names
#
SOCAT_VENDOR_VERSION	= 1
SOCAT_VERSION		= 1.4.3.0
SOCAT			= socat-$(SOCAT_VERSION)
SOCAT_SUFFIX		= tar.bz2
SOCAT_URL		= http://www.dest-unreach.org/socat/download/$(SOCAT).$(SOCAT_SUFFIX)
SOCAT_SOURCE		= $(SRCDIR)/$(SOCAT).$(SOCAT_SUFFIX)
SOCAT_DIR		= $(BUILDDIR)/socat-1.4
SOCAT_IPKG_TMP		= $(SOCAT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

socat_get: $(STATEDIR)/socat.get

socat_get_deps = $(SOCAT_SOURCE)

$(STATEDIR)/socat.get: $(socat_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SOCAT))
	touch $@

$(SOCAT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SOCAT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

socat_extract: $(STATEDIR)/socat.extract

socat_extract_deps = $(STATEDIR)/socat.get

$(STATEDIR)/socat.extract: $(socat_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SOCAT_DIR))
	@$(call extract, $(SOCAT_SOURCE))
	@$(call patchin, $(SOCAT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

socat_prepare: $(STATEDIR)/socat.prepare

#
# dependencies
#
socat_prepare_deps = \
	$(STATEDIR)/socat.extract \
	$(STATEDIR)/readline.install \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/virtual-xchain.install

SOCAT_PATH	=  PATH=$(CROSS_PATH)
SOCAT_ENV 	=  $(CROSS_ENV)
#SOCAT_ENV	+=
SOCAT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SOCAT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SOCAT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
SOCAT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SOCAT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/socat.prepare: $(socat_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SOCAT_DIR)/config.cache)
	cd $(SOCAT_DIR) && \
		$(SOCAT_PATH) $(SOCAT_ENV) \
		./configure $(SOCAT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

socat_compile: $(STATEDIR)/socat.compile

socat_compile_deps = $(STATEDIR)/socat.prepare

$(STATEDIR)/socat.compile: $(socat_compile_deps)
	@$(call targetinfo, $@)
	$(SOCAT_PATH) $(MAKE) -C $(SOCAT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

socat_install: $(STATEDIR)/socat.install

$(STATEDIR)/socat.install: $(STATEDIR)/socat.compile
	@$(call targetinfo, $@)
	#$(SOCAT_PATH) $(MAKE) -C $(SOCAT_DIR) install
	sdf
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

socat_targetinstall: $(STATEDIR)/socat.targetinstall

socat_targetinstall_deps = $(STATEDIR)/socat.compile \
	$(STATEDIR)/readline.targetinstall \
	$(STATEDIR)/ncurses.targetinstall \
	$(STATEDIR)/openssl.targetinstall

$(STATEDIR)/socat.targetinstall: $(socat_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SOCAT_PATH) $(MAKE) -C $(SOCAT_DIR) DESTDIR=$(SOCAT_IPKG_TMP) install
	rm -rf $(SOCAT_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(SOCAT_IPKG_TMP)/usr/bin/*
	mkdir -p $(SOCAT_IPKG_TMP)/CONTROL
	echo "Package: socat" 								 >$(SOCAT_IPKG_TMP)/CONTROL/control
	echo "Source: $(SOCAT_URL)"							>>$(SOCAT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SOCAT_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(SOCAT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SOCAT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SOCAT_IPKG_TMP)/CONTROL/control
	echo "Version: $(SOCAT_VERSION)-$(SOCAT_VENDOR_VERSION)" 			>>$(SOCAT_IPKG_TMP)/CONTROL/control
	echo "Depends: readline, ncurses, openssl" 					>>$(SOCAT_IPKG_TMP)/CONTROL/control
	echo "Description: Multipurpose relay"						>>$(SOCAT_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(SOCAT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SOCAT_INSTALL
ROMPACKAGES += $(STATEDIR)/socat.imageinstall
endif

socat_imageinstall_deps = $(STATEDIR)/socat.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/socat.imageinstall: $(socat_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install socat
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

socat_clean:
	rm -rf $(STATEDIR)/socat.*
	rm -rf $(SOCAT_DIR)

# vim: syntax=make
