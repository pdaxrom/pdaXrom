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

PPP_VERSION=2.4.5
PPP=ppp-${PPP_VERSION}.tar.gz
PPP_MIRROR=ftp://ftp.samba.org/pub/ppp
PPP_DIR=$BUILD_DIR/ppp-${PPP_VERSION}
PPP_ENV="$CROSS_ENV_AC"

build_ppp() {
    test -e "$STATE_DIR/ppp.installed" && return
    banner "Build ppp"
    download $PPP_MIRROR $PPP
    extract $PPP
    apply_patches $PPP_DIR $PPP
    pushd $TOP_DIR
    cd $PPP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PPP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS CC=${CROSS}gcc CXX=${CROSS}g++ || error

    make $MAKEARGS CC=${CROSS}gcc CXX=${CROSS}g++ INSTROOT=$PPP_DIR/fakeroot install || error
    mkdir -p fakeroot/etc/ppp
    make $MAKEARGS CC=${CROSS}gcc CXX=${CROSS}g++ INSTROOT=$PPP_DIR/fakeroot install-etcppp || error
    cp -a $GENERICFS_DIR/etc/ppp fakeroot/etc/
    chmod 755 fakeroot/etc/ppp/ip-* fakeroot/etc/ppp/ppp-*
    chmod 600 fakeroot/etc/ppp/chap-secrets fakeroot/etc/ppp/pap-secrets

    mkdir -p fakeroot/usr/bin
    install -m 755 -t fakeroot/usr/bin scripts/pon scripts/poff scripts/plog

    rm -rf fakeroot/usr/include fakeroot/usr/share

    $STRIP fakeroot/usr/sbin/* fakeroot/usr/lib/pppd/${PPP_VERSION}/*

    cp -a fakeroot/etc $ROOTFS_DIR/
    cp -a fakeroot/usr $ROOTFS_DIR/

    popd
    touch "$STATE_DIR/ppp.installed"
}

build_ppp
