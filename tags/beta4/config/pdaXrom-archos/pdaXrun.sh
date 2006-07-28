#!/bin/sh

echo "******************************"
echo "* pdaXrom preparing to start *"
echo "******************************"

losetup /dev/loop/1 /media/rootfs.img
mkdir -p /tmp/pdaXrom
mount /dev/loop/1 /tmp/pdaXrom

mount -t devfs none /tmp/pdaXrom/dev
cd /tmp/pdaXrom
mkdir -p mnt/archos
pivot_root . mnt/archos
exec chroot . /linuxrc 2>&1
