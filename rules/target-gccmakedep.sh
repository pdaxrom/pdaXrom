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

TARGET_GCCMAKEDEP_VERSION=1.0.2
TARGET_GCCMAKEDEP=gccmakedep-${TARGET_GCCMAKEDEP_VERSION}.tar.bz2
TARGET_GCCMAKEDEP_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/util
TARGET_GCCMAKEDEP_DIR=$BUILD_DIR/gccmakedep-${TARGET_GCCMAKEDEP_VERSION}
TARGET_GCCMAKEDEP_ENV="$CROSS_ENV_AC"

build_target_gccmakedep() {
    test -e "$STATE_DIR/target_gccmakedep.installed" && return
    banner "Build target-gccmakedep"
    download $TARGET_GCCMAKEDEP_MIRROR $TARGET_GCCMAKEDEP
    extract $TARGET_GCCMAKEDEP
    apply_patches $TARGET_GCCMAKEDEP_DIR $TARGET_GCCMAKEDEP
    pushd $TOP_DIR
    cd $TARGET_GCCMAKEDEP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_GCCMAKEDEP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error
    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_gccmakedep.installed"
}

build_target_gccmakedep
