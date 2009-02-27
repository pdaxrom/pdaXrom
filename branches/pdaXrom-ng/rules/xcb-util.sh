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

XCB_UTIL_VERSION=0.3.3
XCB_UTIL=xcb-util-${XCB_UTIL_VERSION}.tar.bz2
XCB_UTIL_MIRROR=http://xcb.freedesktop.org/dist
XCB_UTIL_DIR=$BUILD_DIR/xcb-util-${XCB_UTIL_VERSION}
XCB_UTIL_ENV="$CROSS_ENV_AC"

build_xcb_util() {
    test -e "$STATE_DIR/xcb_util-${XCB_UTIL_VERSION}.installed" && return
    banner "Build xcb-util"
    download $XCB_UTIL_MIRROR $XCB_UTIL
    extract $XCB_UTIL
    apply_patches $XCB_UTIL_DIR $XCB_UTIL
    pushd $TOP_DIR
    cd $XCB_UTIL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XCB_UTIL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    find . -name "*.so.*.*.*" -a ! -name "*.[0-9]T" | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/lib/${f/*\//} || error
	ln -sf ${f/*\//} $ROOTFS_DIR/usr/lib/`echo ${f/*\//} | sed 's/\.[0-9]\.[0-9]$//'`
	ln -sf ${f/*\//} $ROOTFS_DIR/usr/lib/`echo ${f/*\//} | sed 's/\.[0-9]\.[0-9]\.[0-9]$//'`
	$STRIP $ROOTFS_DIR/usr/lib/${f/*\//}
    done

    popd
    touch "$STATE_DIR/xcb_util-${XCB_UTIL_VERSION}.installed"
}

build_xcb_util
