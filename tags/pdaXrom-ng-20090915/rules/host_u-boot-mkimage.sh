#
# host packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_U_BOOT_MKIMAGE_VERSION=1.1.6
HOST_U_BOOT_MKIMAGE=u-boot-mkimage-${HOST_U_BOOT_MKIMAGE_VERSION}.tar.bz2
HOST_U_BOOT_MKIMAGE_MIRROR=http://www.pengutronix.de/software/ptxdist/temporary-src
HOST_U_BOOT_MKIMAGE_DIR=$HOST_BUILD_DIR/u-boot-mkimage-${HOST_U_BOOT_MKIMAGE_VERSION}
HOST_U_BOOT_MKIMAGE_ENV=

build_host_u_boot_mkimage() {
    test -e "$STATE_DIR/host_u_boot_mkimage.installed" && return
    banner "Build host-u-boot-mkimage"
    download $HOST_U_BOOT_MKIMAGE_MIRROR $HOST_U_BOOT_MKIMAGE
    extract_host $HOST_U_BOOT_MKIMAGE
    apply_patches $HOST_U_BOOT_MKIMAGE_DIR $HOST_U_BOOT_MKIMAGE
    pushd $TOP_DIR
    cd $HOST_U_BOOT_MKIMAGE_DIR
    make $MAKEARGS || error

    install -D -m 755 mkimage $HOST_BIN_DIR/bin/mkimage || error

    popd
    touch "$STATE_DIR/host_u_boot_mkimage.installed"
}

build_host_u_boot_mkimage
