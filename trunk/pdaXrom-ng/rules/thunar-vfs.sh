#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

THUNAR_VFS_VERSION=1.1.1
THUNAR_VFS=thunar-vfs-${THUNAR_VFS_VERSION}.tar.bz2
THUNAR_VFS_MIRROR=http://archive.xfce.org/src/xfce/thunar-vfs/1.1
THUNAR_VFS_DIR=$BUILD_DIR/thunar-vfs-${THUNAR_VFS_VERSION}
THUNAR_VFS_ENV="$CROSS_ENV_AC"

build_thunar_vfs() {
    test -e "$STATE_DIR/thunar_vfs.installed" && return
    banner "Build thunar-vfs"
    download $THUNAR_VFS_MIRROR $THUNAR_VFS
    extract $THUNAR_VFS
    apply_patches $THUNAR_VFS_DIR $THUNAR_VFS
    pushd $TOP_DIR
    cd $THUNAR_VFS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$THUNAR_VFS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/thunar_vfs.installed"
}

build_thunar_vfs
