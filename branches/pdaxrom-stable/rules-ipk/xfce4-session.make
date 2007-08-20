# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Adrian Crutchfield
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_XFCE4-SESSION
PACKAGES += xfce4-session
endif

#
# Paths and names
#
XFCE4-SESSION_VENDOR_VERSION	= 1
XFCE4-SESSION_VERSION	= 4.4.0
XFCE4-SESSION		= xfce4-session-$(XFCE4-SESSION_VERSION)
XFCE4-SESSION_SUFFIX		= tar.bz2
XFCE4-SESSION_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(XFCE4-SESSION).$(XFCE4-SESSION_SUFFIX)
XFCE4-SESSION_SOURCE		= $(SRCDIR)/$(XFCE4-SESSION).$(XFCE4-SESSION_SUFFIX)
XFCE4-SESSION_DIR		= $(BUILDDIR)/$(XFCE4-SESSION)
XFCE4-SESSION_IPKG_TMP	= $(XFCE4-SESSION_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfce4-session_get: $(STATEDIR)/xfce4-session.get

xfce4-session_get_deps = $(XFCE4-SESSION_SOURCE)

$(STATEDIR)/xfce4-session.get: $(xfce4-session_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFCE4-SESSION))
	touch $@

$(XFCE4-SESSION_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFCE4-SESSION_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfce4-session_extract: $(STATEDIR)/xfce4-session.extract

xfce4-session_extract_deps = $(STATEDIR)/xfce4-session.get

$(STATEDIR)/xfce4-session.extract: $(xfce4-session_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-SESSION_DIR))
	@$(call extract, $(XFCE4-SESSION_SOURCE))
	@$(call patchin, $(XFCE4-SESSION))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfce4-session_prepare: $(STATEDIR)/xfce4-session.prepare

#
# dependencies
#
xfce4-session_prepare_deps = \
	$(STATEDIR)/xfce4-session.extract \
	$(STATEDIR)/virtual-xchain.install

XFCE4-SESSION_PATH	=  PATH=$(CROSS_PATH)
XFCE4-SESSION_ENV 	=  $(CROSS_ENV)
#XFCE4-SESSION_ENV	+=
XFCE4-SESSION_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFCE4-SESSION_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XFCE4-SESSION_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XFCE4-SESSION_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFCE4-SESSION_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfce4-session.prepare: $(xfce4-session_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFCE4-SESSION_DIR)/config.cache)
	cd $(XFCE4-SESSION_DIR) && \
		$(XFCE4-SESSION_PATH) $(XFCE4-SESSION_ENV) \
		./configure $(XFCE4-SESSION_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfce4-session_compile: $(STATEDIR)/xfce4-session.compile

xfce4-session_compile_deps = $(STATEDIR)/xfce4-session.prepare

$(STATEDIR)/xfce4-session.compile: $(xfce4-session_compile_deps)
	@$(call targetinfo, $@)
	$(XFCE4-SESSION_PATH) $(MAKE) -C $(XFCE4-SESSION_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfce4-session_install: $(STATEDIR)/xfce4-session.install

$(STATEDIR)/xfce4-session.install: $(STATEDIR)/xfce4-session.compile
	@$(call targetinfo, $@)
	rm -rf $(XFCE4-SESSION_IPKG_TMP)
	$(XFCE4-SESSION_PATH) $(MAKE) -C $(XFCE4-SESSION_DIR) DESTDIR=$(XFCE4-SESSION_IPKG_TMP) install
	@$(call copyincludes, $(XFCE4-SESSION_IPKG_TMP))
	@$(call copylibraries,$(XFCE4-SESSION_IPKG_TMP))
	@$(call copymiscfiles,$(XFCE4-SESSION_IPKG_TMP))
	rm -rf $(XFCE4-SESSION_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfce4-session_targetinstall: $(STATEDIR)/xfce4-session.targetinstall

xfce4-session_targetinstall_deps = $(STATEDIR)/xfce4-session.compile

XFCE4-SESSION_DEPLIST = 

$(STATEDIR)/xfce4-session.targetinstall: $(xfce4-session_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XFCE4-SESSION_PATH) $(MAKE) -C $(XFCE4-SESSION_DIR) DESTDIR=$(XFCE4-SESSION_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(XFCE4-SESSION_VERSION)-$(XFCE4-SESSION_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh xfce4-session $(XFCE4-SESSION_IPKG_TMP)

	@$(call removedevfiles, $(XFCE4-SESSION_IPKG_TMP))
	@$(call stripfiles, $(XFCE4-SESSION_IPKG_TMP))
	mkdir -p $(XFCE4-SESSION_IPKG_TMP)/CONTROL
	echo "Package: xfce4-session" 							 >$(XFCE4-SESSION_IPKG_TMP)/CONTROL/control
	echo "Source: $(XFCE4-SESSION_URL)"							>>$(XFCE4-SESSION_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XFCE4-SESSION_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XFCE4-SESSION_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(XFCE4-SESSION_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XFCE4-SESSION_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFCE4-SESSION_VERSION)-$(XFCE4-SESSION_VENDOR_VERSION)" 			>>$(XFCE4-SESSION_IPKG_TMP)/CONTROL/control
	echo "Depends: $(XFCE4-SESSION_DEPLIST)" 						>>$(XFCE4-SESSION_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XFCE4-SESSION_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(XFCE4-SESSION_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFCE4-SESSION_INSTALL
ROMPACKAGES += $(STATEDIR)/xfce4-session.imageinstall
endif

xfce4-session_imageinstall_deps = $(STATEDIR)/xfce4-session.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfce4-session.imageinstall: $(xfce4-session_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfce4-session
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfce4-session_clean:
	rm -rf $(STATEDIR)/xfce4-session.*
	rm -rf $(XFCE4-SESSION_DIR)

# vim: syntax=make
