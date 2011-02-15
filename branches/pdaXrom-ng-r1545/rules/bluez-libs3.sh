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

BLUEZ_LIBS3_VERSION=3.36
BLUEZ_LIBS3=bluez-libs-${BLUEZ_LIBS3_VERSION}.tar.gz
BLUEZ_LIBS3_MIRROR=http://bluez.sf.net/download
BLUEZ_LIBS3_DIR=$BUILD_DIR/bluez-libs-${BLUEZ_LIBS3_VERSION}
BLUEZ_LIBS3_ENV="$CROSS_ENV_AC"

build_bluez_libs3() {
    test -e "$STATE_DIR/bluez_libs3.installed" && return
    banner "Build bluez-libs3"
    download $BLUEZ_LIBS3_MIRROR $BLUEZ_LIBS3
    extract $BLUEZ_LIBS3
    apply_patches $BLUEZ_LIBS3_DIR $BLUEZ_LIBS3
    pushd $TOP_DIR
    cd $BLUEZ_LIBS3_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$BLUEZ_LIBS3_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 src/.libs/libbluetooth.so.2.11.2 $ROOTFS_DIR/usr/lib/libbluetooth.so.2.11.2 || error
    ln -sf libbluetooth.so.2.11.2 $ROOTFS_DIR/usr/lib/libbluetooth.so.2
    ln -sf libbluetooth.so.2.11.2 $ROOTFS_DIR/usr/lib/libbluetooth.so
    $STRIP $ROOTFS_DIR/usr/lib/libbluetooth.so.2.11.2 || error

    popd
    touch "$STATE_DIR/bluez_libs3.installed"
}

build_bluez_libs3
