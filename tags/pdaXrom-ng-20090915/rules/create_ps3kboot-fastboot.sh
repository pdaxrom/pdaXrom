create_ps3kboot() {
    sed -i "s|--timeout=60|--timeout=15|" $ROOTFS_DIR/etc/init.d/udev

    rm -f $ROOTFS_DIR/linuxrc
    ln -sf /etc/init.d/rcS $ROOTFS_DIR/init

    ( umask 077; cd $ROOTFS_DIR && find . | cpio -o -H newc | gzip > `get_kernel_ramdisk_path $TARGET_ARCH`; ) || error "create ramdisk"
    
    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`

    pushd $TOP_DIR
    cd $KERNEL_DIR

    make SUBARCH=$SUBARCH CROSS_COMPILE=${TOOLCHAIN_PREFIX}/bin/${CROSS} $MAKEARGS zImage.initrd || error

    cp -f $KERNEL_DIR/arch/powerpc/boot/otheros.bld $IMAGES_DIR/pdaXrom-ng-otheros-${PS3BOOT_VERSION}-`date +%Y%m%d`.bld || error "copy otheros.bld"
    cd $IMAGES_DIR
    md5sum pdaXrom-ng-otheros-${PS3BOOT_VERSION}-`date +%Y%m%d`.bld > pdaXrom-ng-otheros-${PS3BOOT_VERSION}-`date +%Y%m%d`.bld.md5sum

    local T=`echo /tmp/ps3boot.$$`

    mkdir -p $T || error

    $INSTALL -D -m 644 $KERNEL_DIR/arch/powerpc/boot/otheros.bld $T/PS3/otheros/otheros.bld || error

    cd $T
    
    zip -9r $IMAGES_DIR/pdaXrom-ng-otheros-${PS3BOOT_VERSION}-`date +%Y%m%d`.zip .
    cd $IMAGES_DIR
    md5sum pdaXrom-ng-otheros-${PS3BOOT_VERSION}-`date +%Y%m%d`.zip > pdaXrom-ng-otheros-${PS3BOOT_VERSION}-`date +%Y%m%d`.zip.md5sum

    popd
    
}

create_ps3kboot