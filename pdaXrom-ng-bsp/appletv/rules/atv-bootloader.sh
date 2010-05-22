#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

ATV_BOOTLOADER_VERSION=svn
ATV_BOOTLOADER=atv-bootloader-${ATV_BOOTLOADER_VERSION}
ATV_BOOTLOADER_SVN=http://atv-bootloader.googlecode.com/svn/trunk
ATV_BOOTLOADER_DIR=$BUILD_DIR/atv-bootloader-${ATV_BOOTLOADER_VERSION}
ATV_BOOTLOADER_ENV="$CROSS_ENV_AC"

build_atv_bootloader() {
#    test -e "$STATE_DIR/atv_bootloader.installed" && return
    banner "Build atv-bootloader"
    #download_svn $ATV_BOOTLOADER_SVN $ATV_BOOTLOADER
    rm -rf $ATV_BOOTLOADER_DIR
    cp -R $BSP_SRC_DIR/$ATV_BOOTLOADER $ATV_BOOTLOADER_DIR
    apply_patches $ATV_BOOTLOADER_DIR $ATV_BOOTLOADER
    pushd $TOP_DIR
    cd $ATV_BOOTLOADER_DIR

    cp -f ${IMAGES_DIR}/${TARGET_KERNEL_IMAGE-bzImage} vmlinuz || error "can't copy kernel image"
    cp -f ${IMAGES_DIR}/rootfs.img initrd.gz || error "can't copy initrd image"

    make $MAKEARGS P="$DARWIN_TOOLCHAINS_PREFIX" S= || error "build mach_kernel"

    cp -f mach_kernel ${IMAGES_DIR} || error "copy mach_kernel"

    popd
#    touch "$STATE_DIR/atv_bootloader.installed"
}

build_atv_bootloader
