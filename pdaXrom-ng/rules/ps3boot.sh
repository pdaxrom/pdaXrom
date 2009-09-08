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

PS3BOOT_VERSION=0.1.2
PS3BOOT=ps3boot-${PS3BOOT_VERSION}.tar.bz2
PS3BOOT_MIRROR=http://mail.pdaxrom.org/downloads/PS3/bootloader/src
PS3BOOT_DIR=$BUILD_DIR/ps3boot-${PS3BOOT_VERSION}
PS3BOOT_ENV="$CROSS_ENV_AC"

build_ps3boot() {
    test -e "$STATE_DIR/ps3boot-${PS3BOOT_VERSION}.installed" && return
    banner "Build ps3boot"
    download $PS3BOOT_MIRROR $PS3BOOT
    extract $PS3BOOT
    apply_patches $PS3BOOT_DIR $PS3BOOT
    pushd $TOP_DIR
    cd $PS3BOOT_DIR
    
    make $MAKEARGS CC=${CROSS}gcc SYSTEM=linuxfb DATADIR=/usr/share/ps3boot || error
    
    $INSTALL -D -m 755 ps3boot $ROOTFS_DIR/usr/sbin/ps3boot || error
    $STRIP $ROOTFS_DIR/usr/sbin/ps3boot

    $INSTALL -D -m 755 ps3boot-udev $ROOTFS_DIR/usr/sbin/ps3boot-udev || error
    $STRIP $ROOTFS_DIR/usr/sbin/ps3boot-udev
    
    for f in artwork/*.* fonts/Vera.ttf; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/share/ps3boot/$f || error
    done

    $INSTALL -D -m 644 utils/99-ps3boot.rules $ROOTFS_DIR/etc/udev/rules.d/99-ps3boot.rules || error
    $INSTALL -D -m 755 utils/ps3boot $ROOTFS_DIR/etc/init.d/ps3boot || error
    install_rc_start ps3boot 50

    popd
    touch "$STATE_DIR/ps3boot-${PS3BOOT_VERSION}.installed"
}

build_ps3boot
