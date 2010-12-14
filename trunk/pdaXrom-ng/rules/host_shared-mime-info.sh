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

HOST_SHARED_MIME_INFO=shared-mime-info-0.90.tar.bz2
HOST_SHARED_MIME_INFO_MIRROR=http://people.freedesktop.org/~hadess
HOST_SHARED_MIME_INFO_DIR=$HOST_BUILD_DIR/shared-mime-info-0.90
HOST_SHARED_MIME_INFO_ENV="PKG_CONFIG=\"$HOST_PKG_CONFIG\""

build_host_shared_mime_info() {
    test -e "$STATE_DIR/host_shared_mime_info.installed" && return
    banner "Build host-shared-mime-info"
    download $HOST_SHARED_MIME_INFO_MIRROR $HOST_SHARED_MIME_INFO
    extract_host $HOST_SHARED_MIME_INFO
    apply_patches $HOST_SHARED_MIME_INFO_DIR $HOST_SHARED_MIME_INFO
    pushd $TOP_DIR
    cd $HOST_SHARED_MIME_INFO_DIR
    (
    unset PKG_CONFIG_PATH
    eval $HOST_SHARED_MIME_INFO_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS update-mime-database || error

    $INSTALL -D -m 755 update-mime-database $HOST_BIN_DIR/bin/update-mime-database || error

    popd
    touch "$STATE_DIR/host_shared_mime_info.installed"
}

build_host_shared_mime_info
