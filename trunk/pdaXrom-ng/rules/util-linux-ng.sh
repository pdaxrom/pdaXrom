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

UTIL_LINUX_NG_VERSION=2.16.1
UTIL_LINUX_NG=util-linux-ng-${UTIL_LINUX_NG_VERSION}.tar.bz2
UTIL_LINUX_NG_MIRROR=ftp://ftp.kernel.org/pub/linux/utils/util-linux-ng/v2.16
UTIL_LINUX_NG_DIR=$BUILD_DIR/util-linux-ng-${UTIL_LINUX_NG_VERSION}
UTIL_LINUX_NG_ENV="$CROSS_ENV_AC"

build_util_linux_ng() {
    test -e "$STATE_DIR/util_linux_ng.installed" && return
    banner "Build util-linux-ng"
    download $UTIL_LINUX_NG_MIRROR $UTIL_LINUX_NG
    extract $UTIL_LINUX_NG
    apply_patches $UTIL_LINUX_NG_DIR $UTIL_LINUX_NG
    pushd $TOP_DIR
    cd $UTIL_LINUX_NG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$UTIL_LINUX_NG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    #install_fakeroot_finish || error

    install_rootfs_exec /sbin fakeroot/sbin/mkswap
    install_rootfs_exec /sbin fakeroot/sbin/blkid
    install_rootfs_exec /sbin fakeroot/sbin/findfs
    install_rootfs_exec /bin  fakeroot/bin/mount
    install_rootfs_exec /bin  fakeroot/bin/umount
    install_rootfs_exec /usr/bin fakeroot/usr/bin/mcookie

    #install_fakeroot_init
    #error "asd"
    #install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/util_linux_ng.installed"
}

build_util_linux_ng
