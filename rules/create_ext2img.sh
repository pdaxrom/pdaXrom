TARGET_IMAGE_SIZE_IN_BLOCKS=16384

create_ext2img() {
    genext2fs -b $TARGET_IMAGE_SIZE_IN_BLOCKS -q -d $ROOTFS_DIR $IMAGES_DIR/rootfs.img
}

create_ext2img
