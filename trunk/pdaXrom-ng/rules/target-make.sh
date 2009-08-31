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

TARGET_MAKE_VERSION=3.81
TARGET_MAKE=make-${TARGET_MAKE_VERSION}.tar.bz2
TARGET_MAKE_MIRROR=http://ftp.gnu.org/pub/gnu/make
TARGET_MAKE_DIR=$BUILD_DIR/make-${TARGET_MAKE_VERSION}
TARGET_MAKE_ENV="$CROSS_ENV_AC"

build_target_make() {
    test -e "$STATE_DIR/target_make.installed" && return
    banner "Build target-make"
    download $TARGET_MAKE_MIRROR $TARGET_MAKE
    extract $TARGET_MAKE
    apply_patches $TARGET_MAKE_DIR $TARGET_MAKE
    pushd $TOP_DIR
    cd $TARGET_MAKE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_MAKE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_make.installed"
}

build_target_make
