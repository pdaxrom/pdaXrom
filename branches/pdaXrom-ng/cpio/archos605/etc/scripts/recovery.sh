#!/bin/sh




















































HD_DEVICE=$1
ROOT_FAILED=$2
MEDIA_FAILED=$3
DO_UPDATE=$4
ROOT=$5
MEDIA=$6
MEDIA_VOLUME_LABEL=$7
RECOVERY_ERROR_CODE=$8
MEDIA_PATH=$9
PRODUCT_NAME=$10

MKFSEXT3=/sbin/mkfs.ext3
MKDOSFS=/sbin/mkdosfs
SFDISK=/sbin/sfdisk
DD=/bin/dd
HEAD=/bin/head
MOUNT=/bin/mount
UMOUNT=/bin/umount
AUI=/bin/aui
INSMOD=/sbin/insmod
RMMOD=/sbin/rmmod
CREATE_PARTITIONTABLE=/bin/create_partitiontable
PRINT_ROOT_PARTITION_INFO=/bin/print_root_partition_info
MKDIR=/bin/mkdir

SYSFS_ROOT_PARTITION_START="/sys/block/hda/hda2/start"

FORCE=0
CHECK_ROOT=0
CHECK_MEDIA=0

ROOT_SIZE=390 # sectors

VIDEO_DIRNAME=Video
MUSIC_DIRNAME=Music
PHOTO_DIRNAME=Pictures
INFO_DIRNAME=Info
DATA_DIRNAME=Data

echo "productname:-) $PRODUCT_NAME"
if [ "$PRODUCT_NAME" = "a704wifi" -o "$PRODUCT_NAME" = "a704tv" -o "$PRODUCT_NAME" = "a705" ] ; then
CALIBRATE_AT_START=1
else
CALIBRATE_AT_START=0
fi


# PARTITIONTABLE="/tmp/partitiontable"

if [ $DO_UPDATE -eq 0 ] ; then
	# damaged system 
	KEY=`$AUI -c select -T "Recovery (code $RECOVERY_ERROR_CODE)" -a centered -t "System is damaged. Would you like to recover it ?" \
		-t No -t Repair Disk -t "Format Disk" --blocked`
elif [ $DO_UPDATE -eq 1 ] ; then
	# force with question
	if [ $CALIBRATE_AT_START -eq 0 ] ; then
		KEY=`$AUI -c select -T "Recovery (code $RECOVERY_ERROR_CODE)" -a centered -t "Would you like to recover your system ?" \
			-t No -t "Repair Disk" -t "Format Disk" --blocked`
	else
		KEY=`$AUI -c select -T "Recovery (code $RECOVERY_ERROR_CODE) press on TV LCD: short= up down, long= ok" \
			 -a centered -t "Would you like to recover your system ?" \
			-t No -t "Repair Disk" -t "Format Disk" -t "Force Touchscreen Calibration" --blocked`
	fi
else
	# force without question
	KEY="key=enter"
	SELECT="selected=1"
fi

SELECT=`$AUI --get-selected`

if [ $SELECT = "selected=0" ] || [ $KEY = "key=esc" ] ; then
	exit 2
elif [ $SELECT = "selected=2" ] ; then
	let FORCE=1
elif [ $SELECT = "selected=3" ] ; then
	$AUI -c message -T "Recovery" -a centered -t "calibration screen will be launched after reboot"
	sleep 2
	exit 3
fi

if [ $FORCE -eq 1 ] ; then
	let CHECK_ROOT=1
	let CHECK_MEDIA=1
	let ROOT_FAILED=1
	let MEDIA_FAILED=1
else
	$AUI -c message -T "Recovery" -a centered -t "checking partition table..."

	# read partition sizes, will return error if partition is missing
	$SFDISK -s $ROOT >/dev/null 2>&1
	let CHECK_ROOT=$?
	$SFDISK -s $MEDIA >/dev/null 2>&1
	let CHECK_MEDIA=$?
fi

if [ $CHECK_ROOT -ne 0 ] || [ $CHECK_MEDIA -ne 0 ] ; then
	echo "no partition table exists or partition table damaged"
	STORAGE_SIZE=`cat /sys/block/hda/size`
	let STORAGE_SIZE_MB=$STORAGE_SIZE/2048
	echo "storage size $STORAGE_SIZE_MB MBytes"

	$AUI -c message -T "Recovery" -a centered -t "please wait..."

	if [ $STORAGE_SIZE_MB -ge 25600 ] ; then
		# 300 MB root partition
		BYTES=300000000
	else
		# 200 MB root partition
		BYTES=200000000
	fi

	echo "system partition size $BYTES"
	
	# create partitiontable with information about FAT32 only
	# ext3 information is hidden and is written in last disk sector afterwards.
	$CREATE_PARTITIONTABLE $HD_DEVICE $BYTES | $SFDISK $HD_DEVICE -D -q -f > /dev/null 2>&1

	if [ $? -ne 0 ] ; then
		echo "partitiontable write error"
		exit 1
	fi
	
	#clear first block of fat partition (man 8 fdisk)
	$DD if=/dev/zero of=$MEDIA bs=512 count=1 > /dev/null 2>&1

	# add information about hidden ext3 partition (start in sectors) in last sector of disk
	$CREATE_PARTITIONTABLE $HD_DEVICE $BYTES print_root_start_please | $PRINT_ROOT_PARTITION_INFO /dev/hda
	if [ $? -ne 0 ] ; then
		echo "root partition info write error"
		exit 1
	fi

	if [ $FORCE -eq 0 ] ; then
		exit 0	
	fi
else
	echo "there is a partition table"
fi

if [ $MEDIA_FAILED -ne 0 ] ; then
	# create FAT32 filesystem
	# we do not mention filesystem making in message because we do not want the user to know that
	# there is more than one FAT32 filesystem
	$AUI -c message -T "Recovery" -a centered -t "setting up media..."

	# bug 119b : make /dev/hda1 type FAT32 LBA ( type Ox0C == \014 )
	echo -ne "\014" | dd of=/dev/hda bs=1 seek=450 > /dev/null 2>&1

	$MKDOSFS -F 32 -n $MEDIA_VOLUME_LABEL $MEDIA

	if [ $? -ne 0 ] ; then
		echo "create media filesystem failed"
		exit 1
	fi

	# create mandatory folders
	echo "create mandatory folders"
	$MOUNT -t vfat -o rw $MEDIA $MEDIA_PATH > /dev/null 2>&1
	$MKDIR $MEDIA_PATH/$MUSIC_DIRNAME > /dev/null 2>&1
	$MKDIR $MEDIA_PATH/$PHOTO_DIRNAME > /dev/null 2>&1
	$MKDIR $MEDIA_PATH/$VIDEO_DIRNAME > /dev/null 2>&1
#	$MKDIR $MEDIA_PATH/$INFO_DIRNAME > /dev/null 2>&1
#	$MKDIR $MEDIA_PATH/$DATA_DIRNAME > /dev/null 2>&1
	$UMOUNT $MEDIA_PATH > /dev/null 2>&1
fi

if [ $ROOT_FAILED -ne 0 ] ; then
	# CREATE hidden EXT3 filesystem and install avos
	# we do not mention filesystem making in message because we do not want the user to know that
	# there is more than one FAT32 filesystem
	$AUI -c message -T "Recovery" -a centered -t "setting up operating system..."

	$MKFSEXT3 $ROOT

	if [ $? -ne 0 ] ; then
		echo "create root filesystem failed"
		exit 1	
	fi
	
	let DO_UPDATE=1
fi

if [ $DO_UPDATE -eq 1 ] ; then
	$INSMOD /lib/modules/usbcore.ko
	$INSMOD /lib/modules/musb_hdrc.ko
	$MOUNT -t sysfs sysfs /sys
	$INSMOD /lib/modules/g_file_storage.ko file=$HD_DEVICE size=`cat $SYSFS_ROOT_PARTITION_START`
	$UMOUNT /sys
	echo C >/proc/driver/musb_hdrc

	# TODO!!! Connect USB and install aos file on fat partition here ..
	SELECT=`$AUI -c select -T "Recovery update" -a centered -t "connect your device to your PC and install an update file" \
	-t "done" --blocked`

	# force disconnect
	echo c >/proc/driver/musb_hdrc
	$RMMOD g_file_storage
	$RMMOD musb_hdrc
	$RMMOD usbcore

	# mark MTPLIB dirty
	$MOUNT -t vfat -o rw $MEDIA $MEDIA_PATH > /dev/null 2>&1 
	$MKDIR $MEDIA_PATH/System/ > /dev/null 2>&1 
	$DD if=/dev/zero of=$MEDIA_PATH/System/mtplib_dirty count=0
	$UMOUNT $MEDIA_PATH > /dev/null 2>&1 
	# remount /sys
	$MOUNT -t sysfs sysfs /sys
fi

exit 0
