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

GNU_WGET_VERSION=1.12
GNU_WGET=wget-${GNU_WGET_VERSION}.tar.bz2
GNU_WGET_MIRROR=http://ftp.gnu.org/gnu/wget
GNU_WGET_DIR=$BUILD_DIR/wget-${GNU_WGET_VERSION}
GNU_WGET_ENV="$CROSS_ENV_AC"

build_gnu_wget() {
    test -e "$STATE_DIR/gnu_wget.installed" && return
    banner "Build gnu-wget"
    download $GNU_WGET_MIRROR $GNU_WGET
    extract $GNU_WGET
    apply_patches $GNU_WGET_DIR $GNU_WGET
    pushd $TOP_DIR
    cd $GNU_WGET_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GNU_WGET_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-libssl-prefix=${TARGET_BIN_DIR} \
	    --with-libgnutls-prefix=${TARGET_BIN_DIR} \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gnu_wget.installed"
}

build_gnu_wget
