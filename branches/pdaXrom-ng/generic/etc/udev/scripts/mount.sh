#!/bin/sh
#
# Called from udev
# Attemp to mount any added removable block devices
# and remove any removed devices
#

export PATH=/usr/sbin:/usr/bin:/sbin:/bin:$PATH

DEVICE=/dev/disk/by-uuid/$ID_FS_UUID

VOL_ID="/lib/udev/vol_id"

echo "$ACTION device $DEVICE" >> /var/log/mounts.log

if [ "$ACTION" = "add" ] && [ "$ID_FS_UUID" ]; then
    if [ ! -e /sys${DEVPATH}/device ]; then
	DEVPATH=${DEVPATH}/..
    fi
    if [ ! -e /sys${DEVPATH}/removable ]; then
	exit 0
    fi
    if [ "`cat /sys${DEVPATH}/removable`" = "0" ]; then
	exit 0
    fi
    FSTYPE="`$VOL_ID --type $DEVICE`"
    if [ "x$FSTYPE" = "x" ]; then
	exit 1
    fi
    modprobe $FSTYPE || exit 1

    mkdir /media/disk-$ID_FS_UUID
    mount $DEVICE /media/disk-$ID_FS_UUID
fi

if [ "$ACTION" = "remove" ] && [ "$ID_FS_UUID" ]; then
    umount -l $DEVICE && rmdir /media/disk-$ID_FS_UUID
fi
