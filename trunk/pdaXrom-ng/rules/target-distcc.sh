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

TARGET_DISTCC_VERSION=3.1
TARGET_DISTCC=distcc-${TARGET_DISTCC_VERSION}.tar.bz2
TARGET_DISTCC_MIRROR=http://distcc.googlecode.com/files
TARGET_DISTCC_DIR=$BUILD_DIR/distcc-${TARGET_DISTCC_VERSION}
TARGET_DISTCC_ENV="$CROSS_ENV_AC"

build_target_distcc() {
    test -e "$STATE_DIR/target_distcc.installed" && return
    banner "Build target-distcc"
    download $TARGET_DISTCC_MIRROR $TARGET_DISTCC
    extract $TARGET_DISTCC
    apply_patches $TARGET_DISTCC_DIR $TARGET_DISTCC
    pushd $TOP_DIR
    cd $TARGET_DISTCC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_DISTCC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --without-gnome \
	    --without-gtk \
	    || error
    ) || error "configure"

    make $MAKEARGS distcc distccd distccmon-text || error

    install_rootfs_usr_bin ./distcc
    install_rootfs_usr_bin ./distccd
    install_rootfs_usr_bin ./distccmon-text

    popd
    touch "$STATE_DIR/target_distcc.installed"
}

build_target_distcc
