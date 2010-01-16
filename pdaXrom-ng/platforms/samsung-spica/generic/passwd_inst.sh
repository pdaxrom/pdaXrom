#!/system/bin/sh

if [ ! -e /system/etc/passwd ]; then
    /system/bin/mount -o remount,rw /dev/stl5 /system
    cat /sbin/passwd.txt > /system/etc/passwd
    /system/bin/mount -o remount,ro /dev/stl5 /system
fi
