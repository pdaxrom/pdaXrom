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
ifdef PTXCONF_FCRON
PACKAGES += fcron
endif

#
# Paths and names
#
FCRON_VENDOR_VERSION	= 1
FCRON_VERSION		= 3.0.1
FCRON			= fcron-$(FCRON_VERSION)
FCRON_SUFFIX		= tar.gz
FCRON_URL		= http://fcron.free.fr/archives/$(FCRON).src.$(FCRON_SUFFIX)
FCRON_SOURCE		= $(SRCDIR)/$(FCRON).src.$(FCRON_SUFFIX)
FCRON_DIR		= $(BUILDDIR)/$(FCRON)
FCRON_IPKG_TMP		= $(FCRON_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fcron_get: $(STATEDIR)/fcron.get

fcron_get_deps = $(FCRON_SOURCE)

$(STATEDIR)/fcron.get: $(fcron_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FCRON))
	touch $@

$(FCRON_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FCRON_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fcron_extract: $(STATEDIR)/fcron.extract

fcron_extract_deps = $(STATEDIR)/fcron.get

$(STATEDIR)/fcron.extract: $(fcron_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FCRON_DIR))
	@$(call extract, $(FCRON_SOURCE))
	@$(call patchin, $(FCRON))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fcron_prepare: $(STATEDIR)/fcron.prepare

#
# dependencies
#
fcron_prepare_deps = \
	$(STATEDIR)/fcron.extract \
	$(STATEDIR)/virtual-xchain.install

FCRON_PATH	=  PATH=$(CROSS_PATH)
FCRON_ENV 	=  $(CROSS_ENV)
#FCRON_ENV	+=
FCRON_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FCRON_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
FCRON_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--with-sendmail=/usr/sbin \
	--with-editor=/usr/bin/mcedit \
	--with-username=nobody \
	--with-groupname=nobody

ifdef PTXCONF_XFREE430
FCRON_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FCRON_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fcron.prepare: $(fcron_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FCRON_DIR)/config.cache)
	cd $(FCRON_DIR) && \
		$(FCRON_PATH) $(FCRON_ENV) \
		./configure $(FCRON_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fcron_compile: $(STATEDIR)/fcron.compile

fcron_compile_deps = $(STATEDIR)/fcron.prepare

$(STATEDIR)/fcron.compile: $(fcron_compile_deps)
	@$(call targetinfo, $@)
	$(FCRON_PATH) $(MAKE) -C $(FCRON_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fcron_install: $(STATEDIR)/fcron.install

$(STATEDIR)/fcron.install: $(STATEDIR)/fcron.compile
	@$(call targetinfo, $@)
	rm -rf $(FCRON_IPKG_TMP)
	$(FCRON_PATH) $(MAKE) -C $(FCRON_DIR) DESTDIR=$(FCRON_IPKG_TMP) install
	@$(call copyincludes, $(FCRON_IPKG_TMP))
	@$(call copylibraries,$(FCRON_IPKG_TMP))
	@$(call copymiscfiles,$(FCRON_IPKG_TMP))
	rm -rf $(FCRON_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fcron_targetinstall: $(STATEDIR)/fcron.targetinstall

fcron_targetinstall_deps = $(STATEDIR)/fcron.compile

FCRON_DEPLIST = 

$(STATEDIR)/fcron.targetinstall: $(fcron_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FCRON_PATH) $(MAKE) -C $(FCRON_DIR) DESTDIR=$(FCRON_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(FCRON_VERSION)-$(FCRON_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh fcron $(FCRON_IPKG_TMP)

	@$(call removedevfiles, $(FCRON_IPKG_TMP))
	@$(call stripfiles, $(FCRON_IPKG_TMP))
	mkdir -p $(FCRON_IPKG_TMP)/CONTROL
	echo "Package: fcron" 								 >$(FCRON_IPKG_TMP)/CONTROL/control
	echo "Source: $(FCRON_URL)"							>>$(FCRON_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(FCRON_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(FCRON_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(FCRON_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(FCRON_IPKG_TMP)/CONTROL/control
	echo "Version: $(FCRON_VERSION)-$(FCRON_VENDOR_VERSION)" 			>>$(FCRON_IPKG_TMP)/CONTROL/control
	echo "Depends: $(FCRON_DEPLIST)" 						>>$(FCRON_IPKG_TMP)/CONTROL/control
	echo "Description: Fcron is a periodical command scheduler which aims at replacing Vixie Cron, so it implements most of its functionalities." >>$(FCRON_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FCRON_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FCRON_INSTALL
ROMPACKAGES += $(STATEDIR)/fcron.imageinstall
endif

fcron_imageinstall_deps = $(STATEDIR)/fcron.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fcron.imageinstall: $(fcron_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fcron
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fcron_clean:
	rm -rf $(STATEDIR)/fcron.*
	rm -rf $(FCRON_DIR)

# vim: syntax=make
