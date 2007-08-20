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
ifdef PTXCONF_YACAS
PACKAGES += yacas
endif

#
# Paths and names
#
YACAS_VENDOR_VERSION	= 1
YACAS_VERSION		= 1.0.59
YACAS			= yacas-$(YACAS_VERSION)
YACAS_SUFFIX		= tar.gz
YACAS_URL		= http://yacas.sourceforge.net/backups/$(YACAS).$(YACAS_SUFFIX)
YACAS_SOURCE		= $(SRCDIR)/$(YACAS).$(YACAS_SUFFIX)
YACAS_DIR		= $(BUILDDIR)/$(YACAS)
YACAS_IPKG_TMP		= $(YACAS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

yacas_get: $(STATEDIR)/yacas.get

yacas_get_deps = $(YACAS_SOURCE)

$(STATEDIR)/yacas.get: $(yacas_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(YACAS))
	touch $@

$(YACAS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(YACAS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

yacas_extract: $(STATEDIR)/yacas.extract

yacas_extract_deps = $(STATEDIR)/yacas.get

$(STATEDIR)/yacas.extract: $(yacas_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(YACAS_DIR))
	@$(call extract, $(YACAS_SOURCE))
	@$(call patchin, $(YACAS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

yacas_prepare: $(STATEDIR)/yacas.prepare

#
# dependencies
#
yacas_prepare_deps = \
	$(STATEDIR)/yacas.extract \
	$(STATEDIR)/xchain-yacas.compile \
	$(STATEDIR)/virtual-xchain.install

YACAS_PATH	=  PATH=$(CROSS_PATH)
YACAS_ENV 	=  $(CROSS_ENV)
#YACAS_ENV	+=
YACAS_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
YACAS_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
YACAS_ENV	+= FFLAGS="$(TARGET_OPT_CFLAGS)"
YACAS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#YACAS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
YACAS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
YACAS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
YACAS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/yacas.prepare: $(yacas_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(YACAS_DIR)/config.cache)
	cd $(YACAS_DIR) && \
		$(YACAS_PATH) $(YACAS_ENV) \
		./configure $(YACAS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

yacas_compile: $(STATEDIR)/yacas.compile

yacas_compile_deps = $(STATEDIR)/yacas.prepare

$(STATEDIR)/yacas.compile: $(yacas_compile_deps)
	@$(call targetinfo, $@)
	$(YACAS_PATH) $(MAKE) -C $(YACAS_DIR) HOST_CXX=g++ HOST_CC=gcc HOST_YACAS=$(XCHAIN_YACAS_DIR)/src/yacas \
	    HOST_GENCOREFUNC=$(XCHAIN_YACAS_DIR)/src/gencorefunctions
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

yacas_install: $(STATEDIR)/yacas.install

$(STATEDIR)/yacas.install: $(STATEDIR)/yacas.compile
	@$(call targetinfo, $@)
	##$(YACAS_PATH) $(MAKE) -C $(YACAS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

yacas_targetinstall: $(STATEDIR)/yacas.targetinstall

yacas_targetinstall_deps = $(STATEDIR)/yacas.compile

$(STATEDIR)/yacas.targetinstall: $(yacas_targetinstall_deps)
	@$(call targetinfo, $@)
	$(YACAS_PATH) $(MAKE) -C $(YACAS_DIR) DESTDIR=$(YACAS_IPKG_TMP) install
	rm -rf $(YACAS_IPKG_TMP)/usr/include
	rm -f  $(YACAS_IPKG_TMP)/usr/lib/*.*a
	rm -f  $(YACAS_IPKG_TMP)/usr/lib/yacas/*.*a
	for FILE in `find $(YACAS_IPKG_TMP)/usr/ -type f`; do			\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;				\
	    if [  "$$ZZZ" != "" ]; then						\
		$(CROSSSTRIP) $$FILE;						\
	    fi;									\
	done
	mkdir -p $(YACAS_IPKG_TMP)/CONTROL
	echo "Package: yacas" 								 >$(YACAS_IPKG_TMP)/CONTROL/control
	echo "Source: $(YACAS_URL)"							>>$(YACAS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(YACAS_IPKG_TMP)/CONTROL/control
	echo "Section: Math"	 							>>$(YACAS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(YACAS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(YACAS_IPKG_TMP)/CONTROL/control
	echo "Version: $(YACAS_VERSION)-$(YACAS_VENDOR_VERSION)" 			>>$(YACAS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(YACAS_IPKG_TMP)/CONTROL/control
	echo "Description:  YACAS is an easy to use, general purpose Computer Algebra System, a program for symbolic manipulation of mathematical expressions." >>$(YACAS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(YACAS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_YACAS_INSTALL
ROMPACKAGES += $(STATEDIR)/yacas.imageinstall
endif

yacas_imageinstall_deps = $(STATEDIR)/yacas.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/yacas.imageinstall: $(yacas_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install yacas
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

yacas_clean:
	rm -rf $(STATEDIR)/yacas.*
	rm -rf $(YACAS_DIR)

# vim: syntax=make
