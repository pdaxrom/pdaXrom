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

SHARED_MIME_INFO=shared-mime-info-0.51.tar.bz2
SHARED_MIME_INFO_MIRROR=http://people.freedesktop.org/~hadess
SHARED_MIME_INFO_DIR=$BUILD_DIR/shared-mime-info-0.51
SHARED_MIME_INFO_ENV="$CROSS_ENV_AC"

build_shared_mime_info() {
    test -e "$STATE_DIR/shared_mime_info.installed" && return
    banner "Build shared-mime-info"
    download $SHARED_MIME_INFO_MIRROR $SHARED_MIME_INFO
    extract $SHARED_MIME_INFO
    apply_patches $SHARED_MIME_INFO_DIR $SHARED_MIME_INFO
    pushd $TOP_DIR
    cd $SHARED_MIME_INFO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SHARED_MIME_INFO_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 freedesktop.org.xml $ROOTFS_DIR/usr/share/mime/packages/freedesktop.org.xml || error
    $INSTALL -D -m 755 update-mime-database $ROOTFS_DIR/usr/bin/update-mime-database || error
    $STRIP $ROOTFS_DIR/usr/bin/update-mime-database

    update-mime-database $ROOTFS_DIR/usr/share/mime

    popd
    touch "$STATE_DIR/shared_mime_info.installed"
}

build_shared_mime_info
