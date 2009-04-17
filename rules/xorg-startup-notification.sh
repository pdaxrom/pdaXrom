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

XORG_STARTUP_NOTIFICATION=startup-notification-0.9.tar.bz2
XORG_STARTUP_NOTIFICATION_MIRROR=http://www.freedesktop.org/software/startup-notification/releases
XORG_STARTUP_NOTIFICATION_DIR=$BUILD_DIR/startup-notification-0.9
XORG_STARTUP_NOTIFICATION_ENV="ac_cv_func_malloc_0_nonnull=yes lf_cv_sane_realloc=yes"

build_xorg_startup_notification() {
    test -e "$STATE_DIR/xorg_startup_notification-0.9" && return
    banner "Build $XORG_STARTUP_NOTIFICATION"
    download $XORG_STARTUP_NOTIFICATION_MIRROR $XORG_STARTUP_NOTIFICATION
    extract $XORG_STARTUP_NOTIFICATION
    apply_patches $XORG_STARTUP_NOTIFICATION_DIR $XORG_STARTUP_NOTIFICATION
    pushd $TOP_DIR
    cd $XORG_STARTUP_NOTIFICATION_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_STARTUP_NOTIFICATION_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 libsn/.libs/libstartup-notification-1.so.0.0.0 $ROOTFS_DIR/usr/lib/libstartup-notification-1.so.0.0.0 || error
    ln -sf libstartup-notification-1.so.0.0.0 $ROOTFS_DIR/usr/lib/libstartup-notification-1.so.0
    ln -sf libstartup-notification-1.so.0.0.0 $ROOTFS_DIR/usr/lib/libstartup-notification-1.so
    $STRIP $ROOTFS_DIR/usr/lib/libstartup-notification-1.so.0.0.0

    popd
    touch "$STATE_DIR/xorg_startup_notification-0.9"
}

build_xorg_startup_notification
