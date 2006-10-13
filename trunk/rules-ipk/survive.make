# -*-makefile-*-
# $Id: template,v 1.10 2003/10/26 21:59:07 mkl Exp $
#
# Copyright (C) 2003 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_SURVIVE
PACKAGES += survive
endif

#
# Paths and names
#
SURVIVE_VENDOR_VERSION	= 3
SURVIVE_VERSION		= 1.1.0
SURVIVE			= survive-$(SURVIVE_VERSION)
SURVIVE_SUFFIX		= tar.bz2
SURVIVE_URL		= http://www.pdaXrom.org/src/$(SURVIVE).$(SURVIVE_SUFFIX)
SURVIVE_SOURCE		= $(SRCDIR)/$(SURVIVE).$(SURVIVE_SUFFIX)
SURVIVE_DIR		= $(BUILDDIR)/$(SURVIVE)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

survive_get: $(STATEDIR)/survive.get

survive_get_deps = $(SURVIVE_SOURCE)

$(STATEDIR)/survive.get: $(survive_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SURVIVE))
	touch $@

$(SURVIVE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SURVIVE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

survive_extract: $(STATEDIR)/survive.extract

survive_extract_deps = $(STATEDIR)/survive.get

$(STATEDIR)/survive.extract: $(survive_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SURVIVE_DIR))
	@$(call extract, $(SURVIVE_SOURCE))
	@$(call patchin, $(SURVIVE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

survive_prepare: $(STATEDIR)/survive.prepare

#
# dependencies
#
survive_prepare_deps = \
	$(STATEDIR)/survive.extract \
	$(STATEDIR)/virtual-xchain.install

SURVIVE_PATH	=  PATH=$(CROSS_PATH)
SURVIVE_ENV 	=  $(CROSS_ENV)
#SURVIVE_ENV	+=

#
# autoconf
#
SURVIVE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/survive.prepare: $(survive_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SURVIVE_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

survive_compile: $(STATEDIR)/survive.compile

survive_compile_deps = $(STATEDIR)/survive.prepare

$(STATEDIR)/survive.compile: $(survive_compile_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_SURVIVE_SURVIVE
	$(SURVIVE_PATH) $(SURVIVE_ENV) $(MAKE) -C $(SURVIVE_DIR) survive CFLAGS="-O2 -I$(KERNEL_DIR)/include"
endif
ifdef PTXCONF_SURVIVE_SLTIME
	$(SURVIVE_PATH) $(SURVIVE_ENV) $(MAKE) -C $(SURVIVE_DIR) sltime CFLAGS="-O2 -I$(KERNEL_DIR)/include"
endif
ifdef PTXCONF_SURVIVE_SETFL
	$(SURVIVE_PATH) $(SURVIVE_ENV) $(MAKE) -C $(SURVIVE_DIR) setfl CFLAGS="-O2 -I$(KERNEL_DIR)/include"
endif
ifdef PTXCONF_SURVIVE_CHKHINGE
	$(SURVIVE_PATH) $(SURVIVE_ENV) $(MAKE) -C $(SURVIVE_DIR) chkhinge CFLAGS="-O2 -I$(KERNEL_DIR)/include"
endif
ifdef PTXCONF_SURVIVE_SWITCHEVD
	$(SURVIVE_PATH) $(SURVIVE_ENV) $(MAKE) -C $(SURVIVE_DIR) switchevd CFLAGS="-O2 -I$(KERNEL_DIR)/include"
endif
ifdef PTXCONF_SURVIVE_WRITEROMINFO
	$(SURVIVE_PATH) $(SURVIVE_ENV) $(MAKE) -C $(SURVIVE_DIR) writerominfo CFLAGS="-O2 -I$(KERNEL_DIR)/include"
endif
ifdef PTXCONF_SURVIVE_SETHWCLOCK
	$(SURVIVE_PATH) $(SURVIVE_ENV) $(MAKE) -C $(SURVIVE_DIR) sethwclock CFLAGS="-O2 -I$(KERNEL_DIR)/include"
endif
ifdef PTXCONF_SURVIVE_NANDLOGICAL
	$(SURVIVE_PATH) $(SURVIVE_ENV) $(MAKE) -C $(SURVIVE_DIR) nandlogical CFLAGS="-O2 -I$(KERNEL_DIR)/include"
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

survive_install: $(STATEDIR)/survive.install

$(STATEDIR)/survive.install: $(STATEDIR)/survive.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

survive_targetinstall: $(STATEDIR)/survive.targetinstall

survive_targetinstall_deps = $(STATEDIR)/survive.compile

$(STATEDIR)/survive.targetinstall: $(survive_targetinstall_deps)
	@$(call targetinfo, $@)
	install -d $(SURVIVE_DIR)/root_tmp/bin
	install -d $(SURVIVE_DIR)/root_tmp/sbin
	install -d $(SURVIVE_DIR)/root_tmp/usr/bin
	install -d $(SURVIVE_DIR)/root_tmp/usr/sbin
ifdef PTXCONF_SURVIVE_SURVIVE
	install $(SURVIVE_DIR)/survive $(SURVIVE_DIR)/root_tmp/sbin/survive
	$(CROSSSTRIP) -R .note -R .comment $(SURVIVE_DIR)/root_tmp/sbin/survive
endif
ifdef PTXCONF_SURVIVE_SLTIME
	install $(SURVIVE_DIR)/sltime $(SURVIVE_DIR)/root_tmp/sbin/sltime
	$(CROSSSTRIP) -R .note -R .comment $(SURVIVE_DIR)/root_tmp/sbin/sltime
endif
ifdef PTXCONF_SURVIVE_SETFL
ifndef PTXCONF_UDEV_INSTALL
	install $(SURVIVE_DIR)/setfl $(SURVIVE_DIR)/root_tmp/sbin/setfl
	$(CROSSSTRIP) -R .note -R .comment $(SURVIVE_DIR)/root_tmp/sbin/setfl
	chmod +s $(SURVIVE_DIR)/root_tmp/sbin/setfl
else
	install $(SURVIVE_DIR)/setfl_sysfs $(SURVIVE_DIR)/root_tmp/sbin/setfl
endif
endif
ifdef PTXCONF_SURVIVE_CHKHINGE
	install -d $(SURVIVE_DIR)/root_tmp/etc/sysconfig
	install $(SURVIVE_DIR)/chkhinge $(SURVIVE_DIR)/root_tmp/usr/bin/chkhinge
	$(CROSSSTRIP) -R .note -R .comment $(SURVIVE_DIR)/root_tmp/usr/bin/chkhinge
	cp -af $(SURVIVE_DIR)/clamshell $(SURVIVE_DIR)/root_tmp/etc/sysconfig
	chmod +s $(SURVIVE_DIR)/root_tmp/usr/bin/chkhinge
endif
ifdef PTXCONF_SURVIVE_SWITCHEVD
	install -d $(SURVIVE_DIR)/root_tmp/etc/sysconfig
	install $(SURVIVE_DIR)/switchevd   $(SURVIVE_DIR)/root_tmp/usr/bin/switchevd
	install $(SURVIVE_DIR)/switchev.sh $(SURVIVE_DIR)/root_tmp/usr/bin/switchev.sh
	$(CROSSSTRIP) -R .note -R .comment $(SURVIVE_DIR)/root_tmp/usr/bin/switchevd
	cp -af $(SURVIVE_DIR)/clamshell $(SURVIVE_DIR)/root_tmp/etc/sysconfig
	cp -af $(SURVIVE_DIR)/usb 	$(SURVIVE_DIR)/root_tmp/etc/sysconfig
	cp -af $(SURVIVE_DIR)/netconfig	$(SURVIVE_DIR)/root_tmp/etc/sysconfig
	cp -af $(SURVIVE_DIR)/rc.d	$(SURVIVE_DIR)/root_tmp/etc
	chmod +s $(SURVIVE_DIR)/root_tmp/usr/bin/switchevd
endif
ifdef PTXCONF_SURVIVE_IPKG
	install -m 755 $(SURVIVE_DIR)/ipkg*  $(SURVIVE_DIR)/root_tmp/usr/bin
	install -m 755 $(SURVIVE_DIR)/mkipkg $(PTXCONF_PREFIX)/bin
endif
ifdef PTXCONF_SURVIVE_WRITEROMINFO
	install $(SURVIVE_DIR)/writerominfo $(SURVIVE_DIR)/root_tmp/sbin/writerominfo
	$(CROSSSTRIP) -R .note -R .comment $(SURVIVE_DIR)/root_tmp/sbin/writerominfo
endif
ifdef PTXCONF_SURVIVE_SETHWCLOCK
	install $(SURVIVE_DIR)/sethwclock $(SURVIVE_DIR)/root_tmp/usr/bin/sethwclock
	$(CROSSSTRIP) -R .note -R .comment $(SURVIVE_DIR)/root_tmp/usr/bin/sethwclock
endif
ifdef PTXCONF_SURVIVE_NANDLOGICAL
	install $(SURVIVE_DIR)/nandlogical $(SURVIVE_DIR)/root_tmp/sbin/nandlogical
	$(CROSSSTRIP) -R .note -R .comment $(SURVIVE_DIR)/root_tmp/sbin/nandlogical
endif
	mkdir -p $(SURVIVE_DIR)/root_tmp/CONTROL
	echo "Package: embedix-utils" 						 >$(SURVIVE_DIR)/root_tmp/CONTROL/control
	echo "Source: $(SURVIVE_URL)"						>>$(SURVIVE_DIR)/root_tmp/CONTROL/control
	echo "Priority: optional" 						>>$(SURVIVE_DIR)/root_tmp/CONTROL/control
	echo "Section: Utilities" 						>>$(SURVIVE_DIR)/root_tmp/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(SURVIVE_DIR)/root_tmp/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(SURVIVE_DIR)/root_tmp/CONTROL/control
	echo "Version: $(SURVIVE_VERSION)-$(SURVIVE_VENDOR_VERSION)" 		>>$(SURVIVE_DIR)/root_tmp/CONTROL/control
	echo "Depends: " 							>>$(SURVIVE_DIR)/root_tmp/CONTROL/control
	echo "Description: little utils for embedded linux system"		>>$(SURVIVE_DIR)/root_tmp/CONTROL/control
	
	echo "#!/bin/sh"					 >$(SURVIVE_DIR)/root_tmp/CONTROL/postinst
ifdef PTXCONF_SURVIVE_SETFL
	echo "chmod +s /sbin/setfl"				>>$(SURVIVE_DIR)/root_tmp/CONTROL/postinst
endif
ifdef PTXCONF_SURVIVE_CHKHINGE
	echo "chmod +s /usr/bin/chkhinge"			>>$(SURVIVE_DIR)/root_tmp/CONTROL/postinst
endif
	chmod 755 $(SURVIVE_DIR)/root_tmp/CONTROL/postinst
	
	@$(call makeipkg, $(SURVIVE_DIR)/root_tmp)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SURVIVE_INSTALL
ROMPACKAGES += $(STATEDIR)/survive.imageinstall
endif

survive_imageinstall_deps = $(STATEDIR)/survive.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/survive.imageinstall: $(survive_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install embedix-utils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

survive_clean:
	rm -rf $(STATEDIR)/survive.*
	rm -rf $(SURVIVE_DIR)

# vim: syntax=make
