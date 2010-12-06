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

LIBROSPRITE_VERSION=svn
LIBROSPRITE=librosprite-${LIBROSPRITE_VERSION}
LIBROSPRITE_SVN=svn://svn.netsurf-browser.org/trunk/librosprite
LIBROSPRITE_DIR=$BUILD_DIR/librosprite-${LIBROSPRITE_VERSION}
LIBROSPRITE_ENV="$CROSS_ENV_AC"

build_librosprite() {
    test -e "$STATE_DIR/librosprite.installed" && return
    banner "Build librosprite"
    download_svn $LIBROSPRITE_SVN $LIBROSPRITE
    cp -R $SRC_DIR/$LIBROSPRITE $LIBROSPRITE_DIR
    apply_patches $LIBROSPRITE_DIR $LIBROSPRITE
    pushd $TOP_DIR
    cd $LIBROSPRITE_DIR

    make CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr  || error

    install_sysroot_files CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr || error

    #install_fakeroot_init
    #install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/librosprite.installed"
}

build_librosprite
