#
# host packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_NCURSES=ncurses-5.7.tar.gz
HOST_NCURSES_MIRROR=http://ftp.gnu.org/pub/gnu/ncurses
HOST_NCURSES_DIR=$HOST_BUILD_DIR/ncurses-5.7
HOST_NCURSES_ENV=
if [ "$HOST_SYSTEM" = "Linux" ]; then
    # linux tic trying to use shared libs from /usr/lib, build it static
    HOST_NCURSES_CONF="--without-shared"
else
    HOST_NCURSES_CONF="--with-shared"
fi

build_host_ncurses() {
    test -e "$STATE_DIR/host_ncurses-5.7" && return
    banner "Build $HOST_NCURSES"
    download $HOST_NCURSES_MIRROR $HOST_NCURSES
    extract_host $HOST_NCURSES
    apply_patches $HOST_NCURSES_DIR $HOST_NCURSES
    pushd $TOP_DIR
    cd $HOST_NCURSES_DIR
    eval $HOST_NCURSES_ENV \
	./configure --prefix=$HOST_BIN_DIR \
	    --with-normal \
	    --disable-nls \
	    --without-ada \
	    --enable-const \
	    --enable-overwrite \
	    --without-gpm \
	    --with-debug \
	    --disable-echo \
	    --disable-widec \
	    --enable-big-core \
	    $HOST_NCURSES_CONF \
	|| error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_ncurses-5.7"
}

build_host_ncurses
