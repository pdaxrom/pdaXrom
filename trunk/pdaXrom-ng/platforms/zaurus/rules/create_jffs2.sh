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
            $MKS -f -q -p -n \
            -d $ROOTFS_DIR \
            -o $IMAGES_DIR/rootfs.img
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
             kernel.img* rootfs.img* autoboot.sh

        rm -f autoboot.sh
}
create_jffs2
copy_kernel_image
create_uboot_kernel_image
compress_image
