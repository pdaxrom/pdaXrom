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
ifdef PTXCONF_EVOLUTION-DATA-SERVER
PACKAGES += evolution-data-server
endif

#
# Paths and names
#
EVOLUTION-DATA-SERVER_VENDOR_VERSION	= 1
EVOLUTION-DATA-SERVER_VERSION		= 1.7.91
EVOLUTION-DATA-SERVER			= evolution-data-server-$(EVOLUTION-DATA-SERVER_VERSION)
EVOLUTION-DATA-SERVER_SUFFIX		= tar.bz2
EVOLUTION-DATA-SERVER_URL		= http://ftp.gnome.org/pub/gnome/sources/evolution-data-server/1.7/$(EVOLUTION-DATA-SERVER).$(EVOLUTION-DATA-SERVER_SUFFIX)
EVOLUTION-DATA-SERVER_SOURCE		= $(SRCDIR)/$(EVOLUTION-DATA-SERVER).$(EVOLUTION-DATA-SERVER_SUFFIX)
EVOLUTION-DATA-SERVER_DIR		= $(BUILDDIR)/$(EVOLUTION-DATA-SERVER)
EVOLUTION-DATA-SERVER_IPKG_TMP		= $(EVOLUTION-DATA-SERVER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

evolution-data-server_get: $(STATEDIR)/evolution-data-server.get

evolution-data-server_get_deps = $(EVOLUTION-DATA-SERVER_SOURCE)

$(STATEDIR)/evolution-data-server.get: $(evolution-data-server_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(EVOLUTION-DATA-SERVER))
	touch $@

$(EVOLUTION-DATA-SERVER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(EVOLUTION-DATA-SERVER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

evolution-data-server_extract: $(STATEDIR)/evolution-data-server.extract

evolution-data-server_extract_deps = $(STATEDIR)/evolution-data-server.get

$(STATEDIR)/evolution-data-server.extract: $(evolution-data-server_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EVOLUTION-DATA-SERVER_DIR))
	@$(call extract, $(EVOLUTION-DATA-SERVER_SOURCE))
	@$(call patchin, $(EVOLUTION-DATA-SERVER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

evolution-data-server_prepare: $(STATEDIR)/evolution-data-server.prepare

#
# dependencies
#
evolution-data-server_prepare_deps = \
	$(STATEDIR)/evolution-data-server.extract \
	$(STATEDIR)/libsoup.install \
	$(STATEDIR)/virtual-xchain.install

EVOLUTION-DATA-SERVER_PATH	=  PATH=$(CROSS_PATH)
EVOLUTION-DATA-SERVER_ENV 	=  $(CROSS_ENV)
#EVOLUTION-DATA-SERVER_ENV	+=
EVOLUTION-DATA-SERVER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#EVOLUTION-DATA-SERVER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
EVOLUTION-DATA-SERVER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-nss=no \
	--disable-schemas-install \
	--libexecdir=/usr/sbin

ifdef PTXCONF_XFREE430
EVOLUTION-DATA-SERVER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
EVOLUTION-DATA-SERVER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/evolution-data-server.prepare: $(evolution-data-server_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EVOLUTION-DATA-SERVER_DIR)/config.cache)
	cd $(EVOLUTION-DATA-SERVER_DIR) && \
		$(EVOLUTION-DATA-SERVER_PATH) $(EVOLUTION-DATA-SERVER_ENV) \
		./configure $(EVOLUTION-DATA-SERVER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

evolution-data-server_compile: $(STATEDIR)/evolution-data-server.compile

evolution-data-server_compile_deps = $(STATEDIR)/evolution-data-server.prepare

$(STATEDIR)/evolution-data-server.compile: $(evolution-data-server_compile_deps)
	@$(call targetinfo, $@)
	$(EVOLUTION-DATA-SERVER_PATH) $(MAKE) -C $(EVOLUTION-DATA-SERVER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

evolution-data-server_install: $(STATEDIR)/evolution-data-server.install

$(STATEDIR)/evolution-data-server.install: $(STATEDIR)/evolution-data-server.compile
	@$(call targetinfo, $@)
	rm -rf $(EVOLUTION-DATA-SERVER_IPKG_TMP)
	$(EVOLUTION-DATA-SERVER_PATH) $(MAKE) -C $(EVOLUTION-DATA-SERVER_DIR) DESTDIR=$(EVOLUTION-DATA-SERVER_IPKG_TMP) install
	@$(call copyincludes, $(EVOLUTION-DATA-SERVER_IPKG_TMP))
	@$(call copylibraries,$(EVOLUTION-DATA-SERVER_IPKG_TMP))
	@$(call copymiscfiles,$(EVOLUTION-DATA-SERVER_IPKG_TMP))
	rm -rf $(EVOLUTION-DATA-SERVER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

evolution-data-server_targetinstall: $(STATEDIR)/evolution-data-server.targetinstall

evolution-data-server_targetinstall_deps = $(STATEDIR)/evolution-data-server.compile \
	$(STATEDIR)/libsoup.targetinstall

$(STATEDIR)/evolution-data-server.targetinstall: $(evolution-data-server_targetinstall_deps)
	@$(call targetinfo, $@)
	$(EVOLUTION-DATA-SERVER_PATH) $(MAKE) -C $(EVOLUTION-DATA-SERVER_DIR) DESTDIR=$(EVOLUTION-DATA-SERVER_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(EVOLUTION-DATA-SERVER_VERSION)-$(EVOLUTION-DATA-SERVER_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh evolution-data-server $(EVOLUTION-DATA-SERVER_IPKG_TMP)

	@$(call removedevfiles, $(EVOLUTION-DATA-SERVER_IPKG_TMP))
	@$(call stripfiles, $(EVOLUTION-DATA-SERVER_IPKG_TMP))
	mkdir -p $(EVOLUTION-DATA-SERVER_IPKG_TMP)/CONTROL
	echo "Package: evolution-data-server" 						 >$(EVOLUTION-DATA-SERVER_IPKG_TMP)/CONTROL/control
	echo "Source: $(EVOLUTION-DATA-SERVER_URL)"					>>$(EVOLUTION-DATA-SERVER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(EVOLUTION-DATA-SERVER_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(EVOLUTION-DATA-SERVER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(EVOLUTION-DATA-SERVER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(EVOLUTION-DATA-SERVER_IPKG_TMP)/CONTROL/control
	echo "Version: $(EVOLUTION-DATA-SERVER_VERSION)-$(EVOLUTION-DATA-SERVER_VENDOR_VERSION)" 			>>$(EVOLUTION-DATA-SERVER_IPKG_TMP)/CONTROL/control
	echo "Depends: libsoup" 					 		>>$(EVOLUTION-DATA-SERVER_IPKG_TMP)/CONTROL/control
	echo "Description:  The Evolution Data Server package provides a unified backend for programs that work with contacts, tasks, and calendar information." >>$(EVOLUTION-DATA-SERVER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(EVOLUTION-DATA-SERVER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_EVOLUTION-DATA-SERVER_INSTALL
ROMPACKAGES += $(STATEDIR)/evolution-data-server.imageinstall
endif

evolution-data-server_imageinstall_deps = $(STATEDIR)/evolution-data-server.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/evolution-data-server.imageinstall: $(evolution-data-server_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install evolution-data-server
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

evolution-data-server_clean:
	rm -rf $(STATEDIR)/evolution-data-server.*
	rm -rf $(EVOLUTION-DATA-SERVER_DIR)

# vim: syntax=make
