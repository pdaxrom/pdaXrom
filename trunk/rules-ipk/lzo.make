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
ifdef PTXCONF_LZO
PACKAGES += lzo
endif

#
# Paths and names
#
LZO_VENDOR_VERSION	= 1
LZO_VERSION		= 2.02
LZO			= lzo-$(LZO_VERSION)
LZO_SUFFIX		= tar.gz
LZO_URL			= http://www.oberhumer.com/opensource/lzo/download/$(LZO).$(LZO_SUFFIX)
LZO_SOURCE		= $(SRCDIR)/$(LZO).$(LZO_SUFFIX)
LZO_DIR			= $(BUILDDIR)/$(LZO)
LZO_IPKG_TMP		= $(LZO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lzo_get: $(STATEDIR)/lzo.get

lzo_get_deps = $(LZO_SOURCE)

$(STATEDIR)/lzo.get: $(lzo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LZO))
	touch $@

$(LZO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LZO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lzo_extract: $(STATEDIR)/lzo.extract

lzo_extract_deps = $(STATEDIR)/lzo.get

$(STATEDIR)/lzo.extract: $(lzo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LZO_DIR))
	@$(call extract, $(LZO_SOURCE))
	@$(call patchin, $(LZO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lzo_prepare: $(STATEDIR)/lzo.prepare

#
# dependencies
#
lzo_prepare_deps = \
	$(STATEDIR)/lzo.extract \
	$(STATEDIR)/virtual-xchain.install

LZO_PATH	=  PATH=$(CROSS_PATH)
LZO_ENV 	=  $(CROSS_ENV)
#LZO_ENV	+=
LZO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LZO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LZO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
LZO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LZO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/lzo.prepare: $(lzo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LZO_DIR)/config.cache)
	cd $(LZO_DIR) && \
		$(LZO_PATH) $(LZO_ENV) \
		./configure $(LZO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lzo_compile: $(STATEDIR)/lzo.compile

lzo_compile_deps = $(STATEDIR)/lzo.prepare

$(STATEDIR)/lzo.compile: $(lzo_compile_deps)
	@$(call targetinfo, $@)
	$(LZO_PATH) $(MAKE) -C $(LZO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lzo_install: $(STATEDIR)/lzo.install

$(STATEDIR)/lzo.install: $(STATEDIR)/lzo.compile
	@$(call targetinfo, $@)
	rm -rf $(LZO_IPKG_TMP)
	$(LZO_PATH) $(MAKE) -C $(LZO_DIR) DESTDIR=$(LZO_IPKG_TMP) install
	@$(call copyincludes, $(LZO_IPKG_TMP))
	@$(call copylibraries,$(LZO_IPKG_TMP))
	@$(call copymiscfiles,$(LZO_IPKG_TMP))
	rm -rf $(LZO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lzo_targetinstall: $(STATEDIR)/lzo.targetinstall

lzo_targetinstall_deps = $(STATEDIR)/lzo.compile

$(STATEDIR)/lzo.targetinstall: $(lzo_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LZO_PATH) $(MAKE) -C $(LZO_DIR) DESTDIR=$(LZO_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LZO_VERSION)-$(LZO_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh lzo $(LZO_IPKG_TMP)

	@$(call removedevfiles, $(LZO_IPKG_TMP))
	@$(call stripfiles, $(LZO_IPKG_TMP))
	mkdir -p $(LZO_IPKG_TMP)/CONTROL
	echo "Package: lzo" 								 >$(LZO_IPKG_TMP)/CONTROL/control
	echo "Source: $(LZO_URL)"							>>$(LZO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LZO_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LZO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LZO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LZO_IPKG_TMP)/CONTROL/control
	echo "Version: $(LZO_VERSION)-$(LZO_VENDOR_VERSION)" 				>>$(LZO_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LZO_IPKG_TMP)/CONTROL/control
	echo "Description: LZO is a portable lossless data compression library written in ANSI C" >>$(LZO_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LZO_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LZO_INSTALL
ROMPACKAGES += $(STATEDIR)/lzo.imageinstall
endif

lzo_imageinstall_deps = $(STATEDIR)/lzo.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/lzo.imageinstall: $(lzo_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lzo
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lzo_clean:
	rm -rf $(STATEDIR)/lzo.*
	rm -rf $(LZO_DIR)

# vim: syntax=make
