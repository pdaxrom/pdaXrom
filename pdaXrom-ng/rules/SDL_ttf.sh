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

SDL_TTF_VERSION=2.0.9
SDL_TTF=SDL_ttf-${SDL_TTF_VERSION}.tar.gz
SDL_TTF_MIRROR=http://www.libsdl.org/projects/SDL_ttf/release
SDL_TTF_DIR=$BUILD_DIR/SDL_ttf-${SDL_TTF_VERSION}
SDL_TTF_ENV="$CROSS_ENV_AC"

build_SDL_ttf() {
    test -e "$STATE_DIR/SDL_ttf.installed" && return
    banner "Build SDL_ttf"
    download $SDL_TTF_MIRROR $SDL_TTF
    extract $SDL_TTF
    apply_patches $SDL_TTF_DIR $SDL_TTF
    pushd $TOP_DIR
    cd $SDL_TTF_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SDL_TTF_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-sdl-prefix=$TARGET_BIN_DIR \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_rootfs_usr_lib .libs/libSDL_ttf-2.0.so.0.6.3

    popd
    touch "$STATE_DIR/SDL_ttf.installed"
}

build_SDL_ttf
