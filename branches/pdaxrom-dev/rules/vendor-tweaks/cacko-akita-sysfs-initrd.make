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

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

cacko_targetinstall: $(STATEDIR)/cacko.targetinstall

$(STATEDIR)/cacko.targetinstall:
	@$(call targetinfo, vendor-tweaks.targetinstall)
	rm -rf $(ROOTFS_DIR)/ipkg
#	create some directories
	install -m 755 -d $(ROOTFS_DIR)/ipkg/bin
	install -m 755 -d $(ROOTFS_DIR)/ipkg/dev
	install -m 755 -d $(ROOTFS_DIR)/ipkg/home
	install -m 755 -d $(ROOTFS_DIR)/ipkg/home/root
	install -m 755 -d $(ROOTFS_DIR)/ipkg/lib
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/cf
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/card
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/net
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/ide
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/ide2
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/ide3
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/usbstorage
	install -m 755 -d $(ROOTFS_DIR)/ipkg/proc
	install -m 755 -d $(ROOTFS_DIR)/ipkg/root
	install -m 755 -d $(ROOTFS_DIR)/ipkg/sbin
	install -m 755 -d $(ROOTFS_DIR)/ipkg/sys
	install -m 755 -d $(ROOTFS_DIR)/ipkg/tmp
	install -m 755 -d $(ROOTFS_DIR)/ipkg/usr/bin
	install -m 755 -d $(ROOTFS_DIR)/ipkg/usr/lib
	install -m 755 -d $(ROOTFS_DIR)/ipkg/usr/sbin
	install -m 755 -d $(ROOTFS_DIR)/ipkg/usr/share
	install -m 755 -d $(ROOTFS_DIR)/ipkg/root
	install -m 775 -d $(ROOTFS_DIR)/ipkg/var
	install -m 755 -d $(ROOTFS_DIR)/ipkg/var/empty
	install -m 775 -d $(ROOTFS_DIR)/ipkg/var/home
	install -m 775 -d $(ROOTFS_DIR)/ipkg/var/lib/pcmcia
	install -m 777 -d $(ROOTFS_DIR)/ipkg/var/lock
	install -m 755 -d $(ROOTFS_DIR)/ipkg/var/lock/subsys
	install -m 755 -d $(ROOTFS_DIR)/ipkg/var/log
	install -m 775 -d $(ROOTFS_DIR)/ipkg/var/run
	install -m 775 -d $(ROOTFS_DIR)/ipkg/var/spool
	install -m 775 -d $(ROOTFS_DIR)/ipkg/var/tmp
	touch             $(ROOTFS_DIR)/ipkg/var/log/lastlog
	###ln -sf /dev/shm/tmp $(ROOTFS_DIR)/ipkg/tmp
	###chmod 777 $(ROOTFS_DIR)/ipkg/tmp
	###ln -sf /dev/shm/run $(ROOTFS_DIR)/ipkg/var/run
	install -m 755 -d $(ROOTFS_DIR)/ipkg/home/root
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/user
	
	@$(call clean, $(ROOTFS_DIR)/ipkg/etc)
	install -m 755 -d $(ROOTFS_DIR)/ipkg/etc
	
ifneq ("none", $(PTXCONF_ETC_NAME))
	cp -a $(TOPDIR)/config/etc/$(PTXCONF_ETC_NAME)/* $(ROOTFS_DIR)/ipkg/etc/
endif

ifdef PTXCONF_CONSOLE-TOOLS-CONSOLECHARS_INSTALL
	mkdir -p $(ROOTFS_DIR)/ipkg/usr/share/kbd/consolefonts
	cp -a $(TOPDIR)/config/pics/Cyr_a8x16.psfu.gz $(ROOTFS_DIR)/ipkg/usr/share/kbd/consolefonts/
endif

	echo $(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\" "(`date +"%H:%M %d/%m/%y"`)" > $(ROOTFS_DIR)/ipkg/etc/.buildver
	echo $(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\"> $(ROOTFS_DIR)/ipkg/etc/issue

	rm   -rf 	  $(ROOTFS_DIR)/ipkg/home/tmp
	install -m 755 -d $(ROOTFS_DIR)/ipkg/home/tmp/ipkg

	install -m 755 -d $(ROOTFS_DIR)/ipkg/etc/sysconfig/netconfig
	cp -a $(TOPDIR)/config/pdaXrom/{ifup,ifdown} $(ROOTFS_DIR)/ipkg/sbin/
	cp -a $(TOPDIR)/config/pdaXrom/pdaxrom-installer.sh $(ROOTFS_DIR)/ipkg/usr/bin/
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

	###cd $(ROOTDIR) && tar c etc  > $(ROOTDIR)/root/.etc_default.tar
	###cp -f $(TOPDIR)/config/bootdisk/.dev_default.tar $(ROOTDIR)/root/
	##cd $(ROOTDIR) && tar c home > 			 $(ROOTDIR)/root/.home_default.tar
	##cd $(ROOTDIR) && tar c var  > 			 $(ROOTDIR)/root/.var_default.tar

	##test -f $(ROOTDIR)/usr/lib/ipkg/info/bluez-utils.postinst && rm -f $(ROOTDIR)/usr/lib/ipkg/info/bluez-utils.postinst

	rm -f $(ROOTDIR)/sbin/{ldconfig,rpcinfo}
	#rm -f $(ROOTDIR)/sbin/rpcinfo
	rm -f $(ROOTDIR)/usr/lib/ipkg/lists/*
	rm -f $(ROOTDIR)/usr/lib/gconv/*
	rm -f $(ROOTDIR)/usr/bin/{iconv,tic}

#	$(PTXCONF_PREFIX)/bin/mkfs.jffs2 --eraseblock=16384 --root=$(ROOTDIR) --little-endian --squash --faketime --devtable=$(TOPDIR)/config/bootdisk/device_table-sysfs.txt --pad -n --output=$(TOPDIR)/bootdisk/initrd.jffs2
#	rm -f $(TOPDIR)/bootdisk/initrd.bin
#	$(PTXCONF_PREFIX)/bin/mksquashfs $(ROOTDIR) $(TOPDIR)/bootdisk/initrd.bin -all-root -le -info

ifdef PTXCONF_DEVFSD
	$(PTXCONF_PREFIX)/bin/genext2fs -r 0 -d $(ROOTDIR) \
	    -f -U -b 8000 \
	    $(TOPDIR)/bootdisk/initrd
else
	$(PTXCONF_PREFIX)/bin/genext2fs -r 0 -d $(ROOTDIR) \
	    -f -U -D $(TOPDIR)/config/bootdisk/device_table-sysfs.txt \
	    -b 8000 \
	    $(TOPDIR)/bootdisk/initrd
endif
	rm -f $(TOPDIR)/bootdisk/initrd.gz
	gzip -9 $(TOPDIR)/bootdisk/initrd
	$(PTXCONF_PREFIX)/bin/mkimage -A arm -O linux -T multi -C none -a 0xa0008000 -e 0xa0008000 \
	    -n "Zaurus pdaXrom emergency system" -d $(TOPDIR)/bootdisk/zImage:$(TOPDIR)/bootdisk/initrd.gz \
	    $(TOPDIR)/bootdisk/emergenc.img
	md5sum $(TOPDIR)/bootdisk/emergenc.img >$(TOPDIR)/bootdisk/emergenc.img.md5sum

	cp -a $(TOPDIR)/config/pdaXrom/updater.pro $(TOPDIR)/bootdisk/
	cp -a $(TOPDIR)/config/pdaXrom/u-boot-installer.sh $(TOPDIR)/bootdisk/updater.sh
	cp -a $(TOPDIR)/config/pdaXrom/autoboot.sh-emergency $(TOPDIR)/bootdisk/autoboot.sh

	cd $(TOPDIR)/bootdisk && zip -9 $(PROJECT)-$(FULLVERSION)-$(CODENAMEX)-u-boot-$(PTXCONF_U-BOOT_CONFIG)-current.zip emergenc.img* u-boot.bin* updater.pro updater.sh autoboot.sh

	touch $@

# vim: syntax=make
