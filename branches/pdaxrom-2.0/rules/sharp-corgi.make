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
PACKAGES-$(PTXCONF_SHARP_CORGI) += sharp-corgi

#
# Paths and names
#
SHARP_CORGI_VERSION	:= 1.0.0
SHARP_CORGI		:= sharp-corgi-$(SHARP_CORGI_VERSION)
SHARP_CORGI_SUFFIX	:=
SHARP_CORGI_URL	:=
SHARP_CORGI_SOURCE	:=
SHARP_CORGI_DIR	:= $(BUILDDIR)/$(SHARP_CORGI)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sharp-corgi_get: $(STATEDIR)/sharp-corgi.get

$(STATEDIR)/sharp-corgi.get:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sharp-corgi_extract: $(STATEDIR)/sharp-corgi.extract

$(STATEDIR)/sharp-corgi.extract:
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sharp-corgi_prepare: $(STATEDIR)/sharp-corgi.prepare

$(STATEDIR)/sharp-corgi.prepare: $(sharp-corgi_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sharp-corgi_compile: $(STATEDIR)/sharp-corgi.compile

$(STATEDIR)/sharp-corgi.compile: $(sharp-corgi_compile_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sharp-corgi_install: $(STATEDIR)/sharp-corgi.install

$(STATEDIR)/sharp-corgi.install: $(sharp-corgi_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sharp-corgi_targetinstall: $(STATEDIR)/sharp-corgi.targetinstall

$(STATEDIR)/sharp-corgi.targetinstall: $(sharp-corgi_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init,sharp-corgi)
	@$(call install_fixup,sharp-corgi, PACKAGE,sharp-corgi)
	@$(call install_fixup,sharp-corgi, PRIORITY,optional)
	@$(call install_fixup,sharp-corgi, VERSION,$(SHARP_CORGI_VERSION))
	@$(call install_fixup,sharp-corgi, SECTION,base)
	@$(call install_fixup,sharp-corgi, AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup,sharp-corgi, DEPENDS,)
	@$(call install_fixup,sharp-corgi, DESCRIPTION,missing)

	# create /etc/rc.d links
	@$(call install_copy, sharp-corgi, 0, 0, 0755, /etc/rc.d)
	@$(call install_copy, sharp-corgi, 0, 0, 0755, /etc/init.d)
	@$(call install_copy, sharp-corgi, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/modules.corgi, \
		/etc/modules,n)
	@$(call install_copy, sharp-corgi, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/inittab, \
		/etc/inittab,n)

ifdef PTXCONF_PEKWM
	cd $(PTXDIST_WORKSPACE)/projectroot/etc/pekwm && \
		for file in `find -type f ! -path "*.svn*"`; do \
			$(call install_copy, sharp-corgi, 0, 0, 0644, \
				$$file, /etc/pekwm/$$file, n) \
		done
endif
ifdef PTXCONF_XORG_SERVER
	@$(call install_copy, sharp-corgi, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xorg.conf, \
		/etc/X11/xorg.conf, n)
	@$(call install_copy, sharp-corgi, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/usr/lib/X11/fonts/misc/fonts.dir, \
		/usr/lib/X11/fonts/misc/fonts.dir, n)
	@$(call install_copy, sharp-corgi, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/X11/xinitrc, \
		/etc/X11/xinitrc, n)
	@$(call install_copy, sharp-corgi, 0, 0, 0755, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/init.d/xorg, \
		/etc/init.d/xorg, n)
	@$(call install_copy, sharp-corgi, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/ts.conf, /etc/ts.conf, n)
	@$(call install_link, sharp-corgi, ../init.d/xorg, /etc/rc.d/S13_xorg)
	@$(call install_link, sharp-corgi, /usr/bin/Xorg, /usr/bin/X)
endif

	@$(call install_copy, sharp-corgi, 0, 0, 0644, \
		$(PTXDIST_WORKSPACE)/projectroot/etc/hosts.equiv, \
		/etc/hosts.equiv, n)

	@$(call install_finish, sharp-corgi)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sharp-corgi_clean:
	rm -rf $(STATEDIR)/sharp-corgi.*
	rm -rf $(IMAGEDIR)/sharp-corgi_*
	rm -rf $(SHARP_CORGI_DIR)

# vim: syntax=make

