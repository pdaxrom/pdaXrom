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

DHCPCD=dhcpcd-4.0.7.tar.bz2
DHCPCD_MIRROR=http://roy.marples.name/downloads/dhcpcd
DHCPCD_DIR=$BUILD_DIR/dhcpcd-4.0.7
DHCPCD_ENV="$CROSS_ENV_AC"

build_dhcpcd() {
    test -e "$STATE_DIR/dhcpcd.installed" && return
    banner "Build dhcpcd"
    download $DHCPCD_MIRROR $DHCPCD
    extract $DHCPCD
    apply_patches $DHCPCD_DIR $DHCPCD
    pushd $TOP_DIR
    cd $DHCPCD_DIR
    
    make $MAKEARGS OS="Linux" \
	HAVE_FORK="yes" \
	HAVE_INIT="SYSV" \
	PREFIX="/" \
	LIBEXECDIR="/lib/dhcpcd" \
	CC=${CROSS}gcc || error

    $INSTALL -D -m 755 dhcpcd $ROOTFS_DIR/sbin/dhcpcd || error
    $STRIP $ROOTFS_DIR/sbin/dhcpcd
    $INSTALL -D -m 755 dhcpcd-run-hooks $ROOTFS_DIR/lib/dhcpcd/dhcpcd-run-hooks || error

    for f in 01-test 10-mtu 20-resolv.conf 30-hostname; do
	$INSTALL -D -m 644 dhcpcd-hooks/$f $ROOTFS_DIR/lib/dhcpcd/dhcpcd-hooks/$f || error
    done

    echo "option domain_name_servers, domain_name, domain_search, host_name" > $ROOTFS_DIR/etc/dhcpcd.conf

    $INSTALL -d $ROOTFS_DIR/var/run/dhcpcd || error
    $INSTALL -d $ROOTFS_DIR/var/db || error

    popd
    touch "$STATE_DIR/dhcpcd.installed"
}

build_dhcpcd
