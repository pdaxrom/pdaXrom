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
ifdef PTXCONF_PYGTK
PACKAGES += pygtk
endif

#
# Paths and names
#
PYGTK_VENDOR_VERSION	= 1
PYGTK_VERSION		= 2.9.6
PYGTK			= pygtk-$(PYGTK_VERSION)
PYGTK_SUFFIX		= tar.bz2
PYGTK_URL		= http://ftp.acc.umu.se/pub/gnome/sources/pygtk/2.9/$(PYGTK).$(PYGTK_SUFFIX)
PYGTK_SOURCE		= $(SRCDIR)/$(PYGTK).$(PYGTK_SUFFIX)
PYGTK_DIR		= $(BUILDDIR)/$(PYGTK)
PYGTK_IPKG_TMP		= $(PYGTK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pygtk_get: $(STATEDIR)/pygtk.get

pygtk_get_deps = $(PYGTK_SOURCE)

$(STATEDIR)/pygtk.get: $(pygtk_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PYGTK))
	touch $@

$(PYGTK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PYGTK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pygtk_extract: $(STATEDIR)/pygtk.extract

pygtk_extract_deps = $(STATEDIR)/pygtk.get

$(STATEDIR)/pygtk.extract: $(pygtk_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYGTK_DIR))
	@$(call extract, $(PYGTK_SOURCE))
	@$(call patchin, $(PYGTK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pygtk_prepare: $(STATEDIR)/pygtk.prepare

#
# dependencies
#
pygtk_prepare_deps = \
	$(STATEDIR)/pygtk.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libglade.install \
	$(STATEDIR)/python.install \
	$(STATEDIR)/xchain-python.install \
	$(STATEDIR)/dbus.install \
	$(STATEDIR)/pygobject.install \
	$(STATEDIR)/pycairo.install \
	$(STATEDIR)/virtual-xchain.install

PYGTK_PATH	=  PATH=$(CROSS_PATH)
PYGTK_ENV 	=  $(CROSS_ENV)
PYGTK_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
PYGTK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PYGTK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
PYGTK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-shared \
	--disable-static \
	--libexecdir=/usr/bin \
	--disable-debug \
	--disable-docs

ifdef PTXCONF_XFREE430
PYGTK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PYGTK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pygtk.prepare: $(pygtk_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYGTK_DIR)/config.cache)
	cd $(PYGTK_DIR) && \
		$(PYGTK_PATH) $(PYGTK_ENV) \
		./configure $(PYGTK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pygtk_compile: $(STATEDIR)/pygtk.compile

pygtk_compile_deps = $(STATEDIR)/pygtk.prepare

$(STATEDIR)/pygtk.compile: $(pygtk_compile_deps)
	@$(call targetinfo, $@)
	$(PYGTK_PATH) $(MAKE) -C $(PYGTK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pygtk_install: $(STATEDIR)/pygtk.install

$(STATEDIR)/pygtk.install: $(STATEDIR)/pygtk.compile
	@$(call targetinfo, $@)
	rm -rf $(PYGTK_IPKG_TMP)
	$(PYGTK_PATH) $(MAKE) -C $(PYGTK_DIR) DESTDIR=$(PYGTK_IPKG_TMP) install
	@$(call copyincludes, $(PYGTK_IPKG_TMP))
	@$(call copylibraries,$(PYGTK_IPKG_TMP))
	@$(call copymiscfiles,$(PYGTK_IPKG_TMP))

	mkdir -p $(CROSS_LIB_DIR)/share/pygtk/2.0/codegen
	mkdir -p $(CROSS_LIB_DIR)/share/pygtk/2.0/defs
	
	cp -a $(PYGTK_DIR)/*.defs 	$(CROSS_LIB_DIR)/share/pygtk/2.0/defs/
	cp -a $(PYGTK_DIR)/gtk/*.defs 	$(CROSS_LIB_DIR)/share/pygtk/2.0/defs/
	cp -a $(PYGTK_DIR)/codegen/*.py $(CROSS_LIB_DIR)/share/pygtk/2.0/codegen
	cp -a $(PYGTK_DIR)/codegen/pygtk-codegen-2.0.in 	$(PTXCONF_PREFIX)/bin/pygtk-codegen-2.0
	perl -i -p -e "s,\@datadir\@,$(CROSS_LIB_DIR)/share,g"	$(PTXCONF_PREFIX)/bin/pygtk-codegen-2.0
	perl -i -p -e "s,\@PYTHON\@,$(PTXCONF_PREFIX)/bin/python,g" $(PTXCONF_PREFIX)/bin/pygtk-codegen-2.0

	chmod 755 $(PTXCONF_PREFIX)/bin/pygtk-codegen-2.0

	rm -rf $(PYGTK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pygtk_targetinstall: $(STATEDIR)/pygtk.targetinstall

pygtk_targetinstall_deps = $(STATEDIR)/pygtk.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libglade.targetinstall \
	$(STATEDIR)/dbus.targetinstall \
	$(STATEDIR)/pygobject.targetinstall \
	$(STATEDIR)/pycairo.targetinstall \
	$(STATEDIR)/python.targetinstall

$(STATEDIR)/pygtk.targetinstall: $(pygtk_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PYGTK_PATH) $(MAKE) -C $(PYGTK_DIR) DESTDIR=$(PYGTK_IPKG_TMP) install

	perl -i -p -e "s,$(PTXCONF_NATIVE_PREFIX),/usr,g" $(PYGTK_IPKG_TMP)/usr/bin/pygtk-codegen-2.0

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(PYGTK_VERSION)-$(PYGTK_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh pygtk $(PYGTK_IPKG_TMP)

	@$(call removedevfiles, $(PYGTK_IPKG_TMP))
	@$(call stripfiles, $(PYGTK_IPKG_TMP))
	mkdir -p $(PYGTK_IPKG_TMP)/CONTROL
	echo "Package: pygtk" 								 >$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Source: $(PYGTK_URL)"							>>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Section: ROX"	 							>>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Version: $(PYGTK_VERSION)-$(PYGTK_VENDOR_VERSION)" 			>>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, python-core, python-codecs, python-fcntl, python-stringold, python-xml, pygobject, pycairo, libglade" >>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Description: Modules that allow you to use gtk in Python programs."	>>$(PYGTK_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(PYGTK_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PYGTK_INSTALL
ROMPACKAGES += $(STATEDIR)/pygtk.imageinstall
endif

pygtk_imageinstall_deps = $(STATEDIR)/pygtk.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pygtk.imageinstall: $(pygtk_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pygtk
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pygtk_clean:
	rm -rf $(STATEDIR)/pygtk.*
	rm -rf $(PYGTK_DIR)

# vim: syntax=make
