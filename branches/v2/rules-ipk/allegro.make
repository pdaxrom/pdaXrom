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
ifdef PTXCONF_ALLEGRO
PACKAGES += allegro
endif

#
# Paths and names
#
ALLEGRO_VENDOR_VERSION	= 1
ALLEGRO_VERSION		= 4.2.0
ALLEGRO			= allegro-$(ALLEGRO_VERSION)
ALLEGRO_SUFFIX		= tar.gz
ALLEGRO_URL		= http://citkit.dl.sourceforge.net/sourceforge/alleg/$(ALLEGRO).$(ALLEGRO_SUFFIX)
ALLEGRO_SOURCE		= $(SRCDIR)/$(ALLEGRO).$(ALLEGRO_SUFFIX)
ALLEGRO_DIR		= $(BUILDDIR)/$(ALLEGRO)
ALLEGRO_IPKG_TMP	= $(ALLEGRO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

allegro_get: $(STATEDIR)/allegro.get

allegro_get_deps = $(ALLEGRO_SOURCE)

$(STATEDIR)/allegro.get: $(allegro_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ALLEGRO))
	touch $@

$(ALLEGRO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ALLEGRO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

allegro_extract: $(STATEDIR)/allegro.extract

allegro_extract_deps = $(STATEDIR)/allegro.get

$(STATEDIR)/allegro.extract: $(allegro_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALLEGRO_DIR))
	@$(call extract, $(ALLEGRO_SOURCE))
	@$(call patchin, $(ALLEGRO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

allegro_prepare: $(STATEDIR)/allegro.prepare

#
# dependencies
#
allegro_prepare_deps = \
	$(STATEDIR)/allegro.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

ALLEGRO_PATH	=  PATH=$(CROSS_PATH)
ALLEGRO_ENV 	=  $(CROSS_ENV)
#ALLEGRO_ENV	+=
ALLEGRO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ALLEGRO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ALLEGRO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifndef PTXCONF_ARCH_X86
ALLEGRO_AUTOCONF += --disable-asm
endif

ifdef PTXCONF_ARCH_ARM
ALLEGRO_AUTOCONF += --enable-color8=no
ALLEGRO_AUTOCONF += --enable-color16=yes
ALLEGRO_AUTOCONF += --enable-color24=no
ALLEGRO_AUTOCONF += --enable-color32=no
endif

ifdef PTXCONF_XFREE430
ALLEGRO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ALLEGRO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/allegro.prepare: $(allegro_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALLEGRO_DIR)/config.cache)
	cd $(ALLEGRO_DIR) && \
		$(ALLEGRO_PATH) $(ALLEGRO_ENV) \
		./configure $(ALLEGRO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

allegro_compile: $(STATEDIR)/allegro.compile

allegro_compile_deps = $(STATEDIR)/allegro.prepare

$(STATEDIR)/allegro.compile: $(allegro_compile_deps)
	@$(call targetinfo, $@)
	$(ALLEGRO_PATH) $(MAKE) -C $(ALLEGRO_DIR) CROSSCOMPILE=1
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

allegro_install: $(STATEDIR)/allegro.install

$(STATEDIR)/allegro.install: $(STATEDIR)/allegro.compile
	@$(call targetinfo, $@)
	rm -rf $(ALLEGRO_IPKG_TMP)
	$(ALLEGRO_PATH) $(MAKE) -C $(ALLEGRO_DIR) DESTDIR=$(ALLEGRO_IPKG_TMP) install CROSSCOMPILE=1
	rm -rf $(ALLEGRO_IPKG_TMP)/usr/lib/allegro
	cp -a $(ALLEGRO_IPKG_TMP)/usr/bin/allegro-config	$(PTXCONF_PREFIX)/bin
	cp -a $(ALLEGRO_IPKG_TMP)/usr/include/*			$(CROSS_LIB_DIR)/include/
	cp -a $(ALLEGRO_IPKG_TMP)/usr/lib/*			$(CROSS_LIB_DIR)/lib/
	cp -a $(ALLEGRO_IPKG_TMP)/usr/share/*			$(PTXCONF_PREFIX)/share/
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" 		$(PTXCONF_PREFIX)/bin/allegro-config
	rm -rf $(ALLEGRO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

allegro_targetinstall: $(STATEDIR)/allegro.targetinstall

allegro_targetinstall_deps = $(STATEDIR)/allegro.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/allegro.targetinstall: $(allegro_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ALLEGRO_PATH) $(MAKE) -C $(ALLEGRO_DIR) DESTDIR=$(ALLEGRO_IPKG_TMP) install CROSSCOMPILE=1
	rm -rf $(ALLEGRO_IPKG_TMP)/usr/bin
	rm -rf $(ALLEGRO_IPKG_TMP)/usr/include
	rm -rf $(ALLEGRO_IPKG_TMP)/usr/share
	rm -rf $(ALLEGRO_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(ALLEGRO_IPKG_TMP)/usr/lib/*.so*
	$(CROSSSTRIP) $(ALLEGRO_IPKG_TMP)/usr/lib/allegro/4.2/*.so
	mkdir -p $(ALLEGRO_IPKG_TMP)/CONTROL
	echo "Package: allegro" 							 >$(ALLEGRO_IPKG_TMP)/CONTROL/control
	echo "Source: $(ALLEGRO_URL)"							>>$(ALLEGRO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ALLEGRO_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(ALLEGRO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ALLEGRO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ALLEGRO_IPKG_TMP)/CONTROL/control
	echo "Version: $(ALLEGRO_VERSION)-$(ALLEGRO_VENDOR_VERSION)" 			>>$(ALLEGRO_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree" 								>>$(ALLEGRO_IPKG_TMP)/CONTROL/control
	echo "Description: Allegro is a game programming library for C/C++"		>>$(ALLEGRO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ALLEGRO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ALLEGRO_INSTALL
ROMPACKAGES += $(STATEDIR)/allegro.imageinstall
endif

allegro_imageinstall_deps = $(STATEDIR)/allegro.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/allegro.imageinstall: $(allegro_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install allegro
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

allegro_clean:
	rm -rf $(STATEDIR)/allegro.*
	rm -rf $(ALLEGRO_DIR)

# vim: syntax=make
