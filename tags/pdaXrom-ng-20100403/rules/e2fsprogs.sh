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

E2FSPROGS_VERSION=1.41.9
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
    local C=
    case ${CROSS} in
    *uclibc*)
	C="--disable-tls"
	;;
    esac
    cd $E2FSPROGS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$E2FSPROGS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --with-cc=${CROSS}gcc \
	    --with-linker=${CROSS}gcc \
	    --enable-elf-shlibs \
	    $C \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make -C lib/uuid $MAKEARGS DESTDIR=$TARGET_BIN_DIR install || error
    make -C lib/blkid $MAKEARGS DESTDIR=$TARGET_BIN_DIR install || error

    install_sysroot_files || error

    ln -sf libblkid.so.1	$TARGET_LIB/libblkid.so
    ln -sf libcom_err.so.2	$TARGET_LIB/libcom_err.so
    ln -sf libe2p.so.2		$TARGET_LIB/libe2p.so
    ln -sf libext2fs.so.2	$TARGET_LIB/libext2fs.so
    ln -sf libss.so.2		$TARGET_LIB/libss.so
    ln -sf libuuid.so.1		$TARGET_LIB/libuuid.so

    install_fakeroot_init

    ln -sf e2fsck fakeroot/sbin/fsck.ext2
    ln -sf e2fsck fakeroot/sbin/fsck.ext3
    ln -sf e2fsck fakeroot/sbin/fsck.ext4
    ln -sf e2fsck fakeroot/sbin/fsck.ext4dev

    ln -sf mke2fs fakeroot/sbin/mkfs.ext2
    ln -sf mke2fs fakeroot/sbin/mkfs.ext3
    ln -sf mke2fs fakeroot/sbin/mkfs.ext4
    ln -sf mke2fs fakeroot/sbin/mkfs.ext4dev

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/e2fsprogs.installed"
}

build_e2fsprogs
