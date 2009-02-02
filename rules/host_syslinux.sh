#
# host packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_SYSLINUX=syslinux-3.72.tar.bz2
HOST_SYSLINUX_MIRROR=http://www.kernel.org/pub/linux/utils/boot/syslinux
HOST_SYSLINUX_DIR=$HOST_BUILD_DIR/syslinux-3.72
HOST_SYSLINUX_ENV=

build_host_syslinux() {
    test -e "$STATE_DIR/host_syslinux-3.72" && return
    banner "Build $HOST_SYSLINUX"
    download $HOST_SYSLINUX_MIRROR $HOST_SYSLINUX
    extract_host $HOST_SYSLINUX
    apply_patches $HOST_SYSLINUX_DIR $HOST_SYSLINUX
    pushd $TOP_DIR
    cd $HOST_SYSLINUX_DIR
    make CC=${TARGET_ARCH}-gcc LD=${TARGET_ARCH}-ld OBJDUMP=${TARGET_ARCH}-objdump \
	OBJCOPY=${TARGET_ARCH}-objcopy AR=${TARGET_ARCH}-ar NM=${TARGET_ARCH}-nm \
	RANLIB=${TARGET_ARCH}-ranlib \
	core/isolinux.bin \
	|| error

    $INSTALL -D -m 644 core/isolinux.bin $HOST_BIN_DIR/share/syslinux/isolinux.bin || error

    popd
    touch "$STATE_DIR/host_syslinux-3.72"
}

build_host_syslinux
