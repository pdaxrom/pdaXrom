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

LIBSAMPLERATE=libsamplerate-0.1.4.tar.gz
LIBSAMPLERATE_MIRROR=http://www.mega-nerd.com/SRC
LIBSAMPLERATE_DIR=$BUILD_DIR/libsamplerate-0.1.4
LIBSAMPLERATE_ENV="$CROSS_ENV_AC"

build_libsamplerate() {
    test -e "$STATE_DIR/libsamplerate.installed" && return
    banner "Build libsamplerate"
    download $LIBSAMPLERATE_MIRROR $LIBSAMPLERATE
    extract $LIBSAMPLERATE
    apply_patches $LIBSAMPLERATE_DIR $LIBSAMPLERATE
    pushd $TOP_DIR
    cd $LIBSAMPLERATE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBSAMPLERATE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libsamplerate.so.0.1.4 $ROOTFS_DIR/usr/lib/libsamplerate.so.0.1.4 || error
    ln -sf libsamplerate.so.0.1.4 $ROOTFS_DIR/usr/lib/libsamplerate.so.0
    ln -sf libsamplerate.so.0.1.4 $ROOTFS_DIR/usr/lib/libsamplerate.so
    $STRIP $ROOTFS_DIR/usr/lib/libsamplerate.so.0.1.4 || error

    popd
    touch "$STATE_DIR/libsamplerate.installed"
}

build_libsamplerate
