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

SDL_IMAGE=SDL_image-1.2.7.tar.gz
SDL_IMAGE_MIRROR=http://www.libsdl.org/projects/SDL_image/release
SDL_IMAGE_DIR=$BUILD_DIR/SDL_image-1.2.7
SDL_IMAGE_ENV=

build_SDL_image() {
    test -e "$STATE_DIR/SDL_image-1.2.7" && return
    banner "Build $SDL_IMAGE"
    download $SDL_IMAGE_MIRROR $SDL_IMAGE
    extract $SDL_IMAGE
    apply_patches $SDL_IMAGE_DIR $SDL_IMAGE
    pushd $TOP_DIR
    cd $SDL_IMAGE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SDL_IMAGE_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-jpg \
	    --enable-jpg-shared=no \
	    --enable-png \
	    --enable-png-shared=no \
	    --disable-tif \
	    --disable-static \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files

    $INSTALL -m 644 .libs/libSDL_image-1.2.so.0.1.6 $ROOTFS_DIR/usr/lib/
    ln -sf libSDL_image-1.2.so.0.1.6 $ROOTFS_DIR/usr/lib/libSDL_image-1.2.so.0
    ln -sf libSDL_image-1.2.so.0.1.6 $ROOTFS_DIR/usr/lib/libSDL_image.so
    $STRIP $ROOTFS_DIR/usr/lib/libSDL_image-1.2.so.0.1.6

    popd
    touch "$STATE_DIR/SDL_image-1.2.7"
}

build_SDL_image
