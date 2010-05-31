INITRAMFS_DIR=$BUILD_DIR/initramfs

create_initramfs() {
    test -d $INITRAMFS_DIR || mkdir -p $INITRAMFS_DIR
    rm -rf $INITRAMFS_DIR/*
    local d=
    for d in bin boot dev mnt sys proc rootfs sbin; do
	mkdir -p $INITRAMFS_DIR/$d
    done

    $INSTALL -D -m 755 $ROOTFS_DIR/usr/bin/kexecboot $INITRAMFS_DIR/init || error

    uuidgen > $INITRAMFS_DIR/uuid
    cp -f $INITRAMFS_DIR/uuid $IMAGES_DIR/uuid

    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`

    cd $KERNEL_DIR
    bash scripts/gen_initramfs_list.sh $INITRAMFS_DIR > $BUILD_DIR/initramfs.list
    sed -i -e "s/`id -u` `id -g`$/0 0/" $BUILD_DIR/initramfs.list
    echo "nod /dev/console 0600 0 0 c 5 1" >> $BUILD_DIR/initramfs.list
    echo "nod /dev/fb0     0666 0 0 c 29 0" >> $BUILD_DIR/initramfs.list
    echo "nod /dev/tty0    0640 0 0 c 4 0" >> $BUILD_DIR/initramfs.list
    echo "nod /dev/tty1    0640 0 0 c 4 1" >> $BUILD_DIR/initramfs.list
    echo "nod /dev/tty2    0640 0 0 c 4 2" >> $BUILD_DIR/initramfs.list
    echo "nod /dev/tty3    0640 0 0 c 4 3" >> $BUILD_DIR/initramfs.list
    echo "nod /dev/null    0666 0 0 c 1 3" >> $BUILD_DIR/initramfs.list

    make SUBARCH=$SUBARCH CROSS_COMPILE=${TOOLCHAIN_PREFIX}/bin/${CROSS} $MAKEARGS `get_kernel_image $TARGET_ARCH` CONFIG_INITRAMFS_SOURCE=$BUILD_DIR/initramfs.list || error

}
compress_image() {
        cp $BSP_GENERICFS_DIR/flash_tools/updater.kexecboot $IMAGES_DIR/updater.sh
        cd $IMAGES_DIR && zip -9 pdaXrom-spitz-r$SVN_REVISION-$TARGET_ARCH.zip \
             updater.sh zImage 
}
create_initramfs
copy_kernel_image
compress_image
