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

LIBWAPCAPLET_VERSION=svn
LIBWAPCAPLET=libwapcaplet-${LIBWAPCAPLET_VERSION}
LIBWAPCAPLET_SVN=svn://svn.netsurf-browser.org/trunk/libwapcaplet
LIBWAPCAPLET_DIR=$BUILD_DIR/libwapcaplet-${LIBWAPCAPLET_VERSION}
LIBWAPCAPLET_ENV="$CROSS_ENV_AC"

build_libwapcaplet() {
    test -e "$STATE_DIR/libwapcaplet.installed" && return
    banner "Build libwapcaplet"
    download_svn $LIBWAPCAPLET_SVN $LIBWAPCAPLET
    cp -R $SRC_DIR/$LIBWAPCAPLET $LIBWAPCAPLET_DIR
    apply_patches $LIBWAPCAPLET_DIR $LIBWAPCAPLET
    pushd $TOP_DIR
    cd $LIBWAPCAPLET_DIR

    make CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr  || error

    install_sysroot_files CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr || error

    #install_fakeroot_init
    #install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libwapcaplet.installed"
}

build_libwapcaplet
