create_initramfs() {
    local K_V=`ls $ROOTFS_DIR/lib/modules`
    $DEPMOD -a -b $ROOTFS_DIR $K_V
    rm -f $ROOTFS_DIR/linuxrc
    ln -sf /sbin/init $ROOTFS_DIR/init
    pushd $TOP_DIR
    cd $ROOTFS_DIR
    find ./ | $CPIO -H newc -o | gzip -9 > $IMAGES_DIR/rootfs.img
    popd
}

create_initramfs

copy_kernel_image
