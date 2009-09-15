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

SQLITE=sqlite-3.6.7.tar.gz
SQLITE_MIRROR=http://www.sqlite.org
SQLITE_DIR=$BUILD_DIR/sqlite-3.6.7
SQLITE_ENV="$CROSS_ENV_AC"

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
	    -disable-tcl \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 .libs/libsqlite3.so.0.8.6 $ROOTFS_DIR/usr/lib/libsqlite3.so.0.8.6 || error
    ln -sf libsqlite3.so.0.8.6 $ROOTFS_DIR/usr/lib/libsqlite3.so.0
    ln -sf libsqlite3.so.0.8.6 $ROOTFS_DIR/usr/lib/libsqlite3.so
    $STRIP $ROOTFS_DIR/usr/lib/libsqlite3.so.0.8.6

    popd
    touch "$STATE_DIR/sqlite.installed"
}

build_sqlite
