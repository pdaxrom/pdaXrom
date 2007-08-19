# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Attila Darazs <zumi@pdaxrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_LESS
PACKAGES += less
endif

#
# Paths and names
#
LESS_VERSION	= 382
LESS		= less-$(LESS_VERSION)
LESS_SUFFIX	= tar.gz
LESS_URL	= ftp://ftp.gnu.org/gnu/less/$(LESS).$(LESS_SUFFIX)
LESS_SOURCE	= $(SRCDIR)/$(LESS).$(LESS_SUFFIX)
LESS_DIR	= $(BUILDDIR)/$(LESS)
LESS_IPKG_TMP	= $(LESS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

less_get: $(STATEDIR)/less.get

less_get_deps = $(LESS_SOURCE)

$(STATEDIR)/less.get: $(less_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LESS))
	touch $@

$(LESS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LESS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

less_extract: $(STATEDIR)/less.extract

less_extract_deps = $(STATEDIR)/less.get

$(STATEDIR)/less.extract: $(less_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LESS_DIR))
	@$(call extract, $(LESS_SOURCE))
	@$(call patchin, $(LESS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

less_prepare: $(STATEDIR)/less.prepare

#
# dependencies
#
less_prepare_deps = \
	$(STATEDIR)/less.extract \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/virtual-xchain.install

LESS_PATH	=  PATH=$(CROSS_PATH)
LESS_ENV 	=  $(CROSS_ENV)
#LESS_ENV	+=
LESS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LESS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LESS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
LESS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LESS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/less.prepare: $(less_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LESS_DIR)/config.cache)
	cd $(LESS_DIR) && \
		$(LESS_PATH) $(LESS_ENV) \
		./configure $(LESS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

less_compile: $(STATEDIR)/less.compile

less_compile_deps = $(STATEDIR)/less.prepare

$(STATEDIR)/less.compile: $(less_compile_deps)
	@$(call targetinfo, $@)
	$(LESS_PATH) $(MAKE) -C $(LESS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

less_install: $(STATEDIR)/less.install

$(STATEDIR)/less.install: $(STATEDIR)/less.compile
	@$(call targetinfo, $@)
	$(LESS_PATH) $(MAKE) -C $(LESS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

less_targetinstall: $(STATEDIR)/less.targetinstall

less_targetinstall_deps = $(STATEDIR)/less.compile \
	$(STATEDIR)/ncurses.targetinstall

$(STATEDIR)/less.targetinstall: $(less_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(LESS_PATH) $(MAKE) -C $(LESS_DIR) DESTDIR=$(LESS_IPKG_TMP) install
	mkdir -p $(LESS_IPKG_TMP)/usr/bin
	cp $(LESS_DIR)/less $(LESS_IPKG_TMP)/usr/bin/
	$(CROSSSTRIP) $(LESS_IPKG_TMP)/usr/bin/less
	mkdir -p $(LESS_IPKG_TMP)/CONTROL
	echo "Package: less" 							 >$(LESS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LESS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(LESS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Attila Darazs <zumi@pdaxrom.org>" 				>>$(LESS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LESS_IPKG_TMP)/CONTROL/control
	echo "Version: $(LESS_VERSION)" 						>>$(LESS_IPKG_TMP)/CONTROL/control
	echo "Depends: ncurses" 							>>$(LESS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(LESS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LESS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LESS_INSTALL
ROMPACKAGES += $(STATEDIR)/less.imageinstall
endif

less_imageinstall_deps = $(STATEDIR)/less.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/less.imageinstall: $(less_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install less
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

less_clean:
	rm -rf $(STATEDIR)/less.*
	rm -rf $(LESS_DIR)

# vim: syntax=make
