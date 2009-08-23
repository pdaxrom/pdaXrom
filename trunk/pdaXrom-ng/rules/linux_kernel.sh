if [ "x$KERNEL_VERSION" = "x" ]; then
    KERNEL_VERSION="2.6.27"
fi

KERNEL=linux-${KERNEL_VERSION}.tar.bz2
case ${KERNEL_VERSION} in
*-rc*)
    KERNEL_MIRROR=http://kernel.org/pub/linux/kernel/v2.6/testing
    ;;
*)
    KERNEL_MIRROR=http://kernel.org/pub/linux/kernel/v2.6
    ;;
esac
KERNEL_DIR=$BUILD_DIR/linux-${KERNEL_VERSION}

#KERNEL_CONFIG=ps3_kernel_config

if [ "x$KERNEL_CONFIG" = "x" ]; then
    error "No kernel config defined!"
fi

get_kernel_subarch() {
    case $1 in
    i386*|i486*|i586*|i686*)
	echo i386
	;;
    x86_64*|amd64*)
	echo x86_64
	;;
    arm*|xscale*)
	echo arm
	;;
    powerpc*|ppc*)
	echo powerpc
	;;
    mips*)
	echo mips
	;;
    *)
	echo $1
	;;
    esac
}

get_kernel_image() {
    case $1 in
    i386*|i486*|i586*|i686*|x86_64*|amd64*)
	echo ${TARGET_KERNEL_IMAGE-bzImage}
	;;
    arm*|xscale*)
	echo ${TARGET_KERNEL_IMAGE-zImage}
	;;
    powerpc*|ppc*)
	echo ${TARGET_KERNEL_IMAGE-zImage}
	;;
    mips*)
	echo ${TARGET_KERNEL_IMAGE-vmlinux}
	;;
    *)
	echo $1
	;;
    esac
}

get_kernel_image_path() {
    case $1 in
    i386*|i486*|i586*|i686*|x86_64*|amd64*)
	echo ${KERNEL_DIR}/arch/x86/boot/${TARGET_KERNEL_IMAGE-bzImage}
	;;
    arm*|xscale*)
	echo ${KERNEL_DIR}/arch/arm/boot/${TARGET_KERNEL_IMAGE-zImage}
	;;
    powerpc*|ppc*)
	echo ${KERNEL_DIR}/arch/powerpc/boot/${TARGET_KERNEL_IMAGE-zImage}
	;;
    mips*)
	echo ${KERNEL_DIR}/${TARGET_KERNEL_IMAGE-vmlinux}
	;;
    *)
	echo $1
	;;
    esac
}

get_kernel_ramdisk_path() {
    case $1 in
    i386*|i486*|i586*|i686*)
	echo ${KERNEL_DIR}/arch/x86/boot/ramdisk.image.gz
	;;
    arm*|xscale*)
	echo ${KERNEL_DIR}/arch/arm/boot/ramdisk.image.gz
	;;
    powerpc*|ppc*)
	echo ${KERNEL_DIR}/arch/powerpc/boot/ramdisk.image.gz
	;;
    mips*)
	echo ${KERNEL_DIR}/arch/mips/boot/ramdisk.image.gz
	;;
    *)
	echo ${1}-ramdisk.image.gz
	;;
    esac
}

build_linux_kernel() {
    test -e "$STATE_DIR/linux_kernel" && return
    banner "Build $KERNEL"
    download $KERNEL_MIRROR $KERNEL
    extract $KERNEL
    apply_patches $KERNEL_DIR $KERNEL
    cp $CONFIG_DIR/kernel/$KERNEL_CONFIG $KERNEL_DIR/.config || error "check kernel config file"
    pushd $TOP_DIR
    cd $KERNEL_DIR
    
    KERNEL_MODULES_ENABLED="yes"
    grep -q "^# CONFIG_MODULES" .config && KERNEL_MODULES_ENABLED="no"
    
    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`
    local KERNEL_IMAGE=`get_kernel_image $TARGET_ARCH`

    if [ "$KERNEL_OLDCONFIG_ENABLED" != "no" ]; then
       make SUBARCH=$SUBARCH CROSS_COMPILE=$CROSS oldconfig $MAKEARGS || error 
    fi

    make SUBARCH=$SUBARCH CROSS_COMPILE=$CROSS $KERNEL_IMAGE $MAKEARGS || error

    if [ "$KERNEL_MODULES_ENABLED" != "no" ]; then
	make SUBARCH=$SUBARCH CROSS_COMPILE=$CROSS modules $MAKEARGS || error
	make SUBARCH=$SUBARCH CROSS_COMPILE=$CROSS $MAKEARGS INSTALL_MOD_PATH=$ROOTFS_DIR modules_install || error
    fi

    popd
    touch "$STATE_DIR/linux_kernel"
}

copy_kernel_image() {
    cp -f `get_kernel_image_path $TARGET_ARCH` $IMAGES_DIR/
}

build_linux_kernel