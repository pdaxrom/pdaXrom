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
ifdef PTXCONF_XCHAIN_PERL
PACKAGES += xchain-perl
endif

#
# Paths and names
#
XCHAIN_PERL		= perl-$(PERL_VERSION)
XCHAIN_PERL_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_PERL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-perl_get: $(STATEDIR)/xchain-perl.get

xchain-perl_get_deps = $(XCHAIN_PERL_SOURCE)

$(STATEDIR)/xchain-perl.get: $(xchain-perl_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_PERL))
	touch $@

$(XCHAIN_PERL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_PERL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-perl_extract: $(STATEDIR)/xchain-perl.extract

xchain-perl_extract_deps = $(STATEDIR)/xchain-perl.get

$(STATEDIR)/xchain-perl.extract: $(xchain-perl_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_PERL_DIR))
	@$(call extract, $(PERL_SOURCE), $(XCHAIN_BUILDDIR))
	#@$(call patchin, $(XCHAIN_PERL), $(XCHAIN_PERL_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-perl_prepare: $(STATEDIR)/xchain-perl.prepare

#
# dependencies
#
xchain-perl_prepare_deps = \
	$(STATEDIR)/xchain-perl.extract

XCHAIN_PERL_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_PERL_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_PERL_ENV	+=

#
# autoconf
#
XCHAIN_PERL_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-perl.prepare: $(xchain-perl_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_PERL_DIR)/config.cache)
	cd $(XCHAIN_PERL_DIR) && \
		$(XCHAIN_PERL_PATH) $(XCHAIN_PERL_ENV) \
		./Configure -de -Dprefix=$(PTXCONF_PREFIX)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-perl_compile: $(STATEDIR)/xchain-perl.compile

xchain-perl_compile_deps = $(STATEDIR)/xchain-perl.prepare

$(STATEDIR)/xchain-perl.compile: $(xchain-perl_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_PERL_PATH) $(MAKE) -C $(XCHAIN_PERL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-perl_install: $(STATEDIR)/xchain-perl.install

$(STATEDIR)/xchain-perl.install: $(STATEDIR)/xchain-perl.compile
	@$(call targetinfo, $@)
	$(XCHAIN_PERL_PATH) $(MAKE) -C $(XCHAIN_PERL_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-perl_targetinstall: $(STATEDIR)/xchain-perl.targetinstall

xchain-perl_targetinstall_deps = $(STATEDIR)/xchain-perl.compile

$(STATEDIR)/xchain-perl.targetinstall: $(xchain-perl_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-perl_clean:
	rm -rf $(STATEDIR)/xchain-perl.*
	rm -rf $(XCHAIN_PERL_DIR)

# vim: syntax=make
