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

LIBICONV_VERSION=1.13.1
LIBICONV=libiconv-${LIBICONV_VERSION}.tar.gz
LIBICONV_MIRROR=http://ftp.gnu.org/pub/gnu/libiconv
LIBICONV_DIR=$BUILD_DIR/libiconv-${LIBICONV_VERSION}
LIBICONV_ENV="$CROSS_ENV_AC"

build_libiconv() {
    test -e "$STATE_DIR/libiconv.installed" && return
    banner "Build libiconv"
    download $LIBICONV_MIRROR $LIBICONV
    extract $LIBICONV
    apply_patches $LIBICONV_DIR $LIBICONV
    pushd $TOP_DIR
    cd $LIBICONV_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBICONV_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libiconv.installed"
}

build_libiconv
