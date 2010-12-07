#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

UDISKS_VERSION=1.0.2
UDISKS=udisks-${UDISKS_VERSION}.tar.gz
UDISKS_MIRROR=http://hal.freedesktop.org/releases
UDISKS_DIR=$BUILD_DIR/udisks-${UDISKS_VERSION}
UDISKS_ENV="$CROSS_ENV_AC"

build_udisks() {
    test -e "$STATE_DIR/udisks.installed" && return
    banner "Build udisks"
    download $UDISKS_MIRROR $UDISKS
    extract $UDISKS
    apply_patches $UDISKS_DIR $UDISKS
    pushd $TOP_DIR
    cd $UDISKS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$UDISKS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/udisks \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    rm -rf fakeroot/usr/share/pkgconfig
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/udisks.installed"
}

build_udisks
