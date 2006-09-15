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
ifdef PTXCONF_MUTT
PACKAGES += mutt
endif

#
# Paths and names
#
MUTT_VENDOR_VERSION	= 1
MUTT_VERSION		= 1.5.12
MUTT			= mutt-$(MUTT_VERSION)
MUTT_SUFFIX		= tar.gz
MUTT_URL		= ftp://ftp.mutt.org/mutt/devel/$(MUTT).$(MUTT_SUFFIX)
MUTT_SOURCE		= $(SRCDIR)/$(MUTT).$(MUTT_SUFFIX)
MUTT_DIR		= $(BUILDDIR)/$(MUTT)
MUTT_IPKG_TMP		= $(MUTT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mutt_get: $(STATEDIR)/mutt.get

mutt_get_deps = $(MUTT_SOURCE)

$(STATEDIR)/mutt.get: $(mutt_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MUTT))
	touch $@

$(MUTT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MUTT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mutt_extract: $(STATEDIR)/mutt.extract

mutt_extract_deps = $(STATEDIR)/mutt.get

$(STATEDIR)/mutt.extract: $(mutt_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MUTT_DIR))
	@$(call extract, $(MUTT_SOURCE))
	@$(call patchin, $(MUTT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mutt_prepare: $(STATEDIR)/mutt.prepare

#
# dependencies
#
mutt_prepare_deps = \
	$(STATEDIR)/mutt.extract \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/virtual-xchain.install

MUTT_PATH	=  PATH=$(CROSS_PATH)
MUTT_ENV 	=  $(CROSS_ENV)
#MUTT_ENV	+=
MUTT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MUTT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MUTT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-mailpath=/var/mail \
	--enable-pop \
	--enable-imap \
	--with-ssl=$(CROSS_LIB_DIR) \
	--sysconfdir=/etc \
	--enable-compressed \
	--enable-nntp
	
ifdef PTXCONF_XFREE430
MUTT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MUTT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mutt.prepare: $(mutt_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MUTT_DIR)/config.cache)
	cd $(MUTT_DIR) && \
		$(MUTT_PATH) $(MUTT_ENV) \
		./configure $(MUTT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mutt_compile: $(STATEDIR)/mutt.compile

mutt_compile_deps = $(STATEDIR)/mutt.prepare

$(STATEDIR)/mutt.compile: $(mutt_compile_deps)
	@$(call targetinfo, $@)
	$(MUTT_PATH) $(MAKE) -C $(MUTT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mutt_install: $(STATEDIR)/mutt.install

$(STATEDIR)/mutt.install: $(STATEDIR)/mutt.compile
	@$(call targetinfo, $@)
	rm -rf $(MUTT_IPKG_TMP)
	$(MUTT_PATH) $(MAKE) -C $(MUTT_DIR) DESTDIR=$(MUTT_IPKG_TMP) install
	@$(call copyincludes, $(MUTT_IPKG_TMP))
	@$(call copylibraries,$(MUTT_IPKG_TMP))
	@$(call copymiscfiles,$(MUTT_IPKG_TMP))
	rm -rf $(MUTT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mutt_targetinstall: $(STATEDIR)/mutt.targetinstall

mutt_targetinstall_deps = $(STATEDIR)/mutt.compile \
	$(STATEDIR)/ncurses.targetinstall \
	$(STATEDIR)/openssl.targetinstall

$(STATEDIR)/mutt.targetinstall: $(mutt_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MUTT_PATH) $(MAKE) -C $(MUTT_DIR) DESTDIR=$(MUTT_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(MUTT_VERSION)-$(MUTT_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh mutt $(MUTT_IPKG_TMP)

	@$(call removedevfiles, $(MUTT_IPKG_TMP))
	@$(call stripfiles, $(MUTT_IPKG_TMP))
	mkdir -p $(MUTT_IPKG_TMP)/CONTROL
	echo "Package: mutt" 								 >$(MUTT_IPKG_TMP)/CONTROL/control
	echo "Source: $(MUTT_URL)"							>>$(MUTT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MUTT_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(MUTT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(MUTT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MUTT_IPKG_TMP)/CONTROL/control
	echo "Version: $(MUTT_VERSION)-$(MUTT_VENDOR_VERSION)" 				>>$(MUTT_IPKG_TMP)/CONTROL/control
	echo "Depends: ncurses, openssl" 						>>$(MUTT_IPKG_TMP)/CONTROL/control
	echo "Description: Mutt is a small but very powerful text-based mail client for Unix operating systems.">>$(MUTT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MUTT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MUTT_INSTALL
ROMPACKAGES += $(STATEDIR)/mutt.imageinstall
endif

mutt_imageinstall_deps = $(STATEDIR)/mutt.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mutt.imageinstall: $(mutt_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mutt
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mutt_clean:
	rm -rf $(STATEDIR)/mutt.*
	rm -rf $(MUTT_DIR)

# vim: syntax=make
