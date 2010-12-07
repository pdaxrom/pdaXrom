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

POLKIT_VERSION=0.99
POLKIT=polkit-${POLKIT_VERSION}.tar.gz
POLKIT_MIRROR=http://hal.freedesktop.org/releases
POLKIT_DIR=$BUILD_DIR/polkit-${POLKIT_VERSION}
POLKIT_ENV="$CROSS_ENV_AC"

build_polkit() {
    test -e "$STATE_DIR/polkit.installed" && return
    banner "Build polkit"
    download $POLKIT_MIRROR $POLKIT
    extract $POLKIT
    apply_patches $POLKIT_DIR $POLKIT
    pushd $TOP_DIR
    cd $POLKIT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$POLKIT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/polkit-1 \
	    --with-authfw=shadow \
	    --with-os-type=pdaXrom \
	    --disable-introspection \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/polkit.installed"
}

build_polkit
