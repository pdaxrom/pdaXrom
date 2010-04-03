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

QMC2_VERSION=0.1
QMC2=qmc2-${QMC2_VERSION}.tar.bz2
QMC2_MIRROR=http://downloads.sourceforge.net/qmc2
QMC2_DIR=$BUILD_DIR/qmc2
QMC2_ENV="$CROSS_ENV_AC"

build_qmc2() {
    test -e "$STATE_DIR/qmc2.installed" && return
    banner "Build qmc2"
    download $QMC2_MIRROR $QMC2
    extract $QMC2
    apply_patches $QMC2_DIR $QMC2
    pushd $TOP_DIR
    cd $QMC2_DIR

    make $MAKEARGS DISTCFG=1 DISTCFGFILE=arch/default.cfg || error

    $INSTALL -D -m 755 qmc2 $ROOTFS_DIR/usr/bin/qmc2 || error
    $STRIP $ROOTFS_DIR/usr/bin/qmc2

    popd
    touch "$STATE_DIR/qmc2.installed"
}

build_qmc2
