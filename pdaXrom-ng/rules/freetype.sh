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

FREETYPE_VERSION=2.3.12
FREETYPE=freetype-${FREETYPE_VERSION}.tar.bz2
FREETYPE_MIRROR=http://download.savannah.gnu.org/releases/freetype
FREETYPE_DIR=$BUILD_DIR/freetype-${FREETYPE_VERSION}
FREETYPE_ENV=

build_freetype() {
    test -e "$STATE_DIR/freetype-${FREETYPE_VERSION}" && return
    banner "Build $FREETYPE"
    download $FREETYPE_MIRROR $FREETYPE
    extract $FREETYPE
    apply_patches $FREETYPE_DIR $FREETYPE
    pushd $TOP_DIR
    cd $FREETYPE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$FREETYPE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    ln -sf $TARGET_BIN_DIR/bin/freetype-config $HOST_BIN_DIR/bin/

    install_fakeroot_init
    rm -rf fakeroot/usr/bin
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/freetype-${FREETYPE_VERSION}"
}

build_freetype
