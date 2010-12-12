#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HAL_VERSION=0.5.14
HAL=hal-${HAL_VERSION}.tar.bz2
HAL_MIRROR=http://hal.freedesktop.org/releases
HAL_DIR=$BUILD_DIR/hal-${HAL_VERSION}
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
	    --disable-pnp-ids \
	    --disable-policy-kit \
	    --disable-console-kit \
	    --with-hwdata=/usr/share/hwdata \
	    --with-udev-prefix=/lib \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/hal $ROOTFS_DIR/etc/init.d/hal || error
    if [ "$USE_FASTBOOT" = "yes" ]; then
	install_rc_start hal 01
    else
	install_rc_start hal 10
    fi
    install_rc_stop  hal 70

    popd
    touch "$STATE_DIR/hal.installed"
}

build_hal
