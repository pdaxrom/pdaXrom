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

PM_UTILS=pm-utils-1.2.3.tar.gz
PM_UTILS_MIRROR=http://pm-utils.freedesktop.org/releases
PM_UTILS_DIR=$BUILD_DIR/pm-utils-1.2.3
PM_UTILS_ENV="$CROSS_ENV_AC"

build_pm_utils() {
    test -e "$STATE_DIR/pm_utils.installed" && return
    banner "Build pm-utils"
    download $PM_UTILS_MIRROR $PM_UTILS
    extract $PM_UTILS
    apply_patches $PM_UTILS_DIR $PM_UTILS
    pushd $TOP_DIR
    cd $PM_UTILS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PM_UTILS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make DESTDIR=$PM_UTILS_DIR/fakeroot install || error
    rm -rf fakeroot/usr/share || error
    rm -rf fakeroot/usr/lib/pkgconfig || error
    $STRIP fakeroot/usr/lib/pm-utils/bin/pm-pmu || error
    $STRIP fakeroot/usr/lib/pm-utils/bin/pm-reset-swap || error

    cp -R fakeroot/etc $ROOTFS_DIR/ || error
    cp -R fakeroot/usr $ROOTFS_DIR/ || error

    popd
    touch "$STATE_DIR/pm_utils.installed"
}

build_pm_utils
