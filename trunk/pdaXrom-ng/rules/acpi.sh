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

ACPI_VERSION=0.09
ACPI=acpi-${ACPI_VERSION}.tar.gz
ACPI_MIRROR=http://grahame.angrygoats.net/source/acpi
ACPI_DIR=$BUILD_DIR/acpi-${ACPI_VERSION}
ACPI_ENV="$CROSS_ENV_AC"

build_acpi() {
    test -e "$STATE_DIR/acpi.installed" && return
    banner "Build acpi"
    download $ACPI_MIRROR $ACPI
    extract $ACPI
    apply_patches $ACPI_DIR $ACPI
    pushd $TOP_DIR
    cd $ACPI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ACPI_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 acpi $ROOTFS_DIR/usr/bin/acpi || error
    $STRIP $ROOTFS_DIR/usr/bin/acpi || error

    popd
    touch "$STATE_DIR/acpi.installed"
}

build_acpi
