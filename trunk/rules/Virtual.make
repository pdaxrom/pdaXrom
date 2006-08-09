# -*-makefile-*-
# $Id: Virtual.make,v 1.4 2003/10/23 15:08:11 mkl Exp $
#
# Copyright (C) 2003 by Marc Kleine-Budde <kleine-budde@gmx.de>
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

# ----------------------------------------------------------------------------
# xchain
# ----------------------------------------------------------------------------

$(STATEDIR)/native_headers.install:
ifdef PTXCONF_NATIVE_HEADERS
	rm -rf $(BUILDDIR)/native_headers
	mkdir -p $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/bin
	mkdir -p $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)
	###
	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/ldd $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/bin
	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/include $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)
	ln -sf include                                        $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/sys-include
	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib     $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)
#ifndef PTXCONF_ARCH_X86
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/*.so*
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/*.*a
	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/*.o              $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib
	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libc.so          $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib
	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libc_nonshared.a $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib
#else
#	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/*.so*
#endif

ifdef PTXCONF_LIBSTDCXX
ifndef PTXCONF_LIBSTDCXX_SHARED
	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/{libstdc++.a,libsupc++.a} $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib
endif
endif

	for i in $$(ls $(PTXCONF_PREFIX)/bin/*-config*); 						\
	    do echo -n $$i' ' ; 									\
	    cp -a $$i $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/bin ;				\
	done

ifeq ("archos-omap", $(PTXCONF_VENDORTWEAKS_USERCONFIG))
	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/sbin/ldconfig $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/bin
	$(CROSSSTRIP) $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/bin/ldconfig
endif

	cp -a $(PTXCONF_PREFIX)/bin/mkipkg                                 $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/bin
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/gconv
	### Fix it in the rules !!!
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/evms
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/GConf
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/bonobo
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/bonobo-2.0
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/gnome-vfs-2.0/modules
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libglade
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnomeprint
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/orbit-2.0
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/python2.2
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/python2.3
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/python2.4
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/vfs
	rm -rf $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/ldscripts
	echo "GROUP ( libc.so.6 libc_nonshared.a )" > $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libc.so
	###
ifdef PTXCONF_XFREE430
#	rm -f $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/include/X11
#	mkdir -p $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/X11/config
#	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/X11R6/include                 $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)
#ifdef PTXCONF_ARCH_X86
#	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/X11R6/lib/*.a                 $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib
#endif
#	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/X11R6/lib/X11/config/Imake.*  $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/X11/config
#	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/X11R6/lib/X11/config/host.def $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/X11/config
#	cp -a $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/X11R6/lib/pkgconfig           $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib
	cp -a $(XFREE430_IPKG_TMP)-static/lib/*.a				    $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/
	perl -i -p -e "s,$(CROSS_LIB_DIR),$(NATIVE_LIB_DIR),g" 			    $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/X11/config/host.def
endif
ifdef PTXCONF_FLEX
	cp -a $(FLEX_DIR)/libfl.a				    $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/
endif
	###
	for FILE in $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/bin/* ; do 				\
	    perl -i -p -e "s,$(CROSS_LIB_DIR),$(NATIVE_LIB_DIR),g" 	$$FILE;					\
	done
	###
	for FILE in $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/*.sh ; do 	\
	    perl -i -p -e "s,$(CROSS_LIB_DIR),$(NATIVE_LIB_DIR),g" 	$$FILE;					\
	done
	###
	for FILE in $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/*.pc ; do 	\
	    perl -i -p -e "s,$(CROSS_LIB_DIR),$(NATIVE_LIB_DIR),g" 	$$FILE;						\
	done
	###
#ifdef PTXCONF_WXWIDGETS
	for FILE in $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/wx/config/* ; do 	\
	    perl -i -p -e "s,$(CROSS_LIB_DIR),$(NATIVE_LIB_DIR),g" 	$$FILE;						\
	    rm -f $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/bin/wx-config ;					\
	    ln -sf $$FILE $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/bin/wx-config ;				\
	done
	###
#endif
#ifdef PTXCONF_ARCH_X86
#	for FILE in $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/*.la ; do	 	\
#	    perl -i -p -e "s,$(CROSS_LIB_DIR),$(NATIVE_LIB_DIR),g" 	$$FILE;						\
#	done
#	###
#endif
	mkdir -p $(BUILDDIR)/native_headers/CONTROL
	echo "Package: gcc-headers" 				 >$(BUILDDIR)/native_headers/CONTROL/control
	echo "Priority: optional" 				>>$(BUILDDIR)/native_headers/CONTROL/control
	echo "Section: Development" 				>>$(BUILDDIR)/native_headers/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(BUILDDIR)/native_headers/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(BUILDDIR)/native_headers/CONTROL/control
	echo "Version: $(FULLVERSION)"	 			>>$(BUILDDIR)/native_headers/CONTROL/control
	echo "Depends: gcc" 					>>$(BUILDDIR)/native_headers/CONTROL/control
	echo "Description: pdaXrom C/C++ header files"		>>$(BUILDDIR)/native_headers/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BUILDDIR)/native_headers/
	###
ifdef PTXCONF_QT-X11-FREE
	rm -rf   $(BUILDDIR)/native_headers-qt
	mkdir -p $(BUILDDIR)/native_headers-qt/usr/lib/qt/bin
	mkdir -p $(BUILDDIR)/native_headers-qt/usr/lib/qt/mkspecs

	###mv $(QT-X11-FREE_DIR)/bin/qmake $(QT-X11-FREE_DIR)/bin/qmake.old
	make -C $(QT-X11-FREE_DIR)/qmake clean
	$(QT-X11-FREE_PATH) make -C $(QT-X11-FREE_DIR)/qmake $(CROSS_ENV_CC) $(CROSS_ENV_CXX)
	cp -a   $(QT-X11-FREE_DIR)/qmake/qmake $(BUILDDIR)/native_headers-qt/usr/lib/qt/bin
	$(CROSSSTRIP) $(BUILDDIR)/native_headers-qt/usr/lib/qt/bin/qmake
	rm -f $(QT-X11-FREE_DIR)/bin/qmake
	###mv $(QT-X11-FREE_DIR)/bin/qmake.old $(QT-X11-FREE_DIR)/bin/qmake

	cp -aL $(QT-X11-FREE_DIR)/include		$(BUILDDIR)/native_headers-qt/usr/lib/qt
	cp -aL $(QT-X11-FREE_DIR)/mkspecs/default	$(BUILDDIR)/native_headers-qt/usr/lib/qt/mkspecs
	mkdir -p $(BUILDDIR)/native_headers-qt/CONTROL
	echo "Package: qt-headers" 				 >$(BUILDDIR)/native_headers-qt/CONTROL/control
	echo "Priority: optional" 				>>$(BUILDDIR)/native_headers-qt/CONTROL/control
	echo "Section: Development" 				>>$(BUILDDIR)/native_headers-qt/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(BUILDDIR)/native_headers-qt/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(BUILDDIR)/native_headers-qt/CONTROL/control
	echo "Version: $(FULLVERSION)"	 			>>$(BUILDDIR)/native_headers-qt/CONTROL/control
	echo "Depends: gcc, qt-mt" 				>>$(BUILDDIR)/native_headers-qt/CONTROL/control
	echo "Description: pdaXrom Qt C++ header files"		>>$(BUILDDIR)/native_headers-qt/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BUILDDIR)/native_headers-qt/
endif

	rm -rf   $(BUILDDIR)/native_headers_cramfs
	mkdir -p $(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)
	cp -a $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX) 	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
	cp -a $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)		$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
	cp -a $(BUILDDIR)/native_headers/$(PTXCONF_NATIVE_PREFIX)	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
ifdef PTXCONF_DISTCC
	cp -a $(DISTCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_FLEX
	cp -a $(FLEX_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)		$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_GAWK
	cp -a $(GAWK_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	      	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_M4
	cp -a $(M4_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	      	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_UMAKE
	cp -a $(UMAKE_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_UPATCH
	cp -a $(UPATCH_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_PKGCONFIG
	cp -a $(PKGCONFIG_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_SED
	cp -a $(SED_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	      	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_UGREP
	cp -a $(UGREP_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_GETTEXT
	cp -a $(GETTEXT_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_BISON
	cp -a $(BISON_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_DIFFUTILS
	cp -a $(DIFFUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_GETTEXT
	cp -a $(GETTEXT_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)	$(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_NATIVE_CVS
	cp -a $(NATIVE_CVS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)   $(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_NATIVE_AUTOCONF
	cp -a $(NATIVE_AUTOCONF_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)      $(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
endif
ifdef PTXCONF_NATIVE_AUTOMAKE
	cp -a $(NATIVE_AUTOMAKE_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)      $(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/..
#	cp -a $(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/share/aclocal/*  \
#	      $(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/share/aclocal-1.9/
#	rm -rf $(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/share/aclocal
#	ln -sf aclocal-1.9 $(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/share/aclocal
endif
	rm -rf $(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX)/lib/*.*a
ifdef PTXCONF_CRAMFS
	$(PTXCONF_PREFIX)/bin/mkcramfs $(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX) $(TOPDIR)/bootdisk/zgcc-$(GCC_VERSION).img
endif
ifdef PTXCONF_XCHAIN_SQUASHFS
	$(PTXCONF_PREFIX)/bin/mksquashfs $(BUILDDIR)/native_headers_cramfs/$(PTXCONF_NATIVE_PREFIX) $(TOPDIR)/bootdisk/zgcc-$(GCC_VERSION).img -all-root -info
endif
	md5sum $(TOPDIR)/bootdisk/zgcc-$(GCC_VERSION).img > $(TOPDIR)/bootdisk/zgcc-$(GCC_VERSION).img.md5sum

endif

	#
	# make native crosstools
	#
	
ifdef PTXCONF_QT-X11-FREE
	rm -rf $(CROSS_LIB_DIR)/qt
	mkdir -p $(CROSS_LIB_DIR)/qt/{bin,include,lib,mkspecs}
	cp -aL $(QT-X11-FREE_DIR)/include		$(CROSS_LIB_DIR)/qt
	cp -aL $(QT-X11-FREE_DIR)/lib			$(CROSS_LIB_DIR)/qt
	cp -aL $(QT-X11-FREE_DIR)/mkspecs/default	$(CROSS_LIB_DIR)/qt/mkspecs
	ln -s $(PTXCONF_PREFIX)/bin/qmake		$(CROSS_LIB_DIR)/qt/bin/qmake
	ln -s $(PTXCONF_PREFIX)/bin/moc			$(CROSS_LIB_DIR)/qt/bin/moc
	ln -s $(PTXCONF_PREFIX)/bin/uic			$(CROSS_LIB_DIR)/qt/bin/uic
	ln -s $(PTXCONF_PREFIX)/bin/designer		$(CROSS_LIB_DIR)/qt/bin/designer
endif	
#ifdef PTXCONF_QTOPIA-FREE
#	rm -rf $(CROSS_LIB_DIR)/qtopia
#	mkdir -p $(CROSS_LIB_DIR)/qtopia/{bin,include,lib,mkspecs}
#	mkdir -p $(CROSS_LIB_DIR)/qtopia/include/qtopia
#	ln -sf qtopia					$(CROSS_LIB_DIR)/qtopia/include/qpe
#	cp -aL $(QT-EMBEDDED_DIR)/include		$(CROSS_LIB_DIR)/qtopia
#	cp -aL $(QTOPIA-FREE_DIR)/include/qtopia/*	$(CROSS_LIB_DIR)/qtopia/include/qtopia
#	cp -aL $(QTOPIA-FREE_DIR)/include/*.*		$(CROSS_LIB_DIR)/qtopia/include
#	cp -aL $(QTOPIA-FREE_DIR)/lib			$(CROSS_LIB_DIR)/qtopia
#	cp -aL $(QTOPIA-FREE_DIR)/mkspecs/qws		$(CROSS_LIB_DIR)/qtopia/mkspecs
#
#	cp -a $(QT-EMBEDDED_DIR)/bin/moc		$(PTXCONF_PREFIX)/bin
#	cp -a $(QT-EMBEDDED_DIR)/bin/uic		$(PTXCONF_PREFIX)/bin
#	cp -a $(QTOPIA-FREE_DIR)/bin/qmake		$(PTXCONF_PREFIX)/bin
#
#	ln -s $(PTXCONF_PREFIX)/bin/qmake		$(CROSS_LIB_DIR)/qtopia/bin/qmake
#	ln -s $(PTXCONF_PREFIX)/bin/moc			$(CROSS_LIB_DIR)/qtopia/bin/moc
#	ln -s $(PTXCONF_PREFIX)/bin/uic			$(CROSS_LIB_DIR)/qtopia/bin/uic
#	ln -s $(PTXCONF_PREFIX)/bin/designer-2.3.2	$(CROSS_LIB_DIR)/qtopia/bin/designer
#endif
	echo "#!/bin/bash"				 >$(PTXCONF_PREFIX)/runsdk.sh
	echo ". /etc/profile"				>>$(PTXCONF_PREFIX)/runsdk.sh
	echo "export PATH=$(PTXCONF_PREFIX)/bin:\$$PATH" >>$(PTXCONF_PREFIX)/runsdk.sh
ifdef PTXCONF_QT-X11-FREE
	echo "export QTDIR=$(CROSS_LIB_DIR)/qt"		>>$(PTXCONF_PREFIX)/runsdk.sh
	echo "export KDEDIR=$(CROSS_LIB_DIR)/qt"	>>$(PTXCONF_PREFIX)/runsdk.sh
endif
ifdef PTXCONF_XFREE430
	echo "export X11INC=$(CROSS_LIB_DIR)/include"	>>$(PTXCONF_PREFIX)/runsdk.sh
	echo "export X11LIB=$(CROSS_LIB_DIR)/lib"	>>$(PTXCONF_PREFIX)/runsdk.sh
endif
ifdef PTXCONF_QTOPIA-FREE
	echo "export QTDIR=$(QTOPIA-FREE_DIR)"	>>$(PTXCONF_PREFIX)/runsdk.sh
	echo "export QTEDIR=$(QTOPIA-FREE_DIR)"	>>$(PTXCONF_PREFIX)/runsdk.sh
	echo "export QPEDIR=$(QTOPIA-FREE_DIR)"	>>$(PTXCONF_PREFIX)/runsdk.sh
ifdef PTXCONF_QTOPIA-FREE-SL5500
	echo "export QMAKESPEC=$(QTOPIA-FREE_DIR)/mkspecs/qws/linux-sharp-g++"	>>$(PTXCONF_PREFIX)/runsdk.sh
endif
ifdef PTXCONF_QTOPIA-FREE-IPAQ
	echo "export QMAKESPEC=$(QTOPIA-FREE_DIR)/mkspecs/qws/linux-ipaq-g++"	>>$(PTXCONF_PREFIX)/runsdk.sh
endif
endif
	echo "export PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig" >>$(PTXCONF_PREFIX)/runsdk.sh
	echo "echo \"Type exit for leave $(PTXCONF_GNU_TARGET) cross environment.\"">>$(PTXCONF_PREFIX)/runsdk.sh
	echo "/bin/bash"				>>$(PTXCONF_PREFIX)/runsdk.sh
	chmod 755 $(PTXCONF_PREFIX)/runsdk.sh
	$(TAR) -C / -jcvf $(TOPDIR)/bootdisk/cross-sdk-$(PTXCONF_GNU_TARGET)-$(GCC_VERSION)-$(GLIBC_VERSION)-$(PTXCONF_FPU_TYPE).tar.bz2 \
		$(PTXCONF_PREFIX)
	echo "Extract cross-sdk-$(PTXCONF_GNU_TARGET)-$(GCC_VERSION)-$(GLIBC_VERSION)-$(PTXCONF_FPU_TYPE).tar.bz2 in / directory." >$(TOPDIR)/bootdisk/cross-sdk.txt
	echo "Run $(PTXCONF_PREFIX)/runsdk.sh for enter in $(PTXCONF_GNU_TARGET) cross environment."	>>$(TOPDIR)/bootdisk/cross-sdk.txt
	echo "binutils version $(BINUTILS_VERSION)"							>>$(TOPDIR)/bootdisk/cross-sdk.txt
	echo "gcc      version $(GCC_VERSION)"								>>$(TOPDIR)/bootdisk/cross-sdk.txt
	echo "glibc    version $(GLIBC_VERSION)"							>>$(TOPDIR)/bootdisk/cross-sdk.txt
	md5sum $(TOPDIR)/bootdisk/cross-sdk-$(PTXCONF_GNU_TARGET)-$(GCC_VERSION)-$(GLIBC_VERSION)-$(PTXCONF_FPU_TYPE).tar.bz2 \
		>$(TOPDIR)/bootdisk/cross-sdk.md5sum
	md5sum $(TOPDIR)/bootdisk/cross-sdk.txt >>$(TOPDIR)/bootdisk/cross-sdk.md5sum
##ifdef PTXCONF_QT-X11-FREE
##	rm -rf $(CROSS_LIB_DIR)/qt
##endif	
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NATIVE_HEADERS_INSTALL
ROMPACKAGES += $(STATEDIR)/native_headers.imageinstall
endif

native_headers_imageinstall_deps = $(STATEDIR)/native_headers.install \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/native_headers.imageinstall: $(native_headers_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gcc-headers
ifdef PTXCONF_QT-X11-FREE
	cd $(FEEDDIR) && $(XIPKG) install qt-headers
endif
	touch $@

###

virtual-xchain_install: $(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_BUILD_CROSSCHAIN
virtual-xchain_install_deps	= $(STATEDIR)/xchain-gccstage2.install
ifdef PTXCONF_KOS
virtual-xchain_install_deps	= $(STATEDIR)/kos.install
endif
endif 

$(STATEDIR)/virtual-xchain.install: $(virtual-xchain_install_deps)
	@$(call targetinfo, $@)
	touch $@

$(STATEDIR)/virtual-image.install: $(STATEDIR)/native_headers.install
	@$(call targetinfo, $@)
	@echo
	@echo -n "cleaning root dir................ "
	@for i in $$(ls $(ROOTDIR)); do echo -n $$i' '; rm -rf $(ROOTDIR)/"$$i"; done
	@echo "done."
	cd $(TOPDIR)/bootdisk/feed; $(XMKPACKAGES)
	echo "src feed0 file://$(TOPDIR)/bootdisk/feed"			 >$(TOPDIR)/scripts/bin/ipkg.conf
	echo "option offline_root $(ROOTDIR)" 				>>$(TOPDIR)/scripts/bin/ipkg.conf
	echo "dest root /"						>>$(TOPDIR)/scripts/bin/ipkg.conf
	echo "dest tmpinst /tmp/ipkg/inst"				>>$(TOPDIR)/scripts/bin/ipkg.conf
	mkdir -p /tmp/ipkg/inst
	$(XIPKG) update
	touch $@
