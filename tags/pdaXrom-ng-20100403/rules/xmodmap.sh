#
# packet template
#
# Copyright (C) 2009 by Adrian Crutchfield <insearchof@inventgen-solutions.com>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

XMODMAP_VERSION=1.0.3
XMODMAP=xmodmap-${XMODMAP_VERSION}.tar.bz2
XMODMAP_MIRROR=http://xorg.freedesktop.org/releases/current/src/app/
XMODMAP_DIR=$BUILD_DIR/xmodmap-${XMODMAP_VERSION}
XMODMAP_ENV="$CROSS_ENV_AC"

build_xmodmap() {
    test -e "$STATE_DIR/xmodmap.installed" && return
    banner "Build xmodmap"
    download $XMODMAP_MIRROR $XMODMAP
    extract $XMODMAP
    apply_patches $XMODMAP_DIR $XMODMAP
    pushd $TOP_DIR
    cd $XMODMAP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XMODMAP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/xmodmap.installed"
}

build_xmodmap
