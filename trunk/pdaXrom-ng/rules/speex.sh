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

SPEEX_VERSION=1.2rc1
SPEEX=speex-${SPEEX_VERSION}.tar.gz
SPEEX_MIRROR=http://downloads.xiph.org/releases/speex
SPEEX_DIR=$BUILD_DIR/speex-${SPEEX_VERSION}
SPEEX_ENV="$CROSS_ENV_AC"

build_speex() {
    test -e "$STATE_DIR/speex.installed" && return
    banner "Build speex"
    download $SPEEX_MIRROR $SPEEX
    extract $SPEEX
    apply_patches $SPEEX_DIR $SPEEX
    pushd $TOP_DIR
    cd $SPEEX_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SPEEX_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-ogg=$TARGET_BIN_DIR \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    install_rootfs_usr_lib libspeex/.libs/libspeex.so.1.5.0
    install_rootfs_usr_lib libspeex/.libs/libspeexdsp.so.1.5.0

    popd
    touch "$STATE_DIR/speex.installed"
}

build_speex
