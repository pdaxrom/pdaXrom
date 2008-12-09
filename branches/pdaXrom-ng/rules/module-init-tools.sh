#
# packet template
#
# Copyright (C) 2004 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

MODULE_INIT_TOOLS=module-init-tools-3.5.tar.bz2
MODULE_INIT_TOOLS_MIRROR=http://www.kernel.org/pub/linux/utils/kernel/module-init-tools
MODULE_INIT_TOOLS_DIR=$BUILD_DIR/module-init-tools-3.5
MODULE_INIT_TOOLS_ENV=

build_module_init_tools() {
    test -e "$STATE_DIR/module-init-tools-3.5" && return
    banner "Build $MODULE_INIT_TOOLS"
    download $MODULE_INIT_TOOLS_MIRROR $MODULE_INIT_TOOLS
    extract $MODULE_INIT_TOOLS
    apply_patches $MODULE_INIT_TOOLS_DIR $MODULE_INIT_TOOLS
    pushd $TOP_DIR
    cd $MODULE_INIT_TOOLS_DIR
    eval $MODULE_INIT_TOOLS_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/ \
	    --sysconfdir=/etc || error
    make $MAKEARGS || error
    $STRIP depmod lsmod insmod modprobe rmmod
    $INSTALL -m 755 depmod insmod lsmod modprobe rmmod $ROOTFS_DIR/sbin/ || error
    popd
    touch "$STATE_DIR/module-init-tools-3.5"
}

build_module_init_tools
