create_initrd() {
    rm -f $ROOTFS_DIR/linuxrc
    
	genext2fs     $TARGET_JFFS2_ARGS \
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
