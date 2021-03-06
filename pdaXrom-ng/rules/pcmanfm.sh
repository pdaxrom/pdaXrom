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

PCMANFM_VERSION=0.9.8
PCMANFM=pcmanfm-${PCMANFM_VERSION}.tar.gz
PCMANFM_MIRROR=http://ovh.dl.sourceforge.net/project/pcmanfm/PCManFM%20%2B%20Libfm%20%28tarball%20release%29/PCManFM
PCMANFM_DIR=$BUILD_DIR/pcmanfm-${PCMANFM_VERSION}
PCMANFM_ENV="$CROSS_ENV_AC"

build_pcmanfm() {
    test -e "$STATE_DIR/pcmanfm.installed" && return
    banner "Build pcmanfm"
    download $PCMANFM_MIRROR $PCMANFM
    extract $PCMANFM
    apply_patches $PCMANFM_DIR $PCMANFM
    pushd $TOP_DIR

    if [ "$ENABLE_HAL" = "no" ]; then
	HAL_CONF="--disable-hal"
    else
	HAL_CONF="--enable-hal"
    fi

    cd $PCMANFM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PCMANFM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    $HAL_CONF \
	    --disable-superuser-checks
    ) || error "configure"

    make $MAKEARGS || error

    install_fakeroot_init

    install_fakeroot_finish || error

    update-mime-database $ROOTFS_DIR/usr/share/mime

    #$INSTALL -D -m 644 $GENERICFS_DIR/pcmanfm/main $ROOTFS_DIR/etc/xdg/pcmanfm/main || error
    #$INSTALL -D -m 644 $GENERICFS_DIR/wallpapers/ng-13.02.2009/3.jpg $ROOTFS_DIR/usr/share/pixmaps/wallpapers/3.jpg || error
    #ln -sf 3.jpg $ROOTFS_DIR/usr/share/pixmaps/wallpapers/default.jpg

    $INSTALL -D -m 644 $GENERICFS_DIR/defaults.list $ROOTFS_DIR/usr/share/applications/defaults.list || error

    popd
    touch "$STATE_DIR/pcmanfm.installed"
}

build_pcmanfm
