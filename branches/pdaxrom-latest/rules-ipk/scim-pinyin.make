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
ifdef PTXCONF_SCIM-PINYIN
PACKAGES += scim-pinyin
endif

#
# Paths and names
#
SCIM-PINYIN_VENDOR_VERSION	= 1
SCIM-PINYIN_VERSION		= 0.5.91
SCIM-PINYIN			= scim-pinyin-$(SCIM-PINYIN_VERSION)
SCIM-PINYIN_SUFFIX		= tar.gz
SCIM-PINYIN_URL			= http://peterhost.dl.sourceforge.net/sourceforge/scim/$(SCIM-PINYIN).$(SCIM-PINYIN_SUFFIX)
SCIM-PINYIN_SOURCE		= $(SRCDIR)/$(SCIM-PINYIN).$(SCIM-PINYIN_SUFFIX)
SCIM-PINYIN_DIR			= $(BUILDDIR)/$(SCIM-PINYIN)
SCIM-PINYIN_IPKG_TMP		= $(SCIM-PINYIN_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

scim-pinyin_get: $(STATEDIR)/scim-pinyin.get

scim-pinyin_get_deps = $(SCIM-PINYIN_SOURCE)

$(STATEDIR)/scim-pinyin.get: $(scim-pinyin_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SCIM-PINYIN))
	touch $@

$(SCIM-PINYIN_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SCIM-PINYIN_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

scim-pinyin_extract: $(STATEDIR)/scim-pinyin.extract

scim-pinyin_extract_deps = $(STATEDIR)/scim-pinyin.get

$(STATEDIR)/scim-pinyin.extract: $(scim-pinyin_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCIM-PINYIN_DIR))
	@$(call extract, $(SCIM-PINYIN_SOURCE))
	@$(call patchin, $(SCIM-PINYIN))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

scim-pinyin_prepare: $(STATEDIR)/scim-pinyin.prepare

#
# dependencies
#
scim-pinyin_prepare_deps = \
	$(STATEDIR)/scim-pinyin.extract \
	$(STATEDIR)/scim.install \
	$(STATEDIR)/virtual-xchain.install

SCIM-PINYIN_PATH	=  PATH=$(CROSS_PATH)
SCIM-PINYIN_ENV 	=  $(CROSS_ENV)
#SCIM-PINYIN_ENV	+=
SCIM-PINYIN_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SCIM-PINYIN_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SCIM-PINYIN_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--disable-skim-support \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
SCIM-PINYIN_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SCIM-PINYIN_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/scim-pinyin.prepare: $(scim-pinyin_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCIM-PINYIN_DIR)/config.cache)
	cd $(SCIM-PINYIN_DIR) && \
		$(SCIM-PINYIN_PATH) $(SCIM-PINYIN_ENV) \
		./configure $(SCIM-PINYIN_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

scim-pinyin_compile: $(STATEDIR)/scim-pinyin.compile

scim-pinyin_compile_deps = $(STATEDIR)/scim-pinyin.prepare

$(STATEDIR)/scim-pinyin.compile: $(scim-pinyin_compile_deps)
	@$(call targetinfo, $@)
	$(SCIM-PINYIN_PATH) $(MAKE) -C $(SCIM-PINYIN_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

scim-pinyin_install: $(STATEDIR)/scim-pinyin.install

$(STATEDIR)/scim-pinyin.install: $(STATEDIR)/scim-pinyin.compile
	@$(call targetinfo, $@)
	###$(SCIM-PINYIN_PATH) $(MAKE) -C $(SCIM-PINYIN_DIR) install
	sadasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

scim-pinyin_targetinstall: $(STATEDIR)/scim-pinyin.targetinstall

scim-pinyin_targetinstall_deps = $(STATEDIR)/scim-pinyin.compile \
	$(STATEDIR)/scim.targetinstall

$(STATEDIR)/scim-pinyin.targetinstall: $(scim-pinyin_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(SCIM-PINYIN_IPKG_TMP)
	$(SCIM-PINYIN_PATH) $(MAKE) -C $(SCIM-PINYIN_DIR) DESTDIR=$(SCIM-PINYIN_IPKG_TMP) install
	##cp -a $(SCIM-PINYIN_IPKG_TMP)/$(CROSS_LIB_DIR)/*	$(SCIM-PINYIN_IPKG_TMP)/usr/
	##rm -rf $(SCIM-PINYIN_IPKG_TMP)/opt

	cd $(SCIM-PINYIN_IPKG_TMP)/usr && find -name *.la | xargs rm -f

	for FILE in `find $(SCIM-PINYIN_IPKG_TMP)/usr -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done

	mkdir -p $(SCIM-PINYIN_IPKG_TMP)/CONTROL
	echo "Package: scim-pinyin" 							 >$(SCIM-PINYIN_IPKG_TMP)/CONTROL/control
	echo "Source: $(SCIM-PINYIN_URL)"						>>$(SCIM-PINYIN_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SCIM-PINYIN_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 							>>$(SCIM-PINYIN_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SCIM-PINYIN_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SCIM-PINYIN_IPKG_TMP)/CONTROL/control
	echo "Version: $(SCIM-PINYIN_VERSION)-$(SCIM-PINYIN_VENDOR_VERSION)" 		>>$(SCIM-PINYIN_IPKG_TMP)/CONTROL/control
	echo "Depends: scim" 								>>$(SCIM-PINYIN_IPKG_TMP)/CONTROL/control
	echo "Description: smart pinyin input method"					>>$(SCIM-PINYIN_IPKG_TMP)/CONTROL/control

	@$(call makeipkg, $(SCIM-PINYIN_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SCIM-PINYIN_INSTALL
ROMPACKAGES += $(STATEDIR)/scim-pinyin.imageinstall
endif

scim-pinyin_imageinstall_deps = $(STATEDIR)/scim-pinyin.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/scim-pinyin.imageinstall: $(scim-pinyin_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install scim-pinyin
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

scim-pinyin_clean:
	rm -rf $(STATEDIR)/scim-pinyin.*
	rm -rf $(SCIM-PINYIN_DIR)

# vim: syntax=make
