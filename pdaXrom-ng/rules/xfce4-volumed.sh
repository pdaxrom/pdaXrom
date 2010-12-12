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

XFCE4_VOLUMED_VERSION=0.1.11
XFCE4_VOLUMED=xfce4-volumed-${XFCE4_VOLUMED_VERSION}.tar.bz2
XFCE4_VOLUMED_MIRROR=http://archive.xfce.org/src/apps/xfce4-volumed/0.1
XFCE4_VOLUMED_DIR=$BUILD_DIR/xfce4-volumed-${XFCE4_VOLUMED_VERSION}
XFCE4_VOLUMED_ENV="$CROSS_ENV_AC"

build_xfce4_volumed() {
    test -e "$STATE_DIR/xfce4_volumed.installed" && return
    banner "Build xfce4-volumed"
    download $XFCE4_VOLUMED_MIRROR $XFCE4_VOLUMED
    extract $XFCE4_VOLUMED
    apply_patches $XFCE4_VOLUMED_DIR $XFCE4_VOLUMED
    pushd $TOP_DIR
    cd $XFCE4_VOLUMED_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFCE4_VOLUMED_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/xfce4_volumed.installed"
}

build_xfce4_volumed
