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
ifdef PTXCONF_PS2CLIENT
PACKAGES += ps2client
endif

#
# Paths and names
#
PS2CLIENT_VENDOR_VERSION	= 1
PS2CLIENT_VERSION		= 3.0.0
PS2CLIENT			= ps2client-$(PS2CLIENT_VERSION)
PS2CLIENT_SUFFIX		= tgz
PS2CLIENT_URL			= http://dev.oopo.net/files/$(PS2CLIENT).$(PS2CLIENT_SUFFIX)
PS2CLIENT_SOURCE		= $(SRCDIR)/$(PS2CLIENT).$(PS2CLIENT_SUFFIX)
PS2CLIENT_DIR			= $(BUILDDIR)/$(PS2CLIENT)
PS2CLIENT_IPKG_TMP		= $(PS2CLIENT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ps2client_get: $(STATEDIR)/ps2client.get

ps2client_get_deps = $(PS2CLIENT_SOURCE)

$(STATEDIR)/ps2client.get: $(ps2client_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PS2CLIENT))
	touch $@

$(PS2CLIENT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PS2CLIENT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ps2client_extract: $(STATEDIR)/ps2client.extract

ps2client_extract_deps = $(STATEDIR)/ps2client.get

$(STATEDIR)/ps2client.extract: $(ps2client_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PS2CLIENT_DIR))
	@$(call extract, $(PS2CLIENT_SOURCE))
	@$(call patchin, $(PS2CLIENT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ps2client_prepare: $(STATEDIR)/ps2client.prepare

#
# dependencies
#
ps2client_prepare_deps = \
	$(STATEDIR)/ps2client.extract \
	$(STATEDIR)/virtual-xchain.install

PS2CLIENT_PATH	=  PATH=$(CROSS_PATH)
PS2CLIENT_ENV 	=  $(CROSS_ENV)
#PS2CLIENT_ENV	+=
PS2CLIENT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PS2CLIENT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PS2CLIENT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
PS2CLIENT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PS2CLIENT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ps2client.prepare: $(ps2client_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PS2CLIENT_DIR)/config.cache)
	#cd $(PS2CLIENT_DIR) && \
	#	$(PS2CLIENT_PATH) $(PS2CLIENT_ENV) \
	#	./configure $(PS2CLIENT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ps2client_compile: $(STATEDIR)/ps2client.compile

ps2client_compile_deps = $(STATEDIR)/ps2client.prepare

$(STATEDIR)/ps2client.compile: $(ps2client_compile_deps)
	@$(call targetinfo, $@)
	$(PS2CLIENT_PATH) $(MAKE) -C $(PS2CLIENT_DIR) $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ps2client_install: $(STATEDIR)/ps2client.install

$(STATEDIR)/ps2client.install: $(STATEDIR)/ps2client.compile
	@$(call targetinfo, $@)
	#rm -rf $(PS2CLIENT_IPKG_TMP)
	#$(PS2CLIENT_PATH) $(MAKE) -C $(PS2CLIENT_DIR) DESTDIR=$(PS2CLIENT_IPKG_TMP) install
	#@$(call copyincludes, $(PS2CLIENT_IPKG_TMP))
	#@$(call copylibraries,$(PS2CLIENT_IPKG_TMP))
	#@$(call copymiscfiles,$(PS2CLIENT_IPKG_TMP))
	#rm -rf $(PS2CLIENT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ps2client_targetinstall: $(STATEDIR)/ps2client.targetinstall

ps2client_targetinstall_deps = $(STATEDIR)/ps2client.compile

$(STATEDIR)/ps2client.targetinstall: $(ps2client_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(PS2CLIENT_PATH) $(MAKE) -C $(PS2CLIENT_DIR) DESTDIR=$(PS2CLIENT_IPKG_TMP) install

	#PATH=$(CROSS_PATH) 						\
	#FEEDDIR=$(FEEDDIR) 						\
	#STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	#VERSION=$(PS2CLIENT_VERSION)-$(PS2CLIENT_VENDOR_VERSION)	 	\
	#ARCH=$(SHORT_TARGET) 						\
	#MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	#$(TOPDIR)/scripts/bin/make-locale-ipks.sh ps2client $(PS2CLIENT_IPKG_TMP)

	#@$(call removedevfiles, $(PS2CLIENT_IPKG_TMP))
	
	mkdir -p $(PS2CLIENT_IPKG_TMP)/usr/bin
	cp -a $(PS2CLIENT_DIR)/bin/* $(PS2CLIENT_IPKG_TMP)/usr/bin
	
	@$(call stripfiles, $(PS2CLIENT_IPKG_TMP))
	mkdir -p $(PS2CLIENT_IPKG_TMP)/CONTROL
	echo "Package: ps2client" 							 >$(PS2CLIENT_IPKG_TMP)/CONTROL/control
	echo "Source: $(PS2CLIENT_URL)"							>>$(PS2CLIENT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PS2CLIENT_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(PS2CLIENT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PS2CLIENT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PS2CLIENT_IPKG_TMP)/CONTROL/control
	echo "Version: $(PS2CLIENT_VERSION)-$(PS2CLIENT_VENDOR_VERSION)" 		>>$(PS2CLIENT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(PS2CLIENT_IPKG_TMP)/CONTROL/control
	echo "Description: These programs, ps2client & fsclient, are command line tools used for interacting with a ps2 system running ps2link and/or ps2netfs.">>$(PS2CLIENT_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(PS2CLIENT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PS2CLIENT_INSTALL
ROMPACKAGES += $(STATEDIR)/ps2client.imageinstall
endif

ps2client_imageinstall_deps = $(STATEDIR)/ps2client.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ps2client.imageinstall: $(ps2client_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ps2client
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ps2client_clean:
	rm -rf $(STATEDIR)/ps2client.*
	rm -rf $(PS2CLIENT_DIR)

# vim: syntax=make
