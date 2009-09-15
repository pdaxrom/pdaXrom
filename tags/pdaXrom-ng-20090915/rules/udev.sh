#
# packet template
#
# Copyright (C) 2004 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

UDEV=udev-135.tar.bz2
UDEV_MIRROR=http://www.kernel.org/pub/linux/utils/kernel/hotplug
UDEV_DIR=$BUILD_DIR/udev-135
UDEV_ENV=

build_udev() {
    test -e "$STATE_DIR/udev-135" && return
    banner "Build $UDEV"
    download $UDEV_MIRROR $UDEV
    extract $UDEV
    apply_patches $UDEV_DIR $UDEV
    pushd $TOP_DIR
    cd $UDEV_DIR
    eval $UDEV_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/ \
	    --sysconfdir=/etc || error

    make $MAKEARGS || error

    sed -i "s|=/|=$TARGET_BIN_DIR|" extras/volume_id/lib/libvolume_id.pc
    sed -i "s|=/|=$TARGET_BIN_DIR|" udev/lib/libudev.pc

    install_sysroot_files || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/udev $ROOTFS_DIR/etc/init.d/udev || error

    if [ "$USE_FASTBOOT" = "yes" ]; then
	install_rc_start udev 04
    else
	install_rc_start udev 00
    fi
    install_rc_stop  udev 97

    $INSTALL -D -m 644 $GENERICFS_DIR/etc/udev/udev.conf  $ROOTFS_DIR/etc/udev/udev.conf || error
    $INSTALL -D -m 644 $GENERICFS_DIR/etc/udev/links.conf $ROOTFS_DIR/etc/udev/links.conf || error

    make DESTDIR=$UDEV_DIR/fakeroot install || error
    rm -rf fakeroot/include fakeroot/lib/pkgconfig fakeroot/share
    
    find fakeroot/ -executable -a ! -type d -a ! -type l | while read f; do
	$STRIP $f
    done

    cp -R fakeroot/etc  $ROOTFS_DIR/ || error
    cp -R fakeroot/lib  $ROOTFS_DIR/ || error
    cp -R fakeroot/sbin $ROOTFS_DIR/ || error

    $INSTALL -D -m 644 rules/packages/40-alsa.rules $ROOTFS_DIR/lib/udev/rules.d/40-alsa.rules || error

    $INSTALL -D -m 644 $GENERICFS_DIR/etc/udev/rules.d/85-net.rules $ROOTFS_DIR/etc/udev/rules.d/85-net.rules || error
    $INSTALL -D -m 755 $GENERICFS_DIR/etc/udev/scripts/net.sh $ROOTFS_DIR/etc/udev/scripts/net.sh || error

    #mkdir -p $ROOTFS_DIR/etc/init.d
    #mkdir -p $ROOTFS_DIR/etc/udev/rules.d
    #mkdir -p $ROOTFS_DIR/etc/udev/scripts
    #mkdir -p $ROOTFS_DIR/sbin
    #$INSTALL -m 755 udev/udevd udev/udevadm $ROOTFS_DIR/sbin/
    #$INSTALL -m 644 $GENERICFS_DIR/etc/udev/udev.conf  $ROOTFS_DIR/etc/udev/
    #$INSTALL -m 644 $GENERICFS_DIR/etc/udev/links.conf $ROOTFS_DIR/etc/udev/
    #$INSTALL -m 644 $GENERICFS_DIR/etc/udev/rules.d/udev.rules $ROOTFS_DIR/etc/udev/rules.d/

    #$INSTALL -D -m 755 extras/volume_id/.libs/vol_id $ROOTFS_DIR/lib/udev/vol_id || error
    #$STRIP $ROOTFS_DIR/lib/udev/vol_id

    #$INSTALL -D -m 644 extras/volume_id/lib/.libs/libvolume_id.so.1.0.6 $ROOTFS_DIR/lib/libvolume_id.so.1.0.6 || error
    #ln -sf libvolume_id.so.1.0.6 $ROOTFS_DIR/lib/libvolume_id.so.1
    #$STRIP $ROOTFS_DIR/lib/libvolume_id.so.1.0.6

    #for f in $GENERICFS_DIR/etc/udev/scripts/*; do
    #	$INSTALL -m 755 $f $ROOTFS_DIR/etc/udev/scripts/
    #done

    popd
    touch "$STATE_DIR/udev-135"
}

build_udev
