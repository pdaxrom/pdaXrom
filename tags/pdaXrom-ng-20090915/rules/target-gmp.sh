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

TARGET_GMP_VERSION=4.3.1
TARGET_GMP=gmp-${TARGET_GMP_VERSION}.tar.bz2
TARGET_GMP_MIRROR=ftp://ftp.gnu.org/gnu/gmp
TARGET_GMP_DIR=$BUILD_DIR/gmp-${TARGET_GMP_VERSION}
TARGET_GMP_ENV="$CROSS_ENV_AC"

build_target_gmp() {
    test -e "$STATE_DIR/target_gmp.installed" && return
    banner "Build target_gmp"
    download $TARGET_GMP_MIRROR $TARGET_GMP
    extract $TARGET_GMP
    apply_patches $TARGET_GMP_DIR $TARGET_GMP
    pushd $TOP_DIR
    cd $TARGET_GMP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_GMP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error "sysroot"

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_gmp.installed"
}

build_target_gmp
