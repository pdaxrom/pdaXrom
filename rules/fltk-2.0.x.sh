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

FLTK_2_0_X_VERSION=r6970
FLTK_2_0_X=fltk-2.0.x-${FLTK_2_0_X_VERSION}.tar.bz2
FLTK_2_0_X_MIRROR=http://ftp.rz.tu-bs.de/pub/mirror/ftp.easysw.com/ftp/pub/fltk/snapshots
FLTK_2_0_X_DIR=$BUILD_DIR/fltk-2.0.x-${FLTK_2_0_X_VERSION}
FLTK_2_0_X_ENV="$CROSS_ENV_AC"

build_fltk_2_0_x() {
    test -e "$STATE_DIR/fltk_2_0_x.installed" && return
    banner "Build fltk-2.0.x"
    download $FLTK_2_0_X_MIRROR $FLTK_2_0_X
    extract $FLTK_2_0_X
    apply_patches $FLTK_2_0_X_DIR $FLTK_2_0_X
    pushd $TOP_DIR
    cd $FLTK_2_0_X_DIR
    sed -i 's|uname=`uname`|uname=Linux|g' configure || error
    sed -i "s|= strip|= ${CROSS}strip|g" makeinclude.in || error
    (
    eval \
	$CROSS_CONF_ENV \
	$FLTK_2_0_X_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-shared \
	    || error
    ) || error "configure"
    
    make $MAKEARGS LD=${CROSS}g++ CC=${CROSS}gcc CXX=${CROSS}g++ || error

    install_sysroot_files || error

    ln -sf $TARGET_BIN_DIR/bin/fltk2-config $HOST_BIN_DIR/bin/fltk2-config || error

    for f in libfltk2_gl  libfltk2_glut  libfltk2_images  libfltk2 ; do
	$INSTALL -D -m 644 lib/$f.so.2.0 $ROOTFS_DIR/usr/lib/$f.so.2.0 || error
	ln -sf $f.so.2.0 $ROOTFS_DIR/usr/lib/$f.so
	$STRIP $ROOTFS_DIR/usr/lib/$f.so.2.0 || error
    done

    popd
    touch "$STATE_DIR/fltk_2_0_x.installed"
}

build_fltk_2_0_x
