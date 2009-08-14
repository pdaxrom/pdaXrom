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

PTLIB_VERSION=2.6.4
PTLIB=ptlib-${PTLIB_VERSION}.tar.bz2
PTLIB_MIRROR=http://www.ekiga.org/admin/downloads/latest/sources/ekiga_3.2.5
PTLIB_DIR=$BUILD_DIR/ptlib-${PTLIB_VERSION}
PTLIB_ENV="$CROSS_ENV_AC"

build_ptlib() {
    test -e "$STATE_DIR/ptlib.installed" && return
    banner "Build ptlib"
    download $PTLIB_MIRROR $PTLIB
    extract $PTLIB
    apply_patches $PTLIB_DIR $PTLIB
    pushd $TOP_DIR
    cd $PTLIB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PTLIB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-v4l2 \
	    --enable-v4l \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf $TARGET_BIN_DIR/bin/ptlib-config $HOST_BIN_DIR/bin/

    make $MAKEARGS DESTDIR=${PTLIB_DIR}/fakeroot install || error
    rm -rf fakeroot/usr/lib/pkgconfig
    rm -f fakeroot/usr/lib/*.*a

    find fakeroot/usr/lib ! -type d -a ! -type l | xargs $STRIP
    cp -a fakeroot/usr/lib $ROOTFS_DIR/usr || error

    popd
    touch "$STATE_DIR/ptlib.installed"
}

build_ptlib
