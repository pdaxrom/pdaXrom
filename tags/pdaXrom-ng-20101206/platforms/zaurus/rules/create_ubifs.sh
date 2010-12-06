remove_data() {
    rm -rf $IMAGES_DIR/root*.img $IMAGES_DIR/*.zip $IMAGES_DIR/kernel.img
}
create_jffs2() {
    rm -f $ROOTFS_DIR/linuxrc
    ln -sf /sbin/init $ROOTFS_DIR/init

    mkfs.ubifs \
            --devtable=$BSP_GENERICFS_DIR/devtables/device_table.txt \
            --min-io-size=2048 \
            --leb-size=126976 \
	    --max-leb-cnt=955 \
	    --squash-uids \
	    --compr=lzo \
            --root=$ROOTFS_DIR \
            --output=$IMAGES_DIR/root_ubifs.img

    ubinize \
	    --o $IMAGES_DIR/root_ubi.img \
	    --min-io-size=2048 \
	    --sub-page-size=512 \
	    --vid-hdr-offset=2048 \
	    --peb-size=128KiB \
	    $BSP_GENERICFS_DIR/ubi_data/spitz-ubi.cfg
}

copy_kernel_image() {
    cp -f `get_kernel_image_path $TARGET_ARCH` $IMAGES_DIR/
}
create_uboot_kernel_image() {
        mkimage -A arm -O linux -T kernel -C none -a 0xa0008000 -e 0xa0008000 \
            -n "pdaXrom-NG 2.6.32 Basic" -d $IMAGES_DIR/zImage \
            $IMAGES_DIR/kernel.img
}
compress_image() {
        cp $BSP_GENERICFS_DIR/flash_tools/autoboot.sh_rootfs $IMAGES_DIR/autoboot.sh
        cd $IMAGES_DIR && zip -9 pdaXrom-spitz-r$SVN_REVISION-$TARGET_ARCH.zip \
             kernel.img* root_ubi.img* autoboot.sh

        rm -f autoboot.sh
}
remove_data
create_jffs2
copy_kernel_image
create_uboot_kernel_image
compress_image
