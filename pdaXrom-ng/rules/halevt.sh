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

HALEVT_VERSION=0.1.4
HALEVT=halevt-${HALEVT_VERSION}.tar.gz
HALEVT_MIRROR=http://savannah.nongnu.org/download/halevt
HALEVT_DIR=$BUILD_DIR/halevt-${HALEVT_VERSION}
HALEVT_ENV="$CROSS_ENV_AC"

build_halevt() {
    test -e "$STATE_DIR/halevt.installed" && return
    banner "Build halevt"
    download $HALEVT_MIRROR $HALEVT
    extract $HALEVT
    apply_patches $HALEVT_DIR $HALEVT
    pushd $TOP_DIR
    cd $HALEVT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$HALEVT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --localstatedir=/var \
	    || error
    ) || error "configure"

    #quick fix - fixme in crosstools!
    ln -sf `${CROSS}gcc -print-file-name=libstdc++.so` ${TARGET_LIB}/libstdc++.so.6 || error

    make $MAKEARGS || error

    make $MAKEARGS DESTDIR=$HALEVT_DIR/fakeroot install || error

    rm -rf fakeroot/usr/share/info
    rm -rf fakeroot/usr/share/locale
    rm -rf fakeroot/usr/share/man

    $STRIP fakeroot/usr/bin/*

    cp -a fakeroot/etc $ROOTFS_DIR/ || error
    cp -a fakeroot/usr $ROOTFS_DIR/ || error
    cp -a fakeroot/var $ROOTFS_DIR/ || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/halevt $ROOTFS_DIR/etc/init.d/halevt || error
    install_rc_start halevt 60
    install_rc_stop halevt 40
    $INSTALL -D -m 644 $GENERICFS_DIR/halevt/halevt.conf $ROOTFS_DIR/etc/halevt/halevt.conf || error

    popd
    touch "$STATE_DIR/halevt.installed"
}

build_halevt
