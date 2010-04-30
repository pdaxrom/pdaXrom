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

GNU_GZIP_VERSION=1.4
GNU_GZIP=gzip-${GNU_GZIP_VERSION}.tar.gz
GNU_GZIP_MIRROR=http://ftp.gnu.org/gnu/gzip
GNU_GZIP_DIR=$BUILD_DIR/gzip-${GNU_GZIP_VERSION}
GNU_GZIP_ENV="$CROSS_ENV_AC"

build_gnu_gzip() {
    test -e "$STATE_DIR/gnu_gzip.installed" && return
    banner "Build gnu-gzip"
    download $GNU_GZIP_MIRROR $GNU_GZIP
    extract $GNU_GZIP
    apply_patches $GNU_GZIP_DIR $GNU_GZIP
    pushd $TOP_DIR
    cd $GNU_GZIP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GNU_GZIP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gnu_gzip.installed"
}

build_gnu_gzip
