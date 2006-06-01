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
ifdef PTXCONF_SCIM-TABLES
PACKAGES += scim-tables
endif

#
# Paths and names
#
SCIM-TABLES_VENDOR_VERSION	= 1
SCIM-TABLES_VERSION		= 0.5.3
SCIM-TABLES			= scim-tables-$(SCIM-TABLES_VERSION)
SCIM-TABLES_SUFFIX		= tar.gz
SCIM-TABLES_URL			= http://peterhost.dl.sourceforge.net/sourceforge/scim/$(SCIM-TABLES).$(SCIM-TABLES_SUFFIX)
SCIM-TABLES_SOURCE		= $(SRCDIR)/$(SCIM-TABLES).$(SCIM-TABLES_SUFFIX)
SCIM-TABLES_DIR			= $(BUILDDIR)/$(SCIM-TABLES)
SCIM-TABLES_IPKG_TMP		= $(SCIM-TABLES_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

scim-tables_get: $(STATEDIR)/scim-tables.get

scim-tables_get_deps = $(SCIM-TABLES_SOURCE)

$(STATEDIR)/scim-tables.get: $(scim-tables_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SCIM-TABLES))
	touch $@

$(SCIM-TABLES_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SCIM-TABLES_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

scim-tables_extract: $(STATEDIR)/scim-tables.extract

scim-tables_extract_deps = $(STATEDIR)/scim-tables.get

$(STATEDIR)/scim-tables.extract: $(scim-tables_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCIM-TABLES_DIR))
	@$(call extract, $(SCIM-TABLES_SOURCE))
	@$(call patchin, $(SCIM-TABLES))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

scim-tables_prepare: $(STATEDIR)/scim-tables.prepare

#
# dependencies
#
scim-tables_prepare_deps = \
	$(STATEDIR)/scim-tables.extract \
	$(STATEDIR)/scim.install \
	$(STATEDIR)/xchain-scim-tables.compile \
	$(STATEDIR)/virtual-xchain.install

SCIM-TABLES_PATH	=  PATH=$(CROSS_PATH)
SCIM-TABLES_ENV 	=  $(CROSS_ENV)
#SCIM-TABLES_ENV	+=
SCIM-TABLES_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SCIM-TABLES_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SCIM-TABLES_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--disable-skim-support \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
SCIM-TABLES_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SCIM-TABLES_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/scim-tables.prepare: $(scim-tables_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCIM-TABLES_DIR)/config.cache)
	cd $(SCIM-TABLES_DIR) && \
		$(SCIM-TABLES_PATH) $(SCIM-TABLES_ENV) \
		./configure $(SCIM-TABLES_AUTOCONF)	    
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

scim-tables_compile: $(STATEDIR)/scim-tables.compile

scim-tables_compile_deps = $(STATEDIR)/scim-tables.prepare

$(STATEDIR)/scim-tables.compile: $(scim-tables_compile_deps)
	@$(call targetinfo, $@)
	$(SCIM-TABLES_PATH) $(MAKE) -C $(SCIM-TABLES_DIR) SCIM_MAKE_TABLE=$(XCHAIN_SCIM-TABLES_DIR)/src/scim-make-table
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

scim-tables_install: $(STATEDIR)/scim-tables.install

$(STATEDIR)/scim-tables.install: $(STATEDIR)/scim-tables.compile
	@$(call targetinfo, $@)
	###$(SCIM-TABLES_PATH) $(MAKE) -C $(SCIM-TABLES_DIR) install
	sadasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

scim-tables_targetinstall: $(STATEDIR)/scim-tables.targetinstall

scim-tables_targetinstall_deps = $(STATEDIR)/scim-tables.compile \
	$(STATEDIR)/scim.targetinstall

$(STATEDIR)/scim-tables.targetinstall: $(scim-tables_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(SCIM-TABLES_IPKG_TMP)
	$(SCIM-TABLES_PATH) $(MAKE) -C $(SCIM-TABLES_DIR) DESTDIR=$(SCIM-TABLES_IPKG_TMP) install
	###cp -a $(SCIM-TABLES_IPKG_TMP)/$(CROSS_LIB_DIR)/*	$(SCIM-TABLES_IPKG_TMP)/usr/
	###rm -rf $(SCIM-TABLES_IPKG_TMP)/opt

	cd $(SCIM-TABLES_IPKG_TMP)/usr && find -name *.la | xargs rm -f

	for FILE in `find $(SCIM-TABLES_IPKG_TMP)/usr -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done

	mkdir -p $(SCIM-TABLES_IPKG_TMP)/CONTROL
	echo "Package: scim-tables" 							 >$(SCIM-TABLES_IPKG_TMP)/CONTROL/control
	echo "Source: $(SCIM-TABLES_URL)"						>>$(SCIM-TABLES_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SCIM-TABLES_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 							>>$(SCIM-TABLES_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SCIM-TABLES_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SCIM-TABLES_IPKG_TMP)/CONTROL/control
	echo "Version: $(SCIM-TABLES_VERSION)-$(SCIM-TABLES_VENDOR_VERSION)" 		>>$(SCIM-TABLES_IPKG_TMP)/CONTROL/control
	echo "Depends: scim" 								>>$(SCIM-TABLES_IPKG_TMP)/CONTROL/control
	echo "Description: Self contained IMEngine"					>>$(SCIM-TABLES_IPKG_TMP)/CONTROL/control

	cd $(FEEDDIR) && $(XMKIPKG) $(SCIM-TABLES_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SCIM-TABLES_INSTALL
ROMPACKAGES += $(STATEDIR)/scim-tables.imageinstall
endif

scim-tables_imageinstall_deps = $(STATEDIR)/scim-tables.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/scim-tables.imageinstall: $(scim-tables_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install scim-tables
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

scim-tables_clean:
	rm -rf $(STATEDIR)/scim-tables.*
	rm -rf $(SCIM-TABLES_DIR)

# vim: syntax=make
