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
PACKAGES-$(PTXCONF_QEMU_X86) += qemu-x86

#
# Paths and names
#
QEMU_X86_VERSION	:= 1.0.0
QEMU_X86		:= qemu-x86-$(QEMU_X86_VERSION)
QEMU_X86_SUFFIX	:=
QEMU_X86_URL	:=
QEMU_X86_SOURCE	:=
QEMU_X86_DIR	:= $(BUILDDIR)/$(QEMU_X86)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

qemu-x86_get: $(STATEDIR)/qemu-x86.get

$(STATEDIR)/qemu-x86.get:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

qemu-x86_extract: $(STATEDIR)/qemu-x86.extract

$(STATEDIR)/qemu-x86.extract:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

qemu-x86_prepare: $(STATEDIR)/qemu-x86.prepare

$(STATEDIR)/qemu-x86.prepare: $(qemu-x86_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

qemu-x86_compile: $(STATEDIR)/qemu-x86.compile

$(STATEDIR)/qemu-x86.compile: $(qemu-x86_compile_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

qemu-x86_install: $(STATEDIR)/qemu-x86.install

$(STATEDIR)/qemu-x86.install: $(qemu-x86_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

qemu-x86_targetinstall: $(STATEDIR)/qemu-x86.targetinstall

$(STATEDIR)/qemu-x86.targetinstall: $(qemu-x86_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init,qemu-x86)
	@$(call install_fixup,qemu-x86, PACKAGE,qemu-x86)
	@$(call install_fixup,qemu-x86, PRIORITY,optional)
	@$(call install_fixup,qemu-x86, VERSION,$(QEMU_X86_VERSION))
	@$(call install_fixup,qemu-x86, SECTION,base)
	@$(call install_fixup,qemu-x86, AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup,qemu-x86, DEPENDS,)
	@$(call install_fixup,qemu-x86, DESCRIPTION,missing)

	# create /etc/rc.d links
	@$(call install_copy, qemu-x86, 0, 0, 0755, /etc/rc.d)
	@$(call install_copy, qemu-x86, 0, 0, 0755, /etc/init.d)
	@$(call install_copy, qemu-x86, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/modules.corgi, \
		/etc/modules,n)
	@$(call install_copy, qemu-x86, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/inittab, \
		/etc/inittab,n)

ifdef PTXCONF_PEKWM
	cd $(PTXDIST_WORKSPACE)/projectroot/etc/pekwm && \
		for file in `find -type f ! -path "*.svn*"`; do \
			$(call install_copy, qemu-x86, 0, 0, 0644, \
				$$file, /etc/pekwm/$$file, n) \
		done
endif
ifdef PTXCONF_XORG_SERVER
	@$(call install_copy, qemu-x86, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xorg.conf, \
		/etc/X11/xorg.conf, n)
	@$(call install_copy, qemu-x86, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/usr/lib/X11/fonts/misc/fonts.dir, \
		/usr/lib/X11/fonts/misc/fonts.dir, n)
	@$(call install_copy, qemu-x86, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xinitrc, \
		/etc/X11/xinitrc, n)
	@$(call install_copy, qemu-x86, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/init.d/xorg, \
		/etc/init.d/xorg, n)
	@$(call install_copy, qemu-x86, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/ts.conf, /etc/ts.conf, n)
	@$(call install_link, qemu-x86, ../init.d/xorg, /etc/rc.d/S13_xorg)
	@$(call install_link, qemu-x86, /usr/bin/Xorg, /usr/bin/X)
endif

	@$(call install_copy, qemu-x86, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/hosts.equiv, \
		/etc/hosts.equiv, n)

	@$(call install_finish, qemu-x86)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

qemu-x86_clean:
	rm -rf $(STATEDIR)/qemu-x86.*
	rm -rf $(IMAGEDIR)/qemu-x86_*
	rm -rf $(QEMU_X86_DIR)

# vim: syntax=make

