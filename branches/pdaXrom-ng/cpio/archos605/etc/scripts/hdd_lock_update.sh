#!/bin/sh

# Author: Niklas Schroeter <schroeter@archos.com>

HD_DEVICE=$1
MEDIA=$2
MEDIA_PATH=$3
AOS_FULLFILENAME=$4
ROOT=$5
ROOT_PATH=$6


MOUNT=/bin/mount
UMOUNT=/bin/umount
AUI=/bin/aui
INSMOD=/sbin/insmod
RMMOD=/sbin/rmmod
AOSPARSER=/bin/aosparser
CREATE_SYSID=/bin/create_sysid
SYS_INFO=/bin/sys_info

MAIN_TITLE="HDD_Recovery_2"

SYSFS_ROOT_PARTITION_START="/sys/block/hda/hda2/start"
let DO_BOOT=0
let UPDATE_DONE=0

launch_update()
{
	echo "executing $1..."
	$AUI -c message -T $MAIN_TITLE  -a centered -t "recovering hdd ..." 
	#$AOS_INSTALL_SCRIPT
	$AOSPARSER $1 $ROOT_PATH # > /dev/null 2>&1
	AOS_RET=$?
	if [ $AOS_RET -ne 0 ] ; then
		echo "update failed (code $AOS_RET)"
		$AUI -c message -T $MAIN_TITLE -a centered -t "hdd recovery failed (code $AOS_RET)"
		sleep 5
		# reboot
		let DO_BOOT=0
		break
	else
		sync
		echo "update successful"
		$AUI -c message -T $MAIN_TITLE -a centered -t "hdd recovery successful"
		let UPDATE_DONE=1
		# reboot
		let DO_BOOT=1
		break
	fi
}

install_usb_host()
{
	if [ -e /lib/modules/scsi_mod.ko ] ; then
	#install all usb moduled needed
		$INSMOD /lib/modules/usbcore.ko
		$INSMOD /lib/modules/musb_hdrc.ko mode_default=1 use_dma=1
		$INSMOD /lib/modules/scsi_mod.ko
		$INSMOD /lib/modules/sd_mod.ko
		$INSMOD /lib/modules/sg.ko
		$INSMOD /lib/modules/usb-storage.ko
		return 1
	else
		return 0
	fi

}

uninstall_usb_host()
{
#uninstall usb host drivers
	$RMMOD usb-storage
	$RMMOD sg
	$RMMOD sd_mod
	$RMMOD scsi_mod
	$RMMOD musb_hdrc
	$RMMOD usbcore	
}

verify_usbh_id()
{
VENDOR_FILE=/sys/bus/usb/devices/usb1/1-1/idVendor
PRODUCT_FILE=/sys/bus/usb/devices/usb1/1-1/idProduct
VENDOR_ID="0e79"
PRODUCT_ID="110a"

	if [ "`cat $VENDOR_FILE`" = $VENDOR_ID ] && [ "`cat $PRODUCT_FILE`" = $PRODUCT_ID ] ; then
		return 1
	else
		return 0
	fi

}

get_secure_offset()
{
# default offset is for archostv+
let OFFSET=2*2*13111972/256
PRODUCT_NAME=`$SYS_INFO p`

	if [ "$PRODUCT_NAME" = "a605" ] ; then
		let OFFSET=3*2*13111972/256
	elif [ "$PRODUCT_NAME" = "a705" ] ; then
		let OFFSET=4*2*13111972/256
	elif [ "$PRODUCT_NAME" = "a405hdd" ] ; then
		let OFFSET=5*2*13111972/256
	fi

	return $OFFSET
}

hwl_unlock()
{
CRAMFSCHECKER=/bin/echo
#checker
HDD_RELOCK=/mnt/ram/hdd_relock

	get_secure_offset
	OFFSET_SECURE=$?


	install_usb_host
	result=$?
	if [ $result -eq 0 ] ; then
		echo "no host driver found"
		return 0
	fi
	
	let sda_count=15
	while [ $sda_count -gt 0 ] ; do
		let sda_count-=1
		if [ -e /sys/block/sda ] ; then
			let sda_count=0
		else
			sleep 1
		fi
	done

	if [ ! -e /sys/block/sda ] ; then
		echo "no host found"
		uninstall_usb_host
		return
	else
		#verify ids
		verify_usbh_id
		if [ $? -eq 0 ] ; then
			echo "bad usb device"
			uninstall_usb_host
			return
		fi
	fi

	dd if=/dev/sda of=/tmp/file.secure bs=256 skip=$OFFSET_SECURE count=1024

	result=1
	$CRAMFSCHECKER /tmp/file.secure
	if [ $? -eq 0 ] ; then
		dd if=/tmp/file.secure of=/dev/ram0 bs=256 skip=1
	
		mount -t cramfs -o loop /dev/ram0 /mnt/ram # > /dev/null 2>&1
		if [ ! -e $HDD_RELOCK ] ; then
			echo "no binary found"
			uninstall_usb_host
			return
		fi
		
		$HDD_RELOCK u
		result=$?
		umount /mnt/ram
	else
		echo "file not secured"
	fi

	uninstall_usb_host

	if [ $result -eq 0 ] ; then
		$AUI -c message -T $MAIN_TITLE -a centered -t "Hard Drive Relocked"
		sleep 2
	else
		$AUI -c message -T $MAIN_TITLE -a centered -t "Relock Failed"
		sleep 5
	fi



}

#hwl unlock
hwl_unlock

#mount media
# > /dev/null 2>&1 
mount -t vfat -o rw $MEDIA $MEDIA_PATH
MEDIA_FAILED=$?
if [ $MEDIA_FAILED -ne 0 ] ; then
	echo "mounting media failed"
	$AUI -c message -T $MAIN_TITLE -a centered -t "Media Failed"
	sleep 5
	/sbin/reboot
	while true; do sleep 1; done

fi

#Update sysid
echo "updating sysid"
$CREATE_SYSID

umount $MEDIA_PATH

# USB Connection
USB_PID=`$SYS_INFO u`

$INSMOD /lib/modules/usbcore.ko
$INSMOD /lib/modules/musb_hdrc.ko
$MOUNT -t sysfs sysfs /sys
$INSMOD /lib/modules/g_file_storage.ko file=$HD_DEVICE size=`cat $SYSFS_ROOT_PARTITION_START` vendor=0x0E79 product=0x$USB_PID

echo C >/proc/driver/musb_hdrc

# TODO!!! Connect USB and install aos file on fat partition here ..
SELECT=`$AUI -c select -T $MAIN_TITLE -a centered -t " " \
-t "done" --blocked`

# force disconnect
echo c >/proc/driver/musb_hdrc
$RMMOD g_file_storage
$RMMOD musb_hdrc
$RMMOD usbcore



#mount media
# > /dev/null 2>&1 
mount -t vfat -o rw $MEDIA $MEDIA_PATH
MEDIA_FAILED=$?
if [ $MEDIA_FAILED -ne 0 ] ; then
	echo "mounting media failed"
	$AUI -c message -T $MAIN_TITLE -a centered -t "Media Failed"
	sleep 5
	/sbin/reboot
	while true; do sleep 1; done

fi

#mount system
mount -t ext3 -o rw $ROOT $ROOT_PATH > /dev/null 2>&1 
ROOT_FAILED=$?
if [ $ROOT_FAILED -ne 0 ] ; then
	echo "mounting ext3 failed"
	$AUI -c message -T $MAIN_TITLE -a centered -t "System Failed"
	sleep 5
	umount $MEDIA_PATH
	/sbin/reboot
	while true; do sleep 1; done
fi

PRODUCT_NAME=`$SYS_INFO p`

# check for aos file
echo "looking for $AOS_FULLFILENAME..."
if [ -e $AOS_FULLFILENAME ] ; then
	launch_update $AOS_FULLFILENAME
# hack to support old style dvr205 filename
elif [ "$PRODUCT_NAME" = "archostv+" ] && [ -e "/mnt/data/firmware_dvr205.aos" ] ; then
		launch_update "/mnt/data/firmware_dvr205.aos"
fi


# reboot
umount $MEDIA_PATH
umount $ROOT_PATH
/sbin/reboot
while true; do sleep 1; done
