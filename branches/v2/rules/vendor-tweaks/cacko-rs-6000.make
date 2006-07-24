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
	chmod 755 $(ROOTFS_DIR)/ipkg/usr/bin/setup
	cp -a $(TOPDIR)/config/pdaXrom-x86/setup-hd $(ROOTFS_DIR)/ipkg/usr/bin/
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
	echo $(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\" "(`date +"%H:%M %d/%m/%y"`)" > $(ROOTDIR)/etc/.buildver
	echo $(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\"> $(ROOTDIR)/etc/issue
	rm   -rf $(ROOTDIR)/home/tmp
	mkdir -p $(ROOTDIR)/home/tmp/ipkg

ifdef PTXCONF_MATCHBOX-WINDOW-MANAGER_INSTALL
	mkdir -p $(ROOTDIR)/home/root
	test -e $(ROOTDIR)/home/root/.xinitrc || ln -sf /usr/bin/matchbox-session $(ROOTDIR)/home/root/.xinitrc
endif

	###cd $(ROOTDIR) && tar c etc  > $(ROOTDIR)/root/.etc_default.tar
	cp -f $(TOPDIR)/config/bootdisk/.dev_default.tar $(ROOTDIR)/root/
	cd $(ROOTDIR) && tar c home > 			 $(ROOTDIR)/root/.home_default.tar
	cd $(ROOTDIR) && tar c var  > 			 $(ROOTDIR)/root/.var_default.tar

	cp $(TOPDIR)/config/pdaXrom-archos/linuxrc	 $(ROOTDIR)/

ifndef PTXCONF_DEVFSD
	$(PTXCONF_PREFIX)/bin/genext2fs -d $(ROOTDIR) \
	-b 262144 \
	-f -U -D $(TOPDIR)/config/bootdisk/device_table.txt \
	$(TOPDIR)/bootdisk/rootfs.img
	/sbin/tune2fs -j $(TOPDIR)/bootdisk/rootfs.img
else
	$(PTXCONF_PREFIX)/bin/genext2fs -d $(ROOTDIR) \
	-b 262144 \
	-f -U $(TOPDIR)/bootdisk/rootfs.img
	/sbin/tune2fs -j $(TOPDIR)/bootdisk/rootfs.img
endif
	cp -a $(TOPDIR)/config/pdaXrom-ppc/qemu-ppc.run 	$(TOPDIR)/bootdisk
	cp -a $(KERNEL_DIR)/arch/ppc/boot/images/zImage.prep 	$(TOPDIR)/bootdisk

	md5sum $(TOPDIR)/bootdisk/rootfs.img  >$(TOPDIR)/bootdisk/rootfs.img.md5sum
	md5sum $(TOPDIR)/bootdisk/zImage.prep >$(TOPDIR)/bootdisk/zImage.prep.md5sum

	touch $@

# vim: syntax=make
