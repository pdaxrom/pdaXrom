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

FNKEY_YEELOONG2F_VERSION=2.6.30.5
FNKEY_YEELOONG2F=fnkey-yeeloong2f-${FNKEY_YEELOONG2F_VERSION}.tar.bz2
FNKEY_YEELOONG2F_MIRROR=http://mail.pdaxrom.org/downloads/lemote/src
FNKEY_YEELOONG2F_DIR=$BUILD_DIR/fnkey-yeeloong2f-${FNKEY_YEELOONG2F_VERSION}
FNKEY_YEELOONG2F_ENV="$CROSS_ENV_AC"

build_fnkey_yeeloong2f() {
    test -e "$STATE_DIR/fnkey_yeeloong2f.installed" && return
    banner "Build fnkey-yeeloong2f"
    download $FNKEY_YEELOONG2F_MIRROR $FNKEY_YEELOONG2F
    extract $FNKEY_YEELOONG2F
    apply_patches $FNKEY_YEELOONG2F_DIR $FNKEY_YEELOONG2F
    pushd $TOP_DIR
    cd $FNKEY_YEELOONG2F_DIR

    make $MAKEARGS CC=${CROSS}gcc OPT_LDFLAGS="-Wl,-rpath,${TARGET_LIB}" || error

    $INSTALL -D -m 755 fnkey $ROOTFS_DIR/usr/bin/fnkey || error "install fnkey"
    $STRIP $ROOTFS_DIR/usr/bin/fnkey
    $INSTALL -D -m 644 fnkey.conf $ROOTFS_DIR/etc/fnkey/fnkey.conf
    $INSTALL -D -m 644 default.sh $ROOTFS_DIR/etc/fnkey/default.sh

    echo "test -e /usr/bin/fnkey && fnkey" > ${ROOTFS_DIR}/etc/X11/Xsession.d/10_fnkeylemote

    popd
    touch "$STATE_DIR/fnkey_yeeloong2f.installed"
}

build_fnkey_yeeloong2f
