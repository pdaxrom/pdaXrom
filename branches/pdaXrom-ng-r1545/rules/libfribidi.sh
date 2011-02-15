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

LIBFRIBIDI=fribidi-0.10.9.tar.gz
LIBFRIBIDI_MIRROR=http://fribidi.org/download
LIBFRIBIDI_DIR=$BUILD_DIR/fribidi-0.10.9
LIBFRIBIDI_ENV="$CROSS_ENV_AC"

build_libfribidi() {
    test -e "$STATE_DIR/libfribidi.installed" && return
    banner "Build libfribidi"
    download $LIBFRIBIDI_MIRROR $LIBFRIBIDI
    extract $LIBFRIBIDI
    apply_patches $LIBFRIBIDI_DIR $LIBFRIBIDI
    pushd $TOP_DIR
    cd $LIBFRIBIDI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBFRIBIDI_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    ln -sf $TARGET_BIN_DIR/bin/fribidi-config $HOST_BIN_DIR/bin/ || error
    
    $INSTALL -D -m 644 .libs/libfribidi.so.0.0.0 $ROOTFS_DIR/usr/lib/libfribidi.so.0.0.0 || error
    ln -sf libfribidi.so.0.0.0 $ROOTFS_DIR/usr/lib/libfribidi.so.0
    ln -sf libfribidi.so.0.0.0 $ROOTFS_DIR/usr/lib/libfribidi.so
    $STRIP $ROOTFS_DIR/usr/lib/libfribidi.so.0.0.0

    popd
    touch "$STATE_DIR/libfribidi.installed"
}

build_libfribidi
