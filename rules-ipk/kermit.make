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
ifdef PTXCONF_KERMIT
PACKAGES += kermit
endif

#
# Paths and names
#
KERMIT_VENDOR_VERSION	= 1
KERMIT_VERSION		= 2.1.1
KERMIT			= kermit-$(KERMIT_VERSION)
KERMIT_SUFFIX		= tar.gz
KERMIT_URL		= ftp://kermit.columbia.edu/kermit/archives/cku211.$(KERMIT_SUFFIX)
KERMIT_SOURCE		= $(SRCDIR)/cku211.$(KERMIT_SUFFIX)
KERMIT_DIR		= $(BUILDDIR)/$(KERMIT)
KERMIT_IPKG_TMP		= $(KERMIT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

kermit_get: $(STATEDIR)/kermit.get

kermit_get_deps = $(KERMIT_SOURCE)

$(STATEDIR)/kermit.get: $(kermit_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KERMIT))
	touch $@

$(KERMIT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KERMIT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

kermit_extract: $(STATEDIR)/kermit.extract

kermit_extract_deps = $(STATEDIR)/kermit.get

$(STATEDIR)/kermit.extract: $(kermit_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, 	 $(KERMIT_DIR))
	@$(call extract, $(KERMIT_SOURCE), $(KERMIT_DIR))
	@$(call patchin, $(KERMIT), $(KERMIT_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

kermit_prepare: $(STATEDIR)/kermit.prepare

#
# dependencies
#
kermit_prepare_deps = \
	$(STATEDIR)/kermit.extract \
	$(STATEDIR)/virtual-xchain.install

KERMIT_PATH	=  PATH=$(CROSS_PATH)
KERMIT_ENV 	=  $(CROSS_ENV)
KERMIT_ENV	+= CFLAGS=" -O2 -fomit-frame-pointer \
	 -DLINUX -DCK_POSIX_SIG \
	 -DNOTCPOPTS -DLINUXFSSTND -DNOCOTFMC -DPOSIX -DUSE_STRERROR \
	 -DNOSYSLOG -DHAVE_PTMX -DNO_DNS_SRV -DNOGFTIMER \
         -DNOB_50 -DNOB_75 -DNOB_134 -DNOB_150 -DNOB_200 \
	 -DNOB_1800 -DNOB_3600 -DNOB_7200 -DNOB_76K -DNOB_230K \
	 -DNOB_460K -DNOB_921K \
	 -DNOAPC -DNOCSETS -DNONET -DNOUNICODE -DNOHELP -DNODEBUG \
	 -DNOFRILLS -DNOFTP -DNODIAL -DNOPUSH -DNOIKSD -DNOHTTP -DNOFLOAT \
	 -DNOSERVER -DNOSEXP -DNORLOGIN -DNOOLDMODEMS -DNOSSH -DNOLISTEN \
	 -DNORESEND -DNOAUTODL -DNOSTREAMING -DNOHINTS -DNOCKXYZ -DNOLEARN \
	 -DNOMKDIR -DNOPERMS -DNOCKTIMERS -DNOCKREGEX -DNOREALPATH \
	 -DCK_SMALL -DNOLOGDIAL -DNORENAME -DNOWHATAMI"
	 
KERMIT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#KERMIT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
KERMIT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
KERMIT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
KERMIT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/kermit.prepare: $(kermit_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KERMIT_DIR)/config.cache)
	#cd $(KERMIT_DIR) && \
	#	$(KERMIT_PATH) $(KERMIT_ENV) \
	#	./configure $(KERMIT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

kermit_compile: $(STATEDIR)/kermit.compile

kermit_compile_deps = $(STATEDIR)/kermit.prepare

$(STATEDIR)/kermit.compile: $(kermit_compile_deps)
	@$(call targetinfo, $@)
	$(KERMIT_PATH) $(KERMIT_ENV) $(MAKE) -C $(KERMIT_DIR) wermit $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

kermit_install: $(STATEDIR)/kermit.install

$(STATEDIR)/kermit.install: $(STATEDIR)/kermit.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

kermit_targetinstall: $(STATEDIR)/kermit.targetinstall

kermit_targetinstall_deps = $(STATEDIR)/kermit.compile

$(STATEDIR)/kermit.targetinstall: $(kermit_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(KERMIT_IPKG_TMP)/usr/local/bin
	mkdir -p $(KERMIT_IPKG_TMP)/usr/local/man/man1
	$(KERMIT_PATH) $(MAKE) -C $(KERMIT_DIR) DESTDIR=$(KERMIT_IPKG_TMP) MANDIR=$(KERMIT_IPKG_TMP)/usr/local/man/man1 install
	rm -rf $(KERMIT_IPKG_TMP)/usr/local/man
	$(CROSSSTRIP) $(KERMIT_IPKG_TMP)/usr/local/bin/kermit
	mkdir -p $(KERMIT_IPKG_TMP)/usr/bin
	ln -sf /usr/local/bin/kermit $(KERMIT_IPKG_TMP)/usr/bin/kermit
	mkdir -p $(KERMIT_IPKG_TMP)/CONTROL
	echo "Package: kermit" 								 >$(KERMIT_IPKG_TMP)/CONTROL/control
	echo "Source: $(KERMIT_URL)"							>>$(KERMIT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(KERMIT_IPKG_TMP)/CONTROL/control
	echo "Section: Utils" 								>>$(KERMIT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(KERMIT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(KERMIT_IPKG_TMP)/CONTROL/control
	echo "Version: $(KERMIT_VERSION)-$(KERMIT_VENDOR_VERSION)" 			>>$(KERMIT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(KERMIT_IPKG_TMP)/CONTROL/control
	echo "Description: Kermit software offers interactive and scripted file transfer and management, terminal emulation, Unicode-aware character-set conversion, and/or Internet security" >>$(KERMIT_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(KERMIT_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_KERMIT_INSTALL
ROMPACKAGES += $(STATEDIR)/kermit.imageinstall
endif

kermit_imageinstall_deps = $(STATEDIR)/kermit.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/kermit.imageinstall: $(kermit_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install kermit
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

kermit_clean:
	rm -rf $(STATEDIR)/kermit.*
	rm -rf $(KERMIT_DIR)

# vim: syntax=make
