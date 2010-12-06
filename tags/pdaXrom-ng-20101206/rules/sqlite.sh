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

SQLITE_VERSION=3.6.23.1
SQLITE=sqlite-${SQLITE_VERSION}.tar.gz
SQLITE_MIRROR=http://sqlite.org
SQLITE_DIR=$BUILD_DIR/sqlite-${SQLITE_VERSION}
SQLITE_ENV="$CROSS_ENV_AC CPPFLAGS='-DSQLITE_ENABLE_COLUMN_METADATA=1'"

build_sqlite() {
    test -e "$STATE_DIR/sqlite.installed" && return
    banner "Build sqlite"
    download $SQLITE_MIRROR $SQLITE
    extract $SQLITE
    apply_patches $SQLITE_DIR $SQLITE
    pushd $TOP_DIR
    cd $SQLITE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SQLITE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-tcl \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/sqlite.installed"
}

build_sqlite
