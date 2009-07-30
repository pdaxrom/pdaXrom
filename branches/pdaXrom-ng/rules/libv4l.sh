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

LIBV4L_VERSION=0.6.0
LIBV4L=libv4l-${LIBV4L_VERSION}.tar.gz
LIBV4L_MIRROR=http://people.atrpms.net/~hdegoede
LIBV4L_DIR=$BUILD_DIR/libv4l-${LIBV4L_VERSION}
LIBV4L_ENV="$CROSS_ENV_AC"

build_libv4l() {
    test -e "$STATE_DIR/libv4l.installed" && return
    banner "Build libv4l"
    download $LIBV4L_MIRROR $LIBV4L
    extract $LIBV4L
    apply_patches $LIBV4L_DIR $LIBV4L
    pushd $TOP_DIR
    cd $LIBV4L_DIR
    
    make $MAKEARGS CC=${CROSS}gcc CXX=${CROSS}g++  || error

    install_sysroot_files || error 
    
    make $MAKEARGS CC=${CROSS}gcc CXX=${CROSS}g++ DESTDIR=${LIBV4L_DIR}/fakeroot install || error
    rm -rf fakeroot/usr/include fakeroot/usr/lib/pkgconfig
    
    find fakeroot/ -executable -a ! -type d -a ! -type l | xargs $STRIP

    cp -a fakeroot/usr/lib $ROOTFS_DIR/usr || error

    popd
    touch "$STATE_DIR/libv4l.installed"
}

build_libv4l
