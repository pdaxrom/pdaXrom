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

XF86_INPUT_SYNAPTICS_VERSION=1.3.0
XF86_INPUT_SYNAPTICS=xf86-input-synaptics-${XF86_INPUT_SYNAPTICS_VERSION}.tar.bz2
XF86_INPUT_SYNAPTICS_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_INPUT_SYNAPTICS_DIR=$BUILD_DIR/xf86-input-synaptics-${XF86_INPUT_SYNAPTICS_VERSION}
XF86_INPUT_SYNAPTICS_ENV=

build_xf86_input_synaptics() {
    test -e "$STATE_DIR/xf86_input_synaptics-${XF86_INPUT_SYNAPTICS_VERSION}" && return
    banner "Build $XF86_INPUT_SYNAPTICS"
    download $XF86_INPUT_SYNAPTICS_MIRROR $XF86_INPUT_SYNAPTICS
    extract $XF86_INPUT_SYNAPTICS
    apply_patches $XF86_INPUT_SYNAPTICS_DIR $XF86_INPUT_SYNAPTICS
    pushd $TOP_DIR
    cd $XF86_INPUT_SYNAPTICS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_INPUT_SYNAPTICS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/synaptics_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/input/synaptics_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/input/synaptics_drv.so

    for f in synclient syndaemon; do
	$INSTALL -D -m 755 tools/$f $ROOTFS_DIR/usr/bin/$f || error
	$STRIP $ROOTFS_DIR/usr/bin/$f
    done

    popd
    touch "$STATE_DIR/xf86_input_synaptics-${XF86_INPUT_SYNAPTICS_VERSION}"
}

build_xf86_input_synaptics
