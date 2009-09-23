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

READLINE_VERSION=6.0
READLINE=readline-${READLINE_VERSION}.tar.gz
READLINE_MIRROR=ftp://ftp.gnu.org/gnu/readline
READLINE_DIR=$BUILD_DIR/readline-${READLINE_VERSION}
READLINE_ENV="$CROSS_ENV_AC"

build_readline() {
    test -e "$STATE_DIR/readline.installed" && return
    banner "Build readline"
    download $READLINE_MIRROR $READLINE
    extract $READLINE
    apply_patches $READLINE_DIR $READLINE
    pushd $TOP_DIR
    cd $READLINE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$READLINE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-multibyte \
	    --with-curses \
	    || error
    ) || error "configure"

    make $MAKEARGS SHLIB_LIBS=-lcurses || error

    install_sysroot_files || error

    install_fakeroot_init
    rm -rf fakeroot/usr/share
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/readline.installed"
}

build_readline
