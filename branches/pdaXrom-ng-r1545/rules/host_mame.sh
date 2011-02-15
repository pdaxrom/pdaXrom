#
# host packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_SDLMAME_VERSION=0.139
HOST_SDLMAME=mame_${HOST_SDLMAME_VERSION}.orig.tar.bz2
HOST_SDLMAME_MIRROR=http://sdlmame4ubuntu.org/cur/major/pool/unofficial/m/mame
HOST_SDLMAME_DIR=$HOST_BUILD_DIR/mame-${HOST_SDLMAME_VERSION}
HOST_SDLMAME_ENV=

build_host_sdlmame() {
    test -e "$STATE_DIR/host_sdlmame.installed" && return
    banner "Build host-sdlmame"
    download $HOST_SDLMAME_MIRROR $HOST_SDLMAME
    extract_host $HOST_SDLMAME
    apply_patches $HOST_SDLMAME_DIR $HOST_SDLMAME
    pushd $TOP_DIR
    cd $HOST_SDLMAME_DIR || error

    local C_ARGS=
    case `uname -m` in
    x86_64)
	C_ARGS="PTR64=1"
	;;
    ppc*|arm*eb-*|mips-*|mips*eb-*|armbe-*)
	C_ARGS="BIGENDIAN=1"
	;;
    esac

    C_ARGS="$C_ARGS SDL_INSTALL_ROOT=/usr SUFFIX64="

    mkdir -p obj/sdl/mame/build
    mkdir -p obj/sdl/mame/osd/sdl
    mkdir -p obj/sdl/mame/lib/util
    mkdir -p obj/sdl/mame/lib/zlib
    mkdir -p obj/sdl/mame/emu/cpu/m68000
    mkdir -p obj/sdl/mame/emu/cpu/tms57002
    make $MAKEARGS TARGETOS=unix NO_X11=1 $C_ARGS obj/sdl/mame/build/file2str || error
    make $MAKEARGS TARGETOS=unix NO_X11=1 $C_ARGS obj/sdl/mame/build/png2bdc  || error
    make $MAKEARGS TARGETOS=unix NO_X11=1 $C_ARGS obj/sdl/mame/build/verinfo  || error
    make $MAKEARGS TARGETOS=unix NO_X11=1 $C_ARGS obj/sdl/mame/build/m68kmake || error
    make $MAKEARGS TARGETOS=unix NO_X11=1 $C_ARGS obj/sdl/mame/build/tmsmake  || error

    rm -f obj/sdl/mame/build/*.o || error
    #cp -f obj/sdl/mame/build/* $HOST_BIN_DIR/bin/ || error

    popd
    touch "$STATE_DIR/host_sdlmame.installed"
}

build_host_sdlmame
