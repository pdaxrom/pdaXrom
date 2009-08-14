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
ifdef PTXCONF_STARPLOT
PACKAGES += starplot
endif

#
# Paths and names
#
STARPLOT_VENDOR_VERSION	= 1
STARPLOT_VERSION	= 0.95.2
STARPLOT		= starplot-$(STARPLOT_VERSION)
STARPLOT_SUFFIX		= tar.gz
STARPLOT_URL		= http://www.starplot.org/downloads/$(STARPLOT).$(STARPLOT_SUFFIX)
STARPLOT_SOURCE		= $(SRCDIR)/$(STARPLOT).$(STARPLOT_SUFFIX)
STARPLOT_DIR		= $(BUILDDIR)/$(STARPLOT)
STARPLOT_IPKG_TMP	= $(STARPLOT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

starplot_get: $(STATEDIR)/starplot.get

starplot_get_deps = $(STARPLOT_SOURCE)

$(STATEDIR)/starplot.get: $(starplot_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(STARPLOT))
	touch $@

$(STARPLOT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(STARPLOT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

starplot_extract: $(STATEDIR)/starplot.extract

starplot_extract_deps = $(STATEDIR)/starplot.get

$(STATEDIR)/starplot.extract: $(starplot_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(STARPLOT_DIR))
	@$(call extract, $(STARPLOT_SOURCE))
	@$(call patchin, $(STARPLOT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

starplot_prepare: $(STATEDIR)/starplot.prepare

#
# dependencies
#
starplot_prepare_deps = \
	$(STATEDIR)/starplot.extract \
	$(STATEDIR)/virtual-xchain.install

STARPLOT_PATH	=  PATH=$(CROSS_PATH)
STARPLOT_ENV 	=  $(CROSS_ENV)
STARPLOT_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
STARPLOT_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
STARPLOT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#STARPLOT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
STARPLOT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
STARPLOT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
STARPLOT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/starplot.prepare: $(starplot_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(STARPLOT_DIR)/config.cache)
	cd $(STARPLOT_DIR) && \
		$(STARPLOT_PATH) $(STARPLOT_ENV) \
		./configure $(STARPLOT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

starplot_compile: $(STATEDIR)/starplot.compile

starplot_compile_deps = $(STATEDIR)/starplot.prepare

$(STATEDIR)/starplot.compile: $(starplot_compile_deps)
	@$(call targetinfo, $@)
	$(STARPLOT_PATH) $(MAKE) -C $(STARPLOT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

starplot_install: $(STATEDIR)/starplot.install

$(STATEDIR)/starplot.install: $(STATEDIR)/starplot.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

starplot_targetinstall: $(STATEDIR)/starplot.targetinstall

starplot_targetinstall_deps = $(STATEDIR)/starplot.compile

$(STATEDIR)/starplot.targetinstall: $(starplot_targetinstall_deps)
	@$(call targetinfo, $@)
	$(STARPLOT_PATH) $(MAKE) -C $(STARPLOT_DIR) DESTDIR=$(STARPLOT_IPKG_TMP) install
	mkdir -p $(STARPLOT_IPKG_TMP)/CONTROL
	echo "Package: starplot" 										 >$(STARPLOT_IPKG_TMP)/CONTROL/control
	echo "Source: $(STARPLOT_URL)"						>>$(STARPLOT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(STARPLOT_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 											>>$(STARPLOT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(STARPLOT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(STARPLOT_IPKG_TMP)/CONTROL/control
	echo "Version: $(STARPLOT_VERSION)-$(STARPLOT_VENDOR_VERSION)" 						>>$(STARPLOT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 											>>$(STARPLOT_IPKG_TMP)/CONTROL/control
	echo "Description: StarPlot is a program for Unix that allows you to view charts of the relative 3-dimensional positions of stars in space." >>$(STARPLOT_IPKG_TMP)/CONTROL/control
	asasd
	@$(call makeipkg, $(STARPLOT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_STARPLOT_INSTALL
ROMPACKAGES += $(STATEDIR)/starplot.imageinstall
endif

starplot_imageinstall_deps = $(STATEDIR)/starplot.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/starplot.imageinstall: $(starplot_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install starplot
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

starplot_clean:
	rm -rf $(STATEDIR)/starplot.*
	rm -rf $(STARPLOT_DIR)

# vim: syntax=make
