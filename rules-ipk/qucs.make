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
ifdef PTXCONF_QUCS
PACKAGES += qucs
endif

#
# Paths and names
#
QUCS_VENDOR_VERSION	= 1
QUCS_VERSION		= 0.0.9
QUCS			= qucs-$(QUCS_VERSION)
QUCS_SUFFIX		= tar.gz
QUCS_URL		= http://ufpr.dl.sourceforge.net/sourceforge/qucs/$(QUCS).$(QUCS_SUFFIX)
QUCS_SOURCE		= $(SRCDIR)/$(QUCS).$(QUCS_SUFFIX)
QUCS_DIR		= $(BUILDDIR)/$(QUCS)
QUCS_IPKG_TMP		= $(QUCS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

qucs_get: $(STATEDIR)/qucs.get

qucs_get_deps = $(QUCS_SOURCE)

$(STATEDIR)/qucs.get: $(qucs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QUCS))
	touch $@

$(QUCS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QUCS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

qucs_extract: $(STATEDIR)/qucs.extract

qucs_extract_deps = $(STATEDIR)/qucs.get

$(STATEDIR)/qucs.extract: $(qucs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QUCS_DIR))
	@$(call extract, $(QUCS_SOURCE))
	@$(call patchin, $(QUCS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

qucs_prepare: $(STATEDIR)/qucs.prepare

#
# dependencies
#
qucs_prepare_deps = \
	$(STATEDIR)/qucs.extract \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/virtual-xchain.install

QUCS_PATH	=  PATH=$(CROSS_PATH)
QUCS_ENV 	=  $(CROSS_ENV)
QUCS_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
QUCS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#QUCS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
QUCS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
QUCS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
QUCS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/qucs.prepare: $(qucs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QUCS_DIR)/config.cache)
	cd $(QUCS_DIR) && \
		$(QUCS_PATH) $(QUCS_ENV) \
		./configure $(QUCS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

qucs_compile: $(STATEDIR)/qucs.compile

qucs_compile_deps = $(STATEDIR)/qucs.prepare

$(STATEDIR)/qucs.compile: $(qucs_compile_deps)
	@$(call targetinfo, $@)
	$(QUCS_PATH) $(MAKE) -C $(QUCS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

qucs_install: $(STATEDIR)/qucs.install

$(STATEDIR)/qucs.install: $(STATEDIR)/qucs.compile
	@$(call targetinfo, $@)
	rm -rf $(QUCS_IPKG_TMP)
	$(QUCS_PATH) $(MAKE) -C $(QUCS_DIR) DESTDIR=$(QUCS_IPKG_TMP) install
	@$(call copyincludes, $(QUCS_IPKG_TMP))
	@$(call copylibraries,$(QUCS_IPKG_TMP))
	@$(call copymiscfiles,$(QUCS_IPKG_TMP))
	rm -rf $(QUCS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

qucs_targetinstall: $(STATEDIR)/qucs.targetinstall

qucs_targetinstall_deps = $(STATEDIR)/qucs.compile \
	$(STATEDIR)/qt-x11-free.targetinstall

$(STATEDIR)/qucs.targetinstall: $(qucs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(QUCS_PATH) $(MAKE) -C $(QUCS_DIR) DESTDIR=$(QUCS_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(QUCS_VERSION)-$(QUCS_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh qucs $(QUCS_IPKG_TMP)

	@$(call removedevfiles, $(QUCS_IPKG_TMP))
	@$(call stripfiles, $(QUCS_IPKG_TMP))
	mkdir -p $(QUCS_IPKG_TMP)/CONTROL
	echo "Package: qucs" 								 >$(QUCS_IPKG_TMP)/CONTROL/control
	echo "Source: $(QUCS_URL)"							>>$(QUCS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(QUCS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(QUCS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(QUCS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(QUCS_IPKG_TMP)/CONTROL/control
	echo "Version: $(QUCS_VERSION)-$(QUCS_VENDOR_VERSION)" 				>>$(QUCS_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt" 								>>$(QUCS_IPKG_TMP)/CONTROL/control
	echo "Description: Qucs is an integrated circuit simulator which means you are able to setup a circuit with a graphical user interface (GUI) and simulate the large-signal, small-signal and noise behaviour of the circuit." >>$(QUCS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(QUCS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QUCS_INSTALL
ROMPACKAGES += $(STATEDIR)/qucs.imageinstall
endif

qucs_imageinstall_deps = $(STATEDIR)/qucs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/qucs.imageinstall: $(qucs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install qucs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

qucs_clean:
	rm -rf $(STATEDIR)/qucs.*
	rm -rf $(QUCS_DIR)

# vim: syntax=make
