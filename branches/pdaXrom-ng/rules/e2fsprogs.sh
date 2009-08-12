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

E2FSPROGS_VERSION=1.41.4
E2FSPROGS=e2fsprogs-${E2FSPROGS_VERSION}.tar.gz
E2FSPROGS_MIRROR=http://prdownloads.sourceforge.net/e2fsprogs
E2FSPROGS_DIR=$BUILD_DIR/e2fsprogs-${E2FSPROGS_VERSION}
E2FSPROGS_ENV="$CROSS_ENV_AC"

build_e2fsprogs() {
    test -e "$STATE_DIR/e2fsprogs.installed" && return
    banner "Build e2fsprogs"
    download $E2FSPROGS_MIRROR $E2FSPROGS
    extract $E2FSPROGS
    apply_patches $E2FSPROGS_DIR $E2FSPROGS
    pushd $TOP_DIR
    cd $E2FSPROGS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$E2FSPROGS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --with-cc=${CROSS}gcc \
	    --with-linker=${CROSS}gcc \
	    --enable-elf-shlibs \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make -C lib/uuid $MAKEARGS DESTDIR=$TARGET_BIN_DIR install || error
    make -C lib/blkid $MAKEARGS DESTDIR=$TARGET_BIN_DIR install || error
    install_sysroot_files || error

    make $MAKEARGS DESTDIR=$E2FSPROGS_DIR/fakeroot install || error

    rm -rf fakeroot/usr/share fakeroot/usr/lib
    ln -sf e2fsck fakeroot/sbin/fsck.ext2
    ln -sf e2fsck fakeroot/sbin/fsck.ext3
    ln -sf e2fsck fakeroot/sbin/fsck.ext4
    ln -sf e2fsck fakeroot/sbin/fsck.ext4dev

    ln -sf mke2fs fakeroot/sbin/mkfs.ext2
    ln -sf mke2fs fakeroot/sbin/mkfs.ext3
    ln -sf mke2fs fakeroot/sbin/mkfs.ext4
    ln -sf mke2fs fakeroot/sbin/mkfs.ext4dev

    $STRIP fakeroot/lib/*
    $STRIP fakeroot/sbin/*
    $STRIP fakeroot/usr/bin/*
    $STRIP fakeroot/usr/sbin/*
    
    cd fakeroot
    
    find . -not -type d -exec rm -f ${ROOTFS_DIR}/{} \; -exec cp -a {} ${ROOTFS_DIR}/{} \; || error

    popd
    touch "$STATE_DIR/e2fsprogs.installed"
}

build_e2fsprogs
