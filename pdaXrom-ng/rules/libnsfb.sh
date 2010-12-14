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

LIBNSFB_VERSION=svn
LIBNSFB=libnsfb-${LIBNSFB_VERSION}
LIBNSFB_SVN=svn://svn.netsurf-browser.org/trunk/libnsfb
LIBNSFB_DIR=$BUILD_DIR/libnsfb-${LIBNSFB_VERSION}
LIBNSFB_ENV="$CROSS_ENV_AC"

build_libnsfb() {
    test -e "$STATE_DIR/libnsfb.installed" && return
    banner "Build libnsfb"
    download_svn $LIBNSFB_SVN $LIBNSFB
    cp -R $SRC_DIR/$LIBNSFB $LIBNSFB_DIR
    apply_patches $LIBNSFB_DIR $LIBNSFB
    pushd $TOP_DIR
    cd $LIBNSFB_DIR

    sed -i -e 's|-Werror||' Makefile

    make CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr  || error

    install_sysroot_files CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr || error

    #install_fakeroot_init
    #install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libnsfb.installed"
}

build_libnsfb
