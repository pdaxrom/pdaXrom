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

GDB=gdb-6.8.tar.bz2
GDB_MIRROR=http://ftp.gnu.org/gnu/gdb
GDB_DIR=$BUILD_DIR/gdb-6.8
GDB_ENV="$CROSS_ENV_AC \
	gdb_cv_func_sigsetjmp=yes \
	bash_cv_func_strcoll_broken=no \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_func_sigsetjmp=present \
	bash_cv_have_mbstate_t=yes \
"

build_gdb() {
    test -e "$STATE_DIR/gdb.installed" && return
    banner "Build gdb"
    download $GDB_MIRROR $GDB
    extract $GDB
    apply_patches $GDB_DIR $GDB
    pushd $TOP_DIR
    mkdir -p $GDB_DIR/build
    cd $GDB_DIR/build
    (
    eval \
	$GDB_ENV \
	'CFLAGS="-O2 -I$TARGET_INC"' \
	'LDFLAGS="-L$TARGET_LIB"' \
	../configure --build=$BUILD_ARCH --host=$TARGET_ARCH --target=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-serial-configure \
	    --with-build-sysroot=$TARGET_BIN_DIR \
	    --with-curses \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 gdb/gdb $ROOTFS_DIR/usr/bin/gdb || error
    $STRIP $ROOTFS_DIR/usr/bin/gdb || error

    popd
    touch "$STATE_DIR/gdb.installed"
}

build_gdb
