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

LIBID3TAG_VERSION=0.15.1b
LIBID3TAG=libid3tag-${LIBID3TAG_VERSION}.tar.gz
LIBID3TAG_MIRROR=ftp://ftp.mars.org/pub/mpeg
LIBID3TAG_DIR=$BUILD_DIR/libid3tag-${LIBID3TAG_VERSION}
LIBID3TAG_ENV="$CROSS_ENV_AC"

build_libid3tag() {
    test -e "$STATE_DIR/libid3tag.installed" && return
    banner "Build libid3tag"
    download $LIBID3TAG_MIRROR $LIBID3TAG
    extract $LIBID3TAG
    apply_patches $LIBID3TAG_DIR $LIBID3TAG
    pushd $TOP_DIR
    cd $LIBID3TAG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBID3TAG_ENV \
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
    touch "$STATE_DIR/libid3tag.installed"
}

build_libid3tag
