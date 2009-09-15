create_jffs2() {
    rm -f $ROOTFS_DIR/linuxrc
    ln -sf /sbin/init $ROOTFS_DIR/init

    local MKS="-l"
    
    case $TARGET_ARCH in
    i*86-*|amd64-*|x86_64-*|arm*el-*|xscale*-*|iwmmx*-*|mips*l-*)
	MKS="-l"
	;;
    powerpc*-*|ppc*-*|arm*eb-*|mips*-*)
	MKS="-b"
	;;
    *)
	MKS="-l"
	;;
    esac

    mkfs.jffs2 $TARGET_JFFS2_ARGS \
	    --devtable=$GENERICFS_DIR/jffs2/devtable.jffs2 \
	    --eraseblock=${TARGET_JFFS2_ERASEBLOCK-16384} \
	    --pagesize=${TARGET_JFFS2_ERASEBLOCK-16384} \
	    $MKS -f -q \
	    -d $ROOTFS_DIR \
	    -o $IMAGES_DIR/rootfs.jffs2
}

copy_kernel_image() {
    cp -f `get_kernel_image_path $TARGET_ARCH` $IMAGES_DIR/
}

create_jffs2

copy_kernel_image
