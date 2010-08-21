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

V86D_VERSION=0.1.9
V86D=v86d-${V86D_VERSION}.tar.bz2
V86D_MIRROR=http://dev.gentoo.org/~spock/projects/uvesafb/archive
V86D_DIR=$BUILD_DIR/v86d-${V86D_VERSION}
V86D_ENV="$CROSS_ENV_AC"

build_v86d() {
    test -e "$STATE_DIR/v86d.installed" && return
    banner "Build v86d"
    download $V86D_MIRROR $V86D
    extract $V86D
    apply_patches $V86D_DIR $V86D
    pushd $TOP_DIR
    cd $V86D_DIR

    ./configure --default

    make clean
    make $MAKEARGS CC=${CROSS}gcc AR=${CROSS}ar || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/v86d.installed"
}

build_v86d
