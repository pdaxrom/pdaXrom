#!/bin/sh

dev=$1

if [ "x$dev" = "x" ]; then
    echo
    echo "Usage:"
    echo "$0 /dev/sdX"
    echo
    exit 1
fi

PARTED="@PARTED@"
PPROBE="@PPROBE@"
MKFSHFS="@MKFSHFS@"

R=`cat /sys/block/\`basename $dev\`/removable`

if [ ! "$R" = "1" ]; then
    echo
    echo "Looks like non removable device..."
    echo "Exit!"
    echo
    exit 1
fi

echo
echo "USB Pen selected as $dev"
printf "Are you sure(y/n)?"
read a

if [ ! "$a" = "y" ]; then
    echo
    echo "Exit..."
    echo
    exit 0
fi

if [ ! `whoami` = "root" ]; then
    echo
    echo "Only root can run this programm, use sudo $0 $@"
    echo "Exit..."
    echo
    exit 1
fi

error() {
    exit 1
}

if [ ! -e LATEST.tar.gz ]; then
    echo "No atv-ps3boot archive found, trying to check it on usb pen..."
    mount ${dev} /mnt >/dev/null 2>/dev/null || mount ${dev}1 /mnt >/dev/null 2>/dev/null
    if [ "$?" = "0" ]; then
	if [ -e /mnt/LATEST.tar.gz ]; then
	    echo "Latest atv-ps3boot ... it's here!"
	    cp -f /mnt/LATEST.tar.gz ~/
	else
	    echo
	    echo "No LATEST.tar.gz found :( download it and put to usb pen or current directory."
	    echo "Exit!"
	    exit 1
	fi
	if [ -e /mnt/boot.efi ]; then
	    echo "Proprietary boot.efi ... it's here!"
	    cp -f /mnt/boot.efi ~/
	fi
	umount /mnt
    fi
fi

echo "Zero the initial sectors"
dd if=/dev/zero of=$dev bs=40 count=1M || error

echo "Sync the system disk partition tables"
$PPROBE $dev || error
sleep 1

echo "Create the GPT format"
$PARTED -s $dev mklabel gpt || error

echo "Create just a recovery partition"
$PARTED -s $dev mkpart primary HFS 40s 69671s || error
$PARTED -s $dev set 1 atvrecv on || error

echo "Sync the system disk partition tables"
$PPROBE $dev || error
sleep 1

echo "Verify that it looks fine and the atvrecv flag is set"
$PARTED -s $dev unit s print || error

echo "Format it"
$MKFSHFS -v ATV-PS3Boot ${dev}1 || error

echo "Mount it"
mount ${dev}1 /mnt || error

echo "Install it"
tar zxvf LATEST.tar.gz -C /mnt/

for d in . ~ /tmp; do
    if [ -e ${d}/boot.efi ]; then
	# remember to copy boot.efi to /mnt
	echo "Copy boot.efi"
	cp -ap ${d}/boot.efi /mnt/
    fi
done

echo "Unmount"
umount /mnt || error

echo "Done!"
