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

LUA_VERSION=5.1.4
LUA=lua-${LUA_VERSION}.tar.gz
LUA_MIRROR=http://www.lua.org/ftp
LUA_DIR=$BUILD_DIR/lua-${LUA_VERSION}
LUA_ENV="$CROSS_ENV_AC"

build_lua() {
    test -e "$STATE_DIR/lua.installed" && return
    banner "Build lua"
    download $LUA_MIRROR $LUA
    extract $LUA
    apply_patches $LUA_DIR $LUA
    pushd $TOP_DIR
    cd $LUA_DIR

    make linux $MAKEARGS CC=${CROSS}gcc AR="${CROSS}ar rcu" RANLIB=${CROSS}ranlib MYLDFLAGS="-Wl,-rpath,${TARGET_LIB} -L${TARGET_LIB}" || error

    install_sysroot_files INSTALL_TOP=${TARGET_BIN_DIR} || error

    install_fakeroot_init INSTALL_TOP=${LUA_DIR}/fakeroot/usr
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/lua.installed"
}

build_lua
