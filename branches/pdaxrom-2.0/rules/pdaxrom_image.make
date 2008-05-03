# -*-makefile-*-
# $Id$
#
# Copyright (C) 2008 by Adrian Crutchfield <insearchof@pdaxrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PDAXROM_IMAGE) += pdaxrom_image

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pdaxrom_image_get: $(STATEDIR)/pdaxrom_image.get

$(STATEDIR)/pdaxrom_image.get: $(pdaxrom_image_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pdaxrom_image_extract: $(STATEDIR)/pdaxrom_image.extract

$(STATEDIR)/pdaxrom_image.extract: $(pdaxrom_image_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pdaxrom_image_prepare: $(STATEDIR)/pdaxrom_image.prepare

$(STATEDIR)/pdaxrom_image.prepare: $(pdaxrom_image_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pdaxrom_image_compile: $(STATEDIR)/pdaxrom_image.compile

$(STATEDIR)/pdaxrom_image.compile: $(pdaxrom_image_compile_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pdaxrom_image_install: $(STATEDIR)/pdaxrom_image.install

$(STATEDIR)/pdaxrom_image.install: $(pdaxrom_image_install_deps_default)
	@$(call targetinfo, $@)

	@ tar cvf $(IMAGEDIR)/pdaxrom-$(PTXCONF_PROJECT_VERSION).tar $(IMAGEDIR)/root.jffs2 $(IMAGEDIR)/kernel.img $(PTXDIST_WORKSPACE)/pdaxrom_data/autoboot.sh > /dev/null 2<&1
 
# FIXME: rsc: this needs a proper SYSROOT description!
#
# TODO:	For files that are required at compiletime (headers, libs to link against)
#	you can copy these files to the sysroot directory.
#	Use macro $(PTXCONF_PREFIX) for host files and $(PTXCONF_GNU_TARGET)
#	for target files
#
#	Example for a host header file:
#		@cp friesel.h $(PTXCONF_PREFIX)/include
#	Example for a host library file:
#		@cp friesel.so $(PTXCONF_PREFIX)/lib
#	Example for a target file:
#		@cp frasel.h  $$(PTXCONF_GNU_TARGET)/include
#	Example for a target library file:
#		@cp frasel.so $(PTXCONF_GNU_TARGET)/lib
#
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pdaxrom_image_targetinstall: $(STATEDIR)/pdaxrom_image.targetinstall

$(STATEDIR)/pdaxrom_image.targetinstall: $(pdaxrom_image_targetinstall_deps_default)
	@$(call targetinfo, $@)
#
# TODO: To build your own packet, if this step requires one
#	@$(call install_init, pdaxrom_image)
#	@$(call install_fixup,pdaxrom_image,PACKAGE,pdaxrom_image)
#	@$(call install_fixup,pdaxrom_image,PRIORITY,optional)
#	@$(call install_fixup,pdaxrom_image,VERSION,0)
#	@$(call install_fixup,pdaxrom_image,SECTION,base)
#	@$(call install_fixup,pdaxrom_image,AUTHOR,"Adrian Crutchfield <insearchof@pdaxrom.org>")
#	@$(call install_fixup,pdaxrom_image,DEPENDS,)
#	@$(call install_fixup,pdaxrom_image,DESCRIPTION,missing)
#
# TODO: Add here all files that should be copied to the target
# Note: Add everything before(!) call to macro install_finish
#
#	@$(call install_copy, pdaxrom_image, 0, 0, 0755, $(PDAXROM_IMAGE_DIR)/foobar, /dev/null)
#
#	@$(call install_finish,pdaxrom_image)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pdaxrom_image_clean:
	rm -rf $(STATEDIR)/pdaxrom_image.*

# vim: syntax=make
