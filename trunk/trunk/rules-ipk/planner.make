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
ifdef PTXCONF_PLANNER
PACKAGES += planner
endif

#
# Paths and names
#
PLANNER_VENDOR_VERSION	= 1
PLANNER_VERSION		= 0.13
PLANNER			= planner-$(PLANNER_VERSION)
PLANNER_SUFFIX		= tar.bz2
PLANNER_URL		= http://ftp.gnome.org/pub/GNOME/sources/planner/$(PLANNER_VERSION)/$(PLANNER).$(PLANNER_SUFFIX)
PLANNER_SOURCE		= $(SRCDIR)/$(PLANNER).$(PLANNER_SUFFIX)
PLANNER_DIR		= $(BUILDDIR)/$(PLANNER)
PLANNER_IPKG_TMP	= $(PLANNER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

planner_get: $(STATEDIR)/planner.get

planner_get_deps = $(PLANNER_SOURCE)

$(STATEDIR)/planner.get: $(planner_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PLANNER))
	touch $@

$(PLANNER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PLANNER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

planner_extract: $(STATEDIR)/planner.extract

planner_extract_deps = $(STATEDIR)/planner.get

$(STATEDIR)/planner.extract: $(planner_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PLANNER_DIR))
	@$(call extract, $(PLANNER_SOURCE))
	@$(call patchin, $(PLANNER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

planner_prepare: $(STATEDIR)/planner.prepare

#
# dependencies
#
planner_prepare_deps = \
	$(STATEDIR)/planner.extract \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/atk124.install \
	$(STATEDIR)/pango12.install \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libglade.install \
	$(STATEDIR)/libgsf.install \
	$(STATEDIR)/libgnome.install \
	$(STATEDIR)/libgnomeui.install \
	$(STATEDIR)/libgnomeprint.install \
	$(STATEDIR)/libgnomeprintui.install \
	$(STATEDIR)/libxslt.install \
	$(STATEDIR)/virtual-xchain.install

PLANNER_PATH	=  PATH=$(CROSS_PATH)
PLANNER_ENV 	=  $(CROSS_ENV)
PLANNER_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
PLANNER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PLANNER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PLANNER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_ARCH_X86
PLANNER_AUTOCONF += --disable-schemas-install
endif

ifdef PTXCONF_XFREE430
PLANNER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PLANNER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/planner.prepare: $(planner_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PLANNER_DIR)/config.cache)
	cd $(PLANNER_DIR) && \
		$(PLANNER_PATH) $(PLANNER_ENV) \
		./configure $(PLANNER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

planner_compile: $(STATEDIR)/planner.compile

planner_compile_deps = $(STATEDIR)/planner.prepare

$(STATEDIR)/planner.compile: $(planner_compile_deps)
	@$(call targetinfo, $@)
	$(PLANNER_PATH) $(MAKE) -C $(PLANNER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

planner_install: $(STATEDIR)/planner.install

$(STATEDIR)/planner.install: $(STATEDIR)/planner.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

planner_targetinstall: $(STATEDIR)/planner.targetinstall

planner_targetinstall_deps = $(STATEDIR)/planner.compile \
	$(STATEDIR)/libglade.targetinstall \
	$(STATEDIR)/libgsf.targetinstall \
	$(STATEDIR)/libgnome.targetinstall \
	$(STATEDIR)/libgnomeui.targetinstall \
	$(STATEDIR)/libgnomeprint.targetinstall \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libxslt.targetinstall

$(STATEDIR)/planner.targetinstall: $(planner_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PLANNER_PATH) $(MAKE) -C $(PLANNER_DIR) DESTDIR=$(PLANNER_IPKG_TMP) install
	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(PLANNER_VERSION)-$(PLANNER_VENDOR_VERSION) 		\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh planner $(PLANNER_IPKG_TMP)
	rm -rf $(PLANNER_IPKG_TMP)/usr/include
	rm -rf $(PLANNER_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(PLANNER_IPKG_TMP)/usr/lib/*.la
	rm -rf $(PLANNER_IPKG_TMP)/usr/share/locale
	rm -rf $(PLANNER_IPKG_TMP)/usr/share/mime/{XMLnamespaces,globs,magic}

	for FILE in `find $(PLANNER_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done

	mkdir -p $(PLANNER_IPKG_TMP)/CONTROL
	echo "Package: planner" 							 >$(PLANNER_IPKG_TMP)/CONTROL/control
	echo "Source: $(PLANNER_URL)"						>>$(PLANNER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PLANNER_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 								>>$(PLANNER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PLANNER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PLANNER_IPKG_TMP)/CONTROL/control
	echo "Version: $(PLANNER_VERSION)-$(PLANNER_VENDOR_VERSION)" 			>>$(PLANNER_IPKG_TMP)/CONTROL/control
	echo "Depends: libgnomeui, gnome-keyring, libbonoboui, libgnome, esound, libglade, libgnomeprintui, libgnomecanvas, gnome-vfs, gconf, orbit2" >>$(PLANNER_IPKG_TMP)/CONTROL/control
	echo "Description: Planner is a tool for planning, scheduling and tracking projects." >>$(PLANNER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PLANNER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PLANNER_INSTALL
ROMPACKAGES += $(STATEDIR)/planner.imageinstall
endif

planner_imageinstall_deps = $(STATEDIR)/planner.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/planner.imageinstall: $(planner_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install planner
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

planner_clean:
	rm -rf $(STATEDIR)/planner.*
	rm -rf $(PLANNER_DIR)

# vim: syntax=make
