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
ifdef PTXCONF_SCILAB
PACKAGES += scilab
endif

#
# Paths and names
#
SCILAB_VENDOR_VERSION	= 1
SCILAB_VERSION		= 3.1.1
SCILAB			= scilab-$(SCILAB_VERSION)-src
SCILAB_SUFFIX		= tar.gz
SCILAB_URL		= http://scilabsoft.inria.fr/download/stable/$(SCILAB).$(SCILAB_SUFFIX)
SCILAB_SOURCE		= $(SRCDIR)/$(SCILAB).$(SCILAB_SUFFIX)
SCILAB_DIR		= $(BUILDDIR)/scilab-$(SCILAB_VERSION)
SCILAB_IPKG_TMP		= $(SCILAB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

scilab_get: $(STATEDIR)/scilab.get

scilab_get_deps = $(SCILAB_SOURCE)

$(STATEDIR)/scilab.get: $(scilab_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SCILAB))
	touch $@

$(SCILAB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SCILAB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

scilab_extract: $(STATEDIR)/scilab.extract

scilab_extract_deps = $(STATEDIR)/scilab.get

$(STATEDIR)/scilab.extract: $(scilab_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(SCILAB_DIR))
	@$(call extract, $(SCILAB_SOURCE))
	@$(call patchin, $(SCILAB),$(SCILAB_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

scilab_prepare: $(STATEDIR)/scilab.prepare

#
# dependencies
#
scilab_prepare_deps = \
	$(STATEDIR)/scilab.extract \
	$(STATEDIR)/vte.install \
	$(STATEDIR)/libgtkhtml.install \
	$(STATEDIR)/virtual-xchain.install

SCILAB_PATH	=  PATH=$(CROSS_PATH)
SCILAB_ENV 	=  $(CROSS_ENV)
###SCILAB_ENV	+= F77=$(PTXCONF_GNU_TARGET)-g77
SCILAB_ENV	+= ac_cv_prog_WITH_G77=yes
SCILAB_ENV	+= ac_cv_lib_ieee_main=no
SCILAB_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
SCILAB_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
SCILAB_ENV	+= FFLAGS="$(TARGET_OPT_CFLAGS)"
SCILAB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SCILAB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SCILAB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared \
	--with-gtk2 \
	--with-g77 \
	--without-java \
	--without-tk

ifdef PTXCONF_XFREE430
SCILAB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SCILAB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/scilab.prepare: $(scilab_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCILAB_DIR)/config.cache)
	cd $(SCILAB_DIR) && \
		$(SCILAB_PATH) $(SCILAB_ENV) \
		./configure $(SCILAB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

scilab_compile: $(STATEDIR)/scilab.compile

scilab_compile_deps = $(STATEDIR)/scilab.prepare

$(STATEDIR)/scilab.compile: $(scilab_compile_deps)
	@$(call targetinfo, $@)
	$(SCILAB_PATH) $(SCILAB_ENV) $(MAKE) -C $(SCILAB_DIR) all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

scilab_install: $(STATEDIR)/scilab.install

$(STATEDIR)/scilab.install: $(STATEDIR)/scilab.compile
	@$(call targetinfo, $@)
	#$(SCILAB_PATH) $(MAKE) -C $(SCILAB_DIR) install
	sdfsd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

scilab_targetinstall: $(STATEDIR)/scilab.targetinstall

scilab_targetinstall_deps = $(STATEDIR)/scilab.compile \
	$(STATEDIR)/vte.targetinstall \
	$(STATEDIR)/libgtkhtml.targetinstall


$(STATEDIR)/scilab.targetinstall: $(scilab_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SCILAB_PATH) $(SCILAB_ENV) $(MAKE) -C $(SCILAB_DIR) DESTDIR=$(SCILAB_IPKG_TMP) install
	mkdir -p $(SCILAB_IPKG_TMP)/CONTROL
	echo "Package: scilab" 								 >$(SCILAB_IPKG_TMP)/CONTROL/control
	echo "Source: $(SCILAB_URL)"						>>$(SCILAB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SCILAB_IPKG_TMP)/CONTROL/control
	echo "Section: Math"	 							>>$(SCILAB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SCILAB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SCILAB_IPKG_TMP)/CONTROL/control
	echo "Version: $(SCILAB_VERSION)-$(SCILAB_VENDOR_VERSION)" 			>>$(SCILAB_IPKG_TMP)/CONTROL/control
	echo "Depends: libgtkhtml" 							>>$(SCILAB_IPKG_TMP)/CONTROL/control
	echo "Description: "				>>$(SCILAB_IPKG_TMP)/CONTROL/control
	sasd
	cd $(FEEDDIR) && $(XMKIPKG) $(SCILAB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SCILAB_INSTALL
ROMPACKAGES += $(STATEDIR)/scilab.imageinstall
endif

scilab_imageinstall_deps = $(STATEDIR)/scilab.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/scilab.imageinstall: $(scilab_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install scilab
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

scilab_clean:
	rm -rf $(STATEDIR)/scilab.*
	rm -rf $(SCILAB_DIR)

# vim: syntax=make
