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

LXDE_LXSESSION_LITE=lxsession-lite-0.3.6.tar.gz
LXDE_LXSESSION_LITE_MIRROR=http://downloads.sourceforge.net/lxde
LXDE_LXSESSION_LITE_DIR=$BUILD_DIR/lxsession-lite-0.3.6
LXDE_LXSESSION_LITE_ENV="$CROSS_ENV_AC"

build_lxde_lxsession_lite() {
    test -e "$STATE_DIR/lxde_lxsession_lite.installed" && return
    banner "Build lxde-lxsession-lite"
    download $LXDE_LXSESSION_LITE_MIRROR $LXDE_LXSESSION_LITE
    extract $LXDE_LXSESSION_LITE
    apply_patches $LXDE_LXSESSION_LITE_DIR $LXDE_LXSESSION_LITE
    pushd $TOP_DIR
    cd $LXDE_LXSESSION_LITE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDE_LXSESSION_LITE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --disable-hal \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 lxsession/lxsession $ROOTFS_DIR/usr/bin/lxsession || error
    $STRIP $ROOTFS_DIR/usr/bin/lxsession
    
    $INSTALL -D -m 755 lxsession-logout/lxsession-logout $ROOTFS_DIR/usr/bin/lxsession-logout || error
    $STRIP $ROOTFS_DIR/usr/bin/lxsession-logout

    $INSTALL -d $ROOTFS_DIR/usr/share/lxsession/images || error
    cp -f images/*.png $ROOTFS_DIR/usr/share/lxsession/images/ || error

    $INSTALL -D -m 644 $GENERICFS_DIR/lxsession/autostart $ROOTFS_DIR/etc/xdg/lxsession/LXDE/autostart || error
    $INSTALL -D -m 644 $GENERICFS_DIR/lxsession/config    $ROOTFS_DIR/etc/xdg/lxsession/LXDE/config    || error
    $INSTALL -D -m 755 $GENERICFS_DIR/lxsession/startlxde $ROOTFS_DIR/usr/bin/startlxde || error
    
    ln -sf ../../../usr/bin/startlxde $ROOTFS_DIR/etc/X11/xinit/xinitrc

    popd
    touch "$STATE_DIR/lxde_lxsession_lite.installed"
}

build_lxde_lxsession_lite
