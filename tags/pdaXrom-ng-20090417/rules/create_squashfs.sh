create_squashfs() {
    local MKS="-le"
    
    case $TARGET_ARCH in
    i*86-*|amd64-*|x86_64-*|arm*el-*|xscale*-*|iwmmx*-*|mips*l-*)
	MKS="-le"
	;;
    powerpc*-*|ppc*-*|arm*eb-*|mips*-*)
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
    if [ ! "$SQUASHFS_LZMA" = "no" ]; then
	mksquashfs $ROOTFS_DIR $IMAGES_DIR/rootfs.img $MKS -all-root -lzmadic 1M || error
    else
	mksquashfs $ROOTFS_DIR $IMAGES_DIR/rootfs.img -all-root || error
    fi
    chmod 644 $IMAGES_DIR/rootfs.img
}

create_squashfs

copy_kernel_image