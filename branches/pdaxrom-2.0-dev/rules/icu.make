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
PACKAGES-$(PTXCONF_ICU) += icu

#
# Paths and names
#
ICU_VERSION	:= 3.8.1
ICU		:= icu4c-3_8_1-src
ICU_SUFFIX	:= tgz
ICU_URL		:= http://download.icu-project.org/files/icu4c/3.8.1/$(ICU).$(ICU_SUFFIX)
ICU_SOURCE	:= $(SRCDIR)/$(ICU).$(ICU_SUFFIX)
ICU_DIR		:= $(BUILDDIR)/icu/source

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

icu_get: $(STATEDIR)/icu.get

$(STATEDIR)/icu.get: $(icu_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(ICU_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, ICU)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

icu_extract: $(STATEDIR)/icu.extract

$(STATEDIR)/icu.extract: $(icu_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(ICU_DIR))
	@$(call extract, ICU)
	@$(call patchin, ICU)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

icu_prepare: $(STATEDIR)/icu.prepare

ICU_PATH	:= PATH=$(CROSS_PATH)
ICU_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
ICU_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/icu.prepare: $(icu_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(ICU_DIR)/config.cache)
	cd $(ICU_DIR) && \
		$(ICU_PATH) $(ICU_ENV) \
		./configure $(ICU_AUTOCONF)
	for i in $(ICU_DIR)/*/Makefile $(ICU_DIR)/*/*.inc $(ICU_DIR)/*/*/Makefile $(ICU_DIR)/*/*/*.inc ; do \
	    sed -i -e 's:$$(INVOKE) $$(BINDIR)/:$$(INVOKE) :g' $$i ; \
	    sed -i -e 's:$$(BINDIR)/::g' $$i ; \
	done
	sed -i -e 's:$$(BINDIR)/::g' $(ICU_DIR)/extra/uconv/pkgdata.inc || true
	sed -i -e 's:$$(BINDIR)/::g' $(ICU_DIR)/extra/uconv/pkgdata.inc.in || true
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

icu_compile: $(STATEDIR)/icu.compile

$(STATEDIR)/icu.compile: $(icu_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(ICU_DIR) && $(ICU_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

icu_install: $(STATEDIR)/icu.install

$(STATEDIR)/icu.install: $(icu_install_deps_default)
	@$(call targetinfo, $@)
	@$(call install, ICU)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

icu_targetinstall: $(STATEDIR)/icu.targetinstall

$(STATEDIR)/icu.targetinstall: $(icu_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init,  icu)
	@$(call install_fixup, icu,PACKAGE,libicudata)
	@$(call install_fixup, icu,PRIORITY,optional)
	@$(call install_fixup, icu,VERSION,$(ICU_VERSION))
	@$(call install_fixup, icu,SECTION,base)
	@$(call install_fixup, icu,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, icu,DEPENDS,)
	@$(call install_fixup, icu,DESCRIPTION,missing)
	@$(call install_copy,  icu, 0, 0, 0755, $(ICU_DIR)/lib/libicudata.so.38.1, /usr/lib/libicudata.so.38.1)
	@$(call install_link,  icu, libicudata.so.38.1, /usr/lib/libicudata.so.38)
	@$(call install_link,  icu, libicudata.so.38.1, /usr/lib/libicudata.so)	
	@$(call install_finish,icu)

	@$(call install_init,  icu)
	@$(call install_fixup, icu,PACKAGE,libicui18n)
	@$(call install_fixup, icu,PRIORITY,optional)
	@$(call install_fixup, icu,VERSION,$(ICU_VERSION))
	@$(call install_fixup, icu,SECTION,base)
	@$(call install_fixup, icu,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, icu,DEPENDS,)
	@$(call install_fixup, icu,DESCRIPTION,missing)
	@$(call install_copy,  icu, 0, 0, 0755, $(ICU_DIR)/lib/libicui18n.so.38.1, /usr/lib/libicui18n.so.38.1)
	@$(call install_link,  icu, libicui18n.so.38.1, /usr/lib/libicui18n.so.38)
	@$(call install_link,  icu, libicui18n.so.38.1, /usr/lib/libicui18n.so)	
	@$(call install_finish,icu)

	@$(call install_init,  icu)
	@$(call install_fixup, icu,PACKAGE,libicuio)
	@$(call install_fixup, icu,PRIORITY,optional)
	@$(call install_fixup, icu,VERSION,$(ICU_VERSION))
	@$(call install_fixup, icu,SECTION,base)
	@$(call install_fixup, icu,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, icu,DEPENDS,)
	@$(call install_fixup, icu,DESCRIPTION,missing)
	@$(call install_copy,  icu, 0, 0, 0755, $(ICU_DIR)/lib/libicuio.so.38.1, /usr/lib/libicuio.so.38.1)
	@$(call install_link,  icu, libicuio.so.38.1, /usr/lib/libicuio.so.38)
	@$(call install_link,  icu, libicuio.so.38.1, /usr/lib/libicuio.so)	
	@$(call install_finish,icu)

	@$(call install_init,  icu)
	@$(call install_fixup, icu,PACKAGE,libicule)
	@$(call install_fixup, icu,PRIORITY,optional)
	@$(call install_fixup, icu,VERSION,$(ICU_VERSION))
	@$(call install_fixup, icu,SECTION,base)
	@$(call install_fixup, icu,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, icu,DEPENDS,)
	@$(call install_fixup, icu,DESCRIPTION,missing)
	@$(call install_copy,  icu, 0, 0, 0755, $(ICU_DIR)/lib/libicule.so.38.1, /usr/lib/libicule.so.38.1)
	@$(call install_link,  icu, libicule.so.38.1, /usr/lib/libicule.so.38)
	@$(call install_link,  icu, libicule.so.38.1, /usr/lib/libicule.so)	
	@$(call install_finish,icu)

	@$(call install_init,  icu)
	@$(call install_fixup, icu,PACKAGE,libiculx)
	@$(call install_fixup, icu,PRIORITY,optional)
	@$(call install_fixup, icu,VERSION,$(ICU_VERSION))
	@$(call install_fixup, icu,SECTION,base)
	@$(call install_fixup, icu,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, icu,DEPENDS,)
	@$(call install_fixup, icu,DESCRIPTION,missing)
	@$(call install_copy,  icu, 0, 0, 0755, $(ICU_DIR)/lib/libiculx.so.38.1, /usr/lib/libiculx.so.38.1)
	@$(call install_link,  icu, libiculx.so.38.1, /usr/lib/libiculx.so.38)
	@$(call install_link,  icu, libiculx.so.38.1, /usr/lib/libiculx.so)	
	@$(call install_finish,icu)

	@$(call install_init,  icu)
	@$(call install_fixup, icu,PACKAGE,libicutu)
	@$(call install_fixup, icu,PRIORITY,optional)
	@$(call install_fixup, icu,VERSION,$(ICU_VERSION))
	@$(call install_fixup, icu,SECTION,base)
	@$(call install_fixup, icu,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, icu,DEPENDS,)
	@$(call install_fixup, icu,DESCRIPTION,missing)
	@$(call install_copy,  icu, 0, 0, 0755, $(ICU_DIR)/lib/libicutu.so.38.1, /usr/lib/libicutu.so.38.1)
	@$(call install_link,  icu, libicutu.so.38.1, /usr/lib/libicutu.so.38)
	@$(call install_link,  icu, libicutu.so.38.1, /usr/lib/libicutu.so)	
	@$(call install_finish,icu)

	@$(call install_init,  icu)
	@$(call install_fixup, icu,PACKAGE,libicuuc)
	@$(call install_fixup, icu,PRIORITY,optional)
	@$(call install_fixup, icu,VERSION,$(ICU_VERSION))
	@$(call install_fixup, icu,SECTION,base)
	@$(call install_fixup, icu,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, icu,DEPENDS,)
	@$(call install_fixup, icu,DESCRIPTION,missing)
	@$(call install_copy,  icu, 0, 0, 0755, $(ICU_DIR)/lib/libicuuc.so.38.1, /usr/lib/libicuuc.so.38.1)
	@$(call install_link,  icu, libicuuc.so.38.1, /usr/lib/libicuuc.so.38)
	@$(call install_link,  icu, libicuuc.so.38.1, /usr/lib/libicuuc.so)	
	@$(call install_finish,icu)

	@$(call install_init,  icu)
	@$(call install_fixup, icu,PACKAGE,icu)
	@$(call install_fixup, icu,PRIORITY,optional)
	@$(call install_fixup, icu,VERSION,$(ICU_VERSION))
	@$(call install_fixup, icu,SECTION,base)
	@$(call install_fixup, icu,AUTHOR,"Alexander Chukov <sash\@pdaXrom.org>")
	@$(call install_fixup, icu,DEPENDS, "libicudata libicui18n libicuio libicule libiculx libicutu libicuuc")
	@$(call install_fixup, icu,DESCRIPTION,missing)

	for f in genbidi genbrk gencase genccode gencmn gencnval genctd gennames gennorm genpname genprops \
	    genrb gensprep genuca icupkg icuswap makeconv pkgdata; do \
	    $(call install_copy,  icu, 0, 0, 0755, $(ICU_DIR)/tools/$$f/$$f, 	/usr/bin/$$f) ; \
	done

	@$(call install_copy,  icu, 0, 0, 0755, $(ICU_DIR)/tools/genrb/derb, 	/usr/bin/derb)

	@$(call install_finish, icu)

	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

icu_clean:
	rm -rf $(STATEDIR)/icu.*
	rm -rf $(IMAGEDIR)/icu_*
	rm -rf $(ICU_DIR)

# vim: syntax=make
