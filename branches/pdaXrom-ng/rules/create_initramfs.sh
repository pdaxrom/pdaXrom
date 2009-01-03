create_squashfs() {
    local MKS="-le"
    
    case $TARGET_ARCH in
    i*86-*|amd64-*|x86_64-*|arm*-*|xscale*-*|iwmmx*-*)
	MKS="-le"
	;;
    powerpc*-*|ppc*-*|mips*-*)
	MKS="-be"
	;;
    *)
	MKS="-le"
	;;
    esac

    local K_V=`ls $ROOTFS_DIR/lib/modules`
    $DEPMOD -a -b $ROOTFS_DIR $K_V
    rm -f $ROOTFS_DIR/linuxrc
    ln -sf /sbin/init $ROOTFS_DIR/init

    echo "c 5 1" > $ROOTFS_DIR/dev/.squashfs_dev_node.console
    echo "c 1 3" > $ROOTFS_DIR/dev/.squashfs_dev_node.null

    rm -f $IMAGES_DIR/rootfs.img
    mksquashfs $ROOTFS_DIR $IMAGES_DIR/rootfs.img $MKS -all-root -lzmadic 1M || error
    #mksquashfs $ROOTFS_DIR $IMAGES_DIR/rootfs.img $MKS -all-root -nolzma || error
}

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

copy_kernel_image() {
    cp -f `get_kernel_image_path $TARGET_ARCH` $IMAGES_DIR/
}

#create_initramfs

create_squashfs

copy_kernel_image
