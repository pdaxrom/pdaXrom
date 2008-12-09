TARGET_IMAGE_SIZE_IN_BLOCKS=16384

build_image() {
    test -e $TARGET_BIN_DIR/rootfs.img && return
    genext2fs -b $TARGET_IMAGE_SIZE_IN_BLOCKS -q -d $ROOTFS_DIR $TARGET_BIN_DIR/rootfs.img
}

build_image
