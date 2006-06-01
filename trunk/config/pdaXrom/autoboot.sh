#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin

echo $1

LOC=$1

for file in $LOC/kernel.img $LOC/KERNEL.IMG; do
    if [ -e $file ]; then
	echo "Kernel $file"
	flash_eraseall /dev/mtd4
	dd if=$file of=/dev/mtdblock4
	break
    fi
    file=""
done

if [ "x$file" = "x" ]; then
    echo "No kernel"
fi

for file in $LOC/rootfs.img $LOC/ROOTFS.IMG; do
    if [ -e $file ]; then
	echo "RootFS $file"
	flash_eraseall /dev/mtd5
	nandwrite /dev/mtd5 $file
	break
    fi
    file=""
done

if [ "x$file" = "x" ]; then
    echo "No rootfs image"
fi

echo "Reboot..."

reboot
