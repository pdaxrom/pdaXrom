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

HOST_ICU4C=icu4c-4_1_1-src.tgz
HOST_ICU4C_MIRROR=http://download.icu-project.org/files/icu4c/4.1
HOST_ICU4C_DIR=$HOST_BUILD_DIR/icu/source
HOST_ICU4C_ENV=

build_host_icu4c() {
    test -e "$STATE_DIR/host_icu4c.installed" && return
    banner "Build host-icu4c"
    download $HOST_ICU4C_MIRROR $HOST_ICU4C
    extract_host $HOST_ICU4C
    apply_patches $HOST_ICU4C_DIR/.. $HOST_ICU4C
    pushd $TOP_DIR
    cd $HOST_ICU4C_DIR
    (
    eval $HOST_ICU4C_ENV \
	./configure --prefix=$HOST_BIN_DIR \
	    --disable-shared \
	    --enable-static
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_icu4c.installed"
}

build_host_icu4c
