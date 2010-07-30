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

LIBPARSERUTILS_VERSION=svn
LIBPARSERUTILS=libparserutils-${LIBPARSERUTILS_VERSION}
LIBPARSERUTILS_SVN=svn://svn.netsurf-browser.org/trunk/libparserutils
LIBPARSERUTILS_DIR=$BUILD_DIR/libparserutils-${LIBPARSERUTILS_VERSION}
LIBPARSERUTILS_ENV="$CROSS_ENV_AC"

build_libparserutils() {
    test -e "$STATE_DIR/libparserutils.installed" && return
    banner "Build libparserutils"
    download_svn $LIBPARSERUTILS_SVN $LIBPARSERUTILS
    cp -R $SRC_DIR/$LIBPARSERUTILS $LIBPARSERUTILS_DIR
    apply_patches $LIBPARSERUTILS_DIR $LIBPARSERUTILS
    pushd $TOP_DIR
    cd $LIBPARSERUTILS_DIR

    make CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr  || error

    install_sysroot_files CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr || error

    #install_fakeroot_init
    #install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libparserutils.installed"
}

build_libparserutils
