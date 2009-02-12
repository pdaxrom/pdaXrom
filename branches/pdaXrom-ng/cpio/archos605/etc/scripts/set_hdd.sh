#!/bin/sh

# Author: Niklas Schroeter <schroeter@archos.com>

HD_DEVICE=$1
ROOT=$2
MEDIA=$3
MEDIA_VOLUME_LABEL=$4
ROOT_MOUNT_POINT=$5
MEDIA_MOUNT_POINT=$6
FORMAT=$7
TITLE=$8




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

ROOT_SIZE=390 # sectors

get_root_bytes()
{
	STORAGE_SIZE=`cat /sys/block/hda/size`
	let STORAGE_SIZE_MB=$STORAGE_SIZE/2048
	echo "storage size $STORAGE_SIZE_MB MBytes"

	if [ $STORAGE_SIZE_MB -ge 25600 ] ; then
		# 300 MB root partition
		return 300000000
	else
		# 200 MB root partition
		return 200000000
	fi

}

print_root() 
{
echo "print root partition: $2"
	# add information about hidden ext3 partition (start in sectors) in last sector of disk
	$CREATE_PARTITIONTABLE $1 $2 print_root_start_please | $PRINT_ROOT_PARTITION_INFO
	if [ $? -ne 0 ] ; then
		echo "root partition info write error"
		exit 1
	fi

}

create_partition()
{
	echo "create partition"

	get_root_bytes
	BYTES=$?

	# create partitiontable with information about FAT32 only
	# ext3 information is hidden and is written in last disk sector afterwards.
	$CREATE_PARTITIONTABLE $HD_DEVICE $BYTES | $SFDISK $HD_DEVICE -D -q > /dev/null 2>&1

	if [ $? -ne 0 ] ; then
		echo "partitiontable write error"
		exit 1
	fi
	
	#clear first block of fat partition (man 8 fdisk)
	$DD if=/dev/zero of=$MEDIA bs=512 count=1 > /dev/null 2>&1

	print_root $HD_DEVICE $BYTES

}


create_root_fs()
{
MKFSEXT3=/sbin/mkfs.ext3

	$AUI -c message -T $TITLE -a centered -t "setting up operating system..."

	$MKFSEXT3 $1

	if [ $? -ne 0 ] ; then
		echo "create root filesystem failed"
		exit 1	
	fi
}

create_media_fs()
{
echo "create media fs"
	# create FAT32 filesystem
	# we do not mention filesystem making in message because we do not want the user to know that
	# there is more than one FAT32 filesystem
	$AUI -c message -T $TITLE -a centered -t "setting up media..."

	# bug 119b : make /dev/hda1 type FAT32 LBA ( type Ox0C == \014 )
	echo -ne "\014" | dd of=/dev/hda bs=1 seek=450 > /dev/null 2>&1

	$MKDOSFS -F 32 -n $1 $2

	if [ $? -ne 0 ] ; then
		echo "create media filesystem failed"
		exit 1	
	fi
}

format_hdd()
{
	create_partition
	create_root_fs $ROOT
	create_media_fs $MEDIA_VOLUME_LABEL $MEDIA
}

repair_hdd()
{
	# read partition sizes, will return error if partition is missing
	$SFDISK -s $ROOT >/dev/null 2>&1
	let CHECK_ROOT=$?

if [ $CHECK_ROOT -ne 0 ] ; then
	# for duplicated disk
	# simply print root and try again
	echo "duplicated disk ?"
	get_root_bytes
	BYTES=$?
	print_root $HD_DEVICE $BYTES
	sync
fi

	# read partition sizes, will return error if partition is missing
	$SFDISK -s $ROOT >/dev/null 2>&1
	let CHECK_ROOT=$?
	$SFDISK -s $MEDIA >/dev/null 2>&1
	let CHECK_MEDIA=$?

if [ $CHECK_ROOT -ne 0 ] || [ $CHECK_MEDIA -ne 0 ] ; then
	echo "no partition table exists or partition table damaged"
	create_partition
fi
	
	#now hda1 and hda2 exist
	
	mount -t ext3 -o rw $ROOT $ROOT_MOUNT_POINT > /dev/null 2>&1 
	ROOT_FAILED=$?
	if [ $ROOT_FAILED -ne 0 ] ; then
		echo "mounting ext3 failed"
		get_root_bytes
		BYTES=$?
		print_root $HD_DEVICE $BYTES
		create_root_fs $ROOT
	else
		echo "root OK"
		umount $ROOT_MOUNT_POINT
	fi
	
	mount -t vfat -o rw,noatime,utf8,shortname=mixed $MEDIA $MEDIA_MOUNT_POINT > /dev/null 2>&1 
	MEDIA_FAILED=$?
	if [ $MEDIA_FAILED -ne 0 ] ; then
		echo "mounting media failed"
		create_media_fs $MEDIA_VOLUME_LABEL $MEDIA
	else
		echo "media OK"
		umount $MEDIA_MOUNT_POINT
	fi

}

if [ $FORMAT -eq 1 ] ; then
	#format
	echo "format hdd"
	$AUI -c message -T $TITLE -a centered -t "Format Hard Drive ..."
	format_hdd
else
	#repair
	echo "repair hdd"
	$AUI -c message -T $TITLE -a centered -t "Check Hard Drive ..."
	repair_hdd
fi

	
exit 0

