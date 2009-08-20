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

LIBAO_VERSION=0.8.8
LIBAO=libao-${LIBAO_VERSION}.tar.gz
LIBAO_MIRROR=http://downloads.xiph.org/releases/ao
LIBAO_DIR=$BUILD_DIR/libao-${LIBAO_VERSION}
LIBAO_ENV="$CROSS_ENV_AC"

build_libao() {
    test -e "$STATE_DIR/libao.installed" && return
    banner "Build libao"
    download $LIBAO_MIRROR $LIBAO
    extract $LIBAO
    apply_patches $LIBAO_DIR $LIBAO
    pushd $TOP_DIR
    cd $LIBAO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBAO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-wmm=no \
	    --enable-esd=no \
	    --enable-broken-oss=no \
	    --enable-arts=no \
	    --enable-nas=no \
	    --enable-pulse=no \
	    --enable-alsa \
	    --enable-alsa09 \
	    --enable-alsa09-mmap \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libao.installed"
}

build_libao
