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

LIBTHEORA_VERSION=1.0
LIBTHEORA=libtheora-${LIBTHEORA_VERSION}.tar.bz2
LIBTHEORA_MIRROR=http://downloads.xiph.org/releases/theora
LIBTHEORA_DIR=$BUILD_DIR/libtheora-${LIBTHEORA_VERSION}
LIBTHEORA_ENV="$CROSS_ENV_AC"

build_libtheora() {
    test -e "$STATE_DIR/libtheora.installed" && return
    banner "Build libtheora"
    download $LIBTHEORA_MIRROR $LIBTHEORA
    extract $LIBTHEORA
    apply_patches $LIBTHEORA_DIR $LIBTHEORA
    pushd $TOP_DIR
    cd $LIBTHEORA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBTHEORA_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-ogg=$TARGET_BIN_DIR \
	    --with-vorbis=$TARGET_BIN_DIR \
	    --with-sdl-prefix=$TARGET_BIN_DIR \
	    --disable-examples \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    install_rootfs_usr_lib lib/.libs/libtheora.so.0.3.4
    install_rootfs_usr_lib lib/.libs/libtheoradec.so.1.0.1
    install_rootfs_usr_lib lib/.libs/libtheoraenc.so.1.0.1

    popd
    touch "$STATE_DIR/libtheora.installed"
}

build_libtheora
