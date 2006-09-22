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
ifdef PTXCONF_LINPHONE
PACKAGES += linphone
endif

#
# Paths and names
#
LINPHONE_VENDOR_VERSION	= 1
LINPHONE_VERSION	= 1.3.5
LINPHONE		= linphone-$(LINPHONE_VERSION)
LINPHONE_SUFFIX		= tar.gz
LINPHONE_URL		= http://download.savannah.nongnu.org/releases/linphone/1.3.x/source/$(LINPHONE).$(LINPHONE_SUFFIX)
LINPHONE_SOURCE		= $(SRCDIR)/$(LINPHONE).$(LINPHONE_SUFFIX)
LINPHONE_DIR		= $(BUILDDIR)/$(LINPHONE)
LINPHONE_IPKG_TMP	= $(LINPHONE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

linphone_get: $(STATEDIR)/linphone.get

linphone_get_deps = $(LINPHONE_SOURCE)

$(STATEDIR)/linphone.get: $(linphone_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LINPHONE))
	touch $@

$(LINPHONE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LINPHONE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

linphone_extract: $(STATEDIR)/linphone.extract

linphone_extract_deps = $(STATEDIR)/linphone.get

$(STATEDIR)/linphone.extract: $(linphone_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LINPHONE_DIR))
	@$(call extract, $(LINPHONE_SOURCE))
	@$(call patchin, $(LINPHONE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

linphone_prepare: $(STATEDIR)/linphone.prepare

#
# dependencies
#
linphone_prepare_deps = \
	$(STATEDIR)/linphone.extract \
	$(STATEDIR)/speex.install \
	$(STATEDIR)/libosip2.install \
	$(STATEDIR)/virtual-xchain.install

LINPHONE_PATH	=  PATH=$(CROSS_PATH)
LINPHONE_ENV 	=  $(CROSS_ENV)
#LINPHONE_ENV	+=
LINPHONE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LINPHONE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LINPHONE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--libexecdir=/usr/sbin \
	--enable-gnome_ui=yes

ifdef PTXCONF_XFREE430
LINPHONE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LINPHONE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/linphone.prepare: $(linphone_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LINPHONE_DIR)/config.cache)
	cd $(LINPHONE_DIR) && \
		$(LINPHONE_PATH) $(LINPHONE_ENV) \
		./configure $(LINPHONE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

linphone_compile: $(STATEDIR)/linphone.compile

linphone_compile_deps = $(STATEDIR)/linphone.prepare

$(STATEDIR)/linphone.compile: $(linphone_compile_deps)
	@$(call targetinfo, $@)
	$(LINPHONE_PATH) $(MAKE) -C $(LINPHONE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

linphone_install: $(STATEDIR)/linphone.install

$(STATEDIR)/linphone.install: $(STATEDIR)/linphone.compile
	@$(call targetinfo, $@)
	asdas
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

linphone_targetinstall: $(STATEDIR)/linphone.targetinstall

linphone_targetinstall_deps = $(STATEDIR)/linphone.compile \
	$(STATEDIR)/speex.targetinstall \
	$(STATEDIR)/libosip2.targetinstall

$(STATEDIR)/linphone.targetinstall: $(linphone_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LINPHONE_PATH) $(MAKE) -C $(LINPHONE_DIR) DESTDIR=$(LINPHONE_IPKG_TMP) install

	#rm -rf $(LINPHONE_IPKG_TMP)/usr/include
	#rm -rf $(LINPHONE_IPKG_TMP)/usr/man
	#rm -rf $(LINPHONE_IPKG_TMP)/usr/lib/pkgconfig
	#rm -rf $(LINPHONE_IPKG_TMP)/usr/share/gtk-doc
	#rm  -r $(LINPHONE_IPKG_TMP)/usr/lib/*.*a

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(LINPHONE_VERSION) 					\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh linphone $(LINPHONE_IPKG_TMP)
	
	@$(call removedevfiles, $(LINPHONE_IPKG_TMP))
	@$(call stripfiles,     $(LINPHONE_IPKG_TMP))

	#rm -rf $(LINPHONE_IPKG_TMP)/usr/share/locale
	#$(CROSSSTRIP) $(LINPHONE_IPKG_TMP)/usr/bin/*
	#$(CROSSSTRIP) $(LINPHONE_IPKG_TMP)/usr/sbin/*
	#$(CROSSSTRIP) $(LINPHONE_IPKG_TMP)/usr/lib/*.so*

	mkdir -p $(LINPHONE_IPKG_TMP)/CONTROL
	echo "Package: linphone" 							 >$(LINPHONE_IPKG_TMP)/CONTROL/control
	echo "Source: $(LINPHONE_URL)"							>>$(LINPHONE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LINPHONE_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(LINPHONE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LINPHONE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LINPHONE_IPKG_TMP)/CONTROL/control
	echo "Version: $(LINPHONE_VERSION)-$(LINPHONE_VENDOR_VERSION)" 			>>$(LINPHONE_IPKG_TMP)/CONTROL/control
	echo "Depends: glib2, libspeex, libosip2, readline, libgnomeui" 		>>$(LINPHONE_IPKG_TMP)/CONTROL/control
	echo "Description: Linphone is a web phone - it let you phone to your friends anywhere in the whole world, freely, simply by using the internet." >>$(LINPHONE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LINPHONE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LINPHONE_INSTALL
ROMPACKAGES += $(STATEDIR)/linphone.imageinstall
endif

linphone_imageinstall_deps = $(STATEDIR)/linphone.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/linphone.imageinstall: $(linphone_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install linphone
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

linphone_clean:
	rm -rf $(STATEDIR)/linphone.*
	rm -rf $(LINPHONE_DIR)

# vim: syntax=make
