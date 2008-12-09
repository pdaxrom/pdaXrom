#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

SDL=SDL-1.2.13.tar.gz
SDL_MIRROR=http://www.libsdl.org/release
SDL_DIR=$BUILD_DIR/SDL-1.2.13
SDL_ENV=

build_SDL() {
    test -e "$STATE_DIR/SDL-1.2.13" && return
    banner "Build $SDL"
    download $SDL_MIRROR $SDL
    extract $SDL
    apply_patches $SDL_DIR $SDL
    pushd $TOP_DIR
    cd $SDL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SDL_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-oss=no \
	    --enable-alsa \
	    --enable-esd=no \
	    --enable-pulseaudio=no \
	    --enable-arts=no \
	    --enable-nas=no \
	    --without-x \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files

    ln -sf $TARGET_BIN_DIR/bin/sdl-config $HOST_BIN_DIR/bin/

    $INSTALL -m 644 build/.libs/libSDL-1.2.so.0.11.2 $ROOTFS_DIR/usr/lib/
    ln -sf libSDL-1.2.so.0.11.2 $ROOTFS_DIR/usr/lib/libSDL-1.2.so.0
    ln -sf libSDL-1.2.so.0.11.2 $ROOTFS_DIR/usr/lib/libSDL.so

    $STRIP $ROOTFS_DIR/usr/lib/libSDL-1.2.so.0.11.2

    popd
    touch "$STATE_DIR/SDL-1.2.13"
}

build_SDL
