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

TARGET_BINUTILS_VERSION=2.19.50.0.1
TARGET_BINUTILS=binutils-${TARGET_BINUTILS_VERSION}.tar.bz2
TARGET_BINUTILS_MIRROR=ftp://ftp.kernel.org/pub/linux/devel/binutils
TARGET_BINUTILS_DIR=$BUILD_DIR/binutils-${TARGET_BINUTILS_VERSION}
TARGET_BINUTILS_ENV="$CROSS_ENV_AC"

build_target_binutils() {
    test -e "$STATE_DIR/target_binutils.installed" && return
    banner "Build target-binutils"
    download $TARGET_BINUTILS_MIRROR $TARGET_BINUTILS
    extract $TARGET_BINUTILS
    apply_patches $TARGET_BINUTILS_DIR $TARGET_BINUTILS
    pushd $TOP_DIR
    mkdir -p $TARGET_BINUTILS_DIR/build-target
    cd $TARGET_BINUTILS_DIR/build-target || error
    local CONF_ARGS=
    case $TARGET_ARCH in
    powerpc*|ppc*)
	CONF_ARGS="--enable-targets=spu"
	;;
    esac

    ../configure \
	--build=$BUILD_ARCH \
	--host=$TARGET_ARCH \
	--target=$TARGET_ARCH \
	--prefix=/usr \
	--enable-werror=no \
	--enable-64-bit-bfd \
	--disable-debug \
	--enable-shared \
	$CONF_ARGS || error "configure"

    make $MAKEARGS MAKEINFO=true || error "make"

    install_fakeroot_init MAKEINFO=true

    for f in fakeroot/usr/$TARGET_ARCH/bin/*; do
	test -f $f && ln -sf ../../bin/`basename $f` $f
    done

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_binutils.installed"
}

build_target_binutils
