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

SLANG_VERSION=2.2.0
SLANG=slang-${SLANG_VERSION}.tar.bz2
SLANG_MIRROR=ftp://space.mit.edu/pub/davis/slang/v2.2
SLANG_DIR=$BUILD_DIR/slang-${SLANG_VERSION}
SLANG_ENV="$CROSS_ENV_AC"

build_slang() {
    test -e "$STATE_DIR/slang.installed" && return
    banner "Build slang"
    download $SLANG_MIRROR $SLANG
    extract $SLANG
    apply_patches $SLANG_DIR $SLANG
    pushd $TOP_DIR
    cd $SLANG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SLANG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error "make"

    install_sysroot_files || error "install sysroot files"

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/slang.installed"
}

build_slang
