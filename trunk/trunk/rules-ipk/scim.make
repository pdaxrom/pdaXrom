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
ifdef PTXCONF_SCIM
PACKAGES += scim
endif

#
# Paths and names
#
SCIM_VENDOR_VERSION	= 1
SCIM_VERSION		= 1.4.0
SCIM			= scim-$(SCIM_VERSION)
SCIM_SUFFIX		= tar.gz
SCIM_URL		= http://peterhost.dl.sourceforge.net/sourceforge/scim/$(SCIM).$(SCIM_SUFFIX)
SCIM_SOURCE		= $(SRCDIR)/$(SCIM).$(SCIM_SUFFIX)
SCIM_DIR		= $(BUILDDIR)/$(SCIM)
SCIM_IPKG_TMP		= $(SCIM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

scim_get: $(STATEDIR)/scim.get

scim_get_deps = $(SCIM_SOURCE)

$(STATEDIR)/scim.get: $(scim_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SCIM))
	touch $@

$(SCIM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SCIM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

scim_extract: $(STATEDIR)/scim.extract

scim_extract_deps = $(STATEDIR)/scim.get

$(STATEDIR)/scim.extract: $(scim_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCIM_DIR))
	@$(call extract, $(SCIM_SOURCE))
	@$(call patchin, $(SCIM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

scim_prepare: $(STATEDIR)/scim.prepare

#
# dependencies
#
scim_prepare_deps = \
	$(STATEDIR)/scim.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

SCIM_PATH	=  PATH=$(CROSS_PATH)
SCIM_ENV 	=  $(CROSS_ENV)
ifdef PTXCONF_LIBICONV
SCIM_ENV	+= LDFLAGS="-liconv"
endif
SCIM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SCIM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SCIM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--sysconfdir=/etc

ifdef PTXCONF_LIBICONV
SCIM_AUTOCONF += --with-libiconv-prefix=$(CROSS_LIB_DIR)
endif

ifdef PTXCONF_XFREE430
SCIM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SCIM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/scim.prepare: $(scim_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCIM_DIR)/config.cache)
	cd $(SCIM_DIR) && \
		$(SCIM_PATH) $(SCIM_ENV) \
		./configure $(SCIM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

scim_compile: $(STATEDIR)/scim.compile

scim_compile_deps = $(STATEDIR)/scim.prepare

$(STATEDIR)/scim.compile: $(scim_compile_deps)
	@$(call targetinfo, $@)
	$(SCIM_PATH) $(MAKE) -C $(SCIM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

scim_install: $(STATEDIR)/scim.install

$(STATEDIR)/scim.install: $(STATEDIR)/scim.compile
	@$(call targetinfo, $@)
	rm -rf $(SCIM_IPKG_TMP)
	$(SCIM_PATH) $(MAKE) -C $(SCIM_DIR) DESTDIR=$(SCIM_IPKG_TMP) install
	rm -rf $(SCIM_IPKG_TMP)/usr/lib/scim-1.0
	
	cp -a $(SCIM_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(SCIM_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib/
	
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libscim-1.0.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libscim-gtkutils-1.0.la
	perl -i -p -e "s,/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libscim-x11utils-1.0.la

	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/scim.pc
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/scim-gtkutils.pc
	perl -i -p -e "s,/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/scim-x11utils.pc

	rm -rf $(SCIM_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

scim_targetinstall: $(STATEDIR)/scim.targetinstall

scim_targetinstall_deps = $(STATEDIR)/scim.compile \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/scim.targetinstall: $(scim_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SCIM_PATH) $(MAKE) -C $(SCIM_DIR) DESTDIR=$(SCIM_IPKG_TMP) install
	mkdir -p $(SCIM_IPKG_TMP)/usr/lib/gtk-2.0/2.4.0/immodules/
	mv -f $(SCIM_IPKG_TMP)/$(CROSS_LIB_DIR)/lib/gtk-2.0/immodules/*.so $(SCIM_IPKG_TMP)/usr/lib/gtk-2.0/2.4.0/immodules/
	rm -rf $(SCIM_IPKG_TMP)/opt
	rm -rf $(SCIM_IPKG_TMP)/usr/include
	rm -rf $(SCIM_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(SCIM_IPKG_TMP)/usr/share/control-center-2.0
	cd $(SCIM_IPKG_TMP)/usr && find -name *.la | xargs rm -f
	for FILE in `find $(SCIM_IPKG_TMP)/usr -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;		\
	    if [  "$$ZZZ" != "" ]; then				\
		$(CROSSSTRIP) $$FILE;				\
	    fi;							\
	done
	mkdir -p $(SCIM_IPKG_TMP)/CONTROL
	echo "Package: scim" 								 >$(SCIM_IPKG_TMP)/CONTROL/control
	echo "Source: $(SCIM_URL)"						>>$(SCIM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SCIM_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(SCIM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SCIM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SCIM_IPKG_TMP)/CONTROL/control
	echo "Version: $(SCIM_VERSION)-$(SCIM_VENDOR_VERSION)" 				>>$(SCIM_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 								>>$(SCIM_IPKG_TMP)/CONTROL/control
	echo "Description: Smart Common Input Method platform project"			>>$(SCIM_IPKG_TMP)/CONTROL/control

	echo "#!/bin/sh"								 >$(SCIM_IPKG_TMP)/CONTROL/postinst
	echo "/usr/bin/gtk-query-immodules-2.0 > /etc/gtk-2.0/gtk.immodules" 		>>$(SCIM_IPKG_TMP)/CONTROL/postinst

	chmod 755 $(SCIM_IPKG_TMP)/CONTROL/postinst

	cd $(FEEDDIR) && $(XMKIPKG) $(SCIM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SCIM_INSTALL
ROMPACKAGES += $(STATEDIR)/scim.imageinstall
endif

scim_imageinstall_deps = $(STATEDIR)/scim.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/scim.imageinstall: $(scim_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install scim
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

scim_clean:
	rm -rf $(STATEDIR)/scim.*
	rm -rf $(SCIM_DIR)

# vim: syntax=make
