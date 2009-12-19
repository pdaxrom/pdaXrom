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

LIBCDDB_VERSION=1.3.2
LIBCDDB=libcddb-${LIBCDDB_VERSION}.tar.bz2
LIBCDDB_MIRROR=http://downloads.sourceforge.net/project/libcddb/libcddb/1.3.2
LIBCDDB_DIR=$BUILD_DIR/libcddb-${LIBCDDB_VERSION}
LIBCDDB_ENV="$CROSS_ENV_AC \
ac_cv_func_realloc_0_nonnull=yes \
"

build_libcddb() {
    test -e "$STATE_DIR/libcddb.installed" && return
    banner "Build libcddb"
    download $LIBCDDB_MIRROR $LIBCDDB
    extract $LIBCDDB
    apply_patches $LIBCDDB_DIR $LIBCDDB
    pushd $TOP_DIR
    cd $LIBCDDB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBCDDB_ENV \
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
    touch "$STATE_DIR/libcddb.installed"
}

build_libcddb
