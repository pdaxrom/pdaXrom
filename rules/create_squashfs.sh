create_squashfs() {
    local MKS="-le"
    
    case $TARGET_ARCH in
    i*86-*|amd64-*|x86_64-*|arm*el-*|xscale*-*|iwmmx*-*|mips*l-*|armle-*)
	MKS="-le"
	;;
    powerpc*-*|ppc*-*|arm*eb-*|mips*-*|armbe-*)
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
    echo "c 1 1" > $ROOTFS_DIR/dev/.squashfs_dev_node.mem
    echo "c 1 5" > $ROOTFS_DIR/dev/.squashfs_dev_node.zero
    if [ "$USE_FASTBOOT" = "yes" ]; then
	echo "c 29 0" > $ROOTFS_DIR/dev/.squashfs_dev_node.fb0
	echo "c 4 0" > $ROOTFS_DIR/dev/.squashfs_dev_node.tty0
	echo "c 4 1" > $ROOTFS_DIR/dev/.squashfs_dev_node.tty1
	echo "c 4 2" > $ROOTFS_DIR/dev/.squashfs_dev_node.tty2
	echo "c 4 3" > $ROOTFS_DIR/dev/.squashfs_dev_node.tty3
	mkdir -p $ROOTFS_DIR/dev/input
	echo "c 13 63" > $ROOTFS_DIR/dev/input/.squashfs_dev_node.mice
	echo "c 13 32" > $ROOTFS_DIR/dev/input/.squashfs_dev_node.mouse0
	mkdir -p $ROOTFS_DIR/dev/snd
	echo "c 116 33" > $ROOTFS_DIR/dev/snd/.squashfs_dev_node.timer
	echo "c 116 16" > $ROOTFS_DIR/dev/snd/.squashfs_dev_node.pcmC0D0p
	echo "c 116 0" > $ROOTFS_DIR/dev/snd/.squashfs_dev_node.controlC0
    fi

    rm -f $IMAGES_DIR/rootfs.img
    if [ ! "$SQUASHFS_LZMA" = "no" ]; then
	mksquashfs $ROOTFS_DIR $IMAGES_DIR/rootfs.img $MKS -all-root -lzmadic 1M || error
    else
	mksquashfs $ROOTFS_DIR $IMAGES_DIR/rootfs.img $MKS -all-root -nolzma || error
    fi
    chmod 644 $IMAGES_DIR/rootfs.img
}

create_squashfs

copy_kernel_image
