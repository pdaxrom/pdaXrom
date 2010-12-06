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

MINGW32_SDL_IMAGE_VERSION=1.2.10
MINGW32_SDL_IMAGE=SDL_image-${MINGW32_SDL_IMAGE_VERSION}.tar.gz
MINGW32_SDL_IMAGE_MIRROR=http://www.libsdl.org/projects/SDL_image/release
MINGW32_SDL_IMAGE_DIR=$BUILD_DIR/SDL_image-${MINGW32_SDL_IMAGE_VERSION}
MINGW32_SDL_IMAGE_ENV="$CROSS_ENV_AC"

build_mingw32_SDL_image() {
    test -e "$STATE_DIR/mingw32_SDL_image.installed" && return
    banner "Build mingw32-SDL-image"
    download $MINGW32_SDL_IMAGE_MIRROR $MINGW32_SDL_IMAGE
    extract $MINGW32_SDL_IMAGE
    apply_patches $MINGW32_SDL_IMAGE_DIR $MINGW32_SDL_IMAGE
    pushd $TOP_DIR
    cd $MINGW32_SDL_IMAGE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MINGW32_SDL_IMAGE_ENV \
	./configure --build=$BUILD_ARCH --host=${TARGET_ARCH/-cygwin*}-mingw32 \
	    --prefix=$TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32 \
	    --with-sdl-prefix=$TOOLCHAIN_PREFIX/${TARGET_ARCH/-cygwin*}-mingw32 \
	    || error
    ) || error "configure"

    make $MAKEARGS || error
    make install || error

    popd
    touch "$STATE_DIR/mingw32_SDL_image.installed"
}

build_mingw32_SDL_image
