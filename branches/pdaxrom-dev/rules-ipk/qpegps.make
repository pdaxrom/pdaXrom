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
ifdef PTXCONF_QPEGPS
PACKAGES += qpegps
endif

#
# Paths and names
#
QPEGPS_VENDOR_VERSION	= 1
QPEGPS_VERSION		= 28042005
QPEGPS			= qpegps-$(QPEGPS_VERSION)
QPEGPS_SUFFIX		= tar.bz2
QPEGPS_URL		= http://www.pdaXrom.org/src/$(QPEGPS).$(QPEGPS_SUFFIX)
QPEGPS_SOURCE		= $(SRCDIR)/$(QPEGPS).$(QPEGPS_SUFFIX)
QPEGPS_DIR		= $(BUILDDIR)/$(QPEGPS)
QPEGPS_IPKG_TMP		= $(QPEGPS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

qpegps_get: $(STATEDIR)/qpegps.get

qpegps_get_deps = $(QPEGPS_SOURCE)

$(STATEDIR)/qpegps.get: $(qpegps_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QPEGPS))
	touch $@

$(QPEGPS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QPEGPS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

qpegps_extract: $(STATEDIR)/qpegps.extract

qpegps_extract_deps = $(STATEDIR)/qpegps.get

$(STATEDIR)/qpegps.extract: $(qpegps_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QPEGPS_DIR))
	@$(call extract, $(QPEGPS_SOURCE))
	@$(call patchin, $(QPEGPS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

qpegps_prepare: $(STATEDIR)/qpegps.prepare

#
# dependencies
#
qpegps_prepare_deps = \
	$(STATEDIR)/qpegps.extract \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_QTOPIA-FREE

qpegps_prepare_deps += \
	$(STATEDIR)/qtopia-free.install

QPEGPS_PATH	=  PATH=$(QTOPIA-FREE_DIR)/bin:$(CROSS_PATH)
QPEGPS_ENV 	=  $(CROSS_ENV)
QPEGPS_ENV	+= QPEDIR=$(QTOPIA-FREE_DIR)
QPEGPS_ENV	+= QTDIR=$(QT-EMBEDDED_DIR)
QPEGPS_ENV	+= QTEDIR=$(QT-EMBEDDED_DIR)
QPEGPS_ENV	+= QMAKESPEC=$(QTOPIA-FREE_QMAKESPEC)

else

qpegps_prepare_deps += \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/qt-x11-free.install

QPEGPS_PATH	=  PATH=$(QT-X11-FREE_DIR)/bin:$(CROSS_PATH)
QPEGPS_ENV 	=  $(CROSS_ENV)
#QPEGPS_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
QPEGPS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig

endif


#
# autoconf
#
QPEGPS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
QPEGPS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
QPEGPS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/qpegps.prepare: $(qpegps_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QPEGPS_DIR)/config.cache)
ifdef PTXCONF_QTOPIA-FREE
	cd $(QPEGPS_DIR) && \
		$(QPEGPS_PATH) $(QPEGPS_ENV) \
		qmake qpegps.pro
else
	cd $(QPEGPS_DIR) && \
		$(QPEGPS_PATH) $(QPEGPS_ENV) \
		qmake qpegps-desktop.pro
endif
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

qpegps_compile: $(STATEDIR)/qpegps.compile

qpegps_compile_deps = $(STATEDIR)/qpegps.prepare

$(STATEDIR)/qpegps.compile: $(qpegps_compile_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_QTOPIA-FREE
	$(QPEGPS_PATH) $(QPEGPS_ENV) $(MAKE) -C $(QPEGPS_DIR)
else
	$(QPEGPS_PATH) $(QPEGPS_ENV) $(MAKE) -C $(QPEGPS_DIR) UIC=uic
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

qpegps_install: $(STATEDIR)/qpegps.install

$(STATEDIR)/qpegps.install: $(STATEDIR)/qpegps.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

qpegps_targetinstall: $(STATEDIR)/qpegps.targetinstall

qpegps_targetinstall_deps = $(STATEDIR)/qpegps.compile

$(STATEDIR)/qpegps.targetinstall: $(qpegps_targetinstall_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_QTOPIA-FREE
	asdasdasd
else
	mkdir -p $(QPEGPS_IPKG_TMP)/usr/lib/qt/bin
	$(INSTALL) -m 755 $(QPEGPS_DIR)/qpegps $(QPEGPS_IPKG_TMP)/usr/lib/qt/bin/
	$(CROSSSTRIP) $(QPEGPS_IPKG_TMP)/usr/lib/qt/bin/qpegps
	cp -a $(QPEGPS_DIR)/icons $(QPEGPS_IPKG_TMP)/usr/lib/qt
	rm -rf $(QPEGPS_IPKG_TMP)/usr/lib/qt/icons/CVS
	mkdir -p $(QPEGPS_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/qpegps.desktop $(QPEGPS_IPKG_TMP)/usr/share/applications/
endif
	mkdir -p $(QPEGPS_IPKG_TMP)/CONTROL
	echo "Package: qpegps" 								 >$(QPEGPS_IPKG_TMP)/CONTROL/control
	echo "Source: $(QPEGPS_URL)"						>>$(QPEGPS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(QPEGPS_IPKG_TMP)/CONTROL/control
	echo "Section: Navigation" 							>>$(QPEGPS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(QPEGPS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(QPEGPS_IPKG_TMP)/CONTROL/control
	echo "Version: $(QPEGPS_VERSION)-$(QPEGPS_VENDOR_VERSION)" 			>>$(QPEGPS_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_QTOPIA-FREE
ifdef PTXCONF_QTOPIA-FREE2
	echo "Depends: qpe-libqtopia2" 							>>$(QPEGPS_IPKG_TMP)/CONTROL/control
else
	echo "Depends: qpe-libqtopia" 							>>$(QPEGPS_IPKG_TMP)/CONTROL/control
endif
else
	echo "Depends: qt-mt, startup-notification, gpsd" 				>>$(QPEGPS_IPKG_TMP)/CONTROL/control
endif
	echo "Description: qpeGPS is a program for displaying a moving map centered at the position read from a GPS device. It's an open source project aimed at users of Linux PDA's." >>$(QPEGPS_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(QPEGPS_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QPEGPS_INSTALL
ROMPACKAGES += $(STATEDIR)/qpegps.imageinstall
endif

qpegps_imageinstall_deps = $(STATEDIR)/qpegps.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/qpegps.imageinstall: $(qpegps_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install qpegps
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

qpegps_clean:
	rm -rf $(STATEDIR)/qpegps.*
	rm -rf $(QPEGPS_DIR)

# vim: syntax=make
