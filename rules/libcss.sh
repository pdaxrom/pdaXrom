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

LIBCSS_VERSION=svn
LIBCSS=libcss-${LIBCSS_VERSION}
LIBCSS_SVN=svn://svn.netsurf-browser.org/trunk/libcss
LIBCSS_DIR=$BUILD_DIR/libcss-${LIBCSS_VERSION}
LIBCSS_ENV="$CROSS_ENV_AC"

build_libcss() {
    test -e "$STATE_DIR/libcss.installed" && return
    banner "Build libcss"
    download_svn $LIBCSS_SVN $LIBCSS
    cp -R $SRC_DIR/$LIBCSS $LIBCSS_DIR
    apply_patches $LIBCSS_DIR $LIBCSS
    pushd $TOP_DIR
    cd $LIBCSS_DIR

    make CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr  || error

    install_sysroot_files CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr || error

    #install_fakeroot_init
    #install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libcss.installed"
}

build_libcss
