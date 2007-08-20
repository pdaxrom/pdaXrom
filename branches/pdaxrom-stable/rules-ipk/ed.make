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
ifdef PTXCONF_ED
PACKAGES += ed
endif

#
# Paths and names
#
ED_VENDOR_VERSION	= 1
ED_VERSION		= 0.2
ED			= ed-$(ED_VERSION)
ED_SUFFIX		= tar.gz
ED_URL			= http://ftp.gnu.org/gnu/ed/$(ED).$(ED_SUFFIX)
ED_SOURCE		= $(SRCDIR)/$(ED).$(ED_SUFFIX)
ED_DIR			= $(BUILDDIR)/$(ED)
ED_IPKG_TMP		= $(ED_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ed_get: $(STATEDIR)/ed.get

ed_get_deps = $(ED_SOURCE)

$(STATEDIR)/ed.get: $(ed_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ED))
	touch $@

$(ED_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ED_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ed_extract: $(STATEDIR)/ed.extract

ed_extract_deps = $(STATEDIR)/ed.get

$(STATEDIR)/ed.extract: $(ed_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ED_DIR))
	@$(call extract, $(ED_SOURCE))
	@$(call patchin, $(ED))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ed_prepare: $(STATEDIR)/ed.prepare

#
# dependencies
#
ed_prepare_deps = \
	$(STATEDIR)/ed.extract \
	$(STATEDIR)/virtual-xchain.install

ED_PATH	=  PATH=$(CROSS_PATH)
ED_ENV 	=  $(CROSS_ENV)
ED_ENV	+= CFLAGS="-O2"
ED_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ED_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ED_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ED_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ED_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ed.prepare: $(ed_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ED_DIR)/config.cache)
	cd $(ED_DIR) && \
		$(ED_PATH) $(ED_ENV) \
		./configure $(ED_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ed_compile: $(STATEDIR)/ed.compile

ed_compile_deps = $(STATEDIR)/ed.prepare

$(STATEDIR)/ed.compile: $(ed_compile_deps)
	@$(call targetinfo, $@)
	$(ED_PATH) $(MAKE) -C $(ED_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ed_install: $(STATEDIR)/ed.install

$(STATEDIR)/ed.install: $(STATEDIR)/ed.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ed_targetinstall: $(STATEDIR)/ed.targetinstall

ed_targetinstall_deps = $(STATEDIR)/ed.compile

$(STATEDIR)/ed.targetinstall: $(ed_targetinstall_deps)
	@$(call targetinfo, $@)
	##$(ED_PATH) $(MAKE) -C $(ED_DIR) DESTDIR=$(ED_IPKG_TMP) install
	$(INSTALL) -D $(ED_DIR)/ed $(ED_IPKG_TMP)/usr/bin/ed
	$(CROSSSTRIP) $(ED_IPKG_TMP)/usr/bin/ed
	mkdir -p $(ED_IPKG_TMP)/CONTROL
	echo "Package: ed" 								 >$(ED_IPKG_TMP)/CONTROL/control
	echo "Source: $(ED_URL)"							>>$(ED_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ED_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(ED_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ED_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ED_IPKG_TMP)/CONTROL/control
	echo "Version: $(ED_VERSION)-$(ED_VENDOR_VERSION)" 				>>$(ED_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(ED_IPKG_TMP)/CONTROL/control
	echo "Description: line-oriented text editor. It is used to create, display, modify and otherwise manipulate text files, both interactively and via shell scripts." >>$(ED_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(ED_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ED_INSTALL
ROMPACKAGES += $(STATEDIR)/ed.imageinstall
endif

ed_imageinstall_deps = $(STATEDIR)/ed.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ed.imageinstall: $(ed_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ed
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ed_clean:
	rm -rf $(STATEDIR)/ed.*
	rm -rf $(ED_DIR)

# vim: syntax=make
