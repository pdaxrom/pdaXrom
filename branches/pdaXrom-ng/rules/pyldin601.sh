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

PYLDIN601=pyldin601-3.2.tar.bz2
PYLDIN601_MIRROR=http://wiki.pdaXrom.org/files
PYLDIN601_SVN=https://mail.pdaxrom.org/svn/pyldin/trunk
PYLDIN601_DIR=$BUILD_DIR/pyldin601-3.2
PYLDIN601_ENV=

build_pyldin601() {
    test -e "$STATE_DIR/pyldin601-3.2" && return
    banner "Build $PYLDIN601"
    #download $PYLDIN601_MIRROR $PYLDIN601
    #extract $PYLDIN601
    #apply_patches $PYLDIN601_DIR $PYLDIN601
    
    if [ ! -d $PYLDIN601_DIR/pyldin601/.svn ]; then
	echo "Download sources"
	svn co $PYLDIN601_SVN $PYLDIN601_DIR
    else
	echo "Update sources"
	pushd $TOP_DIR
	cd $PYLDIN601_DIR
	svn update || error
	popd
    fi
    
    pushd $TOP_DIR
    cd $PYLDIN601_DIR/pyldin601

    make CC=${CROSS}gcc CXX=${CROSS}g++ $MAKEARGS \
	EXTRA_CFLAGS="$CROSS_CFLAGS" OPT_LIBS="$EXTRA_LDFLAGS" \
	|| error

    make DESTDIR=$ROOTFS_DIR install || error

    $STRIP $ROOTFS_DIR/usr/bin/pyldin

    popd
    touch "$STATE_DIR/pyldin601-3.2"
}

build_pyldin601
