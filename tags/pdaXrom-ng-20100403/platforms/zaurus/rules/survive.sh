#
# packet template
#
# Copyright (C) 2009 by Adrian Crutchfield <insearchof@inventgen-solutions.com>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

SURVIVE_VERSION=1.1.0
SURVIVE=survive-${SURVIVE_VERSION}.tar.bz2
SURVIVE_MIRROR=http://distro.ibiblio.org/pub/linux/distributions/pdaxrom/src/
SURVIVE_DIR=$BUILD_DIR/survive-${SURVIVE_VERSION}
SURVIVE_ENV="$CROSS_ENV_AC"

build_survive() {
    test -e "$STATE_DIR/survive.installed" && return
    banner "Build survive"
    download $SURVIVE_MIRROR $SURVIVE
    extract $SURVIVE
    apply_patches $SURVIVE_DIR $SURVIVE
    pushd $TOP_DIR
    cd $SURVIVE_DIR

    make $MAKEARGS CC=${CROSS}gcc -C $SURVIVE_DIR nandlogical CFLAGS="-I$KERNEL_DIR/arch/arm/include" || error

    $INSTALL -D -m 755 nandlogical $ROOTFS_DIR/bin/ || error

    popd
    touch "$STATE_DIR/survive.installed"
}

build_survive
