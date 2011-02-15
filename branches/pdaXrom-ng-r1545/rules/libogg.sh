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

LIBOGG_VERSION=1.1.3
LIBOGG=libogg-${LIBOGG_VERSION}.tar.gz
LIBOGG_MIRROR=http://downloads.xiph.org/releases/ogg
LIBOGG_DIR=$BUILD_DIR/libogg-${LIBOGG_VERSION}
LIBOGG_ENV="$CROSS_ENV_AC"

build_libogg() {
    test -e "$STATE_DIR/libogg.installed" && return
    banner "Build libogg"
    download $LIBOGG_MIRROR $LIBOGG
    extract $LIBOGG
    apply_patches $LIBOGG_DIR $LIBOGG
    pushd $TOP_DIR
    cd $LIBOGG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBOGG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    install_rootfs_usr_lib src/.libs/libogg.so.0.5.3

    popd
    touch "$STATE_DIR/libogg.installed"
}

build_libogg
