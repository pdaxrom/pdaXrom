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
ifdef PTXCONF_OPAL
PACKAGES += opal
endif

#
# Paths and names
#
OPAL_VENDOR_VERSION	= 1
OPAL_VERSION		= 2.2.2
OPAL			= opal-$(OPAL_VERSION)
OPAL_SUFFIX		= tar.gz
OPAL_URL		= http://www.ekiga.org/admin/downloads/latest/sources/sources/$(OPAL).$(OPAL_SUFFIX)
OPAL_SOURCE		= $(SRCDIR)/$(OPAL).$(OPAL_SUFFIX)
OPAL_DIR		= $(BUILDDIR)/$(OPAL)
OPAL_IPKG_TMP		= $(OPAL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

opal_get: $(STATEDIR)/opal.get

opal_get_deps = $(OPAL_SOURCE)

$(STATEDIR)/opal.get: $(opal_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OPAL))
	touch $@

$(OPAL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OPAL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

opal_extract: $(STATEDIR)/opal.extract

opal_extract_deps = $(STATEDIR)/opal.get

$(STATEDIR)/opal.extract: $(opal_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPAL_DIR))
	@$(call extract, $(OPAL_SOURCE))
	@$(call patchin, $(OPAL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

opal_prepare: $(STATEDIR)/opal.prepare

#
# dependencies
#
opal_prepare_deps = \
	$(STATEDIR)/opal.extract \
	$(STATEDIR)/speex.install \
	$(STATEDIR)/pwlib.install \
	$(STATEDIR)/virtual-xchain.install

OPAL_PATH	=  PATH=$(CROSS_PATH)
OPAL_ENV 	=  $(CROSS_ENV)
#OPAL_ENV	+=
OPAL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OPAL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
OPAL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

#	--enable-h263avcodec=$(CROSS_LIB_DIR)/include/ffmpeg

ifdef PTXCONF_XFREE430
OPAL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OPAL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/opal.prepare: $(opal_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPAL_DIR)/config.cache)
	ln -sf $(PWLIB_DIR) $(BUILDDIR)/pwlib
	cd $(OPAL_DIR) && \
		CPP=$(PTXCONF_GNU_TARGET)-cpp \
		$(OPAL_PATH) $(OPAL_ENV) \
		./configure $(OPAL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

opal_compile: $(STATEDIR)/opal.compile

opal_compile_deps = $(STATEDIR)/opal.prepare

$(STATEDIR)/opal.compile: $(opal_compile_deps)
	@$(call targetinfo, $@)
	$(OPAL_PATH) $(MAKE) -C $(OPAL_DIR) $(CROSS_ENV_CC) $(CROSS_ENV_CXX)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

opal_install: $(STATEDIR)/opal.install

$(STATEDIR)/opal.install: $(STATEDIR)/opal.compile
	@$(call targetinfo, $@)
	rm -rf $(OPAL_IPKG_TMP)
	$(OPAL_PATH) $(MAKE) -C $(OPAL_DIR) DESTDIR=$(OPAL_IPKG_TMP) install
	@$(call copyincludes, $(OPAL_IPKG_TMP))
	@$(call copylibraries,$(OPAL_IPKG_TMP))
	@$(call copymiscfiles,$(OPAL_IPKG_TMP))
	rm -rf $(OPAL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

opal_targetinstall: $(STATEDIR)/opal.targetinstall

opal_targetinstall_deps = $(STATEDIR)/opal.compile \
	$(STATEDIR)/speex.targetinstall \
	$(STATEDIR)/pwlib.targetinstall

$(STATEDIR)/opal.targetinstall: $(opal_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OPAL_PATH) $(MAKE) -C $(OPAL_DIR) DESTDIR=$(OPAL_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(OPAL_VERSION)-$(OPAL_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh opal $(OPAL_IPKG_TMP)

	@$(call removedevfiles, $(OPAL_IPKG_TMP))
	@$(call stripfiles, $(OPAL_IPKG_TMP))
	mkdir -p $(OPAL_IPKG_TMP)/CONTROL
	echo "Package: opal" 								 >$(OPAL_IPKG_TMP)/CONTROL/control
	echo "Source: $(OPAL_URL)"							>>$(OPAL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(OPAL_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(OPAL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(OPAL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(OPAL_IPKG_TMP)/CONTROL/control
	echo "Version: $(OPAL_VERSION)-$(OPAL_VENDOR_VERSION)" 				>>$(OPAL_IPKG_TMP)/CONTROL/control
	echo "Depends: pwlib, libspeex" 						>>$(OPAL_IPKG_TMP)/CONTROL/control
	echo "Description: Open Phone Abstraction Library"				>>$(OPAL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OPAL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OPAL_INSTALL
ROMPACKAGES += $(STATEDIR)/opal.imageinstall
endif

opal_imageinstall_deps = $(STATEDIR)/opal.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/opal.imageinstall: $(opal_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install opal
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

opal_clean:
	rm -rf $(STATEDIR)/opal.*
	rm -rf $(OPAL_DIR)

# vim: syntax=make
