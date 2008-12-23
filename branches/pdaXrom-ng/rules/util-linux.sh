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

UTIL_LINUX=util-linux-2.13-pre7.tar.bz2
UTIL_LINUX_MIRROR=http://www.kernel.org/pub/linux/utils/util-linux/testing
UTIL_LINUX_DIR=$BUILD_DIR/util-linux-2.13-pre7
UTIL_LINUX_ENV="$CROSS_ENV_AC"

build_util_linux() {
    test -e "$STATE_DIR/util_linux.installed" && return
    banner "Build util-linux"
    download $UTIL_LINUX_MIRROR $UTIL_LINUX
    extract $UTIL_LINUX
    apply_patches $UTIL_LINUX_DIR $UTIL_LINUX
    pushd $TOP_DIR
    cd $UTIL_LINUX_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$UTIL_LINUX_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS CC=${CROSS}gcc || error

    $INSTALL -D -m 755 misc-utils/mcookie $ROOTFS_DIR/usr/bin/mcookie || error
    $STRIP $ROOTFS_DIR/usr/bin/mcookie

    popd
    touch "$STATE_DIR/util_linux.installed"
}

build_util_linux
