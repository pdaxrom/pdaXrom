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

PEKWM_VERSION=0.1.12
PEKWM=pekwm-${PEKWM_VERSION}.tar.gz
PEKWM_MIRROR=http://pekwm.org/projects/pekwm/files
PEKWM_DIR=$BUILD_DIR/pekwm-${PEKWM_VERSION}
PEKWM_ENV="$CROSS_ENV_AC"

build_pekwm() {
    test -e "$STATE_DIR/pekwm.installed" && return
    banner "Build pekwm"
    download $PEKWM_MIRROR $PEKWM
    extract $PEKWM
    apply_patches $PEKWM_DIR $PEKWM
    pushd $TOP_DIR
    cd $PEKWM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PEKWM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc/xdg \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_fakeroot_init

    #make -C data DESTDIR=$ROOTFS_DIR install || error
    #$INSTALL -D -m 755 src/pekwm $ROOTFS_DIR/usr/bin/pekwm || error
    #$STRIP $ROOTFS_DIR/usr/bin/pekwm || error

    $INSTALL -m 644 -t fakeroot/etc/xdg/pekwm	\
	${GENERICFS_DIR}/pekwm/config/autoproperties	\
	${GENERICFS_DIR}/pekwm/config/config	\
	${GENERICFS_DIR}/pekwm/config/keys	\
	${GENERICFS_DIR}/pekwm/config/menu	\
	${GENERICFS_DIR}/pekwm/config/mouse	\
	${GENERICFS_DIR}/pekwm/config/start	\
	${GENERICFS_DIR}/pekwm/config/vars || error

    chmod 755 fakeroot/etc/xdg/pekwm/start

    $INSTALL -D -m 755 ${GENERICFS_DIR}/pekwm/scripts/buildmenu.sh fakeroot/usr/share/pekwm/scripts/buildmenu.sh
    echo "/usr/share/pekwm/scripts/buildmenu.sh" > fakeroot/etc/X11/Xsession.d/80_pekwm_update_menu

    $INSTALL -D -m 644 ${GENERICFS_DIR}/pekwm/pekwm-menu.desktop fakeroot/usr/share/applications/pekwm-menu.desktop
    $INSTALL -D -m 644 ${GENERICFS_DIR}/pekwm/apple-red.png fakeroot/usr/share/pixmaps/apple-red.png

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/pekwm.installed"
}

build_pekwm
