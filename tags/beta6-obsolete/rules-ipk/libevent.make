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
ifdef PTXCONF_LIBEVENT
PACKAGES += libevent
endif

#
# Paths and names
#
LIBEVENT_VENDOR_VERSION	= 1
LIBEVENT_VERSION	= 1.1a
LIBEVENT		= libevent-$(LIBEVENT_VERSION)
LIBEVENT_SUFFIX		= tar.gz
LIBEVENT_URL		= http://www.monkey.org/~provos/$(LIBEVENT).$(LIBEVENT_SUFFIX)
LIBEVENT_SOURCE		= $(SRCDIR)/$(LIBEVENT).$(LIBEVENT_SUFFIX)
LIBEVENT_DIR		= $(BUILDDIR)/$(LIBEVENT)
LIBEVENT_IPKG_TMP	= $(LIBEVENT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libevent_get: $(STATEDIR)/libevent.get

libevent_get_deps = $(LIBEVENT_SOURCE)

$(STATEDIR)/libevent.get: $(libevent_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBEVENT))
	touch $@

$(LIBEVENT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBEVENT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libevent_extract: $(STATEDIR)/libevent.extract

libevent_extract_deps = $(STATEDIR)/libevent.get

$(STATEDIR)/libevent.extract: $(libevent_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBEVENT_DIR))
	@$(call extract, $(LIBEVENT_SOURCE))
	@$(call patchin, $(LIBEVENT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libevent_prepare: $(STATEDIR)/libevent.prepare

#
# dependencies
#
libevent_prepare_deps = \
	$(STATEDIR)/libevent.extract \
	$(STATEDIR)/virtual-xchain.install

LIBEVENT_PATH	=  PATH=$(CROSS_PATH)
LIBEVENT_ENV 	=  $(CROSS_ENV)
#LIBEVENT_ENV	+=
LIBEVENT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBEVENT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBEVENT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
LIBEVENT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBEVENT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libevent.prepare: $(libevent_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBEVENT_DIR)/config.cache)
	cd $(LIBEVENT_DIR) && \
		$(LIBEVENT_PATH) $(LIBEVENT_ENV) \
		./configure $(LIBEVENT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libevent_compile: $(STATEDIR)/libevent.compile

libevent_compile_deps = $(STATEDIR)/libevent.prepare

$(STATEDIR)/libevent.compile: $(libevent_compile_deps)
	@$(call targetinfo, $@)
	$(LIBEVENT_PATH) $(MAKE) -C $(LIBEVENT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libevent_install: $(STATEDIR)/libevent.install

$(STATEDIR)/libevent.install: $(STATEDIR)/libevent.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBEVENT_IPKG_TMP)
	$(LIBEVENT_PATH) $(MAKE) -C $(LIBEVENT_DIR) DESTDIR=$(LIBEVENT_IPKG_TMP) install

	cp -a $(LIBEVENT_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(LIBEVENT_IPKG_TMP)/usr/lib/*		$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libevent.la

	rm -rf $(LIBEVENT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libevent_targetinstall: $(STATEDIR)/libevent.targetinstall

libevent_targetinstall_deps = $(STATEDIR)/libevent.compile

$(STATEDIR)/libevent.targetinstall: $(libevent_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBEVENT_PATH) $(MAKE) -C $(LIBEVENT_DIR) DESTDIR=$(LIBEVENT_IPKG_TMP) install
	rm -rf $(LIBEVENT_IPKG_TMP)/usr/include
	rm -f  $(LIBEVENT_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBEVENT_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(LIBEVENT_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(LIBEVENT_IPKG_TMP)/CONTROL
	echo "Package: libevent" 							 >$(LIBEVENT_IPKG_TMP)/CONTROL/control
	echo "Source: $(LIBEVENT_URL)"							>>$(LIBEVENT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBEVENT_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LIBEVENT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBEVENT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBEVENT_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBEVENT_VERSION)-$(LIBEVENT_VENDOR_VERSION)" 			>>$(LIBEVENT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LIBEVENT_IPKG_TMP)/CONTROL/control
	echo "Description: The libevent API provides a mechanism to execute a callback function when a specific event occurs on a file descriptor or after a timeout has been reached."	>>$(LIBEVENT_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LIBEVENT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBEVENT_INSTALL
ROMPACKAGES += $(STATEDIR)/libevent.imageinstall
endif

libevent_imageinstall_deps = $(STATEDIR)/libevent.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libevent.imageinstall: $(libevent_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libevent
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libevent_clean:
	rm -rf $(STATEDIR)/libevent.*
	rm -rf $(LIBEVENT_DIR)

# vim: syntax=make
