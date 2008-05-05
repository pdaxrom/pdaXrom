# -*-makefile-*-
# $Id: template-make 7626 2007-11-26 10:27:03Z mkl $
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_OPENBOX) += openbox

#
# Paths and names
#
OPENBOX_VERSION	:= 3.4.7.2
OPENBOX		:= openbox-$(OPENBOX_VERSION)
OPENBOX_SUFFIX	:= tar.gz
OPENBOX_URL	:= http://icculus.org/openbox/releases/$(OPENBOX).$(OPENBOX_SUFFIX)
OPENBOX_SOURCE	:= $(SRCDIR)/$(OPENBOX).$(OPENBOX_SUFFIX)
OPENBOX_DIR	:= $(BUILDDIR)/$(OPENBOX)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

openbox_get: $(STATEDIR)/openbox.get

$(STATEDIR)/openbox.get: $(openbox_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(OPENBOX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, OPENBOX)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

openbox_extract: $(STATEDIR)/openbox.extract

$(STATEDIR)/openbox.extract: $(openbox_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENBOX_DIR))
	@$(call extract, OPENBOX)
	@$(call patchin, OPENBOX)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

openbox_prepare: $(STATEDIR)/openbox.prepare

OPENBOX_PATH	:= PATH=$(CROSS_PATH)
OPENBOX_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
OPENBOX_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/openbox.prepare: $(openbox_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENBOX_DIR)/config.cache)
	cd $(OPENBOX_DIR) && \
		$(OPENBOX_PATH) $(OPENBOX_ENV) \
		./configure $(OPENBOX_AUTOCONF)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

openbox_compile: $(STATEDIR)/openbox.compile

$(STATEDIR)/openbox.compile: $(openbox_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(OPENBOX_DIR) && $(OPENBOX_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

openbox_install: $(STATEDIR)/openbox.install

$(STATEDIR)/openbox.install: $(openbox_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

openbox_targetinstall: $(STATEDIR)/openbox.targetinstall

$(STATEDIR)/openbox.targetinstall: $(openbox_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, openbox)
	@$(call install_fixup, openbox,PACKAGE,openbox)
	@$(call install_fixup, openbox,PRIORITY,optional)
	@$(call install_fixup, openbox,VERSION,$(OPENBOX_VERSION))
	@$(call install_fixup, openbox,SECTION,base)
	@$(call install_fixup, openbox,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, openbox,DEPENDS,)
	@$(call install_fixup, openbox,DESCRIPTION,missing)

	@$(call install_copy, openbox, 0, 0, 0644, $(OPENBOX_DIR)/data/menu.xml, /etc/xdg/openbox/menu.xml)
	@$(call install_copy, openbox, 0, 0, 0644, $(OPENBOX_DIR)/data/rc.xml,   /etc/xdg/openbox/rc.xml)
	@$(call install_copy, openbox, 0, 0, 0755, $(OPENBOX_DIR)/openbox/.libs/openbox, /usr/bin/openbox)
	@$(call install_copy, openbox, 0, 0, 0644, $(OPENBOX_DIR)/parser/.libs/libobparser.so.21.0.2, /usr/lib/libobparser.so.21.0.2)
	@$(call install_link, openbox, libobparser.so.21.0.2, /usr/lib/libobparser.so.21)
	@$(call install_link, openbox, libobparser.so.21.0.2, /usr/lib/libobparser.so)
	@$(call install_copy, openbox, 0, 0, 0644, $(OPENBOX_DIR)/render/.libs/libobrender.so.21.0.2, /usr/lib/libobrender.so.21.0.2)
	@$(call install_link, openbox, libobrender.so.21.0.2, /usr/lib/libobrender.so.21)
	@$(call install_link, openbox, libobrender.so.21.0.2, /usr/lib/libobrender.so)
	@$(call install_copy, openbox, 0, 0, 0644, $(OPENBOX_DIR)/data/openbox.png, /usr/share/pixmaps/openbox.png)
	@$(call install_copy, openbox, 0, 0, 0755, $(OPENBOX_DIR)/data/xsession/openbox-session, /usr/bin/openbox-session)
	@$(call install_copy, openbox, 0, 0, 0644, $(OPENBOX_DIR)/data/xsession/openbox.desktop, /usr/share/xsessions/openbox.desktop)
	@$(call install_copy, openbox, 0, 0, 0644, $(OPENBOX_DIR)/themes/Clearlooks/openbox-3/themerc, /usr/share/themes/Clearlooks/openbox-3/themerc)

	@$(call install_finish, openbox)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

openbox_clean:
	rm -rf $(STATEDIR)/openbox.*
	rm -rf $(IMAGEDIR)/openbox_*
	rm -rf $(OPENBOX_DIR)

# vim: syntax=make
