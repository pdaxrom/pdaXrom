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

TARGET_IMAKE_VERSION=1.0.2
TARGET_IMAKE=imake-${TARGET_IMAKE_VERSION}.tar.bz2
TARGET_IMAKE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/util
TARGET_IMAKE_DIR=$BUILD_DIR/imake-${TARGET_IMAKE_VERSION}
TARGET_IMAKE_ENV="$CROSS_ENV_AC"

build_target_imake() {
    test -e "$STATE_DIR/target_imake.installed" && return
    banner "Build target-imake"
    download $TARGET_IMAKE_MIRROR $TARGET_IMAKE
    extract $TARGET_IMAKE
    apply_patches $TARGET_IMAKE_DIR $TARGET_IMAKE
    pushd $TOP_DIR
    cd $TARGET_IMAKE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_IMAKE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_imake.installed"
}

build_target_imake
