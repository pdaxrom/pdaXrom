BUSYBOX_VERSION=1.13.2
BUSYBOX=busybox-${BUSYBOX_VERSION}.tar.bz2
BUSYBOX_MIRROR=http://busybox.net/downloads
BUSYBOX_DIR=$BUILD_DIR/busybox-${BUSYBOX_VERSION}
if [ "x$BUSYBOX_CONFIG" = "x" ]; then
    BUSYBOX_CONFIG=busybox_config
fi

build_busybox() {
    test -e "$STATE_DIR/busybox" && return
    banner "Build $BUSYBOX"
    download $BUSYBOX_MIRROR $BUSYBOX
    extract $BUSYBOX
    apply_patches $BUSYBOX_DIR $BUSYBOX
    cp $CONFIG_DIR/busybox/$BUSYBOX_CONFIG $BUSYBOX_DIR/.config || error "check busybox config file"
    pushd $TOP_DIR
    cd $BUSYBOX_DIR
    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`
    make SUBARCH=$SUBARCH CROSS_COMPILE=$TARGET_ARCH- $MAKEARGS oldconfig|| error
    make SUBARCH=$SUBARCH CROSS_COMPILE=$TARGET_ARCH- $MAKEARGS || error
    make SUBARCH=$SUBARCH CROSS_COMPILE=$TARGET_ARCH- $MAKEARGS CONFIG_PREFIX=$ROOTFS_DIR install || error

    #
    # no shutdown in busybox, add simple script for it
    #
    test -e $ROOTFS_DIR/sbin/shutdown || $INSTALL -D -m 755 $GENERICFS_DIR/shutdown $ROOTFS_DIR/sbin/shutdown || error

#    if [ -e $ROOTFS_DIR/sbin/udhcpc ]; then
#	mkdir -p $ROOTFS_DIR/usr/share/udhcpc
#	$INSTALL -m 755 examples/udhcp/simple.script $ROOTFS_DIR/usr/share/udhcpc/default.script
#    fi
    popd
    touch "$STATE_DIR/busybox"
}

build_busybox
