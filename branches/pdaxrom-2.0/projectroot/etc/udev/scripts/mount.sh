#!/bin/sh
#
# Called from udev
# Attemp to mount any added block devices 
# and remove any removed devices
#

get_mount_dir() {
PART=${DEVPATH##*/}
PART=${PART%[1-9]}
PART=${DEVPATH##*/${PART}}

DEV=${DEVNAME##*/}

if echo $DEV | grep "^mmcblk"; then
    MNT=$DEV
else

if [ ! -d /sys$DEVPATH/device ]; then
    DEVPATH=$DEVPATH/..
fi

VENDOR=`cat /sys$DEVPATH/device/vendor 2>/dev/null`
MODEL=`cat  /sys$DEVPATH/device/model 2>/dev/null`
MNT=`echo $VENDOR$MODEL | sed s/\ *$// | sed 's|/|\\\\|g'`$PART

if [ "`cat /sys$DEVPATH/removable`" = 1 \
     -o -n "`echo $PHYSDEVPATH | grep -e usb -e ieee1394`" ]; then
  REMOVABLE=true
else
    exit 0
fi

if [ "$REMOVABLE" != true -o "$MNT" = "$PART" ]; then
  case $DEV in
    cdrom*)
      MNT="cdrom ${DEV#cdrom}"
      ;;
    disk*)
      DEV=${DEV%part*}
      MNT="disk ${DEV#disk}$PART"
      ;;
  esac
fi

fi

MNT="/mnt/$MNT"
if [ -d "$MNT" ]; then
  NUM=2
  while [ -d "$MNT ($NUM)" ]; do
    NUM=$(($NUM+1))
  done
  MNT="$MNT ($NUM)"
fi
mkdir "$MNT"
}

MOUNT="/bin/mount"
UMOUNT="/bin/umount"

if [ "$ACTION" = "add" ] && [ -n "$DEVNAME" ]; then
    if grep "^$DEVNAME" /etc/fstab >/dev/null ; then
	mount $DEVNAME
	exit 0
    fi
    get_mount_dir
    if [ -x $MOUNT ]; then
    	$MOUNT $DEVNAME "$MNT" 2> /dev/null || rmdir "$MNT"
    fi
fi

if [ "$ACTION" = "remove" ] && [ -x "$UMOUNT" ] && [ -n "$DEVNAME" ]; then
    if grep "^$DEVNAME" /etc/fstab >/dev/null ; then
	umount $DEVNAME
	exit 0
    fi
    for mnt in `cat /proc/mounts | grep "$DEVNAME" | cut -f 2 -d " " `
    do
	mnt=`printf $mnt`
	$UMOUNT "$mnt" && rmdir "$mnt"
    done
fi

