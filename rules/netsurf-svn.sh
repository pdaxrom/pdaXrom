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

NETSURF_VERSION=svn
NETSURF=netsurf-${NETSURF_VERSION}
NETSURF_SVN=svn://svn.netsurf-browser.org/trunk/netsurf
NETSURF_DIR=$BUILD_DIR/netsurf-${NETSURF_VERSION}
NETSURF_ENV="$CROSS_ENV_AC"

build_netsurf() {
    test -e "$STATE_DIR/netsurf.installed" && return
    banner "Build netsurf"
    if [ ! -d $NETSURF_DIR ]; then
	download_svn $NETSURF_SVN $NETSURF
	cp -R $SRC_DIR/$NETSURF $NETSURF_DIR
	apply_patches $NETSURF_DIR $NETSURF
    fi
    pushd $TOP_DIR
    cd $NETSURF_DIR

    make CC=${CROSS}gcc AR=${CROSS}ar NETSURF_FB_FONTLIB=freetype PREFIX=/usr TARGET=framebuffer || error
    install_fakeroot_init CC=${CROSS}gcc AR=${CROSS}ar NETSURF_FB_FONTLIB=freetype PREFIX=/usr TARGET=framebuffer

    #make CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr TARGET=framebuffer || error
    #install_fakeroot_init CC=${CROSS}gcc AR=${CROSS}ar PREFIX=/usr TARGET=framebuffer

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/netsurf.installed"
}

build_netsurf
