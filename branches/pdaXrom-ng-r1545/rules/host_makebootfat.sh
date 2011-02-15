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

HOST_MAKEBOOTFAT_VERSION=1.4
HOST_MAKEBOOTFAT=makebootfat-${HOST_MAKEBOOTFAT_VERSION}.tar.gz
HOST_MAKEBOOTFAT_MIRROR=http://downloads.sourceforge.net/project/advancemame/advanceboot/1.4
HOST_MAKEBOOTFAT_DIR=$HOST_BUILD_DIR/makebootfat-${HOST_MAKEBOOTFAT_VERSION}
HOST_MAKEBOOTFAT_ENV=

build_host_makebootfat() {
    test -e "$STATE_DIR/host_makebootfat.installed" && return
    banner "Build host-makebootfat"
    download $HOST_MAKEBOOTFAT_MIRROR $HOST_MAKEBOOTFAT
    extract_host $HOST_MAKEBOOTFAT
    apply_patches $HOST_MAKEBOOTFAT_DIR $HOST_MAKEBOOTFAT
    pushd $TOP_DIR
    cd $HOST_MAKEBOOTFAT_DIR
    (
    eval $HOST_MAKEBOOTFAT_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_makebootfat.installed"
}

build_host_makebootfat
