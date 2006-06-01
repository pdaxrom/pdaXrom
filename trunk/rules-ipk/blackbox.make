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
ifdef PTXCONF_BLACKBOX
PACKAGES += blackbox
endif

#
# Paths and names
#
BLACKBOX_VENDOR_VERSION	= 1
BLACKBOX_VERSION	= 0.70.0
BLACKBOX		= blackbox-$(BLACKBOX_VERSION)
BLACKBOX_SUFFIX		= tar.bz2
BLACKBOX_URL		= http://optusnet.dl.sourceforge.net/sourceforge/blackboxwm/$(BLACKBOX).$(BLACKBOX_SUFFIX)
BLACKBOX_SOURCE		= $(SRCDIR)/$(BLACKBOX).$(BLACKBOX_SUFFIX)
BLACKBOX_DIR		= $(BUILDDIR)/$(BLACKBOX)
BLACKBOX_IPKG_TMP	= $(BLACKBOX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

blackbox_get: $(STATEDIR)/blackbox.get

blackbox_get_deps = $(BLACKBOX_SOURCE)

$(STATEDIR)/blackbox.get: $(blackbox_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BLACKBOX))
	touch $@

$(BLACKBOX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BLACKBOX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

blackbox_extract: $(STATEDIR)/blackbox.extract

blackbox_extract_deps = $(STATEDIR)/blackbox.get

$(STATEDIR)/blackbox.extract: $(blackbox_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BLACKBOX_DIR))
	@$(call extract, $(BLACKBOX_SOURCE))
	@$(call patchin, $(BLACKBOX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

blackbox_prepare: $(STATEDIR)/blackbox.prepare

#
# dependencies
#
blackbox_prepare_deps = \
	$(STATEDIR)/blackbox.extract \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
blackbox_prepare_deps += $(STATEDIR)/libiconv.install
endif

BLACKBOX_PATH	=  PATH=$(CROSS_PATH)
BLACKBOX_ENV 	=  $(CROSS_ENV)
BLACKBOX_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
BLACKBOX_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
BLACKBOX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BLACKBOX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
BLACKBOX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--enable-shape \
	--enable-mitshm \
	--enable-xft \
	--enable-shared \
	--disable-static

##	--disable-nls

ifdef PTXCONF_XFREE430
BLACKBOX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BLACKBOX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/blackbox.prepare: $(blackbox_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BLACKBOX_DIR)/config.cache)
	cd $(BLACKBOX_DIR) && $(BLACKBOX_PATH) aclocal
	cd $(BLACKBOX_DIR) && $(BLACKBOX_PATH) automake --add-missing
	cd $(BLACKBOX_DIR) && $(BLACKBOX_PATH) autoconf
	####cd $(BLACKBOX_DIR) && $(BLACKBOX_PATH) ./mk.sh
	@$(call clean, $(BLACKBOX_DIR)/config.cache)
	cd $(BLACKBOX_DIR) && \
		$(BLACKBOX_PATH) $(BLACKBOX_ENV) \
		./configure $(BLACKBOX_AUTOCONF)
	cp -a $(PTXCONF_PREFIX)/bin/libtool $(BLACKBOX_DIR)/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

blackbox_compile: $(STATEDIR)/blackbox.compile

blackbox_compile_deps = $(STATEDIR)/blackbox.prepare

$(STATEDIR)/blackbox.compile: $(blackbox_compile_deps)
	@$(call targetinfo, $@)
	$(BLACKBOX_PATH) $(MAKE) -C $(BLACKBOX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

blackbox_install: $(STATEDIR)/blackbox.install

$(STATEDIR)/blackbox.install: $(STATEDIR)/blackbox.compile
	@$(call targetinfo, $@)
	$(BLACKBOX_PATH) $(MAKE) -C $(BLACKBOX_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

blackbox_targetinstall: $(STATEDIR)/blackbox.targetinstall

blackbox_targetinstall_deps = $(STATEDIR)/blackbox.compile \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/zlib.targetinstall

ifdef PTXCONF_LIBICONV
blackbox_targetinstall_deps += $(STATEDIR)/libiconv.targetinstall
endif

$(STATEDIR)/blackbox.targetinstall: $(blackbox_targetinstall_deps)
	@$(call targetinfo, $@)
	$(BLACKBOX_PATH) $(MAKE) -C $(BLACKBOX_DIR) DESTDIR=$(BLACKBOX_IPKG_TMP) install
	rm -rf $(BLACKBOX_IPKG_TMP)/usr/include
	rm -rf $(BLACKBOX_IPKG_TMP)/usr/lib/pkgconfig
	rm  -f $(BLACKBOX_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(BLACKBOX_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(BLACKBOX_IPKG_TMP)/usr/bin/{blackbox,bsetroot,bstyleconvert}
	$(CROSSSTRIP) $(BLACKBOX_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(BLACKBOX_IPKG_TMP)/CONTROL
	echo "Package: blackbox" 										 >$(BLACKBOX_IPKG_TMP)/CONTROL/control
	echo "Source: $(BLACKBOX_URL)"										>>$(BLACKBOX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(BLACKBOX_IPKG_TMP)/CONTROL/control
	echo "Section: X11"				 							>>$(BLACKBOX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(BLACKBOX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(BLACKBOX_IPKG_TMP)/CONTROL/control
	echo "Version: $(BLACKBOX_VERSION)-$(BLACKBOX_VENDOR_VERSION)" 						>>$(BLACKBOX_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_LIBICONV
	echo "Depends: xfree, libiconv, libz" 								>>$(BLACKBOX_IPKG_TMP)/CONTROL/control
else
	echo "Depends: xfree, libz" 										>>$(BLACKBOX_IPKG_TMP)/CONTROL/control
endif
	echo "Description: BlackBox window manager"								>>$(BLACKBOX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BLACKBOX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BLACKBOX_INSTALL
ROMPACKAGES += $(STATEDIR)/blackbox.imageinstall
endif

blackbox_imageinstall_deps = $(STATEDIR)/blackbox.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/blackbox.imageinstall: $(blackbox_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install blackbox
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

blackbox_clean:
	rm -rf $(STATEDIR)/blackbox.*
	rm -rf $(BLACKBOX_DIR)

# vim: syntax=make
