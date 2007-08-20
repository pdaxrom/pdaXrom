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
ifdef PTXCONF_EDE
PACKAGES += ede
endif

#
# Paths and names
#
EDE_VENDOR_VERSION	= 1
EDE_VERSION		= 1.0.4
EDE			= ede-$(EDE_VERSION)
EDE_SUFFIX		= tar.bz2
EDE_URL			= http://citkit.dl.sourceforge.net/sourceforge/ede/$(EDE).$(EDE_SUFFIX)
EDE_SOURCE		= $(SRCDIR)/$(EDE).$(EDE_SUFFIX)
EDE_DIR			= $(BUILDDIR)/ede
EDE_IPKG_TMP		= $(EDE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ede_get: $(STATEDIR)/ede.get

ede_get_deps = $(EDE_SOURCE)

$(STATEDIR)/ede.get: $(ede_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(EDE))
	touch $@

$(EDE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(EDE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ede_extract: $(STATEDIR)/ede.extract

ede_extract_deps = $(STATEDIR)/ede.get

$(STATEDIR)/ede.extract: $(ede_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(EDE_DIR))
	@$(call extract, $(EDE_SOURCE))
	@$(call patchin, $(EDE), $(EDE_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ede_prepare: $(STATEDIR)/ede.prepare

#
# dependencies
#
ede_prepare_deps = \
	$(STATEDIR)/ede.extract \
	$(STATEDIR)/efltk.install \
	$(STATEDIR)/virtual-xchain.install

EDE_PATH	=  PATH=$(CROSS_PATH)
EDE_ENV 	=  $(CROSS_ENV)
#EDE_ENV	+=
EDE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#EDE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
EDE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-optimize \
	--disable-debug \
	--disable-silent

ifdef PTXCONF_XFREE430
EDE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
EDE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ede.prepare: $(ede_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EDE_DIR)/config.cache)
	cd $(EDE_DIR) && \
		$(EDE_PATH) $(EDE_ENV) \
		./configure $(EDE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ede_compile: $(STATEDIR)/ede.compile

ede_compile_deps = $(STATEDIR)/ede.prepare

$(STATEDIR)/ede.compile: $(ede_compile_deps)
	@$(call targetinfo, $@)
	$(EDE_PATH) $(MAKE) -C $(EDE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ede_install: $(STATEDIR)/ede.install

$(STATEDIR)/ede.install: $(STATEDIR)/ede.compile
	@$(call targetinfo, $@)
	rm -rf $(EDE_IPKG_TMP)
	$(EDE_PATH) $(MAKE) -C $(EDE_DIR) DESTDIR=$(EDE_IPKG_TMP) install
	sdfsdf
	rm -rf $(EDE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ede_targetinstall: $(STATEDIR)/ede.targetinstall

ede_targetinstall_deps = $(STATEDIR)/ede.compile \
	$(STATEDIR)/efltk.targetinstall

$(STATEDIR)/ede.targetinstall: $(ede_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(EDE_IPKG_TMP)
	mkdir -p $(EDE_IPKG_TMP)/usr/{bin,lib,share}
	$(EDE_PATH) $(MAKE) -C $(EDE_DIR) prefix=$(EDE_IPKG_TMP)/usr install LOCALEDIR=$(EDE_IPKG_TMP)/usr/share/locale
	for FILE in `find $(EDE_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(EDE_IPKG_TMP)/CONTROL
	echo "Package: ede" 								 >$(EDE_IPKG_TMP)/CONTROL/control
	echo "Source: $(EDE_URL)"							>>$(EDE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(EDE_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(EDE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(EDE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(EDE_IPKG_TMP)/CONTROL/control
	echo "Version: $(EDE_VERSION)-$(EDE_VENDOR_VERSION)" 				>>$(EDE_IPKG_TMP)/CONTROL/control
	echo "Depends: efltk" 								>>$(EDE_IPKG_TMP)/CONTROL/control
	echo "Description: Equinox Desktop Environment (shortly EDE) is small desktop environment, builted to be simple and fast." >>$(EDE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(EDE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_EDE_INSTALL
ROMPACKAGES += $(STATEDIR)/ede.imageinstall
endif

ede_imageinstall_deps = $(STATEDIR)/ede.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ede.imageinstall: $(ede_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ede
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ede_clean:
	rm -rf $(STATEDIR)/ede.*
	rm -rf $(EDE_DIR)

# vim: syntax=make
