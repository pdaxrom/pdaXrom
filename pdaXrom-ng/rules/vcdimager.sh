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

VCDIMAGER_VERSION=0.7.23
VCDIMAGER=vcdimager-${VCDIMAGER_VERSION}.tar.gz
VCDIMAGER_MIRROR=http://ftp.gnu.org/gnu/vcdimager
VCDIMAGER_DIR=$BUILD_DIR/vcdimager-${VCDIMAGER_VERSION}
VCDIMAGER_ENV="$CROSS_ENV_AC"

build_vcdimager() {
    test -e "$STATE_DIR/vcdimager.installed" && return
    banner "Build vcdimager"
    download $VCDIMAGER_MIRROR $VCDIMAGER
    extract $VCDIMAGER
    apply_patches $VCDIMAGER_DIR $VCDIMAGER
    pushd $TOP_DIR
    cd $VCDIMAGER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$VCDIMAGER_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    case $TARGET_ARCH in
    mips*el-*|x86_64-*|i*86-*|amd64-*|arm*el-*)
	sed -i -e 's|/\* #undef BITFIELD_LSBF \*/|#define BITFIELD_LSBF|' config.h
	;;
    *)
	;;
    esac

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/vcdimager.installed"
}

build_vcdimager
