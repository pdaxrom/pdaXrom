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
ifdef PTXCONF_VTE
PACKAGES += vte
endif

#
# Paths and names
#
VTE_VENDOR_VERSION	= 1
VTE_VERSION		= 0.11.15
VTE			= vte-$(VTE_VERSION)
VTE_SUFFIX		= tar.bz2
VTE_URL			= http://ftp.gnome.org/pub/GNOME/sources/vte/0.11/$(VTE).$(VTE_SUFFIX)
VTE_SOURCE		= $(SRCDIR)/$(VTE).$(VTE_SUFFIX)
VTE_DIR			= $(BUILDDIR)/$(VTE)
VTE_IPKG_TMP		= $(VTE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

vte_get: $(STATEDIR)/vte.get

vte_get_deps = $(VTE_SOURCE)

$(STATEDIR)/vte.get: $(vte_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(VTE))
	touch $@

$(VTE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(VTE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

vte_extract: $(STATEDIR)/vte.extract

vte_extract_deps = $(STATEDIR)/vte.get

$(STATEDIR)/vte.extract: $(vte_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VTE_DIR))
	@$(call extract, $(VTE_SOURCE))
	@$(call patchin, $(VTE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

vte_prepare: $(STATEDIR)/vte.prepare

#
# dependencies
#
vte_prepare_deps = \
	$(STATEDIR)/vte.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

VTE_PATH	=  PATH=$(CROSS_PATH)
VTE_ENV 	=  $(CROSS_ENV)
#VTE_ENV	+=
VTE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#VTE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
VTE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-static \
	--enable-shared \
	--disable-debug \
	--libexecdir=/usr/sbin

ifdef PTXCONF_XFREE430
VTE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
VTE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/vte.prepare: $(vte_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VTE_DIR)/config.cache)
	cd $(VTE_DIR) && \
		$(VTE_PATH) $(VTE_ENV) \
		./configure $(VTE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

vte_compile: $(STATEDIR)/vte.compile

vte_compile_deps = $(STATEDIR)/vte.prepare

$(STATEDIR)/vte.compile: $(vte_compile_deps)
	@$(call targetinfo, $@)
	$(VTE_PATH) $(MAKE) -C $(VTE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

vte_install: $(STATEDIR)/vte.install

$(STATEDIR)/vte.install: $(STATEDIR)/vte.compile
	@$(call targetinfo, $@)
	rm -rf $(VTE_IPKG_TMP)
	$(VTE_PATH) $(MAKE) -C $(VTE_DIR) DESTDIR=$(VTE_IPKG_TMP) install

	cp -a $(VTE_IPKG_TMP)/usr/include/*			$(CROSS_LIB_DIR)/include/
	cp -a $(VTE_IPKG_TMP)/usr/lib/{*.la,*.so*,pkgconfig}	$(CROSS_LIB_DIR)/lib/
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g"	$(CROSS_LIB_DIR)/lib/libvte.la
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR)/lib,g"		$(CROSS_LIB_DIR)/lib/pkgconfig/vte.pc

	rm -rf $(VTE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

vte_targetinstall: $(STATEDIR)/vte.targetinstall

vte_targetinstall_deps = $(STATEDIR)/vte.compile \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/vte.targetinstall: $(vte_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(VTE_IPKG_TMP)
	$(VTE_PATH) $(MAKE) -C $(VTE_DIR) DESTDIR=$(VTE_IPKG_TMP) install
	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(VTE_VERSION)-$(VTE_VENDOR_VERSION) 		\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh vte $(VTE_IPKG_TMP)
	rm -rf $(VTE_IPKG_TMP)/usr/include
	rm -rf $(VTE_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(VTE_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(VTE_IPKG_TMP)/usr/lib/python2.4/site-packages/gtk-2.0/*.la
	rm -rf $(VTE_IPKG_TMP)/usr/share/gtk-doc
	rm -rf $(VTE_IPKG_TMP)/usr/share/locale
	for FILE in `find $(VTE_IPKG_TMP)/usr/ -type f`; do			\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;				\
	    if [  "$$ZZZ" != "" ]; then						\
		$(CROSSSTRIP) $$FILE;						\
	    fi;									\
	done
	mkdir -p $(VTE_IPKG_TMP)/CONTROL
	echo "Package: vte" 								 >$(VTE_IPKG_TMP)/CONTROL/control
	echo "Source: $(VTE_URL)"							>>$(VTE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(VTE_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(VTE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(VTE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(VTE_IPKG_TMP)/CONTROL/control
	echo "Version: $(VTE_VERSION)-$(VTE_VENDOR_VERSION)" 				>>$(VTE_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 								>>$(VTE_IPKG_TMP)/CONTROL/control
	echo "Description: vte terminal widget"						>>$(VTE_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(VTE_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_VTE_INSTALL
ROMPACKAGES += $(STATEDIR)/vte.imageinstall
endif

vte_imageinstall_deps = $(STATEDIR)/vte.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/vte.imageinstall: $(vte_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install vte
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

vte_clean:
	rm -rf $(STATEDIR)/vte.*
	rm -rf $(VTE_DIR)

# vim: syntax=make
