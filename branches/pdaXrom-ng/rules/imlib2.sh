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

IMLIB2=imlib2-1.4.2.tar.bz2
IMLIB2_MIRROR=http://downloads.sourceforge.net/enlightenment
IMLIB2_DIR=$BUILD_DIR/imlib2-1.4.2
IMLIB2_ENV="$CROSS_ENV_AC"

build_imlib2() {
    test -e "$STATE_DIR/imlib2.installed" && return
    banner "Build imlib2"
    download $IMLIB2_MIRROR $IMLIB2
    extract $IMLIB2
    apply_patches $IMLIB2_DIR $IMLIB2
    pushd $TOP_DIR
    cd $IMLIB2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$IMLIB2_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --with-jpeg \
	    --with-png \
	    --with-zlib \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 src/lib/.libs/libImlib2.so.1.4.2 $ROOTFS_DIR/usr/lib/libImlib2.so.1.4.2 || error
    ln -sf libImlib2.so.1.4.2 $ROOTFS_DIR/usr/lib/libImlib2.so.1
    ln -sf libImlib2.so.1.4.2 $ROOTFS_DIR/usr/lib/libImlib2.so
    $STRIP $ROOTFS_DIR/usr/lib/libImlib2.so.1.4.2

    mkdir -p $ROOTFS_DIR/usr/lib/imlib2/filters
    mkdir -p $ROOTFS_DIR/usr/lib/imlib2/loaders

    find src/modules/filters/.libs -name "*.so" | while read f; do
	$INSTALL -m 644 $f $ROOTFS_DIR/usr/lib/imlib2/filters/ || error "install filters"
	$STRIP $ROOTFS_DIR/usr/lib/imlib2/filters/${f/*\//}
    done

    find src/modules/loaders/.libs -name "*.so" | while read f; do
	$INSTALL -m 644 $f $ROOTFS_DIR/usr/lib/imlib2/loaders/ || error "install loaders"
	$STRIP $ROOTFS_DIR/usr/lib/imlib2/loaders/${f/*\//}
    done

    ln -sf $TARGET_BIN_DIR/bin/imlib2-config $HOST_BIN_DIR/bin/ || error

    popd
    touch "$STATE_DIR/imlib2.installed"
}

build_imlib2
