# -*-makefile-*-
# $Id: udev.make,v 1.15 2007/03/07 14:34:52 michl Exp $
#
# Copyright (C) 2005-2006 by Robert Schwebel
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_UDEV096) += udev096

#
# Paths and names
#
UDEV096_VERSION	:= 096
UDEV096		:= udev-$(UDEV096_VERSION)
UDEV096_SUFFIX	:= tar.bz2
UDEV096_URL	:= http://www.kernel.org/pub/linux/utils/kernel/hotplug/$(UDEV096).$(UDEV096_SUFFIX)
UDEV096_SOURCE	:= $(SRCDIR)/$(UDEV096).$(UDEV096_SUFFIX)
UDEV096_DIR	:= $(BUILDDIR)/$(UDEV096)


# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

udev_get: $(STATEDIR)/udev096.get

$(STATEDIR)/udev096.get: $(udev096_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(UDEV096_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, UDEV096)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

udev096_extract: $(STATEDIR)/udev096.extract

$(STATEDIR)/udev096.extract: $(udev096_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(UDEV096_DIR))
	@$(call extract, UDEV096)
	@$(call patchin, UDEV096)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

udev096_prepare: $(STATEDIR)/udev096.prepare

UDEV096_PATH	:=  PATH=$(CROSS_PATH)
UDEV096_ENV 	:=  $(CROSS_ENV)
UDEV096_MAKEVARS =  CROSS_COMPILE=$(COMPILER_PREFIX)

ifdef PTXCONF_UDEV096_FW_HELPER
UDEV096_TOOLVAR	+=  extras/firmware
endif
ifdef PTXCONF_UDEV096_USB_ID
UDEV096_TOOLVAR	+=  extras/usb_id
endif
ifdef PTXCONF_UDEV096_ENABLE_SYSLOG
UDEV096_SYSLOGVAR = USE_LOG=true
else
UDEV096_SYSLOGVAR = USE_LOG=false
endif
ifdef PTXCONF_UDEV096_ENABLE_DEBUG
UDEV096_DEBUGMSG = DEBUG=true
else
UDEV096_DEBUGMSG = DEBUG=false
endif

$(STATEDIR)/udev096.prepare: $(udev096_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(UDEV096_DIR)/config.cache)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

udev096_compile: $(STATEDIR)/udev096.compile

$(STATEDIR)/udev096.compile: $(udev096_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(UDEV096_DIR) && $(UDEV096_ENV) $(UDEV096_PATH) make EXTRAS="$(UDEV096_TOOLVAR)" \
		$(UDEV096_SYSLOGVAR) $(UDEV096_DEBUGMSG) $(UDEV096_MAKEVARS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

udev096_install: $(STATEDIR)/udev096.install

$(STATEDIR)/udev096.install: $(udev096_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

udev096_targetinstall: $(STATEDIR)/udev096.targetinstall

$(STATEDIR)/udev096.targetinstall: $(udev096_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, udev096)
	@$(call install_fixup, udev096,PACKAGE,udev)
	@$(call install_fixup, udev096,PRIORITY,optional)
	@$(call install_fixup, udev096,VERSION,$(UDEV096_VERSION))
	@$(call install_fixup, udev096,SECTION,base)
	@$(call install_fixup, udev096,AUTHOR,"Robert Schwebel <r.schwebel\@pengutronix.de>")
	@$(call install_fixup, udev096,DEPENDS,)
	@$(call install_fixup, udev096,DESCRIPTION,missing)

#
# Install a configuration on demand only
#
ifdef PTXCONF_ROOTFS_ETC_UDEV096_CONF
ifdef PTXCONF_ROOTFS_ETC_UDEV096_CONF_DEFAULT
# use generic
	@$(call install_copy, udev096, 0, 0, 0644, \
		$(PTXDIST_TOPDIR)/generic/etc/udev/udev.conf, \
		/etc/udev/udev.conf, n)
endif
ifdef PTXCONF_ROOTFS_ETC_UDEV096_CONF_USER
# user defined
	@$(call install_copy, udev096, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/udev/udev.conf, \
		/etc/udev/udev.conf, n)
endif
endif
#
# install all user defined rule files
#
ifdef PTXCONF_ROOTFS_ETC_UDEV096_USER_RULES
# create the rules directory as currently stated in the generic config
# FIXME: if the user defines a different directory in his own udev.conf
#        this will fail!
#
	@$(call install_copy, udev096, 0, 0, 0755, \
		/etc/udev/rules.d)
# copy *all* *.rules files into targets rule directory
#
	@cd $(PTXDIST_WORKSPACE)/projectroot/etc/udev/rules.d; \
	for i in *.rules; do \
		$(call install_copy, udev096, 0, 0, 0644, $$i, \
			/etc/udev/rules.d/$$i,n); \
	done;
# scripts
	@$(call install_copy, udev096, 0, 0, 0755, \
		/etc/udev/scripts)
	@cd $(PTXDIST_WORKSPACE)/projectroot/etc/udev/scripts; \
	for i in *.sh; do \
		$(call install_copy, udev096, 0, 0, 0755, $$i, \
			/etc/udev/scripts/$$i,n); \
	done;
	@$(call install_copy, udev096, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/udev/links.conf, \
		/etc/udev/links.conf, n)
endif
ifdef PTXCONF_ROOTFS_ETC_UDEV096_DEFAULT_RULES
	@$(call install_copy, udev096, 0, 0, 0644, \
		$(PTXDIST_TOPDIR)/generic/etc/udev/rules.d/udev.rules, \
		/etc/udev/rules.d/udev.rules, n)
endif
#
# Install the startup script on request only
#
ifdef PTXCONF_ROOTFS_ETC_INITD_UDEV
ifdef PTXCONF_ROOTFS_ETC_INITD_UDEV096_DEFAULT
# install the generic one
	@$(call install_copy, udev096, 0, 0, 0755, \
		$(PTXDIST_TOPDIR)/generic/etc/init.d/udev, \
		/etc/init.d/udev, n)
endif

ifdef PTXCONF_ROOTFS_ETC_INITD_UDEV096_USER
# install users one
	@$(call install_copy, udev096, 0, 0, 0755, \
		${PTXDIST_WORKSPACE}/projectroot/etc/init.d/udev-096, \
		/etc/init.d/udev, n)
endif
#
# FIXME: Is this packet the right location for the link?
#
ifneq ($(PTXCONF_ROOTFS_ETC_INITD_UDEV096_LINK),"")
	@$(call install_copy, udev096, 0, 0, 0755, /etc/rc.d)
	@$(call install_link, udev096, ../init.d/udev, \
		/etc/rc.d/$(PTXCONF_ROOTFS_ETC_INITD_UDEV_LINK))
endif
endif

ifdef PTXCONF_UDEV096_TEST_UDEV
	@$(call install_copy, udev096, 0, 0, 0755, $(UDEV096_DIR)/test-udev, \
		/sbin/test-udev)
endif
ifdef PTXCONF_UDEV096_UDEVD
	@$(call install_copy, udev096, 0, 0, 0755, $(UDEV096_DIR)/udevd, \
		/sbin/udevd)
endif
ifdef PTXCONF_UDEV096_INFO
	@$(call install_copy, udev096, 0, 0, 0755, $(UDEV096_DIR)/udevinfo, \
		/sbin/udevinfo)
endif
ifdef PTXCONF_UDEV096_START
	@$(call install_copy, udev096, 0, 0, 0755, $(UDEV096_DIR)/udevstart, \
		/sbin/udevstart)
endif
ifdef PTXCONF_UDEV096_TEST
	@$(call install_copy, udev096, 0, 0, 0755, $(UDEV096_DIR)/udevtest, \
		/sbin/udevtest)
endif
ifdef PTXCONF_UDEV096_TRIGGER
	@$(call install_copy, udev096, 0, 0, 0755, $(UDEV096_DIR)/udevtrigger, \
		/sbin/udevtrigger)
endif
ifdef PTXCONF_UDEV096_SETTLE
	@$(call install_copy, udev096, 0, 0, 0755, $(UDEV096_DIR)/udevsettle, \
		/sbin/udevsettle)
endif
ifdef PTXCONF_UDEV096_CONTROL
	@$(call install_copy, udev096, 0, 0, 0755, $(UDEV096_DIR)/udevcontrol, \
		/sbin/udevcontrol)
endif
ifdef PTXCONF_UDEV096_MONITOR
	@$(call install_copy, udev096, 0, 0, 0755, $(UDEV096_DIR)/udevmonitor, \
		/sbin/udevmonitor)
endif
ifdef PTXCONF_UDEV096_USB_ID
	@$(call install_copy, udev096, 0, 0, 0755, \
		$(UDEV096_DIR)/extras/usb_id/usb_id, \
		/sbin/usbid)
endif
ifdef PTXCONF_UDEV096_FW_HELPER
	@$(call install_copy, udev096, 0, 0, 0755, \
		$(UDEV096_DIR)/extras/firmware/firmware.sh, \
		/sbin/firmware.sh,n)
endif

	@$(call install_finish, udev096)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

udev096_clean:
	rm -rf $(STATEDIR)/udev096.*
	rm -rf $(IMAGEDIR)/udev096_*
	rm -rf $(UDEV096_DIR)

# vim: syntax=make
