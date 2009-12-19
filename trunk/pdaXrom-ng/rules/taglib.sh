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

TAGLIB_VERSION=1.6.1
TAGLIB=taglib-${TAGLIB_VERSION}.tar.gz
TAGLIB_MIRROR=http://developer.kde.org/~wheeler/files/src
TAGLIB_DIR=$BUILD_DIR/taglib-${TAGLIB_VERSION}
TAGLIB_ENV="$CROSS_ENV_AC"

build_taglib() {
    test -e "$STATE_DIR/taglib.installed" && return
    banner "Build taglib"
    download $TAGLIB_MIRROR $TAGLIB
    extract $TAGLIB
    apply_patches $TAGLIB_DIR $TAGLIB
    pushd $TOP_DIR
    cd $TAGLIB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TAGLIB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-libsuffix \
	    --enable-final \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf ${TARGET_BIN_DIR}/bin/taglib-config ${HOST_BIN_DIR}/bin/taglib-config

    install_fakeroot_init
    rm -rf fakeroot/usr/bin
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/taglib.installed"
}

build_taglib
