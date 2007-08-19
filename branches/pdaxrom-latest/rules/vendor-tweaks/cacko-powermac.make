# -*-makefile-*-
# $Id: cameron-efco.make,v 1.1 2003/12/24 13:39:44 robert Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

VENDORTWEAKS = cacko

PTXCONF_ETC_NAME ?= none
ifeq ("", $(PTXCONF_ETC_NAME))
PTXCONF_ETC_NAME =  none
endif

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

cacko_targetinstall: $(STATEDIR)/cacko.targetinstall

$(STATEDIR)/cacko.targetinstall:
	@$(call targetinfo, vendor-tweaks.targetinstall)

	rm -rf $(ROOTFS_DIR)/ipkg
	
	install -m 755 -d $(ROOTFS_DIR)/ipkg/bin
	install -m 755 -d $(ROOTFS_DIR)/ipkg/dev
	install -m 755 -d $(ROOTFS_DIR)/ipkg/home
	install -m 755 -d $(ROOTFS_DIR)/ipkg/home/root
	install -m 755 -d $(ROOTFS_DIR)/ipkg/lib
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/floppy
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/hd
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/cdrom
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/net
	install -m 755 -d $(ROOTFS_DIR)/ipkg/proc
	install -m 755 -d $(ROOTFS_DIR)/ipkg/root
	install -m 755 -d $(ROOTFS_DIR)/ipkg/sbin
	install -m 755 -d $(ROOTFS_DIR)/ipkg/tmp
	install -m 755 -d $(ROOTFS_DIR)/ipkg/usr/bin
	install -m 755 -d $(ROOTFS_DIR)/ipkg/usr/lib
	install -m 755 -d $(ROOTFS_DIR)/ipkg/usr/sbin
	install -m 755 -d $(ROOTFS_DIR)/ipkg/usr/share
	install -m 775 -d $(ROOTFS_DIR)/ipkg/var
	install -m 755 -d $(ROOTFS_DIR)/ipkg/var/empty
	install -m 775 -d $(ROOTFS_DIR)/ipkg/var/home
	install -m 775 -d $(ROOTFS_DIR)/ipkg/var/lib/pcmcia
	install -m 777 -d $(ROOTFS_DIR)/ipkg/var/lock
	install -m 755 -d $(ROOTFS_DIR)/ipkg/var/lock/subsys
	install -m 755 -d $(ROOTFS_DIR)/ipkg/var/log
	install -m 775 -d $(ROOTFS_DIR)/ipkg/var/spool
	install -m 775 -d $(ROOTFS_DIR)/ipkg/var/tmp
	install -m 777 -d $(ROOTFS_DIR)/ipkg/var/run
	touch             $(ROOTFS_DIR)/ipkg/var/log/lastlog
	###ln -sf /dev/shm/tmp $(ROOTFS_DIR)/ipkg/tmp
	chmod 777 $(ROOTFS_DIR)/ipkg/tmp
	
	@$(call clean, $(ROOTFS_DIR)/ipkg/etc)
	install -m 755 -d $(ROOTFS_DIR)/ipkg/etc

ifneq ("none", $(PTXCONF_ETC_NAME))
	cp -a $(TOPDIR)/config/etc/$(PTXCONF_ETC_NAME)/* $(ROOTFS_DIR)/ipkg/etc/
	chmod 755 $(ROOTFS_DIR)/ipkg/etc/rc.d/init.d/*

	perl -i -p -e "s,\@DATE@,$(shell date -Iseconds),g" $(ROOTFS_DIR)/ipkg/etc/issue

	perl -i -p -e "s,\@GCC_VERSION@,$(GCC_VERSION),g"		$(ROOTFS_DIR)/ipkg/etc/rc.d/rc.sysinit
	perl -i -p -e "s,\@PTXCONF_PREFIX@,$(PTXCONF_NATIVE_PREFIX),g"	$(ROOTFS_DIR)/ipkg/etc/rc.d/rc.sysinit
	perl -i -p -e "s,\@PTXCONF_PREFIX@,$(PTXCONF_NATIVE_PREFIX),g"	$(ROOTFS_DIR)/ipkg/etc/profile
	perl -i -p -e "s,\@CROSS_LIB_DIR@,$(NATIVE_LIB_DIR),g"		$(ROOTFS_DIR)/ipkg/etc/profile
endif

ifdef PTXCONF_CONSOLE-TOOLS-CONSOLECHARS_INSTALL
	mkdir -p $(ROOTFS_DIR)/ipkg/usr/share/kbd/consolefonts
	cp -a $(TOPDIR)/config/pics/Cyr_a8x16.psfu.gz $(ROOTFS_DIR)/ipkg/usr/share/kbd/consolefonts/
endif

	ln -sf /etc/sysconfig/netconfig/ifup   $(ROOTFS_DIR)/ipkg/sbin/ifup
	ln -sf /etc/sysconfig/netconfig/ifdown $(ROOTFS_DIR)/ipkg/sbin/ifdown

	echo $(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\" "(`date +"%H:%M %d/%m/%y"`)" > $(ROOTFS_DIR)/ipkg/etc/.buildver
	echo $(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\"> $(ROOTFS_DIR)/ipkg/etc/issue

	rm   -rf 	  $(ROOTFS_DIR)/ipkg/home/tmp
	install -m 755 -d $(ROOTFS_DIR)/ipkg/home/tmp/ipkg

	cp -a $(TOPDIR)/config/pdaXrom-x86/setup $(ROOTFS_DIR)/ipkg/usr/bin/
	cp -a $(TOPDIR)/config/pdaXrom-x86/setup-hd $(ROOTFS_DIR)/ipkg/usr/bin/
	chmod 755 $(ROOTFS_DIR)/ipkg/usr/bin/setup
	chmod 755 $(ROOTFS_DIR)/ipkg/usr/bin/setup-hd

	cp -a $(TOPDIR)/config/pdaXrom-x86/matchbox-fix/* $(ROOTFS_DIR)/ipkg/

	mkdir -p $(ROOTFS_DIR)/ipkg/CONTROL
	echo "Package: vendor-tweaks" 						 >$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Priority: optional" 						>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Section: Console" 						>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Version: 1.0.0"	 						>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Depends: " 							>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Description: device-specific files and directories ;-)"		>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ROOTFS_DIR)/ipkg

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

cacko_imageinstall: $(STATEDIR)/cacko.imageinstall

cacko_imageinstall_deps = $(STATEDIR)/cacko.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/cacko.imageinstall: $(cacko_imageinstall_deps)
	@$(call targetinfo, $@)
ifneq ("", $(PTXCONF_VENDORTWEAKS))
	cd $(FEEDDIR) && $(XIPKG) install vendor-tweaks
endif
	### This old cr.. need for build Sharp Zaurus kernel
	###tar jxf $(TOPDIR)/../ARCH/cross-zgcc-2.95.3.tar.bz2 -C $(ROOTDIR)/
	###
	ln -sf libpng.so.3 $(ROOTDIR)/usr/lib/libpng.so
	echo $(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\" "(`date +"%H:%M %d/%m/%y"`)" > $(ROOTDIR)/etc/.buildver
	echo $(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\"> $(ROOTDIR)/etc/issue
	rm   -rf $(ROOTDIR)/home/tmp
	mkdir -p $(ROOTDIR)/home/tmp/ipkg
	
	cd $(ROOTDIR) && tar c etc  > $(ROOTDIR)/root/.etc_default.tar
	cd $(ROOTDIR) && tar c home > $(ROOTDIR)/root/.home_default.tar
	cd $(ROOTDIR) && tar c var  > $(ROOTDIR)/root/.var_default.tar

	mkdir -p $(ROOTDIR)/opt/{cross,native}
	
	#$(PTXCONF_PREFIX)/bin/genext2fs -r 0 -d $(ROOTDIR) \
	#-b 96000 \
	#-f $(TOPDIR)/config/bootdisk/dev_ext2.txt \
	#$(TOPDIR)/bootdisk/initrd
ifdef PTXCONF_XFREE430_INSTALL
ifneq ("", $(PTXCONF_XFREE430_CONFIG))
	test -f $(ROOTDIR)/usr/X11R6/bin/Xfbdev  && chmod 4755 $(ROOTDIR)/usr/X11R6/bin/Xfbdev
else
	test -f $(ROOTDIR)/usr/X11R6/bin/XFree86 && chmod 4755 $(ROOTDIR)/usr/X11R6/bin/XFree86
	#test -f $(ROOTDIR)/usr/X11R6/bin/Xmark   && chmod 4755 $(ROOTDIR)/usr/X11R6/bin/Xmark
	#test -f $(ROOTDIR)/usr/X11R6/bin/Xnest   && chmod 4755 $(ROOTDIR)/usr/X11R6/bin/Xnest
	#test -f $(ROOTDIR)/usr/X11R6/bin/Xprt    && chmod 4755 $(ROOTDIR)/usr/X11R6/bin/Xprt
	#test -f $(ROOTDIR)/usr/X11R6/bin/Xvfb    && chmod 4755 $(ROOTDIR)/usr/X11R6/bin/Xvfb
endif
endif
ifdef PTXCONF_XFREE-SVGA_INSTALL
###	chmod 4755 $(ROOTDIR)/usr/X11R6/bin/XFree86
	rm -f $(ROOTDIR)/usr/X11R6/bin/X
	ln -sf XFree86 $(ROOTDIR)/usr/X11R6/bin/X
endif
	chmod 6755 $(ROOTDIR)/bin/busybox
	chmod 4755 $(ROOTDIR)/bin/{ping,mount,umount}

ifdef PTXCONF_XCHAIN_CDRTOOLS
	rm -rf $(ROOTDIR)/boot
	cp -a  $(TOPDIR)/config/pdaXrom-ppc/cdrom/boot $(ROOTDIR)/
ifdef PTXCONF_GENEXT2FS
	rm -rf $(ROOTFS_DIR)/initrd
	mkdir -p $(ROOTFS_DIR)/initrd/{bin,dev,etc,lib,mnt,cdrom,sbin,tmp,proc,modules}
	touch $(ROOTFS_DIR)/initrd/etc/{m,fs}tab
	
	cp -a $(ROOTDIR)/bin/{bash,busybox,mount,umount,cp} 	$(ROOTFS_DIR)/initrd/bin
	cp -a $(ROOTDIR)/usr/bin/wc 				$(ROOTFS_DIR)/initrd/bin
	cp -a $(ROOTDIR)/sbin/insmod*				$(ROOTFS_DIR)/initrd/bin
	cp -a $(ROOTDIR)/sbin/rmmod*				$(ROOTFS_DIR)/initrd/bin
	cp -a $(ROOTDIR)/lib/ld-* 				$(ROOTFS_DIR)/initrd/lib
	##cp -a $(ROOTDIR)/lib/ld-linux* 				$(ROOTFS_DIR)/initrd/lib
	cp -a $(ROOTDIR)/lib/libc*	 			$(ROOTFS_DIR)/initrd/lib
	cp -a $(ROOTDIR)/usr/lib/libncurses* 			$(ROOTFS_DIR)/initrd/lib
	cp -a $(ROOTDIR)/lib/librt* 				$(ROOTFS_DIR)/initrd/lib
	cp -a $(ROOTDIR)/lib/libpthread* 			$(ROOTFS_DIR)/initrd/lib
	cp -a $(ROOTDIR)/lib/libdl* 				$(ROOTFS_DIR)/initrd/lib
	cp -a $(ROOTDIR)/lib/libm* 				$(ROOTFS_DIR)/initrd/lib
	ln -sf /bin/busybox					$(ROOTFS_DIR)/initrd/bin/ls
	ln -sf /bin/busybox					$(ROOTFS_DIR)/initrd/bin/chroot
	ln -sf /bin/busybox					$(ROOTFS_DIR)/initrd/bin/pivot_root
	ln -sf /bin/busybox					$(ROOTFS_DIR)/initrd/bin/echo
	ln -sf /bin/busybox					$(ROOTFS_DIR)/initrd/bin/cat
	ln -sf /bin/busybox					$(ROOTFS_DIR)/initrd/bin/cut
	ln -sf /bin/busybox					$(ROOTFS_DIR)/initrd/bin/sed
	ln -sf /bin/busybox					$(ROOTFS_DIR)/initrd/bin/grep
	ln -sf /bin/busybox					$(ROOTFS_DIR)/initrd/bin/sleep
	ln -sf /bin/bash					$(ROOTFS_DIR)/initrd/bin/sh
	
	###cp $(KERNEL_DIR)/ipkg_tmp/lib/modules/*/kernel/drivers/usb/{core/usbcore.ko,storage/usb-storage.ko,host/*.ko} $(ROOTFS_DIR)/initrd/modules/
	
ifdef PTXCONF_DEVFSD
	echo "/dev/root / auto defaults 1 1"					 >$(ROOTFS_DIR)/initrd/etc/fstab
endif

	cp -a $(TOPDIR)/config/pdaXrom-ppc/linuxrc_cdrom $(ROOTFS_DIR)/initrd/linuxrc

	chmod 755 $(ROOTFS_DIR)/initrd/linuxrc

ifdef PTXCONF_DEVFSD
	$(PTXCONF_PREFIX)/bin/genext2fs -r 0 -d $(ROOTFS_DIR)/initrd \
	    -f -U -b 4096 \
	    $(ROOTDIR)/boot/initrd
else
	$(PTXCONF_PREFIX)/bin/genext2fs -r 0 -d $(ROOTFS_DIR)/initrd \
	    -f -U -D $(TOPDIR)/config/bootdisk/dev_ext2.txt
	    -b 4096 \
	    $(ROOTDIR)/boot/initrd
endif

	gzip -9 $(ROOTDIR)/boot/initrd

	mkdir -p $(ROOTDIR)/boot/initrd

endif
	cp -f $(KERNEL_DIR)/vmlinux $(ROOTDIR)/boot

ifdef PTXCONF_XCHAIN_SQUASHFS
	rm -rf $(ROOTFS_DIR)/cdrom-compressed
	mkdir -p $(ROOTFS_DIR)/cdrom-compressed/boot
	cp -a $(ROOTDIR)/boot $(ROOTFS_DIR)/cdrom-compressed
	$(PTXCONF_PREFIX)/bin/mksquashfs $(ROOTDIR) $(ROOTFS_DIR)/cdrom-compressed/boot/rootfs.bin -all-root -be -info

	$(PTXCONF_PREFIX)/bin/mkisofs -hfs -part -map $(TOPDIR)/config/pdaXrom-ppc/etc/maps \
	-no-desktop -hfs-volid "$(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\"" \
	-hfs-bless $(ROOTFS_DIR)/cdrom-compressed/boot -r \
	-o $(TOPDIR)/bootdisk/pdaXrom.iso $(ROOTFS_DIR)/cdrom-compressed
else
	$(PTXCONF_PREFIX)/bin/mkisofs -hfs -part -map $(TOPDIR)/config/pdaXrom-ppc/etc/maps \
	-no-desktop -hfs-volid "$(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\"" \
	-hfs-bless $(ROOTFS_DIR)/cdrom-compressed/boot -r \
	-o $(TOPDIR)/bootdisk/pdaXrom.iso $(ROOTDIR)
endif
	md5sum $(TOPDIR)/bootdisk/pdaXrom.iso > $(TOPDIR)/bootdisk/pdaXrom.iso.md5sum
endif

	touch $@

# vim: syntax=make
