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

PETITBOOT=petitboot-0.2.tar.gz
PETITBOOT_MIRROR=http://ozlabs.org/~jk/projects/petitboot/downloads
PETITBOOT_DIR=$BUILD_DIR/petitboot-0.2
PETITBOOT_ENV="$CROSS_ENV_AC"

build_petitboot() {
    test -e "$STATE_DIR/petitboot.installed" && return
    banner "Build petitboot"
    download $PETITBOOT_MIRROR $PETITBOOT
    extract $PETITBOOT
    apply_patches $PETITBOOT_DIR $PETITBOOT
    pushd $TOP_DIR
    cd $PETITBOOT_DIR

    make $MAKEARGS CC=${CROSS}gcc || error

    for f in petitboot petitboot-udev-helper; do
	$INSTALL -D -m 755 $f $ROOTFS_DIR/usr/sbin/$f || error
	$STRIP $ROOTFS_DIR/usr/sbin/$f || error
    done

    for f in artwork/*.*; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/share/petitboot/$f || error
    done

    $INSTALL -D -m 644 utils/99-petitboot.rules $ROOTFS_DIR/etc/udev/rules.d/99-petitboot.rules || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/petitboot $ROOTFS_DIR/etc/init.d/petitboot || error
    install_rc_start petitboot 50

    popd
    touch "$STATE_DIR/petitboot.installed"
}

build_petitboot
