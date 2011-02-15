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

VMAC_VERSION=0.1.9.3
VMAC=vMac-${VMAC_VERSION}-src.tgz
VMAC_MIRROR=http://www.leb.net/vmac/download/XWindows
VMAC_DIR=$BUILD_DIR/vMac-${VMAC_VERSION}
VMAC_ENV="$CROSS_ENV_AC"

build_vMac() {
    test -e "$STATE_DIR/vMac.installed" && return
    banner "Build vMac"
    download $VMAC_MIRROR $VMAC
    extract $VMAC
    apply_patches $VMAC_DIR $VMAC
    pushd $TOP_DIR
    cd $VMAC_DIR
    autoreconf -i || error "autoreconf"
    (
    eval \
	$CROSS_CONF_ENV \
	$VMAC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-sdl \
	    || error
    ) || error "configure"

    make HOST_CC=gcc || error

    $INSTALL -D -m 755 vMac ${ROOTFS_DIR}/usr/bin/vMac || error
    $STRIP ${ROOTFS_DIR}/usr/bin/vMac
    $INSTALL -D -m 755 ${GENERICFS_DIR}/vMac/vMac-fb ${ROOTFS_DIR}/usr/bin/vMac-fb

    popd
    touch "$STATE_DIR/vMac.installed"
}

build_vMac
