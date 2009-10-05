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

PIXMAN_VERSION=0.16.2
PIXMAN=pixman-${PIXMAN_VERSION}.tar.bz2
PIXMAN_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
PIXMAN_DIR=$BUILD_DIR/pixman-${PIXMAN_VERSION}
PIXMAN_ENV=

build_pixman() {
    test -e "$STATE_DIR/pixman-${PIXMAN_VERSION}" && return
    banner "Build $PIXMAN"
    download $PIXMAN_MIRROR $PIXMAN
    extract $PIXMAN
    apply_patches $PIXMAN_DIR $PIXMAN
    pushd $TOP_DIR
    cd $PIXMAN_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PIXMAN_ENV \
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
    touch "$STATE_DIR/pixman-${PIXMAN_VERSION}"
}

build_pixman
