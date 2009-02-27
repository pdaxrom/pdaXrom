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

XF86_VIDEO_AST_VERSION=0.88.8
XF86_VIDEO_AST=xf86-video-ast-${XF86_VIDEO_AST_VERSION}.tar.bz2
XF86_VIDEO_AST_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/driver
XF86_VIDEO_AST_DIR=$BUILD_DIR/xf86-video-ast-${XF86_VIDEO_AST_VERSION}
XF86_VIDEO_AST_ENV="$CROSS_ENV_AC"

build_xf86_video_ast() {
    test -e "$STATE_DIR/xf86_video_ast-${XF86_VIDEO_AST_VERSION}.installed" && return
    banner "Build xf86-video-ast"
    download $XF86_VIDEO_AST_MIRROR $XF86_VIDEO_AST
    extract $XF86_VIDEO_AST
    apply_patches $XF86_VIDEO_AST_DIR $XF86_VIDEO_AST
    pushd $TOP_DIR
    cd $XF86_VIDEO_AST_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_VIDEO_AST_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 644 src/.libs/ast_drv.so $ROOTFS_DIR/usr/lib/xorg/modules/drivers/ast_drv.so || error
    $STRIP $ROOTFS_DIR/usr/lib/xorg/modules/drivers/ast_drv.so

    popd
    touch "$STATE_DIR/xf86_video_ast-${XF86_VIDEO_AST_VERSION}.installed"
}

build_xf86_video_ast
