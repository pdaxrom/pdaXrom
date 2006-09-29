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
ifdef PTXCONF_SCREEN
PACKAGES += screen
endif

#
# Paths and names
#
SCREEN_VENDOR_VERSION	= 1
SCREEN_VERSION		= 4.0.2
SCREEN			= screen-$(SCREEN_VERSION)
SCREEN_SUFFIX		= tar.gz
SCREEN_URL		= ftp://ftp.gnu.org/gnu/screen/$(SCREEN).$(SCREEN_SUFFIX)
SCREEN_SOURCE		= $(SRCDIR)/$(SCREEN).$(SCREEN_SUFFIX)
SCREEN_DIR		= $(BUILDDIR)/$(SCREEN)
SCREEN_IPKG_TMP		= $(SCREEN_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

screen_get: $(STATEDIR)/screen.get

screen_get_deps = $(SCREEN_SOURCE)

$(STATEDIR)/screen.get: $(screen_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SCREEN))
	touch $@

$(SCREEN_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SCREEN_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

screen_extract: $(STATEDIR)/screen.extract

screen_extract_deps = $(STATEDIR)/screen.get

$(STATEDIR)/screen.extract: $(screen_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCREEN_DIR))
	@$(call extract, $(SCREEN_SOURCE))
	@$(call patchin, $(SCREEN))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

screen_prepare: $(STATEDIR)/screen.prepare

#
# dependencies
#
screen_prepare_deps = \
	$(STATEDIR)/screen.extract \
	$(STATEDIR)/virtual-xchain.install

SCREEN_PATH	=  PATH=$(CROSS_PATH)
SCREEN_ENV 	=  $(CROSS_ENV)
#SCREEN_ENV	+=
SCREEN_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SCREEN_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SCREEN_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--with-sys-screenrc=/etc

ifdef PTXCONF_XFREE430
SCREEN_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SCREEN_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/screen.prepare: $(screen_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCREEN_DIR)/config.cache)
	cd $(SCREEN_DIR) && \
		$(SCREEN_PATH) $(SCREEN_ENV) \
		./configure $(SCREEN_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

screen_compile: $(STATEDIR)/screen.compile

screen_compile_deps = $(STATEDIR)/screen.prepare

$(STATEDIR)/screen.compile: $(screen_compile_deps)
	@$(call targetinfo, $@)
	$(SCREEN_PATH) $(MAKE) -C $(SCREEN_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

screen_install: $(STATEDIR)/screen.install

$(STATEDIR)/screen.install: $(STATEDIR)/screen.compile
	@$(call targetinfo, $@)
	rm -rf $(SCREEN_IPKG_TMP)
	$(SCREEN_PATH) $(MAKE) -C $(SCREEN_DIR) DESTDIR=$(SCREEN_IPKG_TMP) install
	@$(call copyincludes, $(SCREEN_IPKG_TMP))
	@$(call copylibraries,$(SCREEN_IPKG_TMP))
	@$(call copymiscfiles,$(SCREEN_IPKG_TMP))
	rm -rf $(SCREEN_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

screen_targetinstall: $(STATEDIR)/screen.targetinstall

screen_targetinstall_deps = $(STATEDIR)/screen.compile

SCREEN_DEPLIST = 

$(STATEDIR)/screen.targetinstall: $(screen_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SCREEN_PATH) $(MAKE) -C $(SCREEN_DIR) DESTDIR=$(SCREEN_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(SCREEN_VERSION)-$(SCREEN_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh screen $(SCREEN_IPKG_TMP)

	@$(call removedevfiles, $(SCREEN_IPKG_TMP))
	@$(call stripfiles, $(SCREEN_IPKG_TMP))
	mkdir -p $(SCREEN_IPKG_TMP)/CONTROL
	echo "Package: screen" 								 >$(SCREEN_IPKG_TMP)/CONTROL/control
	echo "Source: $(SCREEN_URL)"							>>$(SCREEN_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SCREEN_IPKG_TMP)/CONTROL/control
	echo "Section: Console" 							>>$(SCREEN_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SCREEN_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SCREEN_IPKG_TMP)/CONTROL/control
	echo "Version: $(SCREEN_VERSION)-$(SCREEN_VENDOR_VERSION)" 			>>$(SCREEN_IPKG_TMP)/CONTROL/control
	echo "Depends: $(SCREEN_DEPLIST)" 						>>$(SCREEN_IPKG_TMP)/CONTROL/control
	echo "Description: Screen is a full-screen window manager that multiplexes a physical terminal between several processes, typically interactive shells." >>$(SCREEN_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SCREEN_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SCREEN_INSTALL
ROMPACKAGES += $(STATEDIR)/screen.imageinstall
endif

screen_imageinstall_deps = $(STATEDIR)/screen.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/screen.imageinstall: $(screen_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install screen
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

screen_clean:
	rm -rf $(STATEDIR)/screen.*
	rm -rf $(SCREEN_DIR)

# vim: syntax=make
