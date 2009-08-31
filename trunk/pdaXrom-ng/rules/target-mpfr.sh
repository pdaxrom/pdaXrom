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

TARGET_MPFR_VERSION=2.4.1
TARGET_MPFR=mpfr-${TARGET_MPFR_VERSION}.tar.bz2
TARGET_MPFR_MIRROR=http://www.mpfr.org/mpfr-current
TARGET_MPFR_DIR=$BUILD_DIR/mpfr-${TARGET_MPFR_VERSION}
TARGET_MPFR_ENV="$CROSS_ENV_AC"

build_target_mpfr() {
    test -e "$STATE_DIR/target_mpfr.installed" && return
    banner "Build target_mpfr"
    download $TARGET_MPFR_MIRROR $TARGET_MPFR
    extract $TARGET_MPFR
    apply_patches $TARGET_MPFR_DIR $TARGET_MPFR
    pushd $TOP_DIR
    cd $TARGET_MPFR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_MPFR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS CPPFLAGS="-DNO_ASM=1" || error "make"

    install_sysroot_files || error "sysroot"

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_mpfr.installed"
}

build_target_mpfr
