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
ifdef PTXCONF_SCIM-HANGUL
PACKAGES += scim-hangul
endif

#
# Paths and names
#
SCIM-HANGUL_VENDOR_VERSION	= 1
SCIM-HANGUL_VERSION		= 0.2.0
SCIM-HANGUL			= scim-hangul-$(SCIM-HANGUL_VERSION)
SCIM-HANGUL_SUFFIX		= tar.gz
SCIM-HANGUL_URL			= http://peterhost.dl.sourceforge.net/sourceforge/scim/$(SCIM-HANGUL).$(SCIM-HANGUL_SUFFIX)
SCIM-HANGUL_SOURCE		= $(SRCDIR)/$(SCIM-HANGUL).$(SCIM-HANGUL_SUFFIX)
SCIM-HANGUL_DIR			= $(BUILDDIR)/$(SCIM-HANGUL)
SCIM-HANGUL_IPKG_TMP		= $(SCIM-HANGUL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

scim-hangul_get: $(STATEDIR)/scim-hangul.get

scim-hangul_get_deps = $(SCIM-HANGUL_SOURCE)

$(STATEDIR)/scim-hangul.get: $(scim-hangul_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SCIM-HANGUL))
	touch $@

$(SCIM-HANGUL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SCIM-HANGUL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

scim-hangul_extract: $(STATEDIR)/scim-hangul.extract

scim-hangul_extract_deps = $(STATEDIR)/scim-hangul.get

$(STATEDIR)/scim-hangul.extract: $(scim-hangul_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCIM-HANGUL_DIR))
	@$(call extract, $(SCIM-HANGUL_SOURCE))
	@$(call patchin, $(SCIM-HANGUL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

scim-hangul_prepare: $(STATEDIR)/scim-hangul.prepare

#
# dependencies
#
scim-hangul_prepare_deps = \
	$(STATEDIR)/scim-hangul.extract \
	$(STATEDIR)/scim.install \
	$(STATEDIR)/virtual-xchain.install

SCIM-HANGUL_PATH	=  PATH=$(CROSS_PATH)
SCIM-HANGUL_ENV 	=  $(CROSS_ENV)
#SCIM-HANGUL_ENV	+=
SCIM-HANGUL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SCIM-HANGUL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SCIM-HANGUL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--disable-skim-support \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
SCIM-HANGUL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SCIM-HANGUL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/scim-hangul.prepare: $(scim-hangul_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCIM-HANGUL_DIR)/config.cache)
	cd $(SCIM-HANGUL_DIR) && \
		$(SCIM-HANGUL_PATH) $(SCIM-HANGUL_ENV) \
		./configure $(SCIM-HANGUL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

scim-hangul_compile: $(STATEDIR)/scim-hangul.compile

scim-hangul_compile_deps = $(STATEDIR)/scim-hangul.prepare

$(STATEDIR)/scim-hangul.compile: $(scim-hangul_compile_deps)
	@$(call targetinfo, $@)
	$(SCIM-HANGUL_PATH) $(MAKE) -C $(SCIM-HANGUL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

scim-hangul_install: $(STATEDIR)/scim-hangul.install

$(STATEDIR)/scim-hangul.install: $(STATEDIR)/scim-hangul.compile
	@$(call targetinfo, $@)
	###$(SCIM-HANGUL_PATH) $(MAKE) -C $(SCIM-HANGUL_DIR) install
	sadasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

scim-hangul_targetinstall: $(STATEDIR)/scim-hangul.targetinstall

scim-hangul_targetinstall_deps = $(STATEDIR)/scim-hangul.compile \
	$(STATEDIR)/scim.targetinstall

$(STATEDIR)/scim-hangul.targetinstall: $(scim-hangul_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(SCIM-HANGUL_IPKG_TMP)
	$(SCIM-HANGUL_PATH) $(MAKE) -C $(SCIM-HANGUL_DIR) DESTDIR=$(SCIM-HANGUL_IPKG_TMP) install
	##cp -a $(SCIM-HANGUL_IPKG_TMP)/$(CROSS_LIB_DIR)/*	$(SCIM-HANGUL_IPKG_TMP)/usr/
	##rm -rf $(SCIM-HANGUL_IPKG_TMP)/opt

	cd $(SCIM-HANGUL_IPKG_TMP)/usr && find -name *.la | xargs rm -f

	for FILE in `find $(SCIM-HANGUL_IPKG_TMP)/usr -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done

	mkdir -p $(SCIM-HANGUL_IPKG_TMP)/CONTROL
	echo "Package: scim-hangul" 							 >$(SCIM-HANGUL_IPKG_TMP)/CONTROL/control
	echo "Source: $(SCIM-HANGUL_URL)"						>>$(SCIM-HANGUL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SCIM-HANGUL_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 							>>$(SCIM-HANGUL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SCIM-HANGUL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SCIM-HANGUL_IPKG_TMP)/CONTROL/control
	echo "Version: $(SCIM-HANGUL_VERSION)-$(SCIM-HANGUL_VENDOR_VERSION)" 		>>$(SCIM-HANGUL_IPKG_TMP)/CONTROL/control
	echo "Depends: scim" 								>>$(SCIM-HANGUL_IPKG_TMP)/CONTROL/control
	echo "Description: smart hangul input method"					>>$(SCIM-HANGUL_IPKG_TMP)/CONTROL/control

	cd $(FEEDDIR) && $(XMKIPKG) $(SCIM-HANGUL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SCIM-HANGUL_INSTALL
ROMPACKAGES += $(STATEDIR)/scim-hangul.imageinstall
endif

scim-hangul_imageinstall_deps = $(STATEDIR)/scim-hangul.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/scim-hangul.imageinstall: $(scim-hangul_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install scim-hangul
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

scim-hangul_clean:
	rm -rf $(STATEDIR)/scim-hangul.*
	rm -rf $(SCIM-HANGUL_DIR)

# vim: syntax=make
