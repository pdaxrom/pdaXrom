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

LIBTOOL_VERSION=2.2.6
LIBTOOL=libtool-${LIBTOOL_VERSION}a.tar.gz
LIBTOOL_MIRROR=http://ftp.gnu.org/gnu/libtool
LIBTOOL_DIR=$BUILD_DIR/libtool-${LIBTOOL_VERSION}
LIBTOOL_ENV="$CROSS_ENV_AC"

build_libtool() {
    test -e "$STATE_DIR/libtool.installed" && return
    banner "Build libtool"
    download $LIBTOOL_MIRROR $LIBTOOL
    extract $LIBTOOL
    apply_patches $LIBTOOL_DIR $LIBTOOL
    pushd $TOP_DIR
    cd $LIBTOOL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBTOOL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    rm -rf fakeroot/usr/bin
    rm -rf fakeroot/usr/share
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libtool.installed"
}

build_libtool
