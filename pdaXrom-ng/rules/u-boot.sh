#
# packet template
#
# Copyright (C) 2009 by Adrian Crutchfield <insearchof@pdaxrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

U_BOOT_VERSION=${U_BOOT_VERSION-2009.08}
U_BOOT=u-boot-${U_BOOT_VERSION}.tar.bz2
U_BOOT_MIRROR=ftp://ftp.denx.de/pub/u-boot
U_BOOT_DIR=$BUILD_DIR/u-boot-${U_BOOT_VERSION}
U_BOOT_ENV="$CROSS_ENV_AC"
CROSS_COMPILE=${TARGET_ARCH}-

if [ $U_BOOT_VERSION = "2006-04-18-1106" ];then
U_BOOT_MIRROR=http://distro.ibiblio.org/pub/linux/distributions/pdaxrom/src
fi

if [ "x$U_BOOT_CONFIG" = "x" ]; then
    error "No U-BOOT config defined!"
fi

build_u_boot() {
    test -e "$STATE_DIR/u_boot.installed" && return
    banner "Build U-Boot"
    download $U_BOOT_MIRROR $U_BOOT
    extract $U_BOOT
    apply_patches $U_BOOT_DIR $U_BOOT
    pushd $TOP_DIR
    cd $U_BOOT_DIR

    make ${U_BOOT_CONFIG}_config || error "configure uboot"
    make CROSS_COMPILE=${TARGET_ARCH}- || error "uboot build"

    cp u-boot.bin $ROOTFS_DIR $IMAGES_DIR/

    popd

    touch "$STATE_DIR/u_boot.installed"
}

build_u_boot
