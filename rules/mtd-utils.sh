#
# packet template
#
# Copyright (C) 2009 by Adrian Crutchfield <insearchof@inventgen-solutions.com>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

MTD_UTILS_VERSION=1.2.0
MTD_UTILS=mtd-utils-${MTD_UTILS_VERSION}.tar.bz2
MTD_UTILS_MIRROR=http://ftp.cross-lfs.org/pub/clfs/conglomeration/mtd-utils/
MTD_UTILS_DIR=$BUILD_DIR/mtd-utils-${MTD_UTILS_VERSION}
MTD_UTILS_ENV="$CROSS_ENV_AC"
UBI_MTD_UTILS_DIR=$BUILD_DIR/mtd-utils-${MTD_UTILS_VERSION}/ubi-utils/
UBI_MTD_UTILS_ENV="$CROSS_ENV_AC"

build_mtd_utils() {
    test -e "$STATE_DIR/mtd_utils.installed" && return
    banner "Build mtd-utils"
    download $MTD_UTILS_MIRROR $MTD_UTILS
    extract $MTD_UTILS
    apply_patches $MTD_UTILS_DIR $MTD_UTILS
    pushd $TOP_DIR
    cd $MTD_UTILS_DIR
#    (
#    eval \
#	$CROSS_CONF_ENV \
#	$MTD_UTILS_ENV \
#	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
#	    --prefix=/usr \
#	    --sysconfdir=/etc \
#	    || error
#   ) || error "configure"

# I NEED TO FIX THIS... It works... but it SUCKS!!!!!!!!!!!!!!!!!!!

    make $MAKEARGS CC=${CROSS}gcc -C $MTD_UTILS_DIR flash_eraseall CFLAGS="-I$KERNEL_DIR/arch/arm/include" || error
    make $MAKEARGS CC=${CROSS}gcc -C $MTD_UTILS_DIR nandwrite CFLAGS="-I$KERNEL_DIR/arch/arm/include" || error

    $INSTALL -D -m 755 $MTD_UTILS_DIR/flash_eraseall $ROOTFS_DIR/bin/
    $INSTALL -D -m 755 $MTD_UTILS_DIR/nandwrite $ROOTFS_DIR/bin/
    popd
    touch "$STATE_DIR/mtd_utils.installed"
}
build_ubi_mtd_utils() {
    test -e "$STATE_DIR/mtd_ubi-utils.installed" && return
    banner "Build ubi-utils"
    pushd $TOP_DIR
    cd $UBI_MTD_UTILS_DIR
#    (
#    eval \
#       $CROSS_CONF_ENV \
#       $MTD_UTILS_ENV \
#       ./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
#           --prefix=/usr \
#           --sysconfdir=/etc \
#           || error
#   ) || error "configure"


    make $MAKEARGS CC=${CROSS}gcc || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/mtd_ubi-utils.installed"
}

build_mtd_utils
build_ubi_mtd_utils
