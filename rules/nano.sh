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

NANO_VERSION=2.1.10
NANO=nano-${NANO_VERSION}.tar.gz
NANO_MIRROR=http://www.nano-editor.org/dist/v2.1
NANO_DIR=$BUILD_DIR/nano-${NANO_VERSION}
NANO_ENV="$CROSS_ENV_AC"

build_nano() {
    test -e "$STATE_DIR/nano.installed" && return
    banner "Build nano"
    download $NANO_MIRROR $NANO
    extract $NANO
    apply_patches $NANO_DIR $NANO
    pushd $TOP_DIR
    cd $NANO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$NANO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    $INSTALL -D -m 755 src/nano $ROOTFS_DIR/usr/bin/nano || error
    $STRIP $ROOTFS_DIR/usr/bin/nano

    popd
    touch "$STATE_DIR/nano.installed"
}

build_nano
