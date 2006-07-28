# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Attila Darazs <zumi@pdaxrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_VIM
PACKAGES += vim
endif

#
# Paths and names
#
VIM_VERSION	= 6.4
VIM		= vim-$(VIM_VERSION)
VIM_SUFFIX	= tar.bz2
VIM_URL		= ftp://ftp.vim.org/pub/vim/unix/$(VIM).$(VIM_SUFFIX)
VIM_SOURCE	= $(SRCDIR)/$(VIM).$(VIM_SUFFIX)
VIM_DIR		= $(BUILDDIR)/vim64
VIM_IPKG_TMP	= $(VIM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

vim_get: $(STATEDIR)/vim.get

vim_get_deps = $(VIM_SOURCE)

$(STATEDIR)/vim.get: $(vim_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(VIM))
	touch $@

$(VIM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(VIM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

vim_extract: $(STATEDIR)/vim.extract

vim_extract_deps = $(STATEDIR)/vim.get

$(STATEDIR)/vim.extract: $(vim_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(VIM_DIR))
	@$(call extract, $(VIM_SOURCE))
	@$(call patchin, $(VIM), $(VIM_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

vim_prepare: $(STATEDIR)/vim.prepare

#
# dependencies
#
vim_prepare_deps = \
	$(STATEDIR)/vim.extract \
	$(STATEDIR)/virtual-xchain.install

VIM_PATH	=  PATH=$(CROSS_PATH)
VIM_ENV 	=  $(CROSS_ENV)
#VIM_ENV	+=
VIM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#VIM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
VIM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-tlib=ncurses \
	--enable-gui=gtk2

ifdef PTXCONF_XFREE430
VIM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
VIM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/vim.prepare: $(vim_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VIM_DIR)/config.cache)
	cd $(VIM_DIR) && \
		$(VIM_PATH) $(VIM_ENV) \
		./configure $(VIM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

vim_compile: $(STATEDIR)/vim.compile

vim_compile_deps = $(STATEDIR)/vim.prepare

$(STATEDIR)/vim.compile: $(vim_compile_deps)
	@$(call targetinfo, $@)
	$(VIM_PATH) $(MAKE) -C $(VIM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

vim_install: $(STATEDIR)/vim.install

$(STATEDIR)/vim.install: $(STATEDIR)/vim.compile
	@$(call targetinfo, $@)
	$(VIM_PATH) $(MAKE) -C $(VIM_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

vim_targetinstall: $(STATEDIR)/vim.targetinstall

vim_targetinstall_deps = $(STATEDIR)/vim.compile

$(STATEDIR)/vim.targetinstall: $(vim_targetinstall_deps)
	@$(call targetinfo, $@)
	$(VIM_PATH) $(MAKE) -C $(VIM_DIR) DESTDIR=$(VIM_IPKG_TMP) install
	rm -rf $(VIM_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(VIM_IPKG_TMP)/usr/bin/vim
	$(CROSSSTRIP) $(VIM_IPKG_TMP)/usr/bin/xxd
	mkdir -p $(VIM_IPKG_TMP)/main_tmp
	mkdir -p $(VIM_IPKG_TMP)/help_tmp/usr/share/vim/vim64
	mkdir -p $(VIM_IPKG_TMP)/syntax_tmp/usr/share/vim/vim64
	mv $(VIM_IPKG_TMP)/usr/share/vim/vim64/doc 	$(VIM_IPKG_TMP)/help_tmp/usr/share/vim/vim64/
	mv $(VIM_IPKG_TMP)/usr/share/vim/vim64/syntax 	$(VIM_IPKG_TMP)/syntax_tmp/usr/share/vim/vim64/
	mv $(VIM_IPKG_TMP)/usr 				$(VIM_IPKG_TMP)/main_tmp/

	mkdir -p $(VIM_IPKG_TMP)/main_tmp/usr/share/applications
	mkdir -p $(VIM_IPKG_TMP)/main_tmp/usr/share/pixmaps

	cp -a $(TOPDIR)/config/pics/gvim.desktop 	$(VIM_IPKG_TMP)/main_tmp/usr/share/applications/
	cp -a $(TOPDIR)/config/pics/vim_48x48.xpm 	$(VIM_IPKG_TMP)/main_tmp/usr/share/pixmaps/

	mkdir -p $(VIM_IPKG_TMP)/main_tmp/CONTROL
	mkdir -p $(VIM_IPKG_TMP)/help_tmp/CONTROL
	mkdir -p $(VIM_IPKG_TMP)/syntax_tmp/CONTROL
	# Main
	echo "Package: vim" 								 >$(VIM_IPKG_TMP)/main_tmp/CONTROL/control
	echo "Priority: optional" 							>>$(VIM_IPKG_TMP)/main_tmp/CONTROL/control
	echo "Section: pdaXrom" 							>>$(VIM_IPKG_TMP)/main_tmp/CONTROL/control
	echo "Maintainer: Attila Darazs <zumi@pdaxrom.org>" 				>>$(VIM_IPKG_TMP)/main_tmp/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(VIM_IPKG_TMP)/main_tmp/CONTROL/control
	echo "Version: $(VIM_VERSION)" 							>>$(VIM_IPKG_TMP)/main_tmp/CONTROL/control
	echo "Depends: " 								>>$(VIM_IPKG_TMP)/main_tmp/CONTROL/control
	echo "Description: Vi IMproved - text editor"					>>$(VIM_IPKG_TMP)/main_tmp/CONTROL/control
	# Doc
	echo "Package: vim-help" 							 >$(VIM_IPKG_TMP)/help_tmp/CONTROL/control
	echo "Priority: optional" 							>>$(VIM_IPKG_TMP)/help_tmp/CONTROL/control
	echo "Section: pdaXrom" 							>>$(VIM_IPKG_TMP)/help_tmp/CONTROL/control
	echo "Maintainer: Attila Darazs <zumi@pdaxrom.org>" 				>>$(VIM_IPKG_TMP)/help_tmp/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(VIM_IPKG_TMP)/help_tmp/CONTROL/control
	echo "Version: $(VIM_VERSION)" 							>>$(VIM_IPKG_TMP)/help_tmp/CONTROL/control
	echo "Depends: vim" 								>>$(VIM_IPKG_TMP)/help_tmp/CONTROL/control
	echo "Description: Vi IMproved - help files"				>>$(VIM_IPKG_TMP)/help_tmp/CONTROL/control
	# Syntax
	echo "Package: vim-syntax" 							 >$(VIM_IPKG_TMP)/syntax_tmp/CONTROL/control
	echo "Priority: optional" 							>>$(VIM_IPKG_TMP)/syntax_tmp/CONTROL/control
	echo "Section: pdaXrom" 							>>$(VIM_IPKG_TMP)/syntax_tmp/CONTROL/control
	echo "Maintainer: Attila Darazs <zumi@pdaxrom.org>" 				>>$(VIM_IPKG_TMP)/syntax_tmp/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(VIM_IPKG_TMP)/syntax_tmp/CONTROL/control
	echo "Version: $(VIM_VERSION)" 							>>$(VIM_IPKG_TMP)/syntax_tmp/CONTROL/control
	echo "Depends: vim" 								>>$(VIM_IPKG_TMP)/syntax_tmp/CONTROL/control
	echo "Description: Vi IMproved - syntax highlighting files"			>>$(VIM_IPKG_TMP)/syntax_tmp/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(VIM_IPKG_TMP)/main_tmp
	cd $(FEEDDIR) && $(XMKIPKG) $(VIM_IPKG_TMP)/help_tmp
	cd $(FEEDDIR) && $(XMKIPKG) $(VIM_IPKG_TMP)/syntax_tmp
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_VIM_INSTALL
ROMPACKAGES += $(STATEDIR)/vim.imageinstall
endif

vim_imageinstall_deps = $(STATEDIR)/vim.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/vim.imageinstall: $(vim_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install vim
	cd $(FEEDDIR) && $(XIPKG) install vim-help
	cd $(FEEDDIR) && $(XIPKG) install vim-syntax
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

vim_clean:
	rm -rf $(STATEDIR)/vim.*
	rm -rf $(VIM_DIR)

# vim: syntax=make
