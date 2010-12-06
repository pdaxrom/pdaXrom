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

JWM_VERSION=2.0.1
JWM=jwm-${JWM_VERSION}.tar.bz2
JWM_MIRROR=http://downloads.sourceforge.net/project/jwm/jwm/2.0.1
JWM_DIR=$BUILD_DIR/jwm-${JWM_VERSION}
JWM_ENV="$CROSS_ENV_AC"

build_jwm() {
    test -e "$STATE_DIR/jwm.installed" && return
    banner "Build jwm"
    download $JWM_MIRROR $JWM
    extract $JWM
    apply_patches $JWM_DIR $JWM
    pushd $TOP_DIR
    cd $JWM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$JWM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_rootfs_usr_bin src/jwm

    popd
    touch "$STATE_DIR/jwm.installed"
}

build_jwm
