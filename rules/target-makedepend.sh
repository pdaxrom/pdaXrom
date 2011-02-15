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

TARGET_MAKEDEPEND_VERSION=1.0.2
TARGET_MAKEDEPEND=makedepend-${TARGET_MAKEDEPEND_VERSION}.tar.bz2
TARGET_MAKEDEPEND_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/util
TARGET_MAKEDEPEND_DIR=$BUILD_DIR/makedepend-${TARGET_MAKEDEPEND_VERSION}
TARGET_MAKEDEPEND_ENV="$CROSS_ENV_AC"

build_target_makedepend() {
    test -e "$STATE_DIR/target_makedepend.installed" && return
    banner "Build target-makedepend"
    download $TARGET_MAKEDEPEND_MIRROR $TARGET_MAKEDEPEND
    extract $TARGET_MAKEDEPEND
    apply_patches $TARGET_MAKEDEPEND_DIR $TARGET_MAKEDEPEND
    pushd $TOP_DIR
    cd $TARGET_MAKEDEPEND_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_MAKEDEPEND_ENV \
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
    touch "$STATE_DIR/target_makedepend.installed"
}

build_target_makedepend
