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
ifdef PTXCONF_LINUX-PAM
PACKAGES += Linux-PAM
endif

#
# Paths and names
#
LINUX-PAM_VENDOR_VERSION	= 1
LINUX-PAM_VERSION		= 0.81
LINUX-PAM			= Linux-PAM-$(LINUX-PAM_VERSION)
LINUX-PAM_SUFFIX		= tar.bz2
LINUX-PAM_URL			= http://www.kernel.org/pub/linux/libs/pam/pre/library/$(LINUX-PAM).$(LINUX-PAM_SUFFIX)
LINUX-PAM_SOURCE		= $(SRCDIR)/$(LINUX-PAM).$(LINUX-PAM_SUFFIX)
LINUX-PAM_DIR			= $(BUILDDIR)/$(LINUX-PAM)
LINUX-PAM_IPKG_TMP		= $(LINUX-PAM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

Linux-PAM_get: $(STATEDIR)/Linux-PAM.get

Linux-PAM_get_deps = $(LINUX-PAM_SOURCE)

$(STATEDIR)/Linux-PAM.get: $(Linux-PAM_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LINUX-PAM))
	touch $@

$(LINUX-PAM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LINUX-PAM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

Linux-PAM_extract: $(STATEDIR)/Linux-PAM.extract

Linux-PAM_extract_deps = $(STATEDIR)/Linux-PAM.get

$(STATEDIR)/Linux-PAM.extract: $(Linux-PAM_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LINUX-PAM_DIR))
	@$(call extract, $(LINUX-PAM_SOURCE))
	@$(call patchin, $(LINUX-PAM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

Linux-PAM_prepare: $(STATEDIR)/Linux-PAM.prepare

#
# dependencies
#
Linux-PAM_prepare_deps = \
	$(STATEDIR)/Linux-PAM.extract \
	$(STATEDIR)/virtual-xchain.install

LINUX-PAM_PATH	=  PATH=$(CROSS_PATH)
LINUX-PAM_ENV 	=  $(CROSS_ENV)
#LINUX-PAM_ENV	+=
LINUX-PAM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LINUX-PAM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LINUX-PAM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
LINUX-PAM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LINUX-PAM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/Linux-PAM.prepare: $(Linux-PAM_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LINUX-PAM_DIR)/config.cache)
	cd $(LINUX-PAM_DIR) && \
		$(LINUX-PAM_PATH) $(LINUX-PAM_ENV) \
		./configure $(LINUX-PAM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

Linux-PAM_compile: $(STATEDIR)/Linux-PAM.compile

Linux-PAM_compile_deps = $(STATEDIR)/Linux-PAM.prepare

$(STATEDIR)/Linux-PAM.compile: $(Linux-PAM_compile_deps)
	@$(call targetinfo, $@)
	$(LINUX-PAM_PATH) $(MAKE) -C $(LINUX-PAM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

Linux-PAM_install: $(STATEDIR)/Linux-PAM.install

$(STATEDIR)/Linux-PAM.install: $(STATEDIR)/Linux-PAM.compile
	@$(call targetinfo, $@)
	rm -rf $(LINUX-PAM_IPKG_TMP)
	$(LINUX-PAM_PATH) $(MAKE) -C $(LINUX-PAM_DIR) FAKEROOT=$(LINUX-PAM_IPKG_TMP) install
	cp -a $(LINUX-PAM_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(LINUX-PAM_IPKG_TMP)/usr/lib/*.*		$(CROSS_LIB_DIR)/lib/
	rm -rf $(LINUX-PAM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

Linux-PAM_targetinstall: $(STATEDIR)/Linux-PAM.targetinstall

Linux-PAM_targetinstall_deps = $(STATEDIR)/Linux-PAM.compile \
	$(STATEDIR)/Linux-PAM.install

$(STATEDIR)/Linux-PAM.targetinstall: $(Linux-PAM_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LINUX-PAM_PATH) $(MAKE) -C $(LINUX-PAM_DIR) FAKEROOT=$(LINUX-PAM_IPKG_TMP) install
	rm -rf $(LINUX-PAM_IPKG_TMP)/usr/{include,man,share}
	for FILE in `find $(LINUX-PAM_IPKG_TMP)/usr -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(LINUX-PAM_IPKG_TMP)/CONTROL
	echo "Package: linux-pam" 							 >$(LINUX-PAM_IPKG_TMP)/CONTROL/control
	echo "Source: $(LINUX-PAM_URL)"							>>$(LINUX-PAM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LINUX-PAM_IPKG_TMP)/CONTROL/control
	echo "Section: System" 								>>$(LINUX-PAM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LINUX-PAM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LINUX-PAM_IPKG_TMP)/CONTROL/control
	echo "Version: $(LINUX-PAM_VERSION)-$(LINUX-PAM_VENDOR_VERSION)" 		>>$(LINUX-PAM_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LINUX-PAM_IPKG_TMP)/CONTROL/control
	echo "Description: Linux-PAM is a free implementation of the following DCE-RFC from Sunsoft." >>$(LINUX-PAM_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(LINUX-PAM_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LINUX-PAM_INSTALL
ROMPACKAGES += $(STATEDIR)/Linux-PAM.imageinstall
endif

Linux-PAM_imageinstall_deps = $(STATEDIR)/Linux-PAM.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/Linux-PAM.imageinstall: $(Linux-PAM_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install linux-pam
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

Linux-PAM_clean:
	rm -rf $(STATEDIR)/Linux-PAM.*
	rm -rf $(LINUX-PAM_DIR)

# vim: syntax=make
