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

LIBNSBMP_VERSION=svn
LIBNSBMP=libnsbmp-${LIBNSBMP_VERSION}
LIBNSBMP_SVN=svn://svn.netsurf-browser.org/trunk/libnsbmp
LIBNSBMP_DIR=$BUILD_DIR/libnsbmp-${LIBNSBMP_VERSION}
LIBNSBMP_ENV="$CROSS_ENV_AC"

build_libnsbmp() {
    test -e "$STATE_DIR/libnsbmp.installed" && return
    banner "Build libnsbmp"
    download_svn $LIBNSBMP_SVN $LIBNSBMP
    cp -R $SRC_DIR/$LIBNSBMP $LIBNSBMP_DIR
    apply_patches $LIBNSBMP_DIR $LIBNSBMP
    pushd $TOP_DIR
    cd $LIBNSBMP_DIR

    make CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr  || error

    install_sysroot_files CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr || error

    #install_fakeroot_init
    #install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libnsbmp.installed"
}

build_libnsbmp
