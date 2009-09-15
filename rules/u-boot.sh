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

U_BOOT_VERSION=2006-04-18-1106
U_BOOT=u-boot-${U_BOOT_VERSION}.tar.bz2
U_BOOT_MIRROR=http://mail.pdaxrom.org/src/
U_BOOT_DIR=$BUILD_DIR/u-boot-${U_BOOT_VERSION}
U_BOOT_ENV="$CROSS_ENV_AC"
CROSS_COMPILE=${TARGET_ARCH}-

build_u_boot() {
    test -e "$STATE_DIR/u_boot.installed" && return
    banner "Build U-Boot"
    download $U_BOOT_MIRROR $U_BOOT
    extract $U_BOOT
    apply_patches $U_BOOT_DIR $U_BOOT
    pushd $TOP_DIR
    cd $U_BOOT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$U_BOOT_ENV 
   ) 
    make $U_BOOT_CONFIG
    make -C $U_BOOT_DIR CROSS_COMPILE=${TARGET_ARCH}- 
 
    popd
    cp $U_BOOT_DIR/u-boot.bin $ROOTFS_DIR $IMAGES_DIR/
    touch "$STATE_DIR/u_boot.installed"
}

build_u_boot
