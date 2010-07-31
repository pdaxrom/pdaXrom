#!/bin/sh
#
# Called from udev
# Attemp to mount any added removable block devices
# and remove any removed devices
#

export PATH=/usr/sbin:/usr/bin:/sbin:/bin:$PATH

DEVICE=/dev/disk/by-uuid/$ID_FS_UUID

VOL_ID="/lib/udev/vol_id"

echo "$ACTION device $DEVICE [$ID_FS_LABEL] [$ID_FS_TYPE]" >> /var/log/mounts.log

MOUNTDIR=""
if [ "$ID_FS_LABEL" ]; then
    MOUNTDIR="$ID_FS_LABEL"
elif [ "$ID_FS_UUID" ]; then
    MOUNTDIR="$ID_FS_UUID"
fi

if [ "$ACTION" = "add" ] && [ "$MOUNTDIR" ]; then
    if [ ! -e /sys${DEVPATH}/device ]; then
	DEVPATH=${DEVPATH}/..
    fi
    if [ ! -e /sys${DEVPATH}/removable ]; then
	exit 0
    fi
    if [ "`cat /sys${DEVPATH}/removable`" = "0" ]; then
	exit 0
    fi
    if [ "x$ID_FS_TYPE" = "x" ]; then
	exit 1
    fi
    modprobe $ID_FS_TYPE || exit 1

    mkdir "/media/$MOUNTDIR"
    mount $DEVICE "/media/$MOUNTDIR"
fi

if [ "$ACTION" = "remove" ] && [ "$MOUNTDIR" ]; then
    umount -l "/media/$MOUNTDIR" && rmdir "/media/$MOUNTDIR"
fi
