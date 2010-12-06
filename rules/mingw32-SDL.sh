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

MINGW32_SDL=SDL-1.2.13.tar.gz
MINGW32_SDL_MIRROR=http://www.libsdl.org/release
MINGW32_SDL_DIR=$BUILD_DIR/SDL-1.2.13
MINGW32_SDL_ENV="$CROSS_ENV_AC"

build_mingw32_SDL() {
    test -e "$STATE_DIR/mingw32_SDL.installed" && return
    banner "Build mingw32-SDL"
    download $MINGW32_SDL_MIRROR $MINGW32_SDL
    extract $MINGW32_SDL
    apply_patches $MINGW32_SDL_DIR $MINGW32_SDL
    pushd $TOP_DIR
    cd $MINGW32_SDL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MINGW32_SDL_ENV \
	./configure --build=$BUILD_ARCH --host=${TARGET_ARCH/-cygwin*}-mingw32 \
	    --prefix=$TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32 \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make install || error

    ln -s ../${TARGET_ARCH/-cygwin*}-mingw32/bin/sdl-config $TOOLCHAIN_PREFIX/bin/i386-mingw32msvc-sdl-config
    ln -s ../${TARGET_ARCH/-cygwin*}-mingw32/bin/sdl-config $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-sdl-config
    ln -s ../${TARGET_ARCH/-cygwin*}-mingw32/bin/sdl-config $TOOLCHAIN_PREFIX/bin/sdl-config

    popd
    touch "$STATE_DIR/mingw32_SDL.installed"
}

build_mingw32_SDL
