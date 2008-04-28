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
PACKAGES-$(PTXCONF_ITELEC_DAVINCI) += itelec-davinci

#
# Paths and names
#
ITELEC_DAVINCI_VERSION	:= 1.0.0
ITELEC_DAVINCI		:= iTelec-Davinci-$(ITELEC_DAVINCI_VERSION)
ITELEC_DAVINCI_SUFFIX	:=
ITELEC_DAVINCI_URL	:=
ITELEC_DAVINCI_SOURCE	:=
ITELEC_DAVINCI_DIR	:= $(BUILDDIR)/$(ITELEC_DAVINCI)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

itelec-davinci_get: $(STATEDIR)/itelec-davinci.get

$(STATEDIR)/itelec-davinci.get:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

itelec-davinci_extract: $(STATEDIR)/itelec-davinci.extract

$(STATEDIR)/itelec-davinci.extract:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

itelec-davinci_prepare: $(STATEDIR)/itelec-davinci.prepare

$(STATEDIR)/itelec-davinci.prepare: $(itelec-davinci_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

itelec-davinci_compile: $(STATEDIR)/itelec-davinci.compile

$(STATEDIR)/itelec-davinci.compile: $(itelec-davinci_compile_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

itelec-davinci_install: $(STATEDIR)/itelec-davinci.install

$(STATEDIR)/itelec-davinci.install: $(itelec-davinci_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

itelec-davinci_targetinstall: $(STATEDIR)/itelec-davinci.targetinstall

$(STATEDIR)/itelec-davinci.targetinstall: $(itelec-davinci_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init,itelec-davinci)
	@$(call install_fixup,itelec-davinci, PACKAGE,itelec-davinci)
	@$(call install_fixup,itelec-davinci, PRIORITY,optional)
	@$(call install_fixup,itelec-davinci, VERSION,$(ITELEC_DAVINCI_VERSION))
	@$(call install_fixup,itelec-davinci, SECTION,base)
	@$(call install_fixup,itelec-davinci, AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup,itelec-davinci, DEPENDS,)
	@$(call install_fixup,itelec-davinci, DESCRIPTION,missing)

	# create /etc/rc.d links
	@$(call install_copy, itelec-davinci, 0, 0, 0755, /etc/rc.d)
	@$(call install_copy, itelec-davinci, 0, 0, 0755, /etc/init.d)
	@$(call install_copy, itelec-davinci, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/modules.davinci, \
		/etc/modules,n)

ifdef PTXCONF_PEKWM
	cd $(PTXDIST_WORKSPACE)/projectroot/etc/pekwm && \
		for file in `find -type f ! -path "*.svn*"`; do \
			$(call install_copy, itelec-davinci, 0, 0, 0644, \
				$$file, /etc/pekwm/$$file, n) \
		done
endif

ifdef PTXCONF_XORG_SERVER
	@$(call install_copy, itelec-davinci, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xorg.conf, \
		/etc/X11/xorg.conf, n)
	@$(call install_copy, itelec-davinci, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/usr/lib/X11/fonts/misc/fonts.dir, \
		/usr/lib/X11/fonts/misc/fonts.dir, n)
	@$(call install_copy, itelec-davinci, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xinitrc, \
		/etc/X11/xinitrc, n)
	@$(call install_copy, itelec-davinci, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/init.d/xorg, \
		/etc/init.d/xorg, n)
	@$(call install_copy, itelec-davinci, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/ts.conf, /etc/ts.conf, n)
	@$(call install_link, itelec-davinci, ../init.d/xorg, /etc/rc.d/S13_xorg)
	@$(call install_link, itelec-davinci, /usr/bin/Xorg, /usr/bin/X)
endif

	@$(call install_copy, itelec-davinci, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/hosts.equiv, \
		/etc/hosts.equiv, n)

	@$(call install_finish, itelec-davinci)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

itelec-davinci_clean:
	rm -rf $(STATEDIR)/itelec-davinci.*
	rm -rf $(IMAGEDIR)/itelec-davinci_*
	rm -rf $(ITELEC_DAVINCI_DIR)

# vim: syntax=make

