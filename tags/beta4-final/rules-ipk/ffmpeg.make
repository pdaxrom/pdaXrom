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
ifdef PTXCONF_FFMPEG
PACKAGES += ffmpeg
endif

#
# Paths and names
#
#FFMPEG_VERSION		= 20050621
FFMPEG_VERSION		= 20060703
FFMPEG			= FFMpeg-$(FFMPEG_VERSION)
FFMPEG_SUFFIX		= tar.bz2
FFMPEG_URL		= http://mplayerhq.hu/MPlayer/cvs/$(FFMPEG).$(FFMPEG_SUFFIX)
FFMPEG_SOURCE		= $(SRCDIR)/$(FFMPEG).$(FFMPEG_SUFFIX)
FFMPEG_DIR		= $(BUILDDIR)/$(FFMPEG)
FFMPEG_IPKG_TMP		= $(FFMPEG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ffmpeg_get: $(STATEDIR)/ffmpeg.get

ffmpeg_get_deps = $(FFMPEG_SOURCE)

$(STATEDIR)/ffmpeg.get: $(ffmpeg_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FFMPEG))
	touch $@

$(FFMPEG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FFMPEG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ffmpeg_extract: $(STATEDIR)/ffmpeg.extract

ffmpeg_extract_deps = $(STATEDIR)/ffmpeg.get

$(STATEDIR)/ffmpeg.extract: $(ffmpeg_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FFMPEG_DIR))
	@$(call extract, $(FFMPEG_SOURCE))
	@$(call patchin, $(FFMPEG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ffmpeg_prepare: $(STATEDIR)/ffmpeg.prepare

#
# dependencies
#
ffmpeg_prepare_deps = \
	$(STATEDIR)/ffmpeg.extract \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_ARCH_ARM
ffmpeg_prepare_deps += $(STATEDIR)/libipp.prepare
endif

ifdef PTXCONF_FFMPEG_LAME
ffmpeg_prepare_deps += $(STATEDIR)/lame.install
endif

ifdef PTXCONF_FFMPEG_VORBIS
ffmpeg_prepare_deps += $(STATEDIR)/libvorbis.install
endif
ifdef PTXCONF_FFMPEG_LIBOGG
ffmpeg_prepare_deps += $(STATEDIR)/libogg.install
endif

FFMPEG_PATH	=  PATH=$(CROSS_PATH)
FFMPEG_ENV 	=  $(CROSS_ENV)
#FFMPEG_ENV	+=
FFMPEG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FFMPEG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
FFMPEG_AUTOCONF = \
	--prefix=/usr \
	--disable-debug \
	--cross-prefix=$(PTXCONF_GNU_TARGET)- \
	--enable-shared \
	--disable-strip \
	--enable-pp \
	--enable-gpl \
	--enable-a52

#	--build=$(GNU_HOST)
#	--host=$(PTXCONF_GNU_TARGET)

ifdef PTXCONF_FFMPEG_LIBOGG
FFMPEG_AUTOCONF	+= --enable-libogg
endif

ifdef PTXCONF_FFMPEG_VORBIS
FFMPEG_AUTOCONF	+= --enable-vorbis
endif

ifndef PTXCONF_ARCH_PPC
FFMPEG_AUTOCONF	+= --enable-amr_nb --enable-amr_nb-fixed
endif

ifdef PTXCONF_ARCH_X86
FFMPEG_AUTOCONF	+= --cpu=x86
#FFMPEG_AUTOCONF	+= --enable-mmx
else
 ifdef PTXCONF_ARCH_PPC
    FFMPEG_AUTOCONF	+= --cpu=powerpc
 else
    FFMPEG_AUTOCONF	+= --cpu=$(PTXCONF_ARCH)
 endif
endif

ifdef PTXCONF_FFMPEG_LAME
FFMPEG_AUTOCONF	+= --enable-mp3lame
endif

ifdef PTXCONF_ARCH_ARM
FFMPEG_AUTOCONF	+= --cpu=armv4l
FFMPEG_AUTOCONF	+= --enable-ipp
FFMPEG_AUTOCONF	+= --ipp-dir=$(LIBIPP_DIR)
ifndef PTXCONF_FFMPEG_IWMMXT
FFMPEG_AUTOCONF	+= --disable-iwmmxt
else
FFMPEG_AUTOCONF	+= --extra-cflags="-mtune=iwmmxt -Wa,-mcpu=iwmmxt"
endif
endif

ifdef PTXCONF_XFREE430
#FFMPEG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
#FFMPEG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ffmpeg.prepare: $(ffmpeg_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FFMPEG_DIR)/config.cache)
	cd $(FFMPEG_DIR) && \
		$(FFMPEG_PATH) $(FFMPEG_ENV) \
		./configure $(FFMPEG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ffmpeg_compile: $(STATEDIR)/ffmpeg.compile

ffmpeg_compile_deps = $(STATEDIR)/ffmpeg.prepare

$(STATEDIR)/ffmpeg.compile: $(ffmpeg_compile_deps)
	@$(call targetinfo, $@)
	$(FFMPEG_PATH) $(MAKE) -C $(FFMPEG_DIR) $(CROSS_ENV_CC) CFLAGS_NORM="$(TARGET_OPT_CFLAGS) -DWMOPS=0"
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ffmpeg_install: $(STATEDIR)/ffmpeg.install

$(STATEDIR)/ffmpeg.install: $(STATEDIR)/ffmpeg.compile
	@$(call targetinfo, $@)
	$(FFMPEG_PATH) $(MAKE) -C $(FFMPEG_DIR)/libavformat  prefix=$(CROSS_LIB_DIR) libdir=$(CROSS_LIB_DIR)/lib incdir=$(CROSS_LIB_DIR)/include/ffmpeg install
	$(FFMPEG_PATH) $(MAKE) -C $(FFMPEG_DIR)/libavcodec   prefix=$(CROSS_LIB_DIR) libdir=$(CROSS_LIB_DIR)/lib incdir=$(CROSS_LIB_DIR)/include/ffmpeg install
	$(FFMPEG_PATH) $(MAKE) -C $(FFMPEG_DIR)/libavutil    prefix=$(CROSS_LIB_DIR) libdir=$(CROSS_LIB_DIR)/lib incdir=$(CROSS_LIB_DIR)/include/ffmpeg install
	$(FFMPEG_PATH) $(MAKE) -C $(FFMPEG_DIR)/libpostproc  prefix=$(CROSS_LIB_DIR) libdir=$(CROSS_LIB_DIR)/lib incdir=$(CROSS_LIB_DIR)/include/ffmpeg install

#	cp -a $(FFMPEG_DIR)/libavcodec/dsputil.h 		$(CROSS_LIB_DIR)/include/ffmpeg/
#	cp -a $(FFMPEG_DIR)/libpostproc/postprocess.h 		$(CROSS_LIB_DIR)/include/ffmpeg/
#	cp -a $(FFMPEG_DIR)/libpostproc.pc			$(CROSS_LIB_DIR)/lib/pkgconfig/
#	cp -a $(FFMPEG_DIR)/libavproc.pc			$(CROSS_LIB_DIR)/lib/pkgconfig/
#	perl -i -p -e "s,\"common.h\",<ffmpeg/common.h>,g"	$(CROSS_LIB_DIR)/include/ffmpeg/dsputil.h
#	perl -i -p -e "s,\"avcodec.h\",<ffmpeg/avcodec.h>,g"	$(CROSS_LIB_DIR)/include/ffmpeg/dsputil.h

	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/libavcodec.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/libavformat.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/libavutil.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" $(CROSS_LIB_DIR)/lib/pkgconfig/libpostproc.pc
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ffmpeg_targetinstall: $(STATEDIR)/ffmpeg.targetinstall

ffmpeg_targetinstall_deps = $(STATEDIR)/ffmpeg.compile

ifdef PTXCONF_FFMPEG_LAME
ffmpeg_targetinstall_deps += $(STATEDIR)/lame.targetinstall
FFMPEG_LIBSO = ", lame"
endif

ifdef PTXCONF_FFMPEG_VORBIS
ffmpeg_targetinstall_deps += $(STATEDIR)/libvorbis.targetinstall
FFMPEG_LIBSO += ", libvorbis"
endif
ifdef PTXCONF_FFMPEG_LIBOGG
ffmpeg_targetinstall_deps += $(STATEDIR)/libogg.targetinstall
FFMPEG_LIBSO += ", libogg"
endif

$(STATEDIR)/ffmpeg.targetinstall: $(ffmpeg_targetinstall_deps)
	@$(call targetinfo, $@)

	rm -rf $(FFMPEG_IPKG_TMP)
	$(FFMPEG_PATH) $(MAKE) -C $(FFMPEG_DIR)/libavformat prefix=$(FFMPEG_IPKG_TMP)/usr/ install libdir=$(FFMPEG_IPKG_TMP)/usr/lib incdir=$(FFMPEG_IPKG_TMP)/usr/include
	$(FFMPEG_PATH) $(MAKE) -C $(FFMPEG_DIR)/libavcodec  prefix=$(FFMPEG_IPKG_TMP)/usr/ install libdir=$(FFMPEG_IPKG_TMP)/usr/lib incdir=$(FFMPEG_IPKG_TMP)/usr/include
	$(FFMPEG_PATH) $(MAKE) -C $(FFMPEG_DIR)/libavutil   prefix=$(FFMPEG_IPKG_TMP)/usr/ install libdir=$(FFMPEG_IPKG_TMP)/usr/lib incdir=$(FFMPEG_IPKG_TMP)/usr/include
	$(FFMPEG_PATH) $(MAKE) -C $(FFMPEG_DIR)/libpostproc prefix=$(FFMPEG_IPKG_TMP)/usr/ install libdir=$(FFMPEG_IPKG_TMP)/usr/lib incdir=$(FFMPEG_IPKG_TMP)/usr/include
	rm -rf $(FFMPEG_IPKG_TMP)/usr/lib/pkgconfig
	$(CROSSSTRIP) $(FFMPEG_IPKG_TMP)/usr/lib/*
	rm -rf $(FFMPEG_IPKG_TMP)/usr/include
	mkdir -p $(FFMPEG_IPKG_TMP)/CONTROL
	echo "Package: libffmpeg" 							 >$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Source: $(FFMPEG_URL)" 							>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Version: $(FFMPEG_VERSION)" 						>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Depends: libz$(FFMPEG_LIBSO)" 						>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Description: Multimedia system"						>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FFMPEG_IPKG_TMP)

	rm -rf $(FFMPEG_IPKG_TMP)
	$(INSTALL) -D -m 755 $(FFMPEG_DIR)/ffmpeg $(FFMPEG_IPKG_TMP)/usr/bin/ffmpeg
	$(CROSSSTRIP) $(FFMPEG_IPKG_TMP)/usr/bin/ffmpeg
	mkdir -p $(FFMPEG_IPKG_TMP)/CONTROL
	echo "Package: ffmpeg" 								 >$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Source: $(FFMPEG_URL)" 							>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Version: $(FFMPEG_VERSION)" 						>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Depends: libffmpeg" 							>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Description: Multimedia system"						>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FFMPEG_IPKG_TMP)

	rm -rf $(FFMPEG_IPKG_TMP)
	$(INSTALL) -D -m 755 $(FFMPEG_DIR)/ffplay $(FFMPEG_IPKG_TMP)/usr/bin/ffplay
	$(CROSSSTRIP) $(FFMPEG_IPKG_TMP)/usr/bin/ffplay
	mkdir -p $(FFMPEG_IPKG_TMP)/CONTROL
	echo "Package: ffplay" 								 >$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Source: $(FFMPEG_URL)" 							>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Version: $(FFMPEG_VERSION)" 						>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Depends: libffmpeg" 							>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	echo "Description: Multimedia system"						>>$(FFMPEG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FFMPEG_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FFMPEG_INSTALL
ROMPACKAGES += $(STATEDIR)/ffmpeg.imageinstall
endif

ffmpeg_imageinstall_deps = $(STATEDIR)/ffmpeg.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ffmpeg.imageinstall: $(ffmpeg_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libffmpeg
ifdef PTXCONF_FFMPEG_INSTALL_FFMPEG
	cd $(FEEDDIR) && $(XIPKG) install ffmpeg
endif
ifdef PTXCONF_FFMPEG_INSTALL_FFPLAY
	cd $(FEEDDIR) && $(XIPKG) install ffplay
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ffmpeg_clean:
	rm -rf $(STATEDIR)/ffmpeg.*
	rm -rf $(FFMPEG_DIR)

# vim: syntax=make
