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

DIRECTFB_VERSION=1.3.0
DIRECTFB=DirectFB-${DIRECTFB_VERSION}.tar.gz
DIRECTFB_MIRROR=http://www.directfb.org/downloads/Core
DIRECTFB_DIR=$BUILD_DIR/DirectFB-${DIRECTFB_VERSION}
DIRECTFB_ENV="$CROSS_ENV_AC"

build_DirectFB() {
    test -e "$STATE_DIR/DirectFB.installed" && return
    banner "Build DirectFB"
    download $DIRECTFB_MIRROR $DIRECTFB
    extract $DIRECTFB
    apply_patches $DIRECTFB_DIR $DIRECTFB
    pushd $TOP_DIR
    ln -sf $KERNEL_DIR/include/linux $TARGET_INC/linux || error
    ln -sf $KERNEL_DIR/include/asm $TARGET_INC/asm || error
    cd $DIRECTFB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$DIRECTFB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-gfxdrivers=none \
	    --enable-fbdev \
	    --with-inputdrivers=joystick,keyboard,linuxinput,ps2mouse \
	    --with-smooth-scaling \
	    --enable-video4linux=no \
	    --with-tests \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    make $MAKEARGS DESTDIR=$DIRECTFB_DIR/fakeroot install || error
    find fakeroot/ -name "*.la" | xargs rm -f
    find fakeroot/ -executable -a ! -type d -a ! -type l | while read f; do
	$STRIP $f
    done

    rm -rf fakeroot/usr/include fakeroot/usr/share/man fakeroot/usr/lib/pkgconfig
    rm -f fakeroot/usr/bin/directfb-config fakeroot/usr/bin/directfb-csource

    cp -a fakeroot/usr $ROOTFS_DIR/ || error

    popd
    touch "$STATE_DIR/DirectFB.installed"
}

build_DirectFB
