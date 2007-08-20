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
ifdef PTXCONF_ELINKS
PACKAGES += elinks
endif

#
# Paths and names
#
ELINKS_VENDOR_VERSION	= 1
ELINKS_VERSION		= 0.11.1
ELINKS			= elinks-$(ELINKS_VERSION)
ELINKS_SUFFIX		= tar.bz2
ELINKS_URL		= http://elinks.or.cz/download/$(ELINKS).$(ELINKS_SUFFIX)
ELINKS_SOURCE		= $(SRCDIR)/$(ELINKS).$(ELINKS_SUFFIX)
ELINKS_DIR		= $(BUILDDIR)/$(ELINKS)
ELINKS_IPKG_TMP		= $(ELINKS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

elinks_get: $(STATEDIR)/elinks.get

elinks_get_deps = $(ELINKS_SOURCE)

$(STATEDIR)/elinks.get: $(elinks_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ELINKS))
	touch $@

$(ELINKS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ELINKS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

elinks_extract: $(STATEDIR)/elinks.extract

elinks_extract_deps = $(STATEDIR)/elinks.get

$(STATEDIR)/elinks.extract: $(elinks_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ELINKS_DIR))
	@$(call extract, $(ELINKS_SOURCE))
	@$(call patchin, $(ELINKS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

elinks_prepare: $(STATEDIR)/elinks.prepare

#
# dependencies
#
elinks_prepare_deps = \
	$(STATEDIR)/elinks.extract \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_XFREE430
elinks_prepare_deps += $(STATEDIR)/xfree430.install
endif

ELINKS_PATH	=  PATH=$(CROSS_PATH)
ELINKS_ENV 	=  $(CROSS_ENV)
#ELINKS_ENV	+=
ELINKS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ELINKS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ELINKS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-html-highlight \
	--enable-88-colors \
	--enable-256-colors \
	--enable-bittorrent \
	--enable-nntp

ifdef PTXCONF_XFREE430
ELINKS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ELINKS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/elinks.prepare: $(elinks_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ELINKS_DIR)/config.cache)
	cd $(ELINKS_DIR) && \
		$(ELINKS_PATH) $(ELINKS_ENV) \
		./configure $(ELINKS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

elinks_compile: $(STATEDIR)/elinks.compile

elinks_compile_deps = $(STATEDIR)/elinks.prepare

$(STATEDIR)/elinks.compile: $(elinks_compile_deps)
	@$(call targetinfo, $@)
	$(ELINKS_PATH) $(MAKE) -C $(ELINKS_DIR) $(CROSS_ENV_LD)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

elinks_install: $(STATEDIR)/elinks.install

$(STATEDIR)/elinks.install: $(STATEDIR)/elinks.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

elinks_targetinstall: $(STATEDIR)/elinks.targetinstall

elinks_targetinstall_deps = $(STATEDIR)/elinks.compile

ELINKS_DEPLIST = openssl, bzip2

ifdef PTXCONF_XFREE430
elinks_targetinstall_deps += $(STATEDIR)/xfree430.targetinstall
ELINKS_DEPLIST += , xfree
endif

$(STATEDIR)/elinks.targetinstall: $(elinks_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ELINKS_PATH) $(MAKE) -C $(ELINKS_DIR) DESTDIR=$(ELINKS_IPKG_TMP) install $(CROSS_ENV_LD)

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(ELINKS_VERSION)-$(ELINKS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh elinks $(ELINKS_IPKG_TMP)

	@$(call removedevfiles, $(ELINKS_IPKG_TMP))
	@$(call stripfiles, $(ELINKS_IPKG_TMP))
	mkdir -p $(ELINKS_IPKG_TMP)/CONTROL
	echo "Package: elinks" 								 >$(ELINKS_IPKG_TMP)/CONTROL/control
	echo "Source: $(ELINKS_URL)"							>>$(ELINKS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ELINKS_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(ELINKS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ELINKS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ELINKS_IPKG_TMP)/CONTROL/control
	echo "Version: $(ELINKS_VERSION)-$(ELINKS_VENDOR_VERSION)" 			>>$(ELINKS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(ELINKS_DEPLIST)" 						>>$(ELINKS_IPKG_TMP)/CONTROL/control
	echo "Description: ELinks is a program for browsing the web in text mode."	>>$(ELINKS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(ELINKS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ELINKS_INSTALL
ROMPACKAGES += $(STATEDIR)/elinks.imageinstall
endif

elinks_imageinstall_deps = $(STATEDIR)/elinks.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/elinks.imageinstall: $(elinks_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install elinks
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

elinks_clean:
	rm -rf $(STATEDIR)/elinks.*
	rm -rf $(ELINKS_DIR)

# vim: syntax=make
