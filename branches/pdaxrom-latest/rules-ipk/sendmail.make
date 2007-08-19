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
ifdef PTXCONF_SENDMAIL
PACKAGES += sendmail
endif

#
# Paths and names
#
SENDMAIL_VENDOR_VERSION	= 1
SENDMAIL_VERSION	= 8.13.7
SENDMAIL		= sendmail.$(SENDMAIL_VERSION)
SENDMAIL_SUFFIX		= tar.gz
SENDMAIL_URL		= ftp://ftp.sendmail.org/pub/sendmail/$(SENDMAIL).$(SENDMAIL_SUFFIX)
SENDMAIL_SOURCE		= $(SRCDIR)/$(SENDMAIL).$(SENDMAIL_SUFFIX)
SENDMAIL_DIR		= $(BUILDDIR)/$(SENDMAIL)
SENDMAIL_IPKG_TMP	= $(SENDMAIL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sendmail_get: $(STATEDIR)/sendmail.get

sendmail_get_deps = $(SENDMAIL_SOURCE)

$(STATEDIR)/sendmail.get: $(sendmail_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SENDMAIL))
	touch $@

$(SENDMAIL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SENDMAIL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sendmail_extract: $(STATEDIR)/sendmail.extract

sendmail_extract_deps = $(STATEDIR)/sendmail.get

$(STATEDIR)/sendmail.extract: $(sendmail_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SENDMAIL_DIR))
	@$(call extract, $(SENDMAIL_SOURCE))
	@$(call patchin, $(SENDMAIL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sendmail_prepare: $(STATEDIR)/sendmail.prepare

#
# dependencies
#
sendmail_prepare_deps = \
	$(STATEDIR)/sendmail.extract \
	$(STATEDIR)/virtual-xchain.install

SENDMAIL_PATH	=  PATH=$(CROSS_PATH)
SENDMAIL_ENV 	=  $(CROSS_ENV)
#SENDMAIL_ENV	+=
SENDMAIL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SENDMAIL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
SENDMAIL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
SENDMAIL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SENDMAIL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/sendmail.prepare: $(sendmail_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SENDMAIL_DIR)/config.cache)
	cd $(SENDMAIL_DIR) && \
		$(SENDMAIL_PATH) $(SENDMAIL_ENV) \
		./configure $(SENDMAIL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sendmail_compile: $(STATEDIR)/sendmail.compile

sendmail_compile_deps = $(STATEDIR)/sendmail.prepare

$(STATEDIR)/sendmail.compile: $(sendmail_compile_deps)
	@$(call targetinfo, $@)
	$(SENDMAIL_PATH) $(MAKE) -C $(SENDMAIL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sendmail_install: $(STATEDIR)/sendmail.install

$(STATEDIR)/sendmail.install: $(STATEDIR)/sendmail.compile
	@$(call targetinfo, $@)
	rm -rf $(SENDMAIL_IPKG_TMP)
	$(SENDMAIL_PATH) $(MAKE) -C $(SENDMAIL_DIR) DESTDIR=$(SENDMAIL_IPKG_TMP) install
	@$(call copyincludes, $(SENDMAIL_IPKG_TMP))
	@$(call copylibraries,$(SENDMAIL_IPKG_TMP))
	@$(call copymiscfiles,$(SENDMAIL_IPKG_TMP))
	rm -rf $(SENDMAIL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sendmail_targetinstall: $(STATEDIR)/sendmail.targetinstall

sendmail_targetinstall_deps = $(STATEDIR)/sendmail.compile

$(STATEDIR)/sendmail.targetinstall: $(sendmail_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SENDMAIL_PATH) $(MAKE) -C $(SENDMAIL_DIR) DESTDIR=$(SENDMAIL_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(SENDMAIL_VERSION)-$(SENDMAIL_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh sendmail $(SENDMAIL_IPKG_TMP)

	@$(call removedevfiles, $(SENDMAIL_IPKG_TMP))
	@$(call stripfiles, $(SENDMAIL_IPKG_TMP))
	mkdir -p $(SENDMAIL_IPKG_TMP)/CONTROL
	echo "Package: sendmail" 							 >$(SENDMAIL_IPKG_TMP)/CONTROL/control
	echo "Source: $(SENDMAIL_URL)"							>>$(SENDMAIL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SENDMAIL_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(SENDMAIL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SENDMAIL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SENDMAIL_IPKG_TMP)/CONTROL/control
	echo "Version: $(SENDMAIL_VERSION)-$(SENDMAIL_VENDOR_VERSION)" 			>>$(SENDMAIL_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(SENDMAIL_IPKG_TMP)/CONTROL/control
	echo "Description: Sendmail is a Mail Transfer Agent, which is the program that moves mail from one machine to another.">>$(SENDMAIL_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(SENDMAIL_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SENDMAIL_INSTALL
ROMPACKAGES += $(STATEDIR)/sendmail.imageinstall
endif

sendmail_imageinstall_deps = $(STATEDIR)/sendmail.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/sendmail.imageinstall: $(sendmail_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sendmail
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sendmail_clean:
	rm -rf $(STATEDIR)/sendmail.*
	rm -rf $(SENDMAIL_DIR)

# vim: syntax=make
