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

USPLASH_VERSION=0.5.33
USPLASH=usplash_${USPLASH_VERSION}.tar.gz
USPLASH_MIRROR=http://launchpad.net/ubuntu/karmic/+source/usplash/0.5.33/+files
USPLASH_DIR=$BUILD_DIR/ubuntu
USPLASH_ENV="$CROSS_ENV_AC"

build_usplash() {
    test -e "$STATE_DIR/usplash.installed" && return
    banner "Build usplash"
    download $USPLASH_MIRROR $USPLASH
    extract $USPLASH
    apply_patches $USPLASH_DIR $USPLASH
    pushd $TOP_DIR
    cd $USPLASH_DIR

    #cp -f $HOST_USPLASH_DIR/bogl/bdftobogl bogl/ || error
    #cp -f $HOST_USPLASH_DIR/bogl/pngtobogl bogl/ || error
    #cp -f $HOST_USPLASH_DIR/bogl/pngtobogl.o bogl/ || error

    make CC=${CROSS}gcc architecture=`get_kernel_subarch` BDFTOBOGL=bdftobogl PNGTOBOGL=pngtobogl CROSS=1 || error
    $INSTALL -D -m 755 usplash $ROOTFS_DIR/sbin/usplash || error
    $STRIP $ROOTFS_DIR/sbin/usplash
    $INSTALL -D -m 755 usplash_write $ROOTFS_DIR/sbin/usplash_write || error
    $STRIP $ROOTFS_DIR/sbin/usplash_write
    $INSTALL -D -m 755 usplash_down $ROOTFS_DIR/sbin/usplash_down || error
    $INSTALL -D -m 644 libusplash.so.0 $ROOTFS_DIR/lib/libusplash.so.0 || error
    ln -sf libusplash.so.0 $ROOTFS_DIR/lib/libusplash.so
    $STRIP $ROOTFS_DIR/lib/libusplash.so.0
    mkdir -p $ROOTFS_DIR/var/lib/usplash
    mkfifo $ROOTFS_DIR/var/lib/usplash/usplash_fifo

    $INSTALL -D -m 644 usplash-theme.h $TARGET_INC/usplash-theme.h || error
    $INSTALL -D -m 644 usplash_backend.h $TARGET_INC/usplash_backend.h || error
    $INSTALL -D -m 644 libusplash.h $TARGET_INC/libusplash.h || error

    make CC=${CROSS}gcc -C example-theme || error
    $INSTALL -D -m 644 example-theme/eft-theme.so $ROOTFS_DIR/usr/lib/usplash/eft-theme.so || error
    $STRIP $ROOTFS_DIR/usr/lib/usplash/eft-theme.so
    ln -sf eft-theme.so $ROOTFS_DIR/usr/lib/usplash/usplash-artwork.so

    popd
    touch "$STATE_DIR/usplash.installed"
}

build_usplash
