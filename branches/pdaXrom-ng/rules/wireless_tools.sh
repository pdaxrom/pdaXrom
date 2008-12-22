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

WIRELESS_TOOLS=wireless_tools.29.tar.gz
WIRELESS_TOOLS_MIRROR=http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux
WIRELESS_TOOLS_DIR=$BUILD_DIR/wireless_tools.29
WIRELESS_TOOLS_ENV=

build_wireless_tools() {
    test -e "$STATE_DIR/wireless_tools-29" && return
    banner "Build $WIRELESS_TOOLS"
    download $WIRELESS_TOOLS_MIRROR $WIRELESS_TOOLS
    extract $WIRELESS_TOOLS
    apply_patches $WIRELESS_TOOLS_DIR $WIRELESS_TOOLS
    pushd $TOP_DIR
    cd $WIRELESS_TOOLS_DIR

    make $MAKEARGS CC=${TARGET_ARCH}-gcc || error

    for f in iwconfig iwevent iwgetid iwlist iwpriv iwspy; do
	$INSTALL -D -m 755 $f $ROOTFS_DIR/usr/sbin/$f
	$STRIP $ROOTFS_DIR/usr/sbin/$f
    done

    $INSTALL -D -m 644 libiw.so.29 $ROOTFS_DIR/usr/lib/libiw.so.29
    ln -s libiw.so.29 $ROOTFS_DIR/usr/lib/libiw.so
    $STRIP $ROOTFS_DIR/usr/lib/libiw.so.29

    popd
    touch "$STATE_DIR/wireless_tools-29"
}

build_wireless_tools