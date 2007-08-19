# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Adrian Cruchfield
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_TERMINAL
PACKAGES += Terminal
endif

#
# Paths and names
#
TERMINAL_VENDOR_VERSION	= 1
TERMINAL_VERSION	= 0.2.6
TERMINAL		= Terminal-$(TERMINAL_VERSION)
TERMINAL_SUFFIX		= tar.bz2
TERMINAL_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(TERMINAL).$(TERMINAL_SUFFIX)
TERMINAL_SOURCE		= $(SRCDIR)/$(TERMINAL).$(TERMINAL_SUFFIX)
TERMINAL_DIR		= $(BUILDDIR)/$(TERMINAL)
TERMINAL_IPKG_TMP	= $(TERMINAL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

Terminal_get: $(STATEDIR)/Terminal.get

Terminal_get_deps = $(TERMINAL_SOURCE)

$(STATEDIR)/Terminal.get: $(Terminal_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TERMINAL))
	touch $@

$(TERMINAL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TERMINAL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

Terminal_extract: $(STATEDIR)/Terminal.extract

Terminal_extract_deps = $(STATEDIR)/Terminal.get

$(STATEDIR)/Terminal.extract: $(Terminal_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TERMINAL_DIR))
	@$(call extract, $(TERMINAL_SOURCE))
	@$(call patchin, $(TERMINAL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

Terminal_prepare: $(STATEDIR)/Terminal.prepare

#
# dependencies
#
Terminal_prepare_deps = \
	$(STATEDIR)/Terminal.extract \
	$(STATEDIR)/virtual-xchain.install

TERMINAL_PATH	=  PATH=$(CROSS_PATH)
TERMINAL_ENV 	=  $(CROSS_ENV)
#TERMINAL_ENV	+=
TERMINAL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TERMINAL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
TERMINAL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
TERMINAL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TERMINAL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/Terminal.prepare: $(Terminal_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TERMINAL_DIR)/config.cache)
	cd $(TERMINAL_DIR) && \
		$(TERMINAL_PATH) $(TERMINAL_ENV) \
		./configure $(TERMINAL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

Terminal_compile: $(STATEDIR)/Terminal.compile

Terminal_compile_deps = $(STATEDIR)/Terminal.prepare

$(STATEDIR)/Terminal.compile: $(Terminal_compile_deps)
	@$(call targetinfo, $@)
	$(TERMINAL_PATH) $(MAKE) -C $(TERMINAL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

Terminal_install: $(STATEDIR)/Terminal.install

$(STATEDIR)/Terminal.install: $(STATEDIR)/Terminal.compile
	@$(call targetinfo, $@)
	rm -rf $(TERMINAL_IPKG_TMP)
	$(TERMINAL_PATH) $(MAKE) -C $(TERMINAL_DIR) DESTDIR=$(TERMINAL_IPKG_TMP) install
	@$(call copyincludes, $(TERMINAL_IPKG_TMP))
	@$(call copylibraries,$(TERMINAL_IPKG_TMP))
	@$(call copymiscfiles,$(TERMINAL_IPKG_TMP))
	rm -rf $(TERMINAL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

Terminal_targetinstall: $(STATEDIR)/Terminal.targetinstall

Terminal_targetinstall_deps = $(STATEDIR)/Terminal.compile

TERMINAL_DEPLIST = 

$(STATEDIR)/Terminal.targetinstall: $(Terminal_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TERMINAL_PATH) $(MAKE) -C $(TERMINAL_DIR) DESTDIR=$(TERMINAL_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(TERMINAL_VERSION)-$(TERMINAL_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh terminal $(TERMINAL_IPKG_TMP)

	@$(call removedevfiles, $(TERMINAL_IPKG_TMP))
	@$(call stripfiles, $(TERMINAL_IPKG_TMP))
	mkdir -p $(TERMINAL_IPKG_TMP)/CONTROL
	echo "Package: terminal" 							 >$(TERMINAL_IPKG_TMP)/CONTROL/control
	echo "Source: $(TERMINAL_URL)"							>>$(TERMINAL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(TERMINAL_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(TERMINAL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Cruchfield" 							>>$(TERMINAL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(TERMINAL_IPKG_TMP)/CONTROL/control
	echo "Version: $(TERMINAL_VERSION)-$(TERMINAL_VENDOR_VERSION)" 			>>$(TERMINAL_IPKG_TMP)/CONTROL/control
	echo "Depends: $(TERMINAL_DEPLIST)" 						>>$(TERMINAL_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(TERMINAL_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(TERMINAL_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TERMINAL_INSTALL
ROMPACKAGES += $(STATEDIR)/Terminal.imageinstall
endif

Terminal_imageinstall_deps = $(STATEDIR)/Terminal.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/Terminal.imageinstall: $(Terminal_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install terminal
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

Terminal_clean:
	rm -rf $(STATEDIR)/Terminal.*
	rm -rf $(TERMINAL_DIR)

# vim: syntax=make
