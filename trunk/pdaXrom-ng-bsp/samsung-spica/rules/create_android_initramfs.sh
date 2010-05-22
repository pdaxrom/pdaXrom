INITRAMFS_DIR=$BUILD_DIR/initramfs

create_initramfs() {
    rm -rf $INITRAMFS_DIR
    test -d $INITRAMFS_DIR || mkdir -p $INITRAMFS_DIR

    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`

    pushd $TOP_DIR

    cd $BUILD_DIR
    cd $INITRAMFS_DIR
    tar jxf ${BSP_GENERICFS_DIR}/initramfs-${KERNEL_VERSION}.tar.bz2 || error "unpack initramfs"

    if [ -d ${ROOTFS_DIR}/lib/modules/`ls ${ROOTFS_DIR}/lib/modules`/extra ]; then
	cp -a ${ROOTFS_DIR}/lib/modules/`ls ${ROOTFS_DIR}/lib/modules`/extra/* ${INITRAMFS_DIR}/lib/modules/
    fi

    if [ -d ${ROOTFS_DIR}/lib/modules/`ls ${ROOTFS_DIR}/lib/modules`/kernel/drivers/video/console ]; then
	cp -a ${ROOTFS_DIR}/lib/modules/`ls ${ROOTFS_DIR}/lib/modules`/kernel/drivers/video/console/* ${INITRAMFS_DIR}/lib/modules/
    fi

    if [ ${ROOTFS_DIR}/usr/sbin/iptables-multi ]; then
	$INSTALL -D -m 755 ${ROOTFS_DIR}/usr/sbin/iptables-multi ${INITRAMFS_DIR}/sbin/iptables-multi
	ln -sf iptables-multi ${INITRAMFS_DIR}/sbin/iptables
	ln -sf iptables-multi ${INITRAMFS_DIR}/sbin/iptables-restore
	ln -sf iptables-multi ${INITRAMFS_DIR}/sbin/iptables-save
	ln -sf iptables-multi ${INITRAMFS_DIR}/sbin/iptables-xml
    fi

    $INSTALL -D -m 4755 ${ROOTFS_DIR}/bin/su ${INITRAMFS_DIR}/sbin/su
    test "$INCLUDE_KEXEC" = "yes" && $INSTALL -D -m 755 ${ROOTFS_DIR}/sbin/kexec ${INITRAMFS_DIR}/sbin/kexec

    mkdir ${INITRAMFS_DIR}/xbin

    $INSTALL -D -m 4755 ${ROOTFS_DIR}/bin/busybox ${INITRAMFS_DIR}/xbin/busybox
    ln -sf busybox ${INITRAMFS_DIR}/xbin/ash
    ln -sf busybox ${INITRAMFS_DIR}/xbin/ls
    ln -sf busybox ${INITRAMFS_DIR}/xbin/mkdir
    ln -sf busybox ${INITRAMFS_DIR}/xbin/mknod
    ln -sf busybox ${INITRAMFS_DIR}/xbin/mount
    ln -sf busybox ${INITRAMFS_DIR}/xbin/sh
    ln -sf busybox ${INITRAMFS_DIR}/xbin/sleep
    ln -sf busybox ${INITRAMFS_DIR}/xbin/umount
    ln -sf busybox ${INITRAMFS_DIR}/xbin/chroot
    ln -sf busybox ${INITRAMFS_DIR}/xbin/switch_root

    ln -sf busybox ${INITRAMFS_DIR}/xbin/depmod
    ln -sf busybox ${INITRAMFS_DIR}/xbin/insmod
    ln -sf busybox ${INITRAMFS_DIR}/xbin/lsmod
    ln -sf busybox ${INITRAMFS_DIR}/xbin/modprobe
    ln -sf busybox ${INITRAMFS_DIR}/xbin/rmmod

cat > ${INITRAMFS_DIR}/default.prop << EOF
#
# ADDITIONAL_DEFAULT_PROPERTIES
#
ro.secure=0
ro.debuggable=1
persist.service.adb.enable=1
EOF

#    rm -f ${INITRAMFS_DIR}/init

#    $INSTALL -D -m 755 ${BSP_GENERICFS_DIR}/android-init ${INITRAMFS_DIR}/init

    #echo "root::0:0:root:/:/sbin/ash" > ${INITRAMFS_DIR}/sbin/passwd.txt

    #$INSTALL -D -m 644 ${BSP_GENERICFS_DIR}/init.rc ${INITRAMFS_DIR}/init.rc
    #$INSTALL -D -m 755 ${BSP_GENERICFS_DIR}/passwd_inst.sh ${INITRAMFS_DIR}/sbin/passwd_inst.sh

    cd $KERNEL_DIR
    bash scripts/gen_initramfs_list.sh $INITRAMFS_DIR > $BUILD_DIR/initramfs.list
    sed -i -e "s/`id -u` `id -g`$/0 0/" $BUILD_DIR/initramfs.list
    echo "nod /dev/console 0600 0 0 c 5 1" >> $BUILD_DIR/initramfs.list
    echo "nod /dev/fb0     0666 0 0 c 29 0" >> $BUILD_DIR/initramfs.list
    echo "nod /dev/tty0    0640 0 0 c 4 0" >> $BUILD_DIR/initramfs.list
    echo "nod /dev/tty1    0640 0 0 c 4 1" >> $BUILD_DIR/initramfs.list

    make SUBARCH=$SUBARCH CROSS_COMPILE=${TOOLCHAIN_PREFIX}/bin/${CROSS} $MAKEARGS `get_kernel_image $TARGET_ARCH` CONFIG_INITRAMFS_SOURCE=$BUILD_DIR/initramfs.list || error

    popd
}

create_initramfs

copy_kernel_image
