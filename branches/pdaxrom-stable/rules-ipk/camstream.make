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
ifdef PTXCONF_CAMSTREAM
PACKAGES += camstream
endif

#
# Paths and names
#
CAMSTREAM_VENDOR_VERSION	= 1
CAMSTREAM_VERSION		= 0.26.3
CAMSTREAM			= camstream-$(CAMSTREAM_VERSION)
CAMSTREAM_SUFFIX		= tar.gz
CAMSTREAM_URL			= http://www.smcc.demon.nl/camstream/download/$(CAMSTREAM).$(CAMSTREAM_SUFFIX)
CAMSTREAM_SOURCE		= $(SRCDIR)/$(CAMSTREAM).$(CAMSTREAM_SUFFIX)
CAMSTREAM_DIR			= $(BUILDDIR)/$(CAMSTREAM)
CAMSTREAM_IPKG_TMP		= $(CAMSTREAM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

camstream_get: $(STATEDIR)/camstream.get

camstream_get_deps = $(CAMSTREAM_SOURCE)

$(STATEDIR)/camstream.get: $(camstream_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CAMSTREAM))
	touch $@

$(CAMSTREAM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CAMSTREAM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

camstream_extract: $(STATEDIR)/camstream.extract

camstream_extract_deps = $(STATEDIR)/camstream.get

$(STATEDIR)/camstream.extract: $(camstream_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CAMSTREAM_DIR))
	@$(call extract, $(CAMSTREAM_SOURCE))
	@$(call patchin, $(CAMSTREAM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

camstream_prepare: $(STATEDIR)/camstream.prepare

#
# dependencies
#
camstream_prepare_deps = \
	$(STATEDIR)/camstream.extract \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/virtual-xchain.install

CAMSTREAM_PATH	=  PATH=$(CROSS_PATH)
CAMSTREAM_ENV 	=  $(CROSS_ENV)
CAMSTREAM_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
CAMSTREAM_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
CAMSTREAM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
CAMSTREAM_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
#ifdef PTXCONF_XFREE430
#CAMSTREAM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
CAMSTREAM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
CAMSTREAM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CAMSTREAM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/camstream.prepare: $(camstream_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CAMSTREAM_DIR)/config.cache)
	#cd $(CAMSTREAM_DIR) && $(CAMSTREAM_PATH) aclocal
	#cd $(CAMSTREAM_DIR) && $(CAMSTREAM_PATH) automake --add-missing
	cd $(CAMSTREAM_DIR) && $(CAMSTREAM_PATH) autoconf
	#cd $(CAMSTREAM_DIR)/camstream && $(CAMSTREAM_PATH) aclocal
	#cd $(CAMSTREAM_DIR)/camstream && $(CAMSTREAM_PATH) automake --add-missing
	cd $(CAMSTREAM_DIR)/camstream && $(CAMSTREAM_PATH) autoconf
	#cd $(CAMSTREAM_DIR)/lib/ccvt && $(CAMSTREAM_PATH) aclocal
	#cd $(CAMSTREAM_DIR)/lib/ccvt && $(CAMSTREAM_PATH) automake --add-missing
	cd $(CAMSTREAM_DIR)/lib/ccvt && $(CAMSTREAM_PATH) autoconf
	cd $(CAMSTREAM_DIR) && \
		$(CAMSTREAM_PATH) $(CAMSTREAM_ENV) \
		./configure $(CAMSTREAM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

camstream_compile: $(STATEDIR)/camstream.compile

camstream_compile_deps = $(STATEDIR)/camstream.prepare

$(STATEDIR)/camstream.compile: $(camstream_compile_deps)
	@$(call targetinfo, $@)
	$(CAMSTREAM_PATH) $(CAMSTREAM_ENV) $(MAKE) -C $(CAMSTREAM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

camstream_install: $(STATEDIR)/camstream.install

$(STATEDIR)/camstream.install: $(STATEDIR)/camstream.compile
	@$(call targetinfo, $@)
	$(CAMSTREAM_PATH) $(MAKE) -C $(CAMSTREAM_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

camstream_targetinstall: $(STATEDIR)/camstream.targetinstall

camstream_targetinstall_deps = $(STATEDIR)/camstream.compile \
	$(STATEDIR)/qt-x11-free.targetinstall

$(STATEDIR)/camstream.targetinstall: $(camstream_targetinstall_deps)
	@$(call targetinfo, $@)
	$(CAMSTREAM_PATH) $(MAKE) -C $(CAMSTREAM_DIR) DESTDIR=$(CAMSTREAM_IPKG_TMP) install
	mkdir -p $(CAMSTREAM_IPKG_TMP)/CONTROL
	echo "Package: camstream" 							 >$(CAMSTREAM_IPKG_TMP)/CONTROL/control
	echo "Source: $(CAMSTREAM_URL)"							>>$(CAMSTREAM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(CAMSTREAM_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(CAMSTREAM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(CAMSTREAM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(CAMSTREAM_IPKG_TMP)/CONTROL/control
	echo "Version: $(CAMSTREAM_VERSION)-$(CAMSTREAM_VENDOR_VERSION)" 		>>$(CAMSTREAM_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt" 								>>$(CAMSTREAM_IPKG_TMP)/CONTROL/control
	echo "Description: CamStream is (going to be) a collection of tools for webcams and other video-devices, enhancing your Linux system with multimedia video.">>$(CAMSTREAM_IPKG_TMP)/CONTROL/control
	asasdasd
	@$(call makeipkg, $(CAMSTREAM_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CAMSTREAM_INSTALL
ROMPACKAGES += $(STATEDIR)/camstream.imageinstall
endif

camstream_imageinstall_deps = $(STATEDIR)/camstream.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/camstream.imageinstall: $(camstream_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install camstream
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

camstream_clean:
	rm -rf $(STATEDIR)/camstream.*
	rm -rf $(CAMSTREAM_DIR)

# vim: syntax=make
