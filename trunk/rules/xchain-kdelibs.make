# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_XCHAIN_KDELIBS
PACKAGES += xchain-kdelibs
endif

#
# Paths and names
#
XCHAIN_KDELIBS			= kdelibs-$(KDELIBS_VERSION)
XCHAIN_KDELIBS_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_KDELIBS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-kdelibs_get: $(STATEDIR)/xchain-kdelibs.get

xchain-kdelibs_get_deps = $(XCHAIN_KDELIBS_SOURCE)

$(STATEDIR)/xchain-kdelibs.get: $(xchain-kdelibs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_KDELIBS))
	touch $@

$(XCHAIN_KDELIBS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KDELIBS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-kdelibs_extract: $(STATEDIR)/xchain-kdelibs.extract

xchain-kdelibs_extract_deps = $(STATEDIR)/xchain-kdelibs.get

$(STATEDIR)/xchain-kdelibs.extract: $(xchain-kdelibs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_KDELIBS_DIR))
	@$(call extract, $(KDELIBS_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_KDELIBS), $(XCHAIN_KDELIBS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-kdelibs_prepare: $(STATEDIR)/xchain-kdelibs.prepare

#
# dependencies
#
xchain-kdelibs_prepare_deps = \
	$(STATEDIR)/xchain-kdelibs.extract

#XCHAIN_KDELIBS_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_KDELIBS_PATH	=  PATH=$(XCHAIN_QT-X11-FREE_DIR)/bin:$(PATH)
XCHAIN_KDELIBS_ENV 	=  $(HOSTCC_ENV)
XCHAIN_KDELIBS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
XCHAIN_KDELIBS_ENV	+= CXXFLAGS="-O2 -fomit-frame-pointer"

#
# autoconf
#
XCHAIN_KDELIBS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--without-arts \
	--with-extra-includes=$(NATIVE_SDK_FILES_PREFIX)/include \
	--prefix=$(XCHAIN_KDELIBS_DIR)/kde-fake-root
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-kdelibs.prepare: $(xchain-kdelibs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_KDELIBS_DIR)/config.cache)
	cd $(XCHAIN_KDELIBS_DIR) && \
		$(XCHAIN_KDELIBS_PATH) $(XCHAIN_KDELIBS_ENV) \
		./configure $(XCHAIN_KDELIBS_AUTOCONF)

	perl -i -p -e "s,$(XCHAIN_KDELIBS_DIR)/kde-fake-root,$(CROSS_LIB_DIR)/kde,g" $(XCHAIN_KDELIBS_DIR)/kdecore/kde-config.cpp

	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-kdelibs_compile: $(STATEDIR)/xchain-kdelibs.compile

xchain-kdelibs_compile_deps = $(STATEDIR)/xchain-kdelibs.prepare

$(STATEDIR)/xchain-kdelibs.compile: $(xchain-kdelibs_compile_deps)
	@$(call targetinfo, $@)

	$(XCHAIN_KDELIBS_PATH) $(MAKE) -C $(XCHAIN_KDELIBS_DIR)

#	$(XCHAIN_KDELIBS_PATH) $(MAKE) -C $(XCHAIN_KDELIBS_DIR)/dcop 
#	$(XCHAIN_KDELIBS_PATH) $(MAKE) -C $(XCHAIN_KDELIBS_DIR)/libltdl
#	$(XCHAIN_KDELIBS_PATH) $(MAKE) -C $(XCHAIN_KDELIBS_DIR)/kdefx
#	$(XCHAIN_KDELIBS_PATH) $(MAKE) -C $(XCHAIN_KDELIBS_DIR)/kdecore
#	$(XCHAIN_KDELIBS_PATH) $(MAKE) -C $(XCHAIN_KDELIBS_DIR)/kstyles/keramik genembed
#	$(XCHAIN_KDELIBS_PATH) $(MAKE) -C $(XCHAIN_KDELIBS_DIR)/pics kimage_concat ksvgtopng
#	$(XCHAIN_KDELIBS_PATH) $(MAKE) -C $(XCHAIN_KDELIBS_DIR)/kio
#	$(XCHAIN_KDELIBS_PATH) $(MAKE) -C $(XCHAIN_KDELIBS_DIR)/kdewidgets
	
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-kdelibs_install: $(STATEDIR)/xchain-kdelibs.install

$(STATEDIR)/xchain-kdelibs.install: $(STATEDIR)/xchain-kdelibs.compile
	@$(call targetinfo, $@)
	$(XCHAIN_KDELIBS_PATH) $(MAKE) -C $(XCHAIN_KDELIBS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-kdelibs_targetinstall: $(STATEDIR)/xchain-kdelibs.targetinstall

xchain-kdelibs_targetinstall_deps = $(STATEDIR)/xchain-kdelibs.compile

$(STATEDIR)/xchain-kdelibs.targetinstall: $(xchain-kdelibs_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-kdelibs_clean:
	rm -rf $(STATEDIR)/xchain-kdelibs.*
	rm -rf $(XCHAIN_KDELIBS_DIR)

# vim: syntax=make
