# -*-makefile-*-
# $Id: template 6655 2007-01-02 12:55:21Z rsc $
#
# Copyright (C) 2007 by Robert Schwebel
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#
#
# We provide this package
#
PACKAGES-$(PTXCONF_QEMU_ARM) += qemu-arm

#
# Paths and names
#
QEMU_ARM_VERSION	:= 1.0.0
QEMU_ARM		:= qemu-arm-$(QEMU_ARM_VERSION)
QEMU_ARM_SUFFIX	:=
QEMU_ARM_URL	:=
QEMU_ARM_SOURCE	:=
QEMU_ARM_DIR	:= $(BUILDDIR)/$(QEMU_ARM)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

qemu-arm_get: $(STATEDIR)/qemu-arm.get

$(STATEDIR)/qemu-arm.get:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

qemu-arm_extract: $(STATEDIR)/qemu-arm.extract

$(STATEDIR)/qemu-arm.extract:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

qemu-arm_prepare: $(STATEDIR)/qemu-arm.prepare

$(STATEDIR)/qemu-arm.prepare: $(qemu-arm_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

qemu-arm_compile: $(STATEDIR)/qemu-arm.compile

$(STATEDIR)/qemu-arm.compile: $(qemu-arm_compile_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

qemu-arm_install: $(STATEDIR)/qemu-arm.install

$(STATEDIR)/qemu-arm.install: $(qemu-arm_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

qemu-arm_targetinstall: $(STATEDIR)/qemu-arm.targetinstall

$(STATEDIR)/qemu-arm.targetinstall: $(qemu-arm_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init,qemu-arm)
	@$(call install_fixup,qemu-arm, PACKAGE,qemu-arm)
	@$(call install_fixup,qemu-arm, PRIORITY,optional)
	@$(call install_fixup,qemu-arm, VERSION,$(QEMU_ARM_VERSION))
	@$(call install_fixup,qemu-arm, SECTION,base)
	@$(call install_fixup,qemu-arm, AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup,qemu-arm, DEPENDS,)
	@$(call install_fixup,qemu-arm, DESCRIPTION,missing)

	# create /etc/rc.d links
	@$(call install_copy, qemu-arm, 0, 0, 0755, /etc/rc.d)
	@$(call install_copy, qemu-arm, 0, 0, 0755, /etc/init.d)
	@$(call install_copy, qemu-arm, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/modules.qemuarm, \
		/etc/modules,n)
	@$(call install_copy, qemu-arm, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/inittab.qemuarm, \
		/etc/inittab,n)

	@$(call install_node, qemu-arm, 0, 0, 0644, c, 204, 64, /dev/ttyAMA0)

ifdef PTXCONF_PEKWM
	cd $(PTXDIST_WORKSPACE)/projectroot/etc/pekwm && \
		for file in `find -type f ! -path "*.svn*"`; do \
			$(call install_copy, qemu-arm, 0, 0, 0644, \
				$$file, /etc/pekwm/$$file, n) \
		done
endif
ifdef PTXCONF_XORG_SERVER
	@$(call install_copy, qemu-arm, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xorg.conf, \
		/etc/X11/xorg.conf, n)
	@$(call install_copy, qemu-arm, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/usr/lib/X11/fonts/misc/fonts.dir, \
		/usr/lib/X11/fonts/misc/fonts.dir, n)
	@$(call install_copy, qemu-arm, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xinitrc, \
		/etc/X11/xinitrc, n)
	@$(call install_copy, qemu-arm, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/init.d/xorg, \
		/etc/init.d/xorg, n)
	@$(call install_copy, qemu-arm, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/ts.conf, /etc/ts.conf, n)
	@$(call install_link, qemu-arm, ../init.d/xorg, /etc/rc.d/S13_xorg)
	@$(call install_link, qemu-arm, /usr/bin/Xorg, /usr/bin/X)
endif

	@$(call install_copy, qemu-arm, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/hosts.equiv, \
		/etc/hosts.equiv, n)

	@$(call install_finish, qemu-arm)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

qemu-arm_clean:
	rm -rf $(STATEDIR)/qemu-arm.*
	rm -rf $(IMAGEDIR)/qemu-arm_*
	rm -rf $(QEMU_ARM_DIR)

# vim: syntax=make

