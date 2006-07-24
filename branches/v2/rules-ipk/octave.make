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
ifdef PTXCONF_OCTAVE
PACKAGES += octave
endif

#
# Paths and names
#
OCTAVE_VENDOR_VERSION	= 1
OCTAVE_VERSION		= 2.9.3
OCTAVE			= octave-$(OCTAVE_VERSION)
OCTAVE_SUFFIX		= tar.bz2
OCTAVE_URL		= ftp://ftp.octave.org/pub/octave/bleeding-edge/$(OCTAVE).$(OCTAVE_SUFFIX)
OCTAVE_SOURCE		= $(SRCDIR)/$(OCTAVE).$(OCTAVE_SUFFIX)
OCTAVE_DIR		= $(BUILDDIR)/$(OCTAVE)
OCTAVE_IPKG_TMP		= $(OCTAVE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

octave_get: $(STATEDIR)/octave.get

octave_get_deps = $(OCTAVE_SOURCE)

$(STATEDIR)/octave.get: $(octave_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OCTAVE))
	touch $@

$(OCTAVE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OCTAVE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

octave_extract: $(STATEDIR)/octave.extract

octave_extract_deps = $(STATEDIR)/octave.get

$(STATEDIR)/octave.extract: $(octave_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OCTAVE_DIR))
	@$(call extract, $(OCTAVE_SOURCE))
	@$(call patchin, $(OCTAVE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

octave_prepare: $(STATEDIR)/octave.prepare

#
# dependencies
#
octave_prepare_deps = \
	$(STATEDIR)/octave.extract \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/readline.install \
	$(STATEDIR)/virtual-xchain.install

OCTAVE_PATH	=  PATH=$(CROSS_PATH)
OCTAVE_ENV 	=  $(CROSS_ENV)
OCTAVE_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
OCTAVE_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
OCTAVE_ENV	+= FFLAGS="$(TARGET_OPT_CFLAGS)"
OCTAVE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OCTAVE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
OCTAVE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
OCTAVE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OCTAVE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/octave.prepare: $(octave_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OCTAVE_DIR)/config.cache)
	cd $(OCTAVE_DIR) && \
		$(OCTAVE_PATH) $(OCTAVE_ENV) \
		./configure $(OCTAVE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

octave_compile: $(STATEDIR)/octave.compile

octave_compile_deps = $(STATEDIR)/octave.prepare

$(STATEDIR)/octave.compile: $(octave_compile_deps)
	@$(call targetinfo, $@)
	$(OCTAVE_PATH) $(MAKE) -C $(OCTAVE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

octave_install: $(STATEDIR)/octave.install

$(STATEDIR)/octave.install: $(STATEDIR)/octave.compile
	@$(call targetinfo, $@)
	##$(OCTAVE_PATH) $(MAKE) -C $(OCTAVE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

octave_targetinstall: $(STATEDIR)/octave.targetinstall

octave_targetinstall_deps = $(STATEDIR)/octave.compile \
	$(STATEDIR)/zlib.targetinstall \
	$(STATEDIR)/readline.targetinstall

$(STATEDIR)/octave.targetinstall: $(octave_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OCTAVE_PATH) $(MAKE) -C $(OCTAVE_DIR) DESTDIR=$(OCTAVE_IPKG_TMP) install
	rm -rf $(OCTAVE_IPKG_TMP)/usr/include
	rm -rf $(OCTAVE_IPKG_TMP)/usr/info
	rm -rf $(OCTAVE_IPKG_TMP)/usr/man

	for FILE in `find $(OCTAVE_IPKG_TMP)/usr -type f`; do			\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;				\
	    if [  "$$ZZZ" != "" ]; then						\
		$(CROSSSTRIP) $$FILE;						\
	    fi;									\
	done

	mkdir -p $(OCTAVE_IPKG_TMP)/CONTROL
	echo "Package: octave" 								 >$(OCTAVE_IPKG_TMP)/CONTROL/control
	echo "Source: $(OCTAVE_URL)"						>>$(OCTAVE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(OCTAVE_IPKG_TMP)/CONTROL/control
	echo "Section: Meth" 								>>$(OCTAVE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(OCTAVE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(OCTAVE_IPKG_TMP)/CONTROL/control
	echo "Version: $(OCTAVE_VERSION)-$(OCTAVE_VENDOR_VERSION)" 			>>$(OCTAVE_IPKG_TMP)/CONTROL/control
	echo "Depends: readline, libz, libg2c" 						>>$(OCTAVE_IPKG_TMP)/CONTROL/control
	echo "Description: high-level language, primarily intended for numerical computations."	>>$(OCTAVE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OCTAVE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OCTAVE_INSTALL
ROMPACKAGES += $(STATEDIR)/octave.imageinstall
endif

octave_imageinstall_deps = $(STATEDIR)/octave.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/octave.imageinstall: $(octave_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install octave
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

octave_clean:
	rm -rf $(STATEDIR)/octave.*
	rm -rf $(OCTAVE_DIR)

# vim: syntax=make
