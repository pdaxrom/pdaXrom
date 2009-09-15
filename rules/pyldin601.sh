#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

PYLDIN601=pyldin601-3.2
PYLDIN601_MIRROR=http://mail.pdaXrom.org/files
PYLDIN601_SVN=https://mail.pdaxrom.org/svn/pyldin/trunk
PYLDIN601_DIR=$BUILD_DIR/pyldin601-3.2
PYLDIN601_ENV=

build_pyldin601() {
    test -e "$STATE_DIR/pyldin601-3.2" && return
    banner "Build $PYLDIN601"
    download_svn $PYLDIN601_SVN $PYLDIN601
    cp -R $SRC_DIR/$PYLDIN601 $PYLDIN601_DIR/
    apply_patches $PYLDIN601_DIR $PYLDIN601
    
    pushd $TOP_DIR
    cd $PYLDIN601_DIR/pyldin601

    make CC=${TARGET_ARCH}-gcc CXX=${TARGET_ARCH}-g++ $MAKEARGS \
	EXTRA_CFLAGS="$CROSS_CFLAGS" OPT_LIBS="$EXTRA_LDFLAGS" \
	|| error

    make DESTDIR=$ROOTFS_DIR install || error

    $STRIP $ROOTFS_DIR/usr/bin/pyldin

    popd
    touch "$STATE_DIR/pyldin601-3.2"
}

build_pyldin601
