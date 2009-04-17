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

HAL=hal-0.5.12rc1.tar.gz
HAL_MIRROR=http://hal.freedesktop.org/releases
HAL_DIR=$BUILD_DIR/hal-0.5.12rc1
HAL_ENV="$CROSS_ENV_AC"

build_hal() {
    test -e "$STATE_DIR/hal.installed" && return
    banner "Build hal"
    download $HAL_MIRROR $HAL
    extract $HAL
    apply_patches $HAL_DIR $HAL
    pushd $TOP_DIR
    cd $HAL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$HAL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/hal \
	    --localstatedir=/var \
	    --disable-verbose-mode \
	    --disable-docbook-docs \
	    --disable-man-pages \
	    --disable-gtk-doc \
	    --disable-smbios \
	    --disable-pmu \
	    --disable-policy-kit \
	    --disable-pnp-ids \
	    --with-hwdata=/usr/share/hwdata \
	    --with-linux-input-header=$KERNEL_DIR/include/linux/input.h \
	    --disable-static \
	    --enable-shared \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    make DESTDIR=$HAL_DIR/fakeroot install || error
    
    rm -rf fakeroot/usr/include \
	fakeroot/usr/lib/pkgconfig \
	fakeroot/usr/lib/*.*a \
	fakeroot/usr/share/gtk-doc \
	fakeroot/usr/share/man

    find fakeroot/ -executable -a ! -type d -a ! -type l | while read f; do
	$STRIP $f
    done

    cp -R fakeroot/etc $ROOTFS_DIR/ || error
    cp -R fakeroot/usr $ROOTFS_DIR/ || error
    cp -R fakeroot/var $ROOTFS_DIR/ || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/hal $ROOTFS_DIR/etc/init.d/hal || error
    install_rc_start hal 10
    install_rc_stop  hal 70

    popd
    touch "$STATE_DIR/hal.installed"
}

build_hal
