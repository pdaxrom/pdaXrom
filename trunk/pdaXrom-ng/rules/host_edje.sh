#
# host packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_EDJE_VERSION=1.0.0.beta3
HOST_EDJE=edje-${HOST_EDJE_VERSION}.tar.bz2
HOST_EDJE_MIRROR=http://download.enlightenment.org/releases
HOST_EDJE_DIR=$HOST_BUILD_DIR/edje-${HOST_EDJE_VERSION}
HOST_EDJE_ENV="LUA_CFLAGS=\"-I${HOST_BIN_DIR}/include\" LUA_LIBS=\"-L${HOST_BIN_DIR}/lib -llua\" PKG_CONFIG_PATH=${HOST_BIN_DIR}/lib/pkgconfig:/usr/lib/pkgconfig"

build_host_edje() {
    test -e "$STATE_DIR/host_edje.installed" && return
    banner "Build host-edje"
    download $HOST_EDJE_MIRROR $HOST_EDJE
    extract_host $HOST_EDJE
    apply_patches $HOST_EDJE_DIR $HOST_EDJE
    pushd $TOP_DIR
    cd $HOST_EDJE_DIR
    (
    eval $HOST_EDJE_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error

    for f in edje_cc edje_convert edje_decc edje_external_inspector edje_inspector edje_player edje_recc inkscape2edc; do
	rm -f ${TARGET_BIN_DIR}/bin/$f
	ln -sf ${HOST_BIN_DIR}/bin/$f ${TARGET_BIN_DIR}/bin/$f || error "symlink to host $f"
    done

    popd
    touch "$STATE_DIR/host_edje.installed"
}

build_host_edje
