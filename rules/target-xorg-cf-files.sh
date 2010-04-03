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

TARGET_XORG_CF_FILES_VERSION=1.0.3
TARGET_XORG_CF_FILES=xorg-cf-files-${TARGET_XORG_CF_FILES_VERSION}.tar.bz2
TARGET_XORG_CF_FILES_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/util
TARGET_XORG_CF_FILES_DIR=$BUILD_DIR/xorg-cf-files-${TARGET_XORG_CF_FILES_VERSION}
TARGET_XORG_CF_FILES_ENV="$CROSS_ENV_AC"

build_target_xorg_cf_files() {
    test -e "$STATE_DIR/target_xorg_cf_files.installed" && return
    banner "Build target-xorg-cf-files"
    download $TARGET_XORG_CF_FILES_MIRROR $TARGET_XORG_CF_FILES
    extract $TARGET_XORG_CF_FILES
    apply_patches $TARGET_XORG_CF_FILES_DIR $TARGET_XORG_CF_FILES
    pushd $TOP_DIR
    cd $TARGET_XORG_CF_FILES_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_XORG_CF_FILES_ENV \
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
    touch "$STATE_DIR/target_xorg_cf_files.installed"
}

build_target_xorg_cf_files
