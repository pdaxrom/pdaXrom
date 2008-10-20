# -*-makefile-*-
# $Id: template 5709 2006-06-09 13:55:00Z mkl $
#
# Copyright (C) 2006 by Marc Kleine-Budde <mkl@pengutronix.de>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PXACAMERA) += pxacamera

#
# Paths and names
#
PXACAMERA_VERSION	:= 0.1
PXACAMERA		:= pxacamera-$(PXACAMERA_VERSION)
PXACAMERA_SUFFIX	:= tar.bz2
PXACAMERA_URL		:= http://www.pengutronix.de/software/ptxdist/temporary-src/$(PXACAMERA).$(PXACAMERA_SUFFIX)
PXACAMERA_SOURCE	:= $(SRCDIR)/$(PXACAMERA).$(PXACAMERA_SUFFIX)
PXACAMERA_DIR		:= $(BUILDDIR)/$(PXACAMERA)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pxacamera_get: $(STATEDIR)/pxacamera.get

$(STATEDIR)/pxacamera.get: $(pxacamera_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(PXACAMERA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, PXACAMERA)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pxacamera_extract: $(STATEDIR)/pxacamera.extract

$(STATEDIR)/pxacamera.extract: $(pxacamera_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(PXACAMERA_DIR))
	@$(call extract, PXACAMERA)
	@$(call patchin, PXACAMERA)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pxacamera_prepare: $(STATEDIR)/pxacamera.prepare

PXACAMERA_PATH	:=  PATH=$(CROSS_PATH)
PXACAMERA_ENV 	:=  $(CROSS_ENV)

$(STATEDIR)/pxacamera.prepare: $(pxacamera_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pxacamera_compile: $(STATEDIR)/pxacamera.compile

$(STATEDIR)/pxacamera.compile: $(pxacamera_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(PXACAMERA_DIR) && $(PXACAMERA_PATH) $(PXACAMERA_ENV) make
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pxacamera_install: $(STATEDIR)/pxacamera.install

$(STATEDIR)/pxacamera.install: $(pxacamera_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pxacamera_targetinstall: $(STATEDIR)/pxacamera.targetinstall

$(STATEDIR)/pxacamera.targetinstall: $(pxacamera_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, pxacamera)
	@$(call install_fixup,pxacamera,PACKAGE,pxacamera)
	@$(call install_fixup,pxacamera,PRIORITY,optional)
	@$(call install_fixup,pxacamera,VERSION,$(PXACAMERA_VERSION))
	@$(call install_fixup,pxacamera,SECTION,base)
	@$(call install_fixup,pxacamera,AUTHOR,"Robert Schwebel <r.schwebel\@pengutronix.de>")
	@$(call install_fixup,pxacamera,DEPENDS,)
	@$(call install_fixup,pxacamera,DESCRIPTION,missing)

	@$(call install_copy, pxacamera, 0, 0, 0755, $(PXACAMERA_DIR)/pxacam, /usr/bin/pxacam)

	@$(call install_finish,pxacamera)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pxacamera_clean:
	rm -rf $(STATEDIR)/pxacamera.*
	rm -rf $(IMAGEDIR)/pxacamera_*
	rm -rf $(PXACAMERA_DIR)

# vim: syntax=make
