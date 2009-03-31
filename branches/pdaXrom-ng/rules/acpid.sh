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

ACPID_VERSION=1.0.8
ACPID=acpid-${ACPID_VERSION}.tar.gz
ACPID_MIRROR=http://downloads.sourceforge.net/acpid
ACPID_DIR=$BUILD_DIR/acpid-${ACPID_VERSION}
ACPID_ENV="$CROSS_ENV_AC"

build_acpid() {
    test -e "$STATE_DIR/acpid.installed" && return
    banner "Build acpid"
    download $ACPID_MIRROR $ACPID
    extract $ACPID
    apply_patches $ACPID_DIR $ACPID
    pushd $TOP_DIR
    cd $ACPID_DIR
    
    make $MAKEARGS CC=${CROSS}gcc  || error

    $INSTALL -D -m 750 acpid $ROOTFS_DIR/usr/sbin/acpid || error
    $STRIP $ROOTFS_DIR/usr/sbin/acpid || error

    $INSTALL -D -m 755 acpi_listen $ROOTFS_DIR/usr/bin/acpi_listen || error
    $STRIP $ROOTFS_DIR/usr/bin/acpi_listen || error

    mkdir -p $ROOTFS_DIR/etc/acpi/events
    cp -f samples/battery/battery.conf $ROOTFS_DIR/etc/acpi/events
    cp -f samples/battery/battery.sh $ROOTFS_DIR/etc/acpi
    chmod 755 $ROOTFS_DIR/etc/acpi/battery.sh

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/acpid $ROOTFS_DIR/etc/init.d/acpid
    install_rc_start acpid 10
    install_rc_stop  acpid 90

    popd
    touch "$STATE_DIR/acpid.installed"
}

build_acpid
