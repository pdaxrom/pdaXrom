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
PACKAGES-$(PTXCONF_PHYCORE_PXA270) += phycore-pxa270

#
# Paths and names
#
PHYCORE_PXA270_VERSION	:= 1.0.0
PHYCORE_PXA270		:= phyCORE-PXA270-$(PHYCORE_PXA270_VERSION)
PHYCORE_PXA270_SUFFIX	:=
PHYCORE_PXA270_URL	:=
PHYCORE_PXA270_SOURCE	:=
PHYCORE_PXA270_DIR	:= $(BUILDDIR)/$(PHYCORE_PXA270)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

phycore-pxa270_get: $(STATEDIR)/phycore-pxa270.get

$(STATEDIR)/phycore-pxa270.get:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

phycore-pxa270_extract: $(STATEDIR)/phycore-pxa270.extract

$(STATEDIR)/phycore-pxa270.extract:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

phycore-pxa270_prepare: $(STATEDIR)/phycore-pxa270.prepare

$(STATEDIR)/phycore-pxa270.prepare: $(phycore-pxa270_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

phycore-pxa270_compile: $(STATEDIR)/phycore-pxa270.compile

$(STATEDIR)/phycore-pxa270.compile: $(phycore-pxa270_compile_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

phycore-pxa270_install: $(STATEDIR)/phycore-pxa270.install

$(STATEDIR)/phycore-pxa270.install: $(phycore-pxa270_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

phycore-pxa270_targetinstall: $(STATEDIR)/phycore-pxa270.targetinstall

$(STATEDIR)/phycore-pxa270.targetinstall: $(phycore-pxa270_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init,phycore-pxa270)
	@$(call install_fixup,phycore-pxa270, PACKAGE,phycore-pxa270)
	@$(call install_fixup,phycore-pxa270, PRIORITY,optional)
	@$(call install_fixup,phycore-pxa270, VERSION,$(PHYCORE_PXA270_VERSION))
	@$(call install_fixup,phycore-pxa270, SECTION,base)
	@$(call install_fixup,phycore-pxa270, AUTHOR,"Robert Schwebel <r.schwebel\@pengutronix.de>")
	@$(call install_fixup,phycore-pxa270, DEPENDS,)
	@$(call install_fixup,phycore-pxa270, DESCRIPTION,missing)

	# create /etc/rc.d links
	@$(call install_copy, phycore-pxa270, 0, 0, 0755, /etc/rc.d)
	@$(call install_copy, phycore-pxa270, 0, 0, 0755, /etc/init.d)
	@$(call install_copy, phycore-pxa270, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/network/can-pre-up, \
		/etc/network/can-pre-up,n)
	# create some special setup files
	@$(call install_copy, phycore-pxa270, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/gpio/gpio, \
		/etc/init.d/gpio, n)
	@$(call install_link, phycore-pxa270, \
		../init.d/gpio, /etc/rc.d/S12_gpio)

ifdef PTXCONF_PEKWM
	cd $(PTXDIST_WORKSPACE)/projectroot/etc/pekwm && \
		for file in `find -type f ! -path "*.svn*"`; do \
			$(call install_copy, phycore-pxa270, 0, 0, 0644, \
				$$file, /etc/pekwm/$$file, n) \
		done
endif
ifdef PTXCONF_XORG_SERVER
	@$(call install_copy, phycore-pxa270, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xorg.conf, \
		/etc/X11/xorg.conf, n)
	@$(call install_copy, phycore-pxa270, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/usr/lib/X11/fonts/misc/fonts.dir, \
		/usr/lib/X11/fonts/misc/fonts.dir, n)
	@$(call install_copy, phycore-pxa270, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xinitrc, \
		/etc/X11/xinitrc, n)
	@$(call install_copy, phycore-pxa270, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/init.d/xorg, \
		/etc/init.d/xorg, n)
	@$(call install_copy, phycore-pxa270, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/ts.conf, /etc/ts.conf, n)
	@$(call install_link, phycore-pxa270, ../init.d/xorg, /etc/rc.d/S13_xorg)
	@$(call install_link, phycore-pxa270, /usr/bin/Xorg, /usr/bin/X)
endif

	@$(call install_copy, phycore-pxa270, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/hosts.equiv, \
		/etc/hosts.equiv, n)

	@$(call install_finish, phycore-pxa270)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

phycore-pxa270_clean:
	rm -rf $(STATEDIR)/phycore-pxa270.*
	rm -rf $(IMAGEDIR)/phycore-pxa270_*
	rm -rf $(PHYCORE_PXA270_DIR)

# vim: syntax=make

