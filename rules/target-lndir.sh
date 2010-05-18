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

TARGET_LNDIR_VERSION=1.0.1
TARGET_LNDIR=lndir-${TARGET_LNDIR_VERSION}.tar.bz2
TARGET_LNDIR_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/util
TARGET_LNDIR_DIR=$BUILD_DIR/lndir-${TARGET_LNDIR_VERSION}
TARGET_LNDIR_ENV="$CROSS_ENV_AC"

build_target_lndir() {
    test -e "$STATE_DIR/target_lndir.installed" && return
    banner "Build target-lndir"
    download $TARGET_LNDIR_MIRROR $TARGET_LNDIR
    extract $TARGET_LNDIR
    apply_patches $TARGET_LNDIR_DIR $TARGET_LNDIR
    pushd $TOP_DIR
    cd $TARGET_LNDIR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_LNDIR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_lndir.installed"
}

build_target_lndir
