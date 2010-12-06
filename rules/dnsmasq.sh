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

DNSMASQ_VERSION=2.52
DNSMASQ=dnsmasq-${DNSMASQ_VERSION}.tar.gz
DNSMASQ_MIRROR=http://www.thekelleys.org.uk/dnsmasq
DNSMASQ_DIR=$BUILD_DIR/dnsmasq-${DNSMASQ_VERSION}
DNSMASQ_ENV="$CROSS_ENV_AC"

build_dnsmasq() {
    test -e "$STATE_DIR/dnsmasq.installed" && return
    banner "Build dnsmasq"
    download $DNSMASQ_MIRROR $DNSMASQ
    extract $DNSMASQ
    apply_patches $DNSMASQ_DIR $DNSMASQ
    pushd $TOP_DIR
    cd $DNSMASQ_DIR

    make $MAKEARGS PREFIX=/usr CC=${CROSS}gcc || error

    #install_sysroot_files || error

    install_fakeroot_init PREFIX=/usr CC=${CROSS}gcc
    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/dnsmasq fakeroot/etc/init.d/dnsmasq
    $INSTALL -D -m 644 dnsmasq.conf.example fakeroot/etc/dnsmasq.conf
    mkdir -p fakeroot/etc/dnsmasq.d
    install_fakeroot_finish || error

    install_rc_start dnsmasq 50
    install_rc_stop  dnsmasq 50

    popd
    touch "$STATE_DIR/dnsmasq.installed"
}

build_dnsmasq
