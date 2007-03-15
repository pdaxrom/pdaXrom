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
	###install -m 755 -d $(ROOTFS_DIR)/ipkg/tmp
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
	ln -sf /dev/shm/tmp $(ROOTFS_DIR)/ipkg/tmp
	###chmod 777 $(ROOTFS_DIR)/ipkg/tmp
	###ln -sf /dev/shm/run $(ROOTFS_DIR)/ipkg/var/run
	install -m 755 -d $(ROOTFS_DIR)/ipkg/home/root
	install -m 755 -d $(ROOTFS_DIR)/ipkg/mnt/user
	
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

ifeq ("sharp-corgi", $(PTXCONF_VENDORTWEAKS_USERCONFIG))
	perl -i -p -e "s,spitz,corgi,g"					$(ROOTFS_DIR)/ipkg/etc/modules
endif

ifdef PTXCONF_CONSOLE-TOOLS-CONSOLECHARS_INSTALL
	mkdir -p $(ROOTFS_DIR)/ipkg/usr/share/kbd/consolefonts
	cp -a $(TOPDIR)/config/pics/Cyr_a8x16.psfu.gz $(ROOTFS_DIR)/ipkg/usr/share/kbd/consolefonts/
endif

	echo $(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\" "(`date +"%H:%M %d/%m/%y"`)" > $(ROOTFS_DIR)/ipkg/etc/.buildver
	echo $(PROJECT) $(FULLVERSION) \"$(CODENAMEX)\"> $(ROOTFS_DIR)/ipkg/etc/issue

	rm   -rf 	  $(ROOTFS_DIR)/ipkg/home/tmp
	install -m 755 -d $(ROOTFS_DIR)/ipkg/home/tmp/ipkg

	cp -a $(TOPDIR)/config/pdaXrom/useradd    $(ROOTFS_DIR)/ipkg/usr/sbin/
	cp -a $(TOPDIR)/config/pdaXrom/sethwclock $(ROOTFS_DIR)/ipkg/usr/bin/

	install -m 755 -d $(ROOTFS_DIR)/ipkg/etc/sysconfig/netconfig
	cp -a $(TOPDIR)/config/pdaXrom/{ifup,ifdown} $(ROOTFS_DIR)/ipkg/sbin/

	#cd $(ROOTFS_DIR)/ipkg && tar c var > 		$(ROOTFS_DIR)/ipkg/root/.var_default.tar
	#cd $(ROOTFS_DIR)/ipkg && tar c home > 		$(ROOTFS_DIR)/ipkg/root/.home_default.tar
	#cp $(TOPDIR)/config/bootdisk/.dev_default.tar	$(ROOTFS_DIR)/ipkg/root/

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
	cd $(ROOTDIR) && tar c home > 			 $(ROOTDIR)/root/.home_default.tar
	cd $(ROOTDIR) && tar c var  > 			 $(ROOTDIR)/root/.var_default.tar
	
	## Copies edited gtkrc-2.0 to home dir
	cp -f $(TOPDIR)/config/pdaXrom/home-matchbox/root/.gtkrc-2.0 $(ROOTDIR)/root/
	
	#test -f $(ROOTDIR)/usr/lib/ipkg/info/bluez-utils.postinst && rm -f $(ROOTDIR)/usr/lib/ipkg/info/bluez-utils.postinst

	$(PTXCONF_PREFIX)/bin/mkfs.jffs2 --eraseblock=16384 --root=$(ROOTDIR) --little-endian --squash --faketime --devtable=$(TOPDIR)/config/bootdisk/device_table-sysfs.txt --pad -n --output=$(TOPDIR)/bootdisk/rootfs.img
	$(PTXCONF_PREFIX)/bin/mkimage -A arm -O linux -T kernel -C none -a 0xa0008000 -e 0xa0008000 -n "Linux 2.6" -d $(TOPDIR)/bootdisk/zImage $(TOPDIR)/bootdisk/kernel.img

	#cd $(TOPDIR)/bootdisk && cat $(TOPDIR)/config/bootdisk/sharp.bin initrd.jffs2 >initrd.bin
	#rm -f cd $(TOPDIR)/bootdisk/initrd.jffs2
	md5sum $(TOPDIR)/bootdisk/rootfs.img >$(TOPDIR)/bootdisk/rootfs.img.md5sum
	md5sum $(TOPDIR)/bootdisk/kernel.img >$(TOPDIR)/bootdisk/kernel.img.md5sum

	cp -a $(TOPDIR)/config/pdaXrom/autoboot.sh $(TOPDIR)/bootdisk/

ifeq ("sharp-corgi", $(PTXCONF_VENDORTWEAKS_USERCONFIG))
	cd $(TOPDIR)/bootdisk && zip -9 $(PROJECT)-$(FULLVERSION)-$(CODENAMEX)-corgi-current.zip kernel.img* rootfs.img* autoboot.sh
endif

ifeq ("sharp-akita", $(PTXCONF_VENDORTWEAKS_USERCONFIG))
	cd $(TOPDIR)/bootdisk && zip -9 $(PROJECT)-$(FULLVERSION)-$(CODENAMEX)-akita-current.zip kernel.img* rootfs.img* autoboot.sh
endif

	touch $@

# vim: syntax=make
