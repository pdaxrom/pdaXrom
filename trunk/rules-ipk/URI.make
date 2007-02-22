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
ifdef PTXCONF_URI
PACKAGES += URI
endif

#
# Paths and names
#
URI_VENDOR_VERSION	= 1
URI_VERSION	= 1.35
URI		= URI-$(URI_VERSION)
URI_SUFFIX		= tar.gz
URI_URL		= http://search.cpan.org/CPAN/authors/id/G/GA/GAAS//$(URI).$(URI_SUFFIX)
URI_SOURCE		= $(SRCDIR)/$(URI).$(URI_SUFFIX)
URI_DIR		= $(BUILDDIR)/$(URI)
URI_IPKG_TMP	= $(URI_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

URI_get: $(STATEDIR)/URI.get

URI_get_deps = $(URI_SOURCE)

$(STATEDIR)/URI.get: $(URI_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(URI))
	touch $@

$(URI_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(URI_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

URI_extract: $(STATEDIR)/URI.extract

URI_extract_deps = $(STATEDIR)/URI.get

$(STATEDIR)/URI.extract: $(URI_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(URI_DIR))
	@$(call extract, $(URI_SOURCE))
	@$(call patchin, $(URI))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

URI_prepare: $(STATEDIR)/URI.prepare

#
# dependencies
#
URI_prepare_deps = \
	$(STATEDIR)/URI.extract \
	$(STATEDIR)/virtual-xchain.install

URI_PATH	=  PATH=$(CROSS_PATH)
URI_ENV 	=  $(CROSS_ENV)
#URI_ENV	+=
URI_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#URI_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
URI_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
URI_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
URI_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/URI.prepare: $(URI_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(URI_DIR)/config.cache)
	cd $(URI_DIR) && \
		$(URI_PATH) $(URI_ENV) \
		perl Makefile.PL $(URI_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

URI_compile: $(STATEDIR)/URI.compile

URI_compile_deps = $(STATEDIR)/URI.prepare

$(STATEDIR)/URI.compile: $(URI_compile_deps)
	@$(call targetinfo, $@)
	$(URI_PATH) $(MAKE) -C $(URI_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

URI_install: $(STATEDIR)/URI.install

$(STATEDIR)/URI.install: $(STATEDIR)/URI.compile
	@$(call targetinfo, $@)
	rm -rf $(URI_IPKG_TMP)
	$(URI_PATH) $(MAKE) -C $(URI_DIR) DESTDIR=$(URI_IPKG_TMP) install
	@$(call copyincludes, $(URI_IPKG_TMP))
	@$(call copylibraries,$(URI_IPKG_TMP))
	@$(call copymiscfiles,$(URI_IPKG_TMP))
	rm -rf $(URI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

URI_targetinstall: $(STATEDIR)/URI.targetinstall

URI_targetinstall_deps = $(STATEDIR)/URI.compile

URI_DEPLIST = 

$(STATEDIR)/URI.targetinstall: $(URI_targetinstall_deps)
	@$(call targetinfo, $@)
	$(URI_PATH) $(MAKE) -C $(URI_DIR) DESTDIR=$(URI_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(URI_VERSION)-$(URI_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh uri $(URI_IPKG_TMP)

	@$(call removedevfiles, $(URI_IPKG_TMP))
	@$(call stripfiles, $(URI_IPKG_TMP))
	mkdir -p $(URI_IPKG_TMP)/CONTROL
	echo "Package: uri" 							 >$(URI_IPKG_TMP)/CONTROL/control
	echo "Source: $(URI_URL)"							>>$(URI_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(URI_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(URI_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Adrian Crutchfield" 							>>$(URI_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(URI_IPKG_TMP)/CONTROL/control
	echo "Version: $(URI_VERSION)-$(URI_VENDOR_VERSION)" 			>>$(URI_IPKG_TMP)/CONTROL/control
	echo "Depends: $(URI_DEPLIST)" 						>>$(URI_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(URI_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(URI_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_URI_INSTALL
ROMPACKAGES += $(STATEDIR)/URI.imageinstall
endif

URI_imageinstall_deps = $(STATEDIR)/URI.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/URI.imageinstall: $(URI_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install uri
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

URI_clean:
	rm -rf $(STATEDIR)/URI.*
	rm -rf $(URI_DIR)

# vim: syntax=make
