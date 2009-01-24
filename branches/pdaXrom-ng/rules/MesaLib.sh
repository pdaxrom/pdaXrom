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

MESALIB=MesaLib-7.3.tar.bz2
MESALIB_MIRROR=http://downloads.sourceforge.net/mesa3d
MESALIB_DIR=$BUILD_DIR/Mesa-7.3
MESALIB_ENV="$CROSS_ENV_AC MKLIB_OPTIONS='-arch Linux'"

build_MesaLib_thud() {
    case $TARGET_ARCH in
    arm*|xscale*)
	echo "linux-arm"
	;;
    ppc*|powerpc*)
	echo "linux-ppc"
	;;
    i*86*)
	echo "linux-dri-x86"
	;;
    x86_64*|amd64*)
	echo "linux-dri-x86-64"
	;;
    *)
	echo "linux-dri"
	;;
    esac
}

build_MesaLib() {
    test -e "$STATE_DIR/MesaLib.installed" && return
    banner "Build MesaLib"
    download $MESALIB_MIRROR $MESALIB
    extract $MESALIB
    apply_patches $MESALIB_DIR $MESALIB
    pushd $TOP_DIR
    cd $MESALIB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MESALIB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS CROSS=${CROSS} || error

    install_sysroot_files || error

    $INSTALL -D -m 644 lib/libGL.so.1.2 $ROOTFS_DIR/usr/lib/libGL.so.1.2 || error
    ln -sf libGL.so.1.2 $ROOTFS_DIR/usr/lib/libGL.so.1
    ln -sf libGL.so.1.2 $ROOTFS_DIR/usr/lib/libGL.so
    $STRIP $ROOTFS_DIR/usr/lib/libGL.so.1.2
    
    $INSTALL -D -m 644 lib/libGLU.so.1.3.070300 $ROOTFS_DIR/usr/lib/libGLU.so.1.3.070300 || error
    ln -sf libGLU.so.1.3.070300 $ROOTFS_DIR/usr/lib/libGLU.so.1
    ln -sf libGLU.so.1.3.070300 $ROOTFS_DIR/usr/lib/libGLU.so
    $STRIP $ROOTFS_DIR/usr/lib/libGLU.so.1.3.070300
    
    $INSTALL -D -m 644 lib/libGLw.so.1.0.0 $ROOTFS_DIR/usr/lib/libGLw.so.1.0.0 || error
    ln -sf libGLw.so.1.0.0 $ROOTFS_DIR/usr/lib/libGLw.so.1
    ln -sf libGLw.so.1.0.0 $ROOTFS_DIR/usr/lib/libGLw.so
    $STRIP $ROOTFS_DIR/usr/lib/libGLw.so.1.0.0

    cd lib
    for f in *_dri.so; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/lib/dri/$f
	$STRIP $ROOTFS_DIR/usr/lib/dri/$f
    done

    popd
    touch "$STATE_DIR/MesaLib.installed"
}

build_MesaLib
