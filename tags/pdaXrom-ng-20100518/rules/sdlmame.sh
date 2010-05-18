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

SDLMAME_VERSION=0.134
SDLMAME=sdlmame_${SDLMAME_VERSION}.orig.tar.gz
SDLMAME_MIRROR=http://sdlmame4ubuntu.org/cur/major/pool/unofficial/s/sdlmame
SDLMAME_DIR=$BUILD_DIR/sdlmame-${SDLMAME_VERSION}
SDLMAME_ENV="$CROSS_ENV_AC"

build_sdlmame() {
    test -e "$STATE_DIR/sdlmame.installed" && return
    banner "Build sdlmame"
    download $SDLMAME_MIRROR $SDLMAME
    extract $SDLMAME
    apply_patches $SDLMAME_DIR $SDLMAME
    pushd $TOP_DIR
    cd $SDLMAME_DIR

    local C_ARGS=
    case $TARGET_ARCH in
    x86_64*|amd64*|mips64el*)
	C_ARGS="PTR64=1"
	;;
    ppc64*|powerpc64*|mips64-*|mips64eb-*)
	C_ARGS="BIGENDIAN=1 PTR64=1"
	;;
    ppc-*|powerpc-*|mips-*|mips*eb-*|arm*eb-*|armbe-*)
	C_ARGS="BIGENDIAN=1"
	;;
    esac

    C_ARGS="$C_ARGS $SDLMAME_MAKE_ARGS"

    local ARCHOPTS=
    local OPTIMIZE=
    case $TARGET_ARCH in
    ppc*|powerpc*)
	ARCHOPTS='-mcpu=G4 -Upowerpc'
	OPTIMIZE=2
	;;
    esac

    mkdir -p obj/sdl/mame/build
    cp -f $HOST_SDLMAME_DIR/obj/sdl/mame/build/* obj/sdl/mame/build/ || error

    make $MAKEARGS CROSS_BUILD=1 \
	TARGETOS=unix \
	$C_ARGS \
	AR=@${CROSS}ar \
	CC=@${CROSS}gcc \
	LD=@${CROSS}gcc \
	RANLIB=@{CROSS}ranlib \
	NO_X11=1 \
	FILE2STR=obj/sdl/mame/build/file2str \
	PNG2BDC=obj/sdl/mame/build/png2bdc \
	VERINFO=obj/sdl/mame/build/verinfo \
	M68KMAKE=obj/sdl/mame/build/m68kmake \
	TMSMAKE=obj/sdl/mame/build/tmsmake \
	OPT_FLAGS="-D'INI_PATH=\"/etc/sdlmame\"' -D_FORTIFY_SOURCE=0" \
	NAME=sdlmame \
	TARGET=mame \
	SUBTARGET=mame \
	OSD=sdl \
	OPTIMIZE=${OPTIMIZE-3} \
	ARCHOPTS="$ARCHOPTS" \
	|| error

    $INSTALL -D -m 755 sdlmame $ROOTFS_DIR/usr/bin/sdlmame || error
    $STRIP $ROOTFS_DIR/usr/bin/sdlmame || error
    ln -sf sdlmame $ROOTFS_DIR/usr/bin/mame

    LOCAL_DIRS=" \
	/etc/sdlmame/ctrlr \
	/usr/share/sdlmame \
	/usr/share/sdlmame/keymaps \
	/usr/share/sdlmame/roms \
	/usr/share/sdlmame/samples \
	/usr/share/sdlmame/artwork \
	/usr/share/sdlmame/cheat \
	/usr/share/sdlmame/crosshair \
	"

    for f in $LOCAL_DIRS; do
	mkdir -p "${ROOTFS_DIR}/$f" || error
    done

    $INSTALL -D -m 644 ui.bdf $ROOTFS_DIR/usr/share/sdlmame/ui.bdf || error
    cp -a keymaps/*.txt $ROOTFS_DIR/usr/share/sdlmame/keymaps || error
    $INSTALL -D -m 644 $GENERICFS_DIR/sdlmame/mame.ini $ROOTFS_DIR/etc/sdlmame/mame.ini || error
    $INSTALL -D -m 644 $GENERICFS_DIR/sdlmame/vector.ini $ROOTFS_DIR/etc/sdlmame/vector.ini || error

    popd
    touch "$STATE_DIR/sdlmame.installed"
}

build_sdlmame
