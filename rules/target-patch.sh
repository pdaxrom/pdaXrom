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

TARGET_PATCH_VERSION=2.5.9
TARGET_PATCH=patch-${TARGET_PATCH_VERSION}.tar.gz
TARGET_PATCH_MIRROR=http://ftp.gnu.org/gnu/patch
TARGET_PATCH_DIR=$BUILD_DIR/patch-${TARGET_PATCH_VERSION}
TARGET_PATCH_ENV="$CROSS_ENV_AC"

build_target_patch() {
    test -e "$STATE_DIR/target_patch.installed" && return
    banner "Build target-patch"
    download $TARGET_PATCH_MIRROR $TARGET_PATCH
    extract $TARGET_PATCH
    apply_patches $TARGET_PATCH_DIR $TARGET_PATCH
    pushd $TOP_DIR
    cd $TARGET_PATCH_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_PATCH_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_rootfs_usr_bin ./patch

    popd
    touch "$STATE_DIR/target_patch.installed"
}

build_target_patch
