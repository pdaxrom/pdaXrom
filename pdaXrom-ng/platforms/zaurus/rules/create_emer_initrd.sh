create_initrd() {
    rm -f $IMAGES_DIR/initrd* $IMAGES_DIR/emergenc.img $IMAGES_DIR/*.zip   
	genext2fs \
	    -d $ROOTFS_DIR/ \
	    -f -U \
	    -D $BSP_GENERICFS_DIR/devtables/device_table.txt \
	    -b 8000 \
	    $IMAGES_DIR/initrd

	cd $IMAGES_DIR
	gzip -9 initrd
}

copy_kernel_image() {
    cp -f `get_kernel_image_path $TARGET_ARCH` $IMAGES_DIR/
}
create_ramdisk_image() {
	mkimage -A arm -O linux -T multi -C none -a 0xa0008000 -e 0xa0008000 \
	    -n "Zaurus Emergency System" -d $IMAGES_DIR/zImage:$IMAGES_DIR/initrd.gz \
	    $IMAGES_DIR/emergenc.img
}
compress_image() {
	cp $BSP_GENERICFS_DIR/flash_tools/u* $IMAGES_DIR/
	cp $BSP_GENERICFS_DIR/flash_tools/autoboot.sh_emer $IMAGES_DIR/autoboot.sh
	cd $IMAGES_DIR && zip -9 pdaXrom-spitz-r$SVN_REVISION-$TARGET_ARCH-uboot.zip \
	     emergenc.img* u-boot.bin* updater.pro updater.sh autoboot.sh

	rm -f updater.pro updater.sh autoboot.sh
}

create_initrd
copy_kernel_image
create_ramdisk_image
compress_image
