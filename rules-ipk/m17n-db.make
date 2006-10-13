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
ifdef PTXCONF_M17N-DB
PACKAGES += m17n-db
endif

#
# Paths and names
#
M17N-DB_VENDOR_VERSION	= 1
M17N-DB_VERSION		= 1.2.0
M17N-DB			= m17n-db-$(M17N-DB_VERSION)
M17N-DB_SUFFIX		= tar.gz
M17N-DB_URL		= http://www.m17n.org/m17n-lib/download/$(M17N-DB).$(M17N-DB_SUFFIX)
M17N-DB_SOURCE		= $(SRCDIR)/$(M17N-DB).$(M17N-DB_SUFFIX)
M17N-DB_DIR		= $(BUILDDIR)/$(M17N-DB)
M17N-DB_IPKG_TMP	= $(M17N-DB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

m17n-db_get: $(STATEDIR)/m17n-db.get

m17n-db_get_deps = $(M17N-DB_SOURCE)

$(STATEDIR)/m17n-db.get: $(m17n-db_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(M17N-DB))
	touch $@

$(M17N-DB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(M17N-DB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

m17n-db_extract: $(STATEDIR)/m17n-db.extract

m17n-db_extract_deps = $(STATEDIR)/m17n-db.get

$(STATEDIR)/m17n-db.extract: $(m17n-db_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(M17N-DB_DIR))
	@$(call extract, $(M17N-DB_SOURCE), $(M17N-DB_DIR)/ipkg_tmp/usr/share)
	@$(call patchin, $(M17N-DB))
	mv $(M17N-DB_DIR)/ipkg_tmp/usr/share/m17n-db-1.2.0 $(M17N-DB_DIR)/ipkg_tmp/usr/share/m17n
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

m17n-db_prepare: $(STATEDIR)/m17n-db.prepare

#
# dependencies
#
m17n-db_prepare_deps = \
	$(STATEDIR)/m17n-db.extract \
	$(STATEDIR)/virtual-xchain.install

M17N-DB_PATH	=  PATH=$(CROSS_PATH)
M17N-DB_ENV 	=  $(CROSS_ENV)
#M17N-DB_ENV	+=
M17N-DB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#M17N-DB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
M17N-DB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
M17N-DB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
M17N-DB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/m17n-db.prepare: $(m17n-db_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(M17N-DB_DIR)/config.cache)
	#cd $(M17N-DB_DIR) && \
	#	$(M17N-DB_PATH) $(M17N-DB_ENV) \
	#	./configure $(M17N-DB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

m17n-db_compile: $(STATEDIR)/m17n-db.compile

m17n-db_compile_deps = $(STATEDIR)/m17n-db.prepare

$(STATEDIR)/m17n-db.compile: $(m17n-db_compile_deps)
	@$(call targetinfo, $@)
	#$(M17N-DB_PATH) $(MAKE) -C $(M17N-DB_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

m17n-db_install: $(STATEDIR)/m17n-db.install

$(STATEDIR)/m17n-db.install: $(STATEDIR)/m17n-db.compile
	@$(call targetinfo, $@)
	#$(M17N-DB_PATH) $(MAKE) -C $(M17N-DB_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

m17n-db_targetinstall: $(STATEDIR)/m17n-db.targetinstall

m17n-db_targetinstall_deps = $(STATEDIR)/m17n-db.compile

$(STATEDIR)/m17n-db.targetinstall: $(m17n-db_targetinstall_deps)
	@$(call targetinfo, $@)
	##$(M17N-DB_PATH) $(MAKE) -C $(M17N-DB_DIR) DESTDIR=$(M17N-DB_IPKG_TMP) install
	mkdir -p $(M17N-DB_IPKG_TMP)/CONTROL
	echo "Package: m17n-db" 							 >$(M17N-DB_IPKG_TMP)/CONTROL/control
	echo "Source: $(M17N-DB_URL)"						>>$(M17N-DB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(M17N-DB_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(M17N-DB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(M17N-DB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(M17N-DB_IPKG_TMP)/CONTROL/control
	echo "Version: $(M17N-DB_VERSION)-$(M17N-DB_VENDOR_VERSION)" 			>>$(M17N-DB_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(M17N-DB_IPKG_TMP)/CONTROL/control
	echo "Description: m17n database"						>>$(M17N-DB_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(M17N-DB_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_M17N-DB_INSTALL
ROMPACKAGES += $(STATEDIR)/m17n-db.imageinstall
endif

m17n-db_imageinstall_deps = $(STATEDIR)/m17n-db.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/m17n-db.imageinstall: $(m17n-db_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install m17n-db
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

m17n-db_clean:
	rm -rf $(STATEDIR)/m17n-db.*
	rm -rf $(M17N-DB_DIR)

# vim: syntax=make
