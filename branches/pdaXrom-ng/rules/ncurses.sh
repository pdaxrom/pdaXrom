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

NCURSES=ncurses-5.7.tar.gz
NCURSES_MIRROR=http://ftp.gnu.org/pub/gnu/ncurses
NCURSES_DIR=$BUILD_DIR/ncurses-5.7
NCURSES_ENV=

build_ncurses() {
    test -e "$STATE_DIR/ncurses-5.7" && return
    banner "Build $NCURSES"
    download $NCURSES_MIRROR $NCURSES
    extract $NCURSES
    apply_patches $NCURSES_DIR $NCURSES
    pushd $TOP_DIR
    cd $NCURSES_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$NCURSES_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-normal \
	    --with-shared \
	    --disable-nls \
	    --without-ada \
	    --enable-const \
	    --enable-overwrite \
	    --without-gpm \
	    --with-debug \
	    --disable-echo \
	    --disable-widec \
	    --enable-big-core \
	    || error
    )
    make $MAKEARGS || error

    make DESTDIR=$TARGET_BIN_DIR install

    for f in libform.so libmenu.so libncurses.so libpanel.so; do
	$INSTALL -m 644 lib/${f}.5.7 $ROOTFS_DIR/usr/lib/
	ln -sf ${f}.5.7 $ROOTFS_DIR/usr/lib/${f}.5
	ln -sf ${f}.5.7 $ROOTFS_DIR/usr/lib/${f}
	$STRIP $ROOTFS_DIR/usr/lib/${f}.5.7
    done

    mkdir -p $ROOTFS_DIR/usr/share/terminfo
    for f in x/xterm x/xterm-color x/xterm-xfree86 v/vt100 v/vt102 v/vt200 a/ansi l/linux; do
	$INSTALL -D -m 644 $TARGET_BIN_DIR/usr/share/terminfo/$f $ROOTFS_DIR/usr/share/terminfo/$f
    done

    popd
    touch "$STATE_DIR/ncurses-5.7"
}

build_ncurses
