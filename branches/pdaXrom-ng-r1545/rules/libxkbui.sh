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

LIBXKBUI_VERSION=1.0.2
LIBXKBUI=libxkbui-${LIBXKBUI_VERSION}.tar.bz2
LIBXKBUI_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXKBUI_DIR=$BUILD_DIR/libxkbui-${LIBXKBUI_VERSION}
LIBXKBUI_ENV=

build_libxkbui() {
    test -e "$STATE_DIR/libxkbui-${LIBXKBUI_VERSION}" && return
    banner "Build $LIBXKBUI"
    download $LIBXKBUI_MIRROR $LIBXKBUI
    extract $LIBXKBUI
    apply_patches $LIBXKBUI_DIR $LIBXKBUI
    pushd $TOP_DIR
    cd $LIBXKBUI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXKBUI_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libxkbui-${LIBXKBUI_VERSION}"
}

build_libxkbui
