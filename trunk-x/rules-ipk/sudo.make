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
ifdef PTXCONF_SUDO
PACKAGES += sudo
endif

#
# Paths and names
#
SUDO_VENDOR_VERSION	= 1
SUDO_VERSION		= 1.6.8p8
SUDO			= sudo-$(SUDO_VERSION)
SUDO_SUFFIX		= tar.gz
SUDO_URL		= http://www.courtesan.com/sudo/dist//$(SUDO).$(SUDO_SUFFIX)
SUDO_SOURCE		= $(SRCDIR)/$(SUDO).$(SUDO_SUFFIX)
SUDO_DIR		= $(BUILDDIR)/$(SUDO)
SUDO_IPKG_TMP		= $(SUDO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sudo_get: $(STATEDIR)/sudo.get

sudo_get_deps = $(SUDO_SOURCE)

$(STATEDIR)/sudo.get: $(sudo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SUDO))
	touch $@

$(SUDO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SUDO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sudo_extract: $(STATEDIR)/sudo.extract

sudo_extract_deps = $(STATEDIR)/sudo.get

$(STATEDIR)/sudo.extract: $(sudo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SUDO_DIR))
	@$(call extract, $(SUDO_SOURCE))
	@$(call patchin, $(SUDO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sudo_prepare: $(STATEDIR)/sudo.prepare

#
# dependencies
#
sudo_prepare_deps = \
	$(STATEDIR)/sudo.extract \
	$(STATEDIR)/virtual-xchain.install

SUDO_PATH	=  PATH=$(CROSS_PATH)
SUDO_ENV 	=  $(CROSS_ENV)
#SUDO_ENV	+=
SUDO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SUDO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SUDO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--libexecdir=/usr/lib \
	--with-editor=/bin/vi \
	--with-env-editor

ifdef PTXCONF_XFREE430
SUDO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SUDO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/sudo.prepare: $(sudo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SUDO_DIR)/config.cache)
	rm -f $(SUDO_DIR)/acsite.m4
	if [ ! -e $(SUDO_DIR)/acinclude.m4 ]; then				\
		cat $(SUDO_DIR)/aclocal.m4 > $(SUDO_DIR)/acinclude.m4	;	\
	fi
	cd $(SUDO_DIR) && $(SUDO_PATH) aclocal
	cd $(SUDO_DIR) && $(SUDO_PATH) autoconf
	cd $(SUDO_DIR) && \
		$(SUDO_PATH) $(SUDO_ENV) \
		./configure $(SUDO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sudo_compile: $(STATEDIR)/sudo.compile

sudo_compile_deps = $(STATEDIR)/sudo.prepare

$(STATEDIR)/sudo.compile: $(sudo_compile_deps)
	@$(call targetinfo, $@)
	$(SUDO_PATH) $(MAKE) -C $(SUDO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sudo_install: $(STATEDIR)/sudo.install

$(STATEDIR)/sudo.install: $(STATEDIR)/sudo.compile
	@$(call targetinfo, $@)
	$(SUDO_PATH) $(MAKE) -C $(SUDO_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sudo_targetinstall: $(STATEDIR)/sudo.targetinstall

sudo_targetinstall_deps = $(STATEDIR)/sudo.compile

$(STATEDIR)/sudo.targetinstall: $(sudo_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SUDO_PATH) $(MAKE) -C $(SUDO_DIR) DESTDIR=$(SUDO_IPKG_TMP) install
	rm -f $(SUDO_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(SUDO_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(SUDO_IPKG_TMP)/usr/lib/*.so*
	$(CROSSSTRIP) $(SUDO_IPKG_TMP)/usr/sbin/*
	rm -f $(SUDO_IPKG_TMP)/usr/bin/sudoedit
	ln -sf sudo $(SUDO_IPKG_TMP)/usr/bin/sudoedit
	#chmod 4755 $(SUDO_IPKG_TMP)/usr/bin/*
	chmod u+s $(SUDO_IPKG_TMP)/usr/bin/sudo
	cp -a $(TOPDIR)/config/pdaXrom/userstuff/sudoers $(SUDO_IPKG_TMP)/etc/sudoers
	chmod 440  $(SUDO_IPKG_TMP)/etc/sudoers
	rm -rf $(SUDO_IPKG_TMP)/usr/man
	mkdir -p $(SUDO_IPKG_TMP)/CONTROL
	echo "Package: sudo" 											 >$(SUDO_IPKG_TMP)/CONTROL/control
	echo "Source: $(SUDO_URL)"										>>$(SUDO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(SUDO_IPKG_TMP)/CONTROL/control
	echo "Section: System" 											>>$(SUDO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(SUDO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(SUDO_IPKG_TMP)/CONTROL/control
	echo "Version: $(SUDO_VERSION)-$(SUDO_VENDOR_VERSION)" 							>>$(SUDO_IPKG_TMP)/CONTROL/control
	echo "Depends: " 											>>$(SUDO_IPKG_TMP)/CONTROL/control
	echo "Description: Sudo (superuser do) allows a system administrator to give certain users (or groups of users) the ability to run some (or all) commands as root or another user while logging the commands and arguments.">>$(SUDO_IPKG_TMP)/CONTROL/control
	
	echo "#!/bin/sh"				 >$(SUDO_IPKG_TMP)/CONTROL/postinst
	echo "chmod u+s /usr/bin/sudo"			>>$(SUDO_IPKG_TMP)/CONTROL/postinst
	echo "chmod 440 /etc/sudoers"			>>$(SUDO_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(SUDO_IPKG_TMP)/CONTROL/postinst
	
	cd $(FEEDDIR) && $(XMKIPKG) $(SUDO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SUDO_INSTALL
ROMPACKAGES += $(STATEDIR)/sudo.imageinstall
endif

sudo_imageinstall_deps = $(STATEDIR)/sudo.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/sudo.imageinstall: $(sudo_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sudo
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sudo_clean:
	rm -rf $(STATEDIR)/sudo.*
	rm -rf $(SUDO_DIR)

# vim: syntax=make
