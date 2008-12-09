create_initramfs() {
    rm -f $ROOTFS_DIR/linuxrc
    ln -sf /sbin/init $ROOTFS_DIR/init
    pushd $TOP_DIR
    cd $ROOTFS_DIR
    find ./ | $CPIO -H newc -o | gzip -9 > ../rootfs.img
    popd
}

create_initramfs
