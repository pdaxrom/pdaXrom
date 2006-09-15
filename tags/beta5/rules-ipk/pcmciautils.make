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
ifdef PTXCONF_PCMCIAUTILS
PACKAGES += pcmciautils
endif

#
# Paths and names
#
PCMCIAUTILS_VENDOR_VERSION	= 1
PCMCIAUTILS_VERSION		= 013
PCMCIAUTILS			= pcmciautils-$(PCMCIAUTILS_VERSION)
PCMCIAUTILS_SUFFIX		= tar.bz2
PCMCIAUTILS_URL			= http://www.kernel.org/pub/linux/utils/kernel/pcmcia/$(PCMCIAUTILS).$(PCMCIAUTILS_SUFFIX)
PCMCIAUTILS_SOURCE		= $(SRCDIR)/$(PCMCIAUTILS).$(PCMCIAUTILS_SUFFIX)
PCMCIAUTILS_DIR			= $(BUILDDIR)/$(PCMCIAUTILS)
PCMCIAUTILS_IPKG_TMP		= $(PCMCIAUTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pcmciautils_get: $(STATEDIR)/pcmciautils.get

pcmciautils_get_deps = $(PCMCIAUTILS_SOURCE)

$(STATEDIR)/pcmciautils.get: $(pcmciautils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PCMCIAUTILS))
	touch $@

$(PCMCIAUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PCMCIAUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pcmciautils_extract: $(STATEDIR)/pcmciautils.extract

pcmciautils_extract_deps = $(STATEDIR)/pcmciautils.get

$(STATEDIR)/pcmciautils.extract: $(pcmciautils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PCMCIAUTILS_DIR))
	@$(call extract, $(PCMCIAUTILS_SOURCE))
	@$(call patchin, $(PCMCIAUTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pcmciautils_prepare: $(STATEDIR)/pcmciautils.prepare

#
# dependencies
#
pcmciautils_prepare_deps = \
	$(STATEDIR)/pcmciautils.extract \
	$(STATEDIR)/sysfsutils.install \
	$(STATEDIR)/virtual-xchain.install

PCMCIAUTILS_PATH	=  PATH=$(CROSS_PATH)
PCMCIAUTILS_ENV 	=  $(CROSS_ENV)
#PCMCIAUTILS_ENV	+=
PCMCIAUTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PCMCIAUTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PCMCIAUTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PCMCIAUTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PCMCIAUTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pcmciautils.prepare: $(pcmciautils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PCMCIAUTILS_DIR)/config.cache)
	#cd $(PCMCIAUTILS_DIR) && \
	#	$(PCMCIAUTILS_PATH) $(PCMCIAUTILS_ENV) \
	#	./configure $(PCMCIAUTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pcmciautils_compile: $(STATEDIR)/pcmciautils.compile

pcmciautils_compile_deps = $(STATEDIR)/pcmciautils.prepare

$(STATEDIR)/pcmciautils.compile: $(pcmciautils_compile_deps)
	@$(call targetinfo, $@)
	$(PCMCIAUTILS_PATH) $(PCMCIAUTILS_ENV) $(MAKE) -C $(PCMCIAUTILS_DIR) ARCH=$(PTXCONF_ARCH_USERSPACE) \
	    CROSS=$(PTXCONF_GNU_TARGET)- LEX=flex SYMLINK="ln -sf"
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pcmciautils_install: $(STATEDIR)/pcmciautils.install

$(STATEDIR)/pcmciautils.install: $(STATEDIR)/pcmciautils.compile
	@$(call targetinfo, $@)
	###$(PCMCIAUTILS_PATH) $(MAKE) -C $(PCMCIAUTILS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pcmciautils_targetinstall: $(STATEDIR)/pcmciautils.targetinstall

pcmciautils_targetinstall_deps = $(STATEDIR)/pcmciautils.compile \
	$(STATEDIR)/sysfsutils.targetinstall


$(STATEDIR)/pcmciautils.targetinstall: $(pcmciautils_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PCMCIAUTILS_PATH) $(MAKE) -C $(PCMCIAUTILS_DIR) DESTDIR=$(PCMCIAUTILS_IPKG_TMP) install SYMLINK="ln -sf"
	rm -f $(PCMCIAUTILS_IPKG_TMP)/sbin/lspcmcia
	ln -sf pccardctl $(PCMCIAUTILS_IPKG_TMP)/sbin/lspcmcia
	rm -rf $(PCMCIAUTILS_IPKG_TMP)/usr/share/man
	mkdir -p $(PCMCIAUTILS_IPKG_TMP)/CONTROL
	echo "Package: pcmciautils" 							 >$(PCMCIAUTILS_IPKG_TMP)/CONTROL/control
	echo "Source: $(PCMCIAUTILS_URL)"						>>$(PCMCIAUTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PCMCIAUTILS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(PCMCIAUTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PCMCIAUTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PCMCIAUTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(PCMCIAUTILS_VERSION)-$(PCMCIAUTILS_VENDOR_VERSION)" 		>>$(PCMCIAUTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: sysfsutils" 							>>$(PCMCIAUTILS_IPKG_TMP)/CONTROL/control
	echo "Description: pcmcia utils"						>>$(PCMCIAUTILS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PCMCIAUTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PCMCIAUTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/pcmciautils.imageinstall
endif

pcmciautils_imageinstall_deps = $(STATEDIR)/pcmciautils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pcmciautils.imageinstall: $(pcmciautils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pcmciautils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pcmciautils_clean:
	rm -rf $(STATEDIR)/pcmciautils.*
	rm -rf $(PCMCIAUTILS_DIR)

# vim: syntax=make
