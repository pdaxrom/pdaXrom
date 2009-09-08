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

LXDE_LXPANEL_VERSION=0.5.3
LXDE_LXPANEL=lxpanel-${LXDE_LXPANEL_VERSION}.tar.gz
LXDE_LXPANEL_MIRROR=http://downloads.sourceforge.net/lxde
LXDE_LXPANEL_DIR=$BUILD_DIR/lxpanel-${LXDE_LXPANEL_VERSION}
LXDE_LXPANEL_ENV="$CROSS_ENV_AC"

build_lxde_lxpanel() {
    test -e "$STATE_DIR/lxde_lxpanel.installed" && return
    banner "Build lxde-lxpanel"
    download $LXDE_LXPANEL_MIRROR $LXDE_LXPANEL
    extract $LXDE_LXPANEL
    apply_patches $LXDE_LXPANEL_DIR $LXDE_LXPANEL
    pushd $TOP_DIR
    cd $LXDE_LXPANEL_DIR
    (
    ./autogen.sh || error
    eval \
	$CROSS_CONF_ENV \
	$LXDE_LXPANEL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 755 src/lxpanel $ROOTFS_DIR/usr/bin/lxpanel || error
    $STRIP $ROOTFS_DIR/usr/bin/lxpanel

    $INSTALL -D -m 755 src/lxpanelctl $ROOTFS_DIR/usr/bin/lxpanelctl || error
    $STRIP $ROOTFS_DIR/usr/bin/lxpanelctl

    find src/plugins -name "*.so" | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/lib/lxpanel/plugins/${f/*\//} || error "$f"
	$STRIP $ROOTFS_DIR/usr/lib/lxpanel/plugins/${f/*\//}
    done

    make -C data DESTDIR=$ROOTFS_DIR install || error

    $INSTALL -D -m 644 $GENERICFS_DIR/lxpanel/panel $ROOTFS_DIR/usr/share/lxpanel/profile/default/panels/panel || error
    $INSTALL -D -m 644 $GENERICFS_DIR/lxpanel/config $ROOTFS_DIR/usr/share/lxpanel/profile/default/config || error

    popd
    touch "$STATE_DIR/lxde_lxpanel.installed"
}

build_lxde_lxpanel
