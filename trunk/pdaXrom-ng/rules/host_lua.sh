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

HOST_LUA_VERSION=5.1.4
HOST_LUA=lua-${HOST_LUA_VERSION}.tar.gz
HOST_LUA_MIRROR=http://www.lua.org/ftp
HOST_LUA_DIR=$HOST_BUILD_DIR/lua-${HOST_LUA_VERSION}
HOST_LUA_ENV="$CROSS_ENV_AC"

build_host_lua() {
    test -e "$STATE_DIR/host_lua.installed" && return
    banner "Build host lua"
    download $HOST_LUA_MIRROR $HOST_LUA
    extract_host $HOST_LUA
    apply_patches $HOST_LUA_DIR $HOST_LUA
    pushd $TOP_DIR
    cd $HOST_LUA_DIR

    make linux $MAKEARGS CC="gcc -fPIC" AR="ar rcu" RANLIB=ranlib MYLDFLAGS="-Wl,-rpath,${TARGET_LIB} -L${TARGET_LIB}" || error

    #local PKG_CONFIG_FILE=lua.pc

    #echo "prefix=${TARGET_BIN_DIR}" > ${TARGET_LIB}/pkgconfig/${PKG_CONFIG_FILE}
    #echo "major_version=5.1" >> ${TARGET_LIB}/pkgconfig/${PKG_CONFIG_FILE}
    #echo "version=5.1.4"   >> ${TARGET_LIB}/pkgconfig/${PKG_CONFIG_FILE}
    #cat ${GENERICFS_DIR}/lua/${PKG_CONFIG_FILE}.in >> ${TARGET_LIB}/pkgconfig/${PKG_CONFIG_FILE}

    install_sysroot_files INSTALL_TOP=${HOST_BIN_DIR} || error

    popd
    touch "$STATE_DIR/host_lua.installed"
}

build_host_lua
