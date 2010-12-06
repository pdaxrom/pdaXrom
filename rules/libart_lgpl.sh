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

LIBART_LGPL_VERSION=2.3.20
LIBART_LGPL=libart_lgpl-${LIBART_LGPL_VERSION}.tar.bz2
LIBART_LGPL_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/libart_lgpl/2.3
LIBART_LGPL_DIR=$BUILD_DIR/libart_lgpl-${LIBART_LGPL_VERSION}
LIBART_LGPL_ENV="$CROSS_ENV_AC"

build_libart_lgpl() {
    test -e "$STATE_DIR/libart_lgpl.installed" && return
    banner "Build libart_lgpl"
    download $LIBART_LGPL_MIRROR $LIBART_LGPL
    extract $LIBART_LGPL
    apply_patches $LIBART_LGPL_DIR $LIBART_LGPL
    pushd $TOP_DIR
    cd $LIBART_LGPL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBART_LGPL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error

	local T_CONF=
	case $TARGET_ARCH in
	i386*|i486*|i586*|i686*)
	    T_CONF="x86"
	    ;;
	arm*l-*|armle-*)
	    T_CONF="armel"
	    ;;
	arm*b-*|armbe-*)
	    T_CONF="armeb"
	    ;;
	mips*l-*)
	    T_CONF="mipsel"
	    ;;
	mips*-*)
	    T_CONF="mipseb"
	    ;;
	powerpc-*|ppc-*)
	    T_CONF="ppc"
	    ;;
	powerpc64-*|ppc64-*)
	    T_CONF="ppc64"
	    ;;
	x86_64*|amd64*)
	    T_CONF="x86_64"
	    ;;
	*)
	    T_CONF="${TARGET_ARCH/-*/}"
	    ;;
	esac
	sed -i "s|./gen_art_config > art_config.h|# nothing|" Makefile
	cp -f $CONFIG_DIR/libart_lgpl/art_config.h-${T_CONF} art_config.h || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 .libs/libart_lgpl_2.so.2.3.20 $ROOTFS_DIR/usr/lib/libart_lgpl_2.so.2.3.20 || error
    ln -sf libart_lgpl_2.so.2.3.20 $ROOTFS_DIR/usr/lib/libart_lgpl_2.so.2
    ln -sf libart_lgpl_2.so.2.3.20 $ROOTFS_DIR/usr/lib/libart_lgpl_2.so
    $STRIP $ROOTFS_DIR/usr/lib/libart_lgpl_2.so.2.3.20

    popd
    touch "$STATE_DIR/libart_lgpl.installed"
}

build_libart_lgpl
