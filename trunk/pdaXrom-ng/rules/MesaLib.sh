#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

MESALIB_VERSION=7.9
MESALIB=MesaLib-${MESALIB_VERSION}.tar.bz2
MESALIB_GLUT=MesaGLUT-${MESALIB_VERSION}.tar.bz2
#MESALIB_DEMOS=MesaDemos-${MESALIB_VERSION}.tar.bz2
MESALIB_MIRROR=ftp://ftp.freedesktop.org/pub/mesa/${MESALIB_VERSION}
MESALIB_DIR=$BUILD_DIR/Mesa-${MESALIB_VERSION}
MESALIB_ENV="$CROSS_ENV_AC"

build_MesaLib() {
    test -e "$STATE_DIR/MesaLib.installed" && return
    banner "Build MesaLib"
    download $MESALIB_MIRROR $MESALIB
    download $MESALIB_MIRROR $MESALIB_GLUT
#    download $MESALIB_MIRROR $MESALIB_DEMOS
    extract $MESALIB
    extract $MESALIB_GLUT
#    extract $MESALIB_DEMOS
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
	    --enable-gallium \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    if [ ! -e src/mesa/gl.pc ]; then
	make -C src/mesa gl.pc INSTALL_DIR=$TARGET_BIN_DIR || error "make gl.pc"
	$INSTALL -D -m 644 src/mesa/gl.pc $TARGET_LIB/pkgconfig/gl.pc || error "install gl.pc"
    fi

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/MesaLib.installed"
}

build_MesaLib
