#!/bin/sh

TOPDIR=`dirname $0`
DEVICE=$1
MNTPNT=/tmp/mnt.$$$

ME=`whoami`

if [ ! "$ME" = "root" ]; then
    echo "You need to be root in order to run this program."
    exit 1
fi

if [ $# -lt 1 ]; then
    echo "$0 <FAT16 USB FLASH DEVICE PARTITION>"
    echo "e.g. $0 /dev/sda1"
    echo "Use cfdisk or fdisk for make partition bootable"
    exit 1
fi

echo "Install syslinux on the $DEVICE"
${TOPDIR}/linux/syslinux ${DEVICE}
mkdir -p ${MNTPNT}
echo "Mount $DEVICE"
mount ${DEVICE} ${MNTPNT}
echo "Copy files to $DEVICE"
cp -f ${TOPDIR}/../boot/rootfs.bin ${MNTPNT}/
cp -f ${TOPDIR}/../boot/isolinux/{initrd.gz,credits.txt,mx2help.txt,pdax86.*,kernel/vmlinuz} ${MNTPNT}/
cp -f ${TOPDIR}/syslinux.cfg ${MNTPNT}/
umount ${MNTPNT}
rm -rf ${MNTPNT}

echo "All done!"
