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
ifdef PTXCONF_MPLAYER
PACKAGES += MPlayer
endif

#
# Paths and names
#
#MPLAYER_VERSION		= 1.0pre7try2
MPLAYER_VERSION		= 1.0pre8
MPLAYER			= MPlayer-$(MPLAYER_VERSION)
MPLAYER_SUFFIX		= tar.bz2
MPLAYER_URL		= http://www1.mplayerhq.hu/MPlayer/releases/$(MPLAYER).$(MPLAYER_SUFFIX)
MPLAYER_SOURCE		= $(SRCDIR)/$(MPLAYER).$(MPLAYER_SUFFIX)
MPLAYER_DIR		= $(BUILDDIR)/$(MPLAYER)
MPLAYER_IPKG_TMP	= $(MPLAYER_DIR)/ipkg_tmp
MPLAYER_IPP_SOURCE	= $(SRCDIR)/ipp_arm_lnx.tar.bz2

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

MPlayer_get: $(STATEDIR)/MPlayer.get

MPlayer_get_deps = $(MPLAYER_SOURCE)

$(STATEDIR)/MPlayer.get: $(MPlayer_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MPLAYER))
	touch $@

$(MPLAYER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MPLAYER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

MPlayer_extract: $(STATEDIR)/MPlayer.extract

MPlayer_extract_deps = $(STATEDIR)/MPlayer.get

$(STATEDIR)/MPlayer.extract: $(MPlayer_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MPLAYER_DIR))
	@$(call extract, $(MPLAYER_SOURCE))
	@$(call patchin, $(MPLAYER))
	###@$(call extract, $(MPLAYER_IPP_SOURCE), $(MPLAYER_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

MPlayer_prepare: $(STATEDIR)/MPlayer.prepare

#
# dependencies
#
MPlayer_prepare_deps = \
	$(STATEDIR)/MPlayer.extract \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/libmad.install \
	$(STATEDIR)/tremor.install \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/ffmpeg.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_ALSA-UTILS
MPlayer_prepare_deps += $(STATEDIR)/alsa-lib.install
endif

ifdef PTXCONF_MPLAYER_SPEEX
MPlayer_prepare_deps += $(STATEDIR)/speex.install
endif

MPLAYER_PATH	=  PATH=$(CROSS_PATH)
MPLAYER_ENV 	=  $(CROSS_ENV)
#MPLAYER_ENV	+=
MPLAYER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MPLAYER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MPLAYER_AUTOCONF = \
	--target=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-arts \
	--disable-sunaudio \
	--disable-nas \
	--disable-gui \
	--disable-mpdvdkit \
	--enable-esd \
	--enable-png \
	--enable-jpeg \
	--enable-freetype \
	--enable-sdl \
	--enable-menu \
	--enable-fbdev \
	--enable-vorbis \
	--with-extraincdir=$(CROSS_LIB_DIR)/include \
	--with-extralibdir=$(CROSS_LIB_DIR)/lib \
	--with-x11incdir=$(CROSS_LIB_DIR)/include \
	--with-x11libdir=$(CROSS_LIB_DIR)/lib \
	--cc=$(PTXCONF_GNU_TARGET)-gcc \
	--disable-mencoder \
	--confdir=/usr/share/mplayer \
	--disable-static \
	--disable-libavcodec \
	--disable-libavformat \
	--disable-libavutil \
	--disable-libpostproc \
	--disable-gl \
	--disable-gif

ifdef PTXCONF_ARCH_PPC
MPLAYER_AUTOCONF += --enable-big-endian
else
MPLAYER_AUTOCONF += --disable-big-endian
endif

###	--enable-rtc
###	--enable-linux-devfs
###	--enable-tremor

ifdef PTXCONF_ARCH_ARM
MPLAYER_AUTOCONF += --enable-ipp
MPLAYER_AUTOCONF += --with-ippincdir=$(LIBIPP_DIR)/include
MPLAYER_AUTOCONF += --with-ipplibdir=$(LIBIPP_DIR)/lib
ifdef PTXCONF_ATICORE
MPLAYER_AUTOCONF += --enable-w100
endif

# Need GCC 3.4+
ifdef PTXCONF_MPLAYER_IWMMXT
MPLAYER_AUTOCONF += --enable-iwmmxt
endif
#ifeq ("sharp-akita", $(PTXCONF_VENDORTWEAKS_USERCONFIG))
#MPLAYER_AUTOCONF += --enable-bvdd
#endif

MPLAYER_AUTOCONF += --disable-mp3lib
MPLAYER_AUTOCONF += --disable-tv
MPLAYER_AUTOCONF += --disable-liba52
endif

ifndef PTXCONF_ALSA-UTILS
MPLAYER_AUTOCONF += --disable-alsa
endif

ifndef PTXCONF_MPLAYER_SPEEX
MPLAYER_AUTOCONF += --disable-speex
endif

#ifdef PTXCONF_XFREE430
#MPLAYER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
#MPLAYER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
#endif

$(STATEDIR)/MPlayer.prepare: $(MPlayer_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MPLAYER_DIR)/config.cache)
	cd $(MPLAYER_DIR) && \
		$(MPLAYER_PATH) $(MPLAYER_ENV) \
		./configure $(MPLAYER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

MPlayer_compile: $(STATEDIR)/MPlayer.compile

MPlayer_compile_deps = $(STATEDIR)/MPlayer.prepare

$(STATEDIR)/MPlayer.compile: $(MPlayer_compile_deps)
	@$(call targetinfo, $@)
	$(MPLAYER_PATH) $(MAKE) -C $(MPLAYER_DIR) HOST_CC=gcc STRIP=$(PTXCONF_GNU_TARGET)-strip STRIPBINARIES=no
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

MPlayer_install: $(STATEDIR)/MPlayer.install

$(STATEDIR)/MPlayer.install: $(STATEDIR)/MPlayer.compile
	@$(call targetinfo, $@)
	###$(MPLAYER_PATH) $(MAKE) -C $(MPLAYER_DIR) install STRIP=$(PTXCONF_GNU_TARGET)-strip STRIPBINARIES=no
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

MPlayer_targetinstall: $(STATEDIR)/MPlayer.targetinstall

MPlayer_targetinstall_deps = $(STATEDIR)/MPlayer.compile \
	$(STATEDIR)/esound.targetinstall \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/libmad.targetinstall \
	$(STATEDIR)/tremor.targetinstall \
	$(STATEDIR)/ffmpeg.targetinstall \
	$(STATEDIR)/SDL.targetinstall

MPLAYER_DEPLIST = xfree, libmad, sdl, esound, libffmpeg

ifdef PTXCONF_MPLAYER_SPEEX
MPlayer_targetinstall_deps += $(STATEDIR)/speex.targetinstall
MPLAYER_DEPLIST += , libspeex
endif

ifdef PTXCONF_ATICORE
MPLAYER_DEPLIST += , aticore
endif

ifdef PTXCONF_ALSA-UTILS
MPLAYER_DEPLIST += , alsa-utils
endif

$(STATEDIR)/MPlayer.targetinstall: $(MPlayer_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MPLAYER_PATH) $(MAKE) -C $(MPLAYER_DIR) DESTDIR=$(MPLAYER_IPKG_TMP) install STRIP=$(PTXCONF_GNU_TARGET)-strip STRIPBINARIES=no
	$(CROSSSTRIP) $(MPLAYER_IPKG_TMP)/usr/bin/*
	rm -rf $(MPLAYER_IPKG_TMP)/usr/man
ifdef PTXCONF_ARCH_ARM
	echo "framedrop = yes" 							 >$(MPLAYER_IPKG_TMP)/usr/share/mplayer/mplayer.conf
	echo "cache = 1024" 							>>$(MPLAYER_IPKG_TMP)/usr/share/mplayer/mplayer.conf
	echo "dr = yes" 							>>$(MPLAYER_IPKG_TMP)/usr/share/mplayer/mplayer.conf
	echo "af=resample=44100" 						>>$(MPLAYER_IPKG_TMP)/usr/share/mplayer/mplayer.conf
else
	echo "zoom = yes" 							 >$(MPLAYER_IPKG_TMP)/usr/share/mplayer/mplayer.conf
endif
	mkdir -p $(MPLAYER_IPKG_TMP)/CONTROL
	echo "Package: mplayer" 						 >$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Source: $(MPLAYER_URL)"						>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia"			 			>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Version: $(MPLAYER_VERSION)" 					>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Depends: $(MPLAYER_DEPLIST)" 					>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Description: the Unix movie player."				>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MPLAYER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MPLAYER_INSTALL
ROMPACKAGES += $(STATEDIR)/MPlayer.imageinstall
endif

MPlayer_imageinstall_deps = $(STATEDIR)/MPlayer.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/MPlayer.imageinstall: $(MPlayer_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mplayer
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

MPlayer_clean:
	rm -rf $(STATEDIR)/MPlayer.*
	rm -rf $(MPLAYER_DIR)

# vim: syntax=make
