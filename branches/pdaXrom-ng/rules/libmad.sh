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

LIBMAD=libmad-0.15.1b.tar.gz
LIBMAD_MIRROR=http://downloads.sourceforge.net/mad
LIBMAD_DIR=$BUILD_DIR/libmad-0.15.1b
LIBMAD_ENV="$CROSS_ENV_AC"

build_libmad() {
    test -e "$STATE_DIR/libmad.installed" && return
    banner "Build libmad"
    download $LIBMAD_MIRROR $LIBMAD
    extract $LIBMAD
    apply_patches $LIBMAD_DIR $LIBMAD
    pushd $TOP_DIR
    cd $LIBMAD_DIR
    (
    local LIBMAD_CONF=
    case $TARGET_ARCH in
    i*86*)
	LIBMAD_CONF="--enable-fpm=intel"
	;;
    x86_64*|amd64*)
	LIBMAD_CONF="--enable-fpm=x86_64"
	;;
    arm*)
	LIBMAD_CONF="--enable-fpm=arm"
	;;
    powerpc*|ppc*)
	LIBMAD_CONF="--enable-fpm=ppc"
	;;
    *)
	error "unknown arch"
	;;
    esac
    
    eval \
	$CROSS_CONF_ENV \
	$LIBMAD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    $LIBMAD_CONF \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 .libs/libmad.so.0.2.1 $ROOTFS_DIR/usr/lib/libmad.so.0.2.1 || error
    ln -sf libmad.so.0.2.1 $ROOTFS_DIR/usr/lib/libmad.so.0
    ln -sf libmad.so.0.2.1 $ROOTFS_DIR/usr/lib/libmad.so
    $STRIP $ROOTFS_DIR/usr/lib/libmad.so.0.2.1 || error

    popd
    touch "$STATE_DIR/libmad.installed"
}

build_libmad
