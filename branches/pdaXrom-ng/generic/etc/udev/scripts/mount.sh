#!/bin/sh
#
# Called from udev
# Attemp to mount any added removable block devices
# and remove any removed devices
#

export PATH=/usr/sbin:/usr/bin:/sbin:/bin:$PATH

MNTDIR="/media"

VOL_ID="/lib/udev/vol_id"

if [ "$ACTION" = "add" ] && [ -n "$DEVNAME" ]; then
    if [ ! -e /sys${DEVPATH}/device ]; then
	DEVPATH=${DEVPATH}/..
    fi
    if [ ! -e /sys${DEVPATH}/removable ]; then
	exit 0
    fi
    if [ "`cat /sys${DEVPATH}/removable`" = "0" ]; then
	exit 0
    fi
    FSTYPE="`$VOL_ID --type $DEVNAME`"
    if [ "x$FSTYPE" = "x" ]; then
	exit 1
    fi
    modprobe $FSTYPE || exit 1
    if grep "^$DEVNAME" /etc/fstab >/dev/null ; then
	mount $DEVNAME
	exit 0
    fi
    MNT="`$VOL_ID --label $DEVNAME`"
    if [ "x$MNT" = "x" ]; then
	MNT="NO NAME"
    fi
    MNT="${MNTDIR}/${MNT}"
    if [ -d "${MNT}" ]; then
	NUM=2
	while [ -d "$MNT ($NUM)" ]; do
	    NUM=$(($NUM+1))
	done
	MNT="$MNT ($NUM)"
    fi
    mkdir "$MNT"
    mount $DEVNAME "$MNT" 2> /dev/null || rmdir "$MNT"
    exit 0
fi

if [ "$ACTION" = "remove" ]; then
    if grep "^$DEVNAME" /etc/fstab >/dev/null ; then
	umount $DEVNAME
	exit 0
    fi

    for MNT in `cat /proc/mounts | grep "^$DEVNAME" | cut -f 2 -d " " `
    do
	MNT=`printf $MNT`
	umount "$MNT" && rmdir "$MNT"
    done
    exit 0
fi
