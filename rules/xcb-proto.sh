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

XCB_PROTO_VERSION=1.4
XCB_PROTO=xcb-proto-${XCB_PROTO_VERSION}.tar.bz2
XCB_PROTO_MIRROR=http://xcb.freedesktop.org/dist
XCB_PROTO_DIR=$BUILD_DIR/xcb-proto-${XCB_PROTO_VERSION}
XCB_PROTO_ENV=

build_xcb_proto() {
    test -e "$STATE_DIR/xcb_proto-${XCB_PROTO_VERSION}" && return
    banner "Build $XCB_PROTO"
    download $XCB_PROTO_MIRROR $XCB_PROTO
    extract $XCB_PROTO
    apply_patches $XCB_PROTO_DIR $XCB_PROTO
    pushd $TOP_DIR
    cd $XCB_PROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XCB_PROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files

    popd
    touch "$STATE_DIR/xcb_proto-${XCB_PROTO_VERSION}"
}

build_xcb_proto
