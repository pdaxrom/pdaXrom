#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

MINIMOUNT_SVN_VERSION=svn
MINIMOUNT_SVN=minimount-${MINIMOUNT_SVN_VERSION}
MINIMOUNT_SVN_URL=https://pdaxrom.svn.sourceforge.net/svnroot/pdaxrom/trunk/minimount
MINIMOUNT_SVN_DIR=$BUILD_DIR/minimount-${MINIMOUNT_SVN_VERSION}
MINIMOUNT_SVN_ENV="$CROSS_ENV_AC"

build_minimount_svn() {
    test -e "$STATE_DIR/minimount_svn.installed" && return
    banner "Build minimount"
    if [ ! -d $MINIMOUNT_SVN_DIR ]; then
	download_svn $MINIMOUNT_SVN_URL $MINIMOUNT_SVN
        cp -R $SRC_DIR/$MINIMOUNT_SVN $MINIMOUNT_SVN_DIR
        apply_patches $MINIMOUNT_SVN_DIR $MINIMOUNT_SVN
    fi
    pushd $TOP_DIR
    cd $MINIMOUNT_SVN_DIR

    make $MAKEARGS CC=${CROSS}gcc || error

    install_fakeroot_init CC=${CROSS}gcc

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/minimount_svn.installed"
}

build_minimount_svn
