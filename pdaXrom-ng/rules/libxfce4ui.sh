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

LIBXFCE4UI_VERSION=4.7.5
LIBXFCE4UI=libxfce4ui-${LIBXFCE4UI_VERSION}.tar.bz2
LIBXFCE4UI_MIRROR=http://mocha.xfce.org/archive/xfce/4.8pre2/src
LIBXFCE4UI_DIR=$BUILD_DIR/libxfce4ui-${LIBXFCE4UI_VERSION}
LIBXFCE4UI_ENV="$CROSS_ENV_AC"

build_libxfce4ui() {
    test -e "$STATE_DIR/libxfce4ui.installed" && return
    banner "Build libxfce4ui"
    download $LIBXFCE4UI_MIRROR $LIBXFCE4UI
    extract $LIBXFCE4UI
    apply_patches $LIBXFCE4UI_DIR $LIBXFCE4UI
    pushd $TOP_DIR
    cd $LIBXFCE4UI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXFCE4UI_ENV \
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
    touch "$STATE_DIR/libxfce4ui.installed"
}

build_libxfce4ui
