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

GNU_TAR_VERSION=1.23
GNU_TAR=tar-${GNU_TAR_VERSION}.tar.bz2
GNU_TAR_MIRROR=http://ftp.gnu.org/gnu/tar
GNU_TAR_DIR=$BUILD_DIR/tar-${GNU_TAR_VERSION}
GNU_TAR_ENV="$CROSS_ENV_AC"

build_gnu_tar() {
    test -e "$STATE_DIR/gnu_tar.installed" && return
    banner "Build gnu-tar"
    download $GNU_TAR_MIRROR $GNU_TAR
    extract $GNU_TAR
    apply_patches $GNU_TAR_DIR $GNU_TAR
    pushd $TOP_DIR
    cd $GNU_TAR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GNU_TAR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --libexecdir=/usr/lib/tar \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gnu_tar.installed"
}

build_gnu_tar
