#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin

# by louigi600

echo "Proceed with pdaxrom installation or boot to emergency system? [y/n]"

read ans

if [ "$ans" != "y" -a "$ans" != "Y" ]; then
    exit 0
fi

echo $1

LOC=$1

for file in $LOC/kernel.img $LOC/kernel.img; do
    if [ -e $file ]; then
	echo "Kernel $file"
	nandlogical /dev/mtd1 WRITE 0x5a0000 0x160000 $file
	break
    fi
    file=""
done

if [ "x$file" = "x" ]; then
    echo "No kernel"
fi

for file in $LOC/rootfs.img $LOC/root.jffs2.img; do
    if [ -e $file ]; then
	echo "RootFS $file"
	flash_eraseall /dev/mtd2
	nandwrite /dev/mtd2 $file
	break
    fi
    file=""
done

if [ "x$file" = "x" ]; then
    echo "No rootfs image"
fi

echo "Reboot..."

reboot
