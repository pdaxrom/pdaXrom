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
PACKAGES-$(PTXCONF_SHARP_AKITA) += sharp-akita

#
# Paths and names
#
SHARP_AKITA_VERSION	:= 1.0.0
SHARP_AKITA		:= sharp-akita-$(SHARP_AKITA_VERSION)
SHARP_AKITA_SUFFIX	:=
SHARP_AKITA_URL	:=
SHARP_AKITA_SOURCE	:=
SHARP_AKITA_DIR	:= $(BUILDDIR)/$(SHARP_AKITA)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sharp-akita_get: $(STATEDIR)/sharp-akita.get

$(STATEDIR)/sharp-akita.get:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sharp-akita_extract: $(STATEDIR)/sharp-akita.extract

$(STATEDIR)/sharp-akita.extract:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sharp-akita_prepare: $(STATEDIR)/sharp-akita.prepare

$(STATEDIR)/sharp-akita.prepare: $(sharp-akita_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sharp-akita_compile: $(STATEDIR)/sharp-akita.compile

$(STATEDIR)/sharp-akita.compile: $(sharp-akita_compile_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sharp-akita_install: $(STATEDIR)/sharp-akita.install

$(STATEDIR)/sharp-akita.install: $(sharp-akita_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sharp-akita_targetinstall: $(STATEDIR)/sharp-akita.targetinstall

$(STATEDIR)/sharp-akita.targetinstall: $(sharp-akita_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init,sharp-akita)
	@$(call install_fixup,sharp-akita, PACKAGE,sharp-akita)
	@$(call install_fixup,sharp-akita, PRIORITY,optional)
	@$(call install_fixup,sharp-akita, VERSION,$(SHARP_AKITA_VERSION))
	@$(call install_fixup,sharp-akita, SECTION,base)
	@$(call install_fixup,sharp-akita, AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup,sharp-akita, DEPENDS,)
	@$(call install_fixup,sharp-akita, DESCRIPTION,missing)

	# create /etc/rc.d links
	@$(call install_copy, sharp-akita, 0, 0, 0755, /etc/rc.d)
	@$(call install_copy, sharp-akita, 0, 0, 0755, /etc/init.d)
	@$(call install_copy, sharp-akita, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/modules.akita, \
		/etc/modules,n)
	@$(call install_copy, sharp-akita, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/inittab, \
		/etc/inittab,n)

ifdef PTXCONF_CONSOLE_TOOLS_LOADKEYS_INIT
	@$(call install_copy, sharp-akita, 0, 0, 0644, \
		$(PDAXROMDIR)/configs/keymaps/akita/keymap-2.6.map, /etc/keymap-2.6.map)
endif

ifdef PTXCONF_PEKWM
	cd $(PTXDIST_WORKSPACE)/projectroot/etc/pekwm && \
		for file in `find -type f ! -path "*.svn*"`; do \
			$(call install_copy, sharp-akita, 0, 0, 0644, \
				$$file, /etc/pekwm/$$file, n) \
		done
endif
ifdef PTXCONF_XORG_SERVER
	@$(call install_copy, sharp-akita, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xorg.conf, \
		/etc/X11/xorg.conf, n)
	@$(call install_copy, sharp-akita, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/usr/lib/X11/fonts/misc/fonts.dir, \
		/usr/lib/X11/fonts/misc/fonts.dir, n)
	@$(call install_copy, sharp-akita, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xinitrc, \
		/etc/X11/xinitrc, n)
	@$(call install_copy, sharp-akita, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/init.d/xorg, \
		/etc/init.d/xorg, n)
	@$(call install_link, sharp-akita, ../init.d/xorg, /etc/rc.d/S13_xorg)
	@$(call install_link, sharp-akita, /usr/bin/Xorg, /usr/bin/X)
endif
	@$(call install_copy, sharp-akita, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/ts.conf, /etc/ts.conf, n)

	@$(call install_copy, sharp-akita, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/hosts.equiv, \
		/etc/hosts.equiv, n)

	@$(call install_finish, sharp-akita)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sharp-akita_clean:
	rm -rf $(STATEDIR)/sharp-akita.*
	rm -rf $(IMAGEDIR)/sharp-akita_*
	rm -rf $(SHARP_AKITA_DIR)

# vim: syntax=make

