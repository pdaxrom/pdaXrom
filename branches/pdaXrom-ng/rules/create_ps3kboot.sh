create_ps3kboot() {
    rm -f $ROOTFS_DIR/linuxrc
    ln -sf /sbin/init $ROOTFS_DIR/init

    ( umask 077; cd $ROOTFS_DIR && find . | cpio -o -H newc | gzip > `get_kernel_ramdisk_path $TARGET_ARCH`; ) || error "create ramdisk"
    
    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`

    pushd $TOP_DIR
    cd $KERNEL_DIR

    make SUBARCH=$SUBARCH CROSS_COMPILE=$CROSS $MAKEARGS zImage.initrd || error

    cp -f $KERNEL_DIR/arch/powerpc/boot/otheros.bld $IMAGES_DIR/ || error "copy otheros.bld"

    popd
    
}

create_ps3kboot
