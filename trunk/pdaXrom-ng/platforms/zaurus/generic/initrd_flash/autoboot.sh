#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin

# by louigi600

echo "Update U-BOOT / Emergency system"
echo
echo "Proceed with pdaxrom installation or boot to emergency system? [y/n]"

read ans

if [ "$ans" != "y" -a "$ans" != "Y" ]; then
    exit 0
fi

echo $1

LOC=$1

for file in $LOC/u-boot.bin $LOC/U-BOOT.BIN; do
    if [ -e $file ]; then
	echo "U-BOOT: $file"
	nandlogical /dev/mtd1 WRITE 0x0 0x20000 $file
	break
    fi
    file=""
done

for file in $LOC/emergenc.img $LOC/EMERGENC.IMG; do
    if [ -e $file ]; then
	echo "EMERGENCY: $file"
	nandlogical /dev/mtd1 WRITE 0x60000 0x540000 $file
	break
    fi
    file=""
done

echo "Reboot..."

reboot
