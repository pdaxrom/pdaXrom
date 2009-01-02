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

HAL_INFO=hal-info-20081219.tar.gz
HAL_INFO_MIRROR=http://hal.freedesktop.org/releases
HAL_INFO_DIR=$BUILD_DIR/hal-info-20081219
HAL_INFO_ENV="$CROSS_ENV_AC"

build_hal_info() {
    test -e "$STATE_DIR/hal_info.installed" && return
    banner "Build hal-info"
    download $HAL_INFO_MIRROR $HAL_INFO
    extract $HAL_INFO
    apply_patches $HAL_INFO_DIR $HAL_INFO
    pushd $TOP_DIR
    cd $HAL_INFO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$HAL_INFO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make DESTDIR=$ROOTFS_DIR install || error

    popd
    touch "$STATE_DIR/hal_info.installed"
}

build_hal_info
