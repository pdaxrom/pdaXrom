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
    cat << END >> $ROOTFS_DIR/etc/fstab
none	/spu		spufs	defaults	0	0
END
    touch "$STATE_DIR/spufs"
}

setup_spufs
