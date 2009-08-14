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

DRI2PROTO_VERSION=1.99.3
DRI2PROTO=dri2proto-${DRI2PROTO_VERSION}.tar.bz2
DRI2PROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
DRI2PROTO_DIR=$BUILD_DIR/dri2proto-${DRI2PROTO_VERSION}
DRI2PROTO_ENV="$CROSS_ENV_AC"

build_dri2proto() {
    test -e "$STATE_DIR/dri2proto.installed" && return
    banner "Build dri2proto"
    download $DRI2PROTO_MIRROR $DRI2PROTO
    extract $DRI2PROTO
    apply_patches $DRI2PROTO_DIR $DRI2PROTO
    pushd $TOP_DIR
    cd $DRI2PROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$DRI2PROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/dri2proto.installed"
}

build_dri2proto
