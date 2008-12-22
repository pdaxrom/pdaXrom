KERNEL=linux-2.6.27.tar.bz2
KERNEL_MIRROR=http://kernel.org/pub/linux/kernel/v2.6
KERNEL_DIR=$BUILD_DIR/linux-2.6.27

#KERNEL_CONFIG=ps3_kernel_config

if [ "x$KERNEL_CONFIG" = "x" ]; then
    error "No kernel config defined!"
fi

get_kernel_subarch() {
    case $1 in
    i386*|i486*|i586*|i686*)
	echo i386
	;;
    arm*|xscale*)
	echo arm
	;;
    powerpc*|ppc*)
	echo powerpc
	;;
    *)
	echo $1
	;;
    esac
}

get_kernel_image() {
    case $1 in
    i386*|i486*|i586*|i686*)
	echo bzImage
	;;
    arm*|xscale*)
	echo zImage
	;;
    powerpc*|ppc*)
	echo zImage
	;;
    *)
	echo $1
	;;
    esac
}

get_kernel_image_path() {
    case $1 in
    i386*|i486*|i586*|i686*)
	echo ${KERNEL_DIR}/arch/x86/boot/bzImage
	;;
    arm*|xscale*)
	echo ${KERNEL_DIR}/arch/arm/boot/zImage
	;;
    powerpc*|ppc*)
	echo ${KERNEL_DIR}/arch/powerpc/boot/zImage
	;;
    *)
	echo $1
	;;
    esac
}

build_linux_kernel() {
    test -e "$STATE_DIR/linux_kernel" && return
    banner "Build $KERNEL"
    download $KERNEL_MIRROR $KERNEL
    extract $KERNEL
    apply_patches $KERNEL_DIR $KERNEL
    cp $TOP_DIR/configs/$KERNEL_CONFIG $KERNEL_DIR/.config
    pushd $TOP_DIR
    cd $KERNEL_DIR
    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`
    local KERNEL_IMAGE=`get_kernel_image $TARGET_ARCH`
    make SUBARCH=$SUBARCH CROSS_COMPILE=$CROSS oldconfig $MAKEARGS || error
    make SUBARCH=$SUBARCH CROSS_COMPILE=$CROSS $KERNEL_IMAGE $MAKEARGS || error
    make SUBARCH=$SUBARCH CROSS_COMPILE=$CROSS modules $MAKEARGS || error
    make SUBARCH=$SUBARCH CROSS_COMPILE=$CROSS $MAKEARGS INSTALL_MOD_PATH=$ROOTFS_DIR modules_install || error
    popd
    touch "$STATE_DIR/linux_kernel"
}

build_linux_kernel