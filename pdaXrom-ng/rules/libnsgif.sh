#
# packet template
#
# Copyright (C) 2009 by Marina Popova <marika@tusur.info>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

LIBNSGIF_VERSION=svn
LIBNSGIF=libnsgif-${LIBNSGIF_VERSION}
LIBNSGIF_SVN=svn://svn.netsurf-browser.org/trunk/libnsgif
LIBNSGIF_DIR=$BUILD_DIR/libnsgif-${LIBNSGIF_VERSION}
LIBNSGIF_ENV="$CROSS_ENV_AC"

build_libnsgif() {
    test -e "$STATE_DIR/libnsgif.installed" && return
    banner "Build libnsgif"
    download_svn $LIBNSGIF_SVN $LIBNSGIF
    cp -R $SRC_DIR/$LIBNSGIF $LIBNSGIF_DIR
    apply_patches $LIBNSGIF_DIR $LIBNSGIF
    pushd $TOP_DIR
    cd $LIBNSGIF_DIR

    make CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr  || error

    install_sysroot_files CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr || error

    #install_fakeroot_init
    #install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libnsgif.installed"
}

build_libnsgif
