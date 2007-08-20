# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_WIN32CODECS
PACKAGES += win32codecs
endif

#
# Paths and names
#
WIN32CODECS_VENDOR_VERSION	= 1
WIN32CODECS_VERSION		= 20061022
WIN32CODECS			= essential-$(WIN32CODECS_VERSION)
WIN32CODECS_SUFFIX		= tar.bz2
WIN32CODECS_URL			= http://www1.mplayerhq.hu/MPlayer/releases/codecs/$(WIN32CODECS).$(WIN32CODECS_SUFFIX)
WIN32CODECS_SOURCE		= $(SRCDIR)/$(WIN32CODECS).$(WIN32CODECS_SUFFIX)
WIN32CODECS_DIR			= $(BUILDDIR)/win32codecs
WIN32CODECS_IPKG_TMP		= $(BUILDDIR)/win32codecs/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

win32codecs_get: $(STATEDIR)/win32codecs.get

win32codecs_get_deps = $(WIN32CODECS_SOURCE)

$(STATEDIR)/win32codecs.get: $(win32codecs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(WIN32CODECS))
	touch $@

$(WIN32CODECS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WIN32CODECS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

win32codecs_extract: $(STATEDIR)/win32codecs.extract

win32codecs_extract_deps = $(STATEDIR)/win32codecs.get

$(STATEDIR)/win32codecs.extract: $(win32codecs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(WIN32CODECS_DIR))
	@$(call extract, $(WIN32CODECS_SOURCE), $(WIN32CODECS_DIR))
	@$(call patchin, $(WIN32CODECS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

win32codecs_prepare: $(STATEDIR)/win32codecs.prepare

#
# dependencies
#
win32codecs_prepare_deps = \
	$(STATEDIR)/win32codecs.extract \
	$(STATEDIR)/virtual-xchain.install

WIN32CODECS_PATH	=  PATH=$(CROSS_PATH)
WIN32CODECS_ENV 	=  $(CROSS_ENV)
#WIN32CODECS_ENV	+=
WIN32CODECS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#WIN32CODECS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
WIN32CODECS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
WIN32CODECS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
WIN32CODECS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/win32codecs.prepare: $(win32codecs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WIN32CODECS_DIR)/config.cache)
	#cd $(WIN32CODECS_DIR) && \
	#	$(WIN32CODECS_PATH) $(WIN32CODECS_ENV) \
	#	./configure $(WIN32CODECS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

win32codecs_compile: $(STATEDIR)/win32codecs.compile

win32codecs_compile_deps = $(STATEDIR)/win32codecs.prepare

$(STATEDIR)/win32codecs.compile: $(win32codecs_compile_deps)
	@$(call targetinfo, $@)
	#$(WIN32CODECS_PATH) $(MAKE) -C $(WIN32CODECS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

win32codecs_install: $(STATEDIR)/win32codecs.install

$(STATEDIR)/win32codecs.install: $(STATEDIR)/win32codecs.compile
	@$(call targetinfo, $@)
	#rm -rf $(WIN32CODECS_IPKG_TMP)
	#$(WIN32CODECS_PATH) $(MAKE) -C $(WIN32CODECS_DIR) DESTDIR=$(WIN32CODECS_IPKG_TMP) install
	#@$(call copyincludes, $(WIN32CODECS_IPKG_TMP))
	#@$(call copylibraries,$(WIN32CODECS_IPKG_TMP))
	#@$(call copymiscfiles,$(WIN32CODECS_IPKG_TMP))
	#rm -rf $(WIN32CODECS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

win32codecs_targetinstall: $(STATEDIR)/win32codecs.targetinstall

win32codecs_targetinstall_deps = $(STATEDIR)/win32codecs.compile

WIN32CODECS_DEPLIST = 

$(STATEDIR)/win32codecs.targetinstall: $(win32codecs_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(WIN32CODECS_IPKG_TMP)/usr/lib/codecs
	cp -a $(WIN32CODECS_DIR)/$(WIN32CODECS)/* $(WIN32CODECS_IPKG_TMP)/usr/lib/codecs/
	mkdir -p $(WIN32CODECS_IPKG_TMP)/CONTROL
	echo "Package: win32codecs" 							 >$(WIN32CODECS_IPKG_TMP)/CONTROL/control
	echo "Source: $(WIN32CODECS_URL)"						>>$(WIN32CODECS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(WIN32CODECS_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(WIN32CODECS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(WIN32CODECS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(WIN32CODECS_IPKG_TMP)/CONTROL/control
	echo "Version: $(WIN32CODECS_VERSION)-$(WIN32CODECS_VENDOR_VERSION)" 		>>$(WIN32CODECS_IPKG_TMP)/CONTROL/control
	echo "Depends: $(WIN32CODECS_DEPLIST)" 						>>$(WIN32CODECS_IPKG_TMP)/CONTROL/control
	echo "Description: win32 codecs pack"						>>$(WIN32CODECS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(WIN32CODECS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WIN32CODECS_INSTALL
ROMPACKAGES += $(STATEDIR)/win32codecs.imageinstall
endif

win32codecs_imageinstall_deps = $(STATEDIR)/win32codecs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/win32codecs.imageinstall: $(win32codecs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install win32codecs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

win32codecs_clean:
	rm -rf $(STATEDIR)/win32codecs.*
	rm -rf $(WIN32CODECS_DIR)
	rm -rf $(WIN32CODECS_IPKG_TMP)

# vim: syntax=make
