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
ifdef PTXCONF_EXO
PACKAGES += exo
endif

#
# Paths and names
#
EXO_VENDOR_VERSION	= 1
EXO_VERSION	= 0.3.2
EXO		= exo-$(EXO_VERSION)
EXO_SUFFIX		= tar.bz2
EXO_URL		= http://www.us.xfce.org/archive/xfce-4.4.0/src//$(EXO).$(EXO_SUFFIX)
EXO_SOURCE		= $(SRCDIR)/$(EXO).$(EXO_SUFFIX)
EXO_DIR		= $(BUILDDIR)/$(EXO)
EXO_IPKG_TMP	= $(EXO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

exo_get: $(STATEDIR)/exo.get

exo_get_deps = $(EXO_SOURCE)

$(STATEDIR)/exo.get: $(exo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(EXO))
	touch $@

$(EXO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(EXO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

exo_extract: $(STATEDIR)/exo.extract

exo_extract_deps = $(STATEDIR)/exo.get

$(STATEDIR)/exo.extract: $(exo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EXO_DIR))
	@$(call extract, $(EXO_SOURCE))
	@$(call patchin, $(EXO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

exo_prepare: $(STATEDIR)/exo.prepare

#
# dependencies
#
exo_prepare_deps = \
	$(STATEDIR)/exo.extract \
	$(STATEDIR)/libxfce4util.targetinstall \
	$(STATEDIR)/virtual-xchain.install

EXO_PATH	=  PATH=$(CROSS_PATH)
EXO_ENV 	=  $(CROSS_ENV)
#EXO_ENV	+=
EXO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#EXO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
EXO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
EXO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
EXO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/exo.prepare: $(exo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EXO_DIR)/config.cache)
	cd $(EXO_DIR) && \
		$(EXO_PATH) $(EXO_ENV) \
		./configure $(EXO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

exo_compile: $(STATEDIR)/exo.compile

exo_compile_deps = $(STATEDIR)/exo.prepare

$(STATEDIR)/exo.compile: $(exo_compile_deps)
	@$(call targetinfo, $@)
	$(EXO_PATH) $(MAKE) -C $(EXO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

exo_install: $(STATEDIR)/exo.install

$(STATEDIR)/exo.install: $(STATEDIR)/exo.compile
	@$(call targetinfo, $@)
	rm -rf $(EXO_IPKG_TMP)
	$(EXO_PATH) $(MAKE) -C $(EXO_DIR) DESTDIR=$(EXO_IPKG_TMP) install
	@$(call copyincludes, $(EXO_IPKG_TMP))
	@$(call copylibraries,$(EXO_IPKG_TMP))
	@$(call copymiscfiles,$(EXO_IPKG_TMP))
	rm -rf $(EXO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

exo_targetinstall: $(STATEDIR)/exo.targetinstall

exo_targetinstall_deps = $(STATEDIR)/exo.compile

EXO_DEPLIST = 

$(STATEDIR)/exo.targetinstall: $(exo_targetinstall_deps)
	@$(call targetinfo, $@)
	$(EXO_PATH) $(MAKE) -C $(EXO_DIR) DESTDIR=$(EXO_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(EXO_VERSION)-$(EXO_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh exo $(EXO_IPKG_TMP)

	@$(call removedevfiles, $(EXO_IPKG_TMP))
	@$(call stripfiles, $(EXO_IPKG_TMP))
	mkdir -p $(EXO_IPKG_TMP)/CONTROL
	echo "Package: exo" 							 >$(EXO_IPKG_TMP)/CONTROL/control
	echo "Source: $(EXO_URL)"							>>$(EXO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(EXO_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(EXO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(EXO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(EXO_IPKG_TMP)/CONTROL/control
	echo "Version: $(EXO_VERSION)-$(EXO_VENDOR_VERSION)" 			>>$(EXO_IPKG_TMP)/CONTROL/control
	echo "Depends: $(EXO_DEPLIST)" 						>>$(EXO_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(EXO_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(EXO_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_EXO_INSTALL
ROMPACKAGES += $(STATEDIR)/exo.imageinstall
endif

exo_imageinstall_deps = $(STATEDIR)/exo.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/exo.imageinstall: $(exo_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install exo
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

exo_clean:
	rm -rf $(STATEDIR)/exo.*
	rm -rf $(EXO_DIR)

# vim: syntax=make
