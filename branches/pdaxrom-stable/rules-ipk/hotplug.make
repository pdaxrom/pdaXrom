# -*-makefile-*-
# $Id: hotplug.make,v 1.4 2003/10/23 15:01:19 mkl Exp $
#
# Copyright (C) 2003 by Dan Kegel, Ixia Communications (http://ixiacom.com)
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_HOTPLUG
PACKAGES += hotplug
endif

#
# Paths and names
#
HOTPLUG_VERSION	= 2004_01_05
HOTPLUG		= hotplug-$(HOTPLUG_VERSION)
HOTPLUG_SUFFIX	= tar.gz
HOTPLUG_URL	= http://unc.dl.sourceforge.net/sourceforge/linux-hotplug/$(HOTPLUG).$(HOTPLUG_SUFFIX)
HOTPLUG_SOURCE	= $(SRCDIR)/$(HOTPLUG).$(HOTPLUG_SUFFIX)
HOTPLUG_DIR	= $(BUILDDIR)/$(HOTPLUG)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

hotplug_get: $(STATEDIR)/hotplug.get

hotplug_get_deps	=  $(HOTPLUG_SOURCE)

$(STATEDIR)/hotplug.get: $(hotplug_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(HOTPLUG))
	touch $@

$(HOTPLUG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(HOTPLUG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

hotplug_extract: $(STATEDIR)/hotplug.extract

hotplug_extract_deps	=  $(STATEDIR)/hotplug.get

$(STATEDIR)/hotplug.extract: $(hotplug_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HOTPLUG_DIR))
	@$(call extract, $(HOTPLUG_SOURCE))
	@$(call patchin, $(HOTPLUG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

hotplug_prepare: $(STATEDIR)/hotplug.prepare

$(STATEDIR)/hotplug.prepare:
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

hotplug_compile: $(STATEDIR)/hotplug.compile

$(STATEDIR)/hotplug.compile:
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

hotplug_targetinstall: $(STATEDIR)/hotplug.targetinstall

hotplug_targetinstall_deps	=  $(STATEDIR)/hotplug.extract

#
# create /etc/hotplug directory before installing to keep it from
# using build system's chkconfig script to install itself!
#
$(STATEDIR)/hotplug.targetinstall: $(hotplug_targetinstall_deps)
	@$(call targetinfo, $@)
	make -C $(HOTPLUG_DIR) prefix=$(HOTPLUG_DIR)/ipkg_tmp/ install

	install -d $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc0.d
	install -d $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc1.d
	install -d $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc2.d
	install -d $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc3.d
	install -d $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc4.d
	install -d $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc5.d
	install -d $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc6.d
	cd $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc0.d && ln -sf ../init.d/hotplug K52hotplug
	cd $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc1.d && ln -sf ../init.d/hotplug K52hotplug
	cd $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc3.d && ln -sf ../init.d/hotplug S48hotplug
	cd $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc4.d && ln -sf ../init.d/hotplug S48hotplug
	cd $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc5.d && ln -sf ../init.d/hotplug S48hotplug
	cd $(HOTPLUG_DIR)/ipkg_tmp/etc/rc.d/rc6.d && ln -sf ../init.d/hotplug K52hotplug
	rm -rf $(HOTPLUG_DIR)/ipkg_tmp/usr/share/man

	mkdir -p $(HOTPLUG_DIR)/ipkg_tmp/CONTROL
	echo "Package: hotplug" 						 >$(HOTPLUG_DIR)/ipkg_tmp/CONTROL/control
	echo "Source: $(HOTPLUG_URL)"						>>$(HOTPLUG_DIR)/ipkg_tmp/CONTROL/control
	echo "Priority: optional" 						>>$(HOTPLUG_DIR)/ipkg_tmp/CONTROL/control
	echo "Section: Utilities" 						>>$(HOTPLUG_DIR)/ipkg_tmp/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(HOTPLUG_DIR)/ipkg_tmp/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(HOTPLUG_DIR)/ipkg_tmp/CONTROL/control
	echo "Version: 2004-01-05"	 					>>$(HOTPLUG_DIR)/ipkg_tmp/CONTROL/control
	echo "Depends: " 							>>$(HOTPLUG_DIR)/ipkg_tmp/CONTROL/control
	echo "Description: This package contains the scripts necessary for hotplug Linux support, and lets you plug in new devices and use them immediately.">>$(HOTPLUG_DIR)/ipkg_tmp/CONTROL/control
	@$(call makeipkg, $(HOTPLUG_DIR)/ipkg_tmp)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_HOTPLUG_INSTALL
ROMPACKAGES += $(STATEDIR)/hotplug.imageinstall
endif

hotplug_imageinstall_deps = $(STATEDIR)/hotplug.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/hotplug.imageinstall: $(hotplug_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install hotplug
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

hotplug_clean:
	rm -rf $(STATEDIR)/hotplug.*
	rm -rf $(HOTPLUG_DIR)

# vim: syntax=make
