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

GIFLIB_VERSION=4.1.6
GIFLIB=giflib-${GIFLIB_VERSION}.tar.bz2
GIFLIB_MIRROR=http://downloads.sourceforge.net/project/giflib/giflib%204.x/giflib-4.1.6
GIFLIB_DIR=$BUILD_DIR/giflib-${GIFLIB_VERSION}
GIFLIB_ENV="$CROSS_ENV_AC"

build_giflib() {
    test -e "$STATE_DIR/giflib.installed" && return
    banner "Build giflib"
    download $GIFLIB_MIRROR $GIFLIB
    extract $GIFLIB
    apply_patches $GIFLIB_DIR $GIFLIB
    pushd $TOP_DIR
    cd $GIFLIB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GIFLIB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    rm -rf fakeroot/usr/bin

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/giflib.installed"
}

build_giflib
