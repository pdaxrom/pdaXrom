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

setup_spufs() {
    test -e "$STATE_DIR/spufs" && return
    banner "Setup spufs"
    $INSTALL -d -m 755 $ROOTFS_DIR/spu
    grep -q 'spufs' $ROOTFS_DIR/etc/fstab || cat << END >> $ROOTFS_DIR/etc/fstab
none	/spu		spufs	defaults	0	0
END
    grep -q 'binfmt' $ROOTFS_DIR/etc/fstab || cat << END >> $ROOTFS_DIR/etc/fstab
none	/proc/sys/fs/binfmt_misc binfmt_misc defaults	0	0
END

    if [ -e $TOOLCHAIN_SYSROOT/usr/bin/elfspe ]; then
	install_rootfs_exec /usr/bin $TOOLCHAIN_SYSROOT/usr/bin/elfspe
	install_rootfs_file /usr/bin $TOOLCHAIN_SYSROOT/usr/bin/elfspe-register
	install_rootfs_file /usr/bin $TOOLCHAIN_SYSROOT/usr/bin/elfspe-unregister
    fi
    touch "$STATE_DIR/spufs"
}

setup_spufs
