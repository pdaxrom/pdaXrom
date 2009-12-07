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

PS3BOOT=ps3boot-svn
PS3BOOT_SVN=http://pdaxrom.svn.sourceforge.net/svnroot/pdaxrom/trunk/ps3boot
PS3BOOT_DIR=$BUILD_DIR/${PS3BOOT}
PS3BOOT_ENV="$CROSS_ENV_AC"
PS3BOOT_VERSION=r`cd $PS3BOOT_DIR && LANG=en_US svn info 2>&1 | grep Revision | awk '{print $2}'`

build_ps3boot() {
    test -e "$STATE_DIR/${PS3BOOT}.installed" && return
    banner "Build ps3boot"
    download_svn $PS3BOOT_SVN $PS3BOOT
    cp -R $SRC_DIR/$PS3BOOT $PS3BOOT_DIR
    apply_patches $PS3BOOT_DIR $PS3BOOT
    pushd $TOP_DIR
    cd $PS3BOOT_DIR

    local MODE=
    grep -q "^CONFIG_PPC_PS3=y" ${KERNEL_DIR}/.config || MODE="pc"

    make $MAKEARGS CC=${CROSS}gcc SYSTEM=linuxfb DATADIR=/usr/share/ps3boot MODE=$MODE  || error

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
    touch "$STATE_DIR/${PS3BOOT}.installed"
}

build_ps3boot
