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
ifdef PTXCONF_XCHAIN_FLTK-UTF8
PACKAGES += xchain-fltk-utf8
endif

#
# Paths and names
#
XCHAIN_FLTK-UTF8		= fltk-utf8-$(FLTK-UTF8_VERSION)
XCHAIN_FLTK-UTF8_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_FLTK-UTF8)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-fltk-utf8_extract: $(STATEDIR)/xchain-fltk-utf8.extract

xchain-fltk-utf8_extract_deps = $(STATEDIR)/fltk-utf8.get

$(STATEDIR)/xchain-fltk-utf8.extract: $(xchain-fltk-utf8_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_FLTK-UTF8_DIR))
	@$(call extract, $(FLTK-UTF8_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_FLTK-UTF8), $(XCHAIN_FLTK-UTF8_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-fltk-utf8_prepare: $(STATEDIR)/xchain-fltk-utf8.prepare

#
# dependencies
#
xchain-fltk-utf8_prepare_deps = \
	$(STATEDIR)/xchain-fltk-utf8.extract \
	$(STATEDIR)/xchain-xutf8.install

XCHAIN_FLTK-UTF8_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_FLTK-UTF8_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_FLTK-UTF8_ENV	+= LDFLAGS="-liconv"

#
# autoconf
#
XCHAIN_FLTK-UTF8_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST) \
	--x-libraries=$(PTXCONF_PREFIX)/lib \
	--x-includes=$(PTXCONF_PREFIX)/include \
	--disable-shared \
	--enable-static
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-fltk-utf8.prepare: $(xchain-fltk-utf8_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_FLTK-UTF8_DIR)/config.cache)
	cd $(XCHAIN_FLTK-UTF8_DIR) && \
		$(XCHAIN_FLTK-UTF8_PATH) $(XCHAIN_FLTK-UTF8_ENV) \
		./configure $(XCHAIN_FLTK-UTF8_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-fltk-utf8_compile: $(STATEDIR)/xchain-fltk-utf8.compile

xchain-fltk-utf8_compile_deps = $(STATEDIR)/xchain-fltk-utf8.prepare

$(STATEDIR)/xchain-fltk-utf8.compile: $(xchain-fltk-utf8_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_FLTK-UTF8_PATH) $(MAKE) -C $(XCHAIN_FLTK-UTF8_DIR) CXX=g++ CC=gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-fltk-utf8_install: $(STATEDIR)/xchain-fltk-utf8.install

$(STATEDIR)/xchain-fltk-utf8.install: $(STATEDIR)/xchain-fltk-utf8.compile
	@$(call targetinfo, $@)
	###$(XCHAIN_FLTK-UTF8_PATH) $(MAKE) -C $(XCHAIN_FLTK-UTF8_DIR) install
	cp -a $(XCHAIN_FLTK-UTF8_DIR)/fluid/fluid $(PTXCONF_PREFIX)/bin/
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-fltk-utf8_targetinstall: $(STATEDIR)/xchain-fltk-utf8.targetinstall

xchain-fltk-utf8_targetinstall_deps = $(STATEDIR)/xchain-fltk-utf8.compile

$(STATEDIR)/xchain-fltk-utf8.targetinstall: $(xchain-fltk-utf8_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-fltk-utf8_clean:
	rm -rf $(STATEDIR)/xchain-fltk-utf8.*
	rm -rf $(XCHAIN_FLTK-UTF8_DIR)

# vim: syntax=make
