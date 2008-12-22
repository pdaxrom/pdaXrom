#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

PS3_UTILS=ps3-utils-2.3.tar.bz2
PS3_UTILS_MIRROR=http://www.kernel.org/pub/linux/kernel/people/geoff/cell/ps3-utils
PS3_UTILS_DIR=$BUILD_DIR/ps3-utils-2.3
PS3_UTILS_ENV=

build_ps3_utils() {
    test -e "$STATE_DIR/ps3_utils-2.3" && return
    banner "Build $PS3_UTILS"
    download $PS3_UTILS_MIRROR $PS3_UTILS
    extract $PS3_UTILS
    apply_patches $PS3_UTILS_DIR $PS3_UTILS
    pushd $TOP_DIR
    cd $PS3_UTILS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PS3_UTILS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 .libs/ps3-video-mode $ROOTFS_DIR/usr/bin/ps3-video-mode
    $STRIP $ROOTFS_DIR/usr/bin/ps3-video-mode

    $INSTALL -D -m 755 .libs/ps3-flash-util $ROOTFS_DIR/usr/sbin/ps3-flash-util
    $STRIP $ROOTFS_DIR/usr/sbin/ps3-flash-util

    $INSTALL -m 755 ps3-boot-game-os ps3-dump-bootloader ps3-rtc-init $ROOTFS_DIR/usr/sbin/
    
    $INSTALL -D -m 644 lib/.libs/libps3-utils.so.2.0.0 $ROOTFS_DIR/usr/lib/libps3-utils.so.2.0.0
    ln -s libps3-utils.so.2.0.0 $ROOTFS_DIR/usr/lib/libps3-utils.so.2
    ln -s libps3-utils.so.2.0.0 $ROOTFS_DIR/usr/lib/libps3-utils.so
    $STRIP $ROOTFS_DIR/usr/lib/libps3-utils.so.2.0.0

    popd
    touch "$STATE_DIR/ps3_utils-2.3"
}

build_ps3_utils
