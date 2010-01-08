#
# host packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_LIBIDL=libIDL-0.8.12.tar.bz2
HOST_LIBIDL_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/libIDL/0.8
HOST_LIBIDL_DIR=$HOST_BUILD_DIR/libIDL-0.8.12
HOST_LIBIDL_ENV="PKG_CONFIG=\"$HOST_PKG_CONFIG\" PKG_CONFIG_PATH=\"$HOST_PKG_CONFIG_PATH\""

build_host_libIDL() {
    test -e "$STATE_DIR/host_libIDL.installed" && return
    banner "Build host-libIDL"
    download $HOST_LIBIDL_MIRROR $HOST_LIBIDL
    extract_host $HOST_LIBIDL
    apply_patches $HOST_LIBIDL_DIR $HOST_LIBIDL
    pushd $TOP_DIR
    cd $HOST_LIBIDL_DIR
    (
    unset PKG_CONFIG_PATH
    eval $HOST_LIBIDL_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error

    mv -f $HOST_BIN_DIR/bin/libIDL-config-2 $HOST_BIN_DIR/bin/host-libIDL-config-2

    popd
    touch "$STATE_DIR/host_libIDL.installed"
}

build_host_libIDL
