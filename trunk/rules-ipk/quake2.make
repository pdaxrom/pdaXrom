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
ifdef PTXCONF_QUAKE2
PACKAGES += quake2
endif

#
# Paths and names
#
QUAKE2_VENDOR_VERSION	= 1
QUAKE2_VERSION		= r0.16.1
QUAKE2			= quake2-$(QUAKE2_VERSION)
QUAKE2_SUFFIX		= tar.gz
QUAKE2_URL		= http://www.pdaXrom.org/src/$(QUAKE2).$(QUAKE2_SUFFIX)
QUAKE2_SOURCE		= $(SRCDIR)/$(QUAKE2).$(QUAKE2_SUFFIX)
QUAKE2_DIR		= $(BUILDDIR)/$(QUAKE2)
QUAKE2_IPKG_TMP	= $(QUAKE2_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

quake2_get: $(STATEDIR)/quake2.get

quake2_get_deps = $(QUAKE2_SOURCE)

$(STATEDIR)/quake2.get: $(quake2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QUAKE2))
	touch $@

$(QUAKE2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QUAKE2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

quake2_extract: $(STATEDIR)/quake2.extract

quake2_extract_deps = $(STATEDIR)/quake2.get

$(STATEDIR)/quake2.extract: $(quake2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QUAKE2_DIR))
	@$(call extract, $(QUAKE2_SOURCE))
	@$(call patchin, $(QUAKE2))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

quake2_prepare: $(STATEDIR)/quake2.prepare

#
# dependencies
#
quake2_prepare_deps = \
	$(STATEDIR)/quake2.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/virtual-xchain.install

QUAKE2_PATH	=  PATH=$(CROSS_PATH)
QUAKE2_ENV 	=  $(CROSS_ENV)
#QUAKE2_ENV	+=
QUAKE2_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#QUAKE2_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
QUAKE2_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
QUAKE2_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
QUAKE2_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

ifdef PTXCONF_QUAKE2_IWMMXT
QUAKE2_TUNE=iwmmxt
else
QUAKE2_TUNE=
endif

$(STATEDIR)/quake2.prepare: $(quake2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QUAKE2_DIR)/config.cache)
	#cd $(QUAKE2_DIR) && \
	#	$(QUAKE2_PATH) $(QUAKE2_ENV) \
	#	./configure $(QUAKE2_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

quake2_compile: $(STATEDIR)/quake2.compile

quake2_compile_deps = $(STATEDIR)/quake2.prepare

$(STATEDIR)/quake2.compile: $(quake2_compile_deps)
	@$(call targetinfo, $@)
	$(QUAKE2_PATH) $(MAKE) -C $(QUAKE2_DIR) ARCH=$(PTXCONF_ARCH_USERSPACE) TUNE=$(QUAKE2_TUNE) $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

quake2_install: $(STATEDIR)/quake2.install

$(STATEDIR)/quake2.install: $(STATEDIR)/quake2.compile
	@$(call targetinfo, $@)
	#$(QUAKE2_PATH) $(MAKE) -C $(QUAKE2_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

quake2_targetinstall: $(STATEDIR)/quake2.targetinstall

quake2_targetinstall_deps = $(STATEDIR)/quake2.compile \
	$(STATEDIR)/SDL.targetinstall

$(STATEDIR)/quake2.targetinstall: $(quake2_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(QUAKE2_PATH) $(MAKE) -C $(QUAKE2_DIR) DESTDIR=$(QUAKE2_IPKG_TMP) install
	mkdir -p $(QUAKE2_IPKG_TMP)/usr/share/quake2/baseq2
	mkdir -p $(QUAKE2_IPKG_TMP)/usr/share/quake2/ctf
	mkdir -p $(QUAKE2_IPKG_TMP)/usr/bin
	cp -a $(QUAKE2_DIR)/release$(PTXCONF_ARCH_USERSPACE)/quake2 		$(QUAKE2_IPKG_TMP)/usr/share/quake2/
	cp -a $(QUAKE2_DIR)/release$(PTXCONF_ARCH_USERSPACE)/ref_softsdl.so	$(QUAKE2_IPKG_TMP)/usr/share/quake2/
	cp -a $(QUAKE2_DIR)/release$(PTXCONF_ARCH_USERSPACE)/sdlquake2		$(QUAKE2_IPKG_TMP)/usr/share/quake2/
	cp -a $(QUAKE2_DIR)/release$(PTXCONF_ARCH_USERSPACE)/gamearm.so		$(QUAKE2_IPKG_TMP)/usr/share/quake2/baseq2/
	cp -a $(QUAKE2_DIR)/release$(PTXCONF_ARCH_USERSPACE)/ctf/gamearm.so	$(QUAKE2_IPKG_TMP)/usr/share/quake2/ctf/
	$(CROSSSTRIP) $(QUAKE2_IPKG_TMP)/usr/share/quake2/{quake2,ref_softsdl.so,sdlquake2}
	$(CROSSSTRIP) $(QUAKE2_IPKG_TMP)/usr/share/quake2/baseq2/gamearm.so
	$(CROSSSTRIP) $(QUAKE2_IPKG_TMP)/usr/share/quake2/ctf/gamearm.so
	ln -sf ref_softsdl.so $(QUAKE2_IPKG_TMP)/usr/share/quake2/ref_soft.so
	ln -sf ref_softsdl.so $(QUAKE2_IPKG_TMP)/usr/share/quake2/ref_softx.so
	mkdir -p $(QUAKE2_IPKG_TMP)/CONTROL
	echo "Package: quake2" 								 >$(QUAKE2_IPKG_TMP)/CONTROL/control
	echo "Source: $(QUAKE2_URL)"						>>$(QUAKE2_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(QUAKE2_IPKG_TMP)/CONTROL/control
	echo "Section: Games"	 							>>$(QUAKE2_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(QUAKE2_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(QUAKE2_IPKG_TMP)/CONTROL/control
	echo "Version: $(QUAKE2_VERSION)-$(QUAKE2_VENDOR_VERSION)" 			>>$(QUAKE2_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl" 								>>$(QUAKE2_IPKG_TMP)/CONTROL/control
	echo "Description: QUAKE 2"							>>$(QUAKE2_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh"			 > $(QUAKE2_IPKG_TMP)/usr/bin/quake2
	echo "cd /usr/share/quake2"		>> $(QUAKE2_IPKG_TMP)/usr/bin/quake2
	echo "./quake2"				>> $(QUAKE2_IPKG_TMP)/usr/bin/quake2
	chmod 755 $(QUAKE2_IPKG_TMP)/usr/bin/quake2
	cd $(FEEDDIR) && $(XMKIPKG) $(QUAKE2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QUAKE2_INSTALL
ROMPACKAGES += $(STATEDIR)/quake2.imageinstall
endif

quake2_imageinstall_deps = $(STATEDIR)/quake2.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/quake2.imageinstall: $(quake2_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install quake2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

quake2_clean:
	rm -rf $(STATEDIR)/quake2.*
	rm -rf $(QUAKE2_DIR)

# vim: syntax=make
