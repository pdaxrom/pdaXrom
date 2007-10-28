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
ifdef PTXCONF_SCIM-M17N
PACKAGES += scim-m17n
endif

#
# Paths and names
#
SCIM-M17N_VENDOR_VERSION	= 1
SCIM-M17N_VERSION		= 0.1.4
SCIM-M17N			= scim-m17n-$(SCIM-M17N_VERSION)
SCIM-M17N_SUFFIX		= tar.gz
SCIM-M17N_URL			= http://peterhost.dl.sourceforge.net/sourceforge/scim/$(SCIM-M17N).$(SCIM-M17N_SUFFIX)
SCIM-M17N_SOURCE		= $(SRCDIR)/$(SCIM-M17N).$(SCIM-M17N_SUFFIX)
SCIM-M17N_DIR			= $(BUILDDIR)/$(SCIM-M17N)
SCIM-M17N_IPKG_TMP		= $(SCIM-M17N_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

scim-m17n_get: $(STATEDIR)/scim-m17n.get

scim-m17n_get_deps = $(SCIM-M17N_SOURCE)

$(STATEDIR)/scim-m17n.get: $(scim-m17n_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SCIM-M17N))
	touch $@

$(SCIM-M17N_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SCIM-M17N_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

scim-m17n_extract: $(STATEDIR)/scim-m17n.extract

scim-m17n_extract_deps = $(STATEDIR)/scim-m17n.get

$(STATEDIR)/scim-m17n.extract: $(scim-m17n_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCIM-M17N_DIR))
	@$(call extract, $(SCIM-M17N_SOURCE))
	@$(call patchin, $(SCIM-M17N))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

scim-m17n_prepare: $(STATEDIR)/scim-m17n.prepare

#
# dependencies
#
scim-m17n_prepare_deps = \
	$(STATEDIR)/scim-m17n.extract \
	$(STATEDIR)/scim.install \
	$(STATEDIR)/m17n-lib.install \
	$(STATEDIR)/virtual-xchain.install

SCIM-M17N_PATH	=  PATH=$(CROSS_PATH)
SCIM-M17N_ENV 	=  $(CROSS_ENV)
#SCIM-M17N_ENV	+=
SCIM-M17N_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SCIM-M17N_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SCIM-M17N_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--disable-skim-support \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
SCIM-M17N_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SCIM-M17N_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/scim-m17n.prepare: $(scim-m17n_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCIM-M17N_DIR)/config.cache)
	cd $(SCIM-M17N_DIR) && \
		$(SCIM-M17N_PATH) $(SCIM-M17N_ENV) \
		./configure $(SCIM-M17N_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

scim-m17n_compile: $(STATEDIR)/scim-m17n.compile

scim-m17n_compile_deps = $(STATEDIR)/scim-m17n.prepare

$(STATEDIR)/scim-m17n.compile: $(scim-m17n_compile_deps)
	@$(call targetinfo, $@)
	$(SCIM-M17N_PATH) $(MAKE) -C $(SCIM-M17N_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

scim-m17n_install: $(STATEDIR)/scim-m17n.install

$(STATEDIR)/scim-m17n.install: $(STATEDIR)/scim-m17n.compile
	@$(call targetinfo, $@)
	###$(SCIM-M17N_PATH) $(MAKE) -C $(SCIM-M17N_DIR) install
	sadasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

scim-m17n_targetinstall: $(STATEDIR)/scim-m17n.targetinstall

scim-m17n_targetinstall_deps = $(STATEDIR)/scim-m17n.compile \
	$(STATEDIR)/m17n-lib.targetinstall \
	$(STATEDIR)/scim.targetinstall

$(STATEDIR)/scim-m17n.targetinstall: $(scim-m17n_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(SCIM-M17N_IPKG_TMP)
	$(SCIM-M17N_PATH) $(MAKE) -C $(SCIM-M17N_DIR) DESTDIR=$(SCIM-M17N_IPKG_TMP) install
	##mkdir -p $(SCIM-M17N_IPKG_TMP)/usr/
	##cp -a $(SCIM-M17N_IPKG_TMP)/$(CROSS_LIB_DIR)/*	$(SCIM-M17N_IPKG_TMP)/usr/
	##rm -rf $(SCIM-M17N_IPKG_TMP)/opt

	cd $(SCIM-M17N_IPKG_TMP)/usr && find -name *.la | xargs rm -f

	for FILE in `find $(SCIM-M17N_IPKG_TMP)/usr -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done

	mkdir -p $(SCIM-M17N_IPKG_TMP)/CONTROL
	echo "Package: scim-m17n" 							 >$(SCIM-M17N_IPKG_TMP)/CONTROL/control
	echo "Source: $(SCIM-M17N_URL)"						>>$(SCIM-M17N_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SCIM-M17N_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 							>>$(SCIM-M17N_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SCIM-M17N_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SCIM-M17N_IPKG_TMP)/CONTROL/control
	echo "Version: $(SCIM-M17N_VERSION)-$(SCIM-M17N_VENDOR_VERSION)" 		>>$(SCIM-M17N_IPKG_TMP)/CONTROL/control
	echo "Depends: scim, m17n-lib" 							>>$(SCIM-M17N_IPKG_TMP)/CONTROL/control
	echo "Description: smart m17n input method"					>>$(SCIM-M17N_IPKG_TMP)/CONTROL/control

	@$(call makeipkg, $(SCIM-M17N_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SCIM-M17N_INSTALL
ROMPACKAGES += $(STATEDIR)/scim-m17n.imageinstall
endif

scim-m17n_imageinstall_deps = $(STATEDIR)/scim-m17n.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/scim-m17n.imageinstall: $(scim-m17n_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install scim-m17n
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

scim-m17n_clean:
	rm -rf $(STATEDIR)/scim-m17n.*
	rm -rf $(SCIM-M17N_DIR)

# vim: syntax=make
